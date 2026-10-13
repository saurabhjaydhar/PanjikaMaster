// T-303 / T-306: the app imports packs produced by the pipeline's pack builder.
// Fixtures: SAMPLE packs signed with a test-only key (scripts/gen_test_packs.py).
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/packs/manifest.dart';
import 'package:panjika/data/packs/pack_importer.dart';
import 'package:panjika/data/repositories/panjika_repository.dart';
import 'package:panjika/domain/usecases/get_day_panjika.dart';

const dir = 'test/fixtures/packs';

Manifest manifest([String name = 'manifest.json']) => Manifest.fromJson(
  jsonDecode(File('$dir/$name').readAsStringSync()) as Map<String, Object?>,
);

List<int> testKey() =>
    base64Decode(File('$dir/test_public_key.txt').readAsStringSync().trim());

(List<int>, List<int>) files(ManifestEntry e) {
  final name = e.url.split('/').last;
  return (
    File('$dir/packs/$name').readAsBytesSync(),
    File('$dir/packs/$name.sig').readAsBytesSync(),
  );
}

void main() {
  late AppDatabase db;
  late PackImporter importer;
  final imported = <String>[];

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    imported.clear();
    importer = PackImporter(
      db,
      publicKey: testKey(),
      allowSample: true,
      onImported: (e) async => imported.add(e.id),
    );
  });
  tearDown(() => db.close());

  Future<void> importAll(Manifest m) async {
    for (final e in m.packs) {
      final (gz, sig) = files(e);
      await importer.import(e, gz, sig);
    }
  }

  Future<int> count(String table) async =>
      (await db.customSelect('SELECT count(*) AS n FROM $table').getSingle())
          .read<int>('n');

  test('the manifest parses', () {
    final m = manifest();
    expect(m.schema, Manifest.supportedSchema);
    expect(
      m.packs.map((p) => p.kind),
      containsAll(['global', 'cities', 'observances']),
    );
    expect(m.packs.first.sha256, hasLength(64));
  });

  test('imports the builder\'s packs; the day assembles from them', () async {
    await importAll(manifest());
    expect(imported, hasLength(3));
    final repo = DriftPanjikaRepository(db);
    final day = await GetDayPanjika(repo, repo)(
      date: const CivilDate(2026, 10, 12),
      tradition: 'drik_bishuddha',
      cityId: 'kolkata',
    );
    expect(day, isNotNull);
    expect(
      day!.provenance.isSample,
      isTrue,
      reason: 'sample fixtures keep the watermark',
    );
    final installed = await db
        .customSelect('SELECT installed_at, sha256 FROM packs')
        .get();
    expect(
      installed.every((r) => r.read<String?>('installed_at') != null),
      isTrue,
    );
    expect(
      installed.every((r) => r.read<String?>('sha256')?.length == 64),
      isTrue,
    );
  });

  test('a bad signature is rejected and nothing changes', () async {
    final e = manifest().packs.first;
    final (gz, sig) = files(e);
    final bad = [...sig]..[0] ^= 0xff;
    await expectLater(
      importer.import(e, gz, bad),
      throwsA(isA<PackBadSignature>()),
    );
    expect(await count('packs'), 0);
    expect(imported, isEmpty);
  });

  test('another key is rejected', () async {
    final other = PackImporter(
      db,
      publicKey: List.filled(32, 7),
      allowSample: true,
    );
    final e = manifest().packs.first;
    final (gz, sig) = files(e);
    await expectLater(
      other.import(e, gz, sig),
      throwsA(isA<PackBadSignature>()),
    );
  });

  test('a partial or altered file is rejected before anything else', () async {
    final e = manifest().packs.first;
    final (gz, sig) = files(e);
    await expectLater(
      importer.import(e, gz.sublist(0, gz.length ~/ 2), sig),
      throwsA(isA<PackCorrupt>()),
    );
    final altered = [...gz]..[gz.length ~/ 2] ^= 0x01;
    await expectLater(
      importer.import(e, altered, sig),
      throwsA(isA<PackCorrupt>()),
    );
    expect(await count('packs'), 0);
  });

  test('a build that must not import samples refuses them', () async {
    final strict = PackImporter(db, publicKey: testKey());
    final e = manifest().packs.first;
    final (gz, sig) = files(e);
    await expectLater(strict.import(e, gz, sig), throwsA(isA<PackInvalid>()));
    expect(await count('packs'), 0);
  });

  test('v1 → v2 upgrade replaces the old pack\'s rows', () async {
    await importAll(manifest());
    final before = await count('transitions');
    final v2 = manifest('manifest_v2.json').packs.single;
    final (gz, sig) = files(v2);
    await importer.import(v2, gz, sig);
    final globals = await db
        .customSelect("SELECT id, version FROM packs WHERE kind = 'global'")
        .get();
    expect(globals.map((r) => (r.read<String>('id'), r.read<int>('version'))), [
      ('sample-global-drik-v2', 2),
    ]);
    expect(await count('transitions'), before);
    final stale = await db
        .customSelect(
          "SELECT count(*) AS n FROM transitions WHERE pack_id != 'sample-global-drik-v2'",
        )
        .getSingle();
    expect(stale.read<int>('n'), 0);
    expect(await count('packs'), 3, reason: 'cities and observances untouched');
  });

  test('re-importing the same pack is harmless', () async {
    await importAll(manifest());
    final n = await count('names');
    await importAll(manifest());
    expect(await count('names'), n);
    expect(await count('packs'), 3);
  });

  test('the table order matches the schema (parents first)', () {
    final drift = File('lib/data/db/pack_tables.drift').readAsStringSync();
    final tables = RegExp(r'CREATE TABLE (\w+)')
        .allMatches(drift)
        .map((m) => m[1])
        .toList();
    expect(packTablesInOrder, tables);
  });
}
