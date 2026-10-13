// T-303 / T-306: the app imports packs produced by the pipeline's pack builder.
// Fixtures: SAMPLE packs signed with a test-only key (scripts/gen_test_packs.py).
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/packs/manifest.dart';
import 'package:panjika/data/packs/pack_importer.dart';
import 'package:panjika/data/repositories/panjika_repository.dart';
import 'package:panjika/domain/usecases/get_day_panjika.dart';

const dir = 'test/fixtures/packs';
const drik = 'drik_bishuddha';

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

  group('T-603 correction', () {
    late PackImporter fixer;
    var at = DateTime.utc(2026, 10, 12, 5);
    setUp(() {
      at = DateTime.utc(2026, 10, 12, 5);
      fixer = PackImporter(
        db,
        publicKey: testKey(),
        allowSample: true,
        now: () => at,
      );
    });

    Future<List<(String, String)>> datesOf(String id) async => [
      for (final r
          in await db
              .customSelect(
                'SELECT date, pack_id FROM observance_dates '
                'WHERE observance_id = ? ORDER BY date',
                variables: [Variable(id)],
              )
              .get())
        (r.read<String>('date'), r.read<String>('pack_id')),
    ];

    test('replaces only the changed rows and flags them for 7 days', () async {
      await importAll(manifest());
      final kaliBefore = await datesOf('kali_puja');
      final lakshmiBefore = await datesOf('lakshmi_puja');
      final windows = await count('observance_windows');
      final rowids = await db
          .customSelect(
            "SELECT rowid FROM observance_dates WHERE observance_id = 'lakshmi_puja'",
          )
          .map((r) => r.read<int>('rowid'))
          .get();

      final fix = manifest('manifest_correction.json').packs.single;
      final (gz, sig) = files(fix);
      await fixer.import(fix, gz, sig);

      const v2 = 'sample-observances-drik-v2';
      final kali = await datesOf('kali_puja');
      expect(kali.single.$1, isNot(kaliBefore.single.$1));
      expect(kali.single.$2, v2);
      // Unchanged rows stay where they are, only retagged with the new pack.
      expect((await datesOf('lakshmi_puja')).single, (
        lakshmiBefore.single.$1,
        v2,
      ));
      expect(
        await db
            .customSelect(
              "SELECT rowid FROM observance_dates WHERE observance_id = 'lakshmi_puja'",
            )
            .map((r) => r.read<int>('rowid'))
            .get(),
        rowids,
      );
      expect(await count('observance_windows'), windows);
      final stale = await db
          .customSelect(
            'SELECT count(*) AS n FROM observances WHERE pack_id != ?',
            variables: [const Variable(v2)],
          )
          .getSingle();
      expect(stale.read<int>('n'), 0);
      final packs = await db
          .customSelect(
            "SELECT id, version FROM packs WHERE kind = 'observances'",
          )
          .get();
      expect(packs.map((r) => (r.read<String>('id'), r.read<int>('version'))), [
        (v2, 2),
      ]);

      final repo = DriftPanjikaRepository(db);
      expect(await repo.correctedObservances(drik, at), {'kali_puja'});
      expect(
        await repo.correctedObservances(drik, at.add(const Duration(days: 6))),
        {'kali_puja'},
      );
      expect(
        await repo.correctedObservances(drik, at.add(const Duration(days: 8))),
        isEmpty,
        reason: 'the label lasts 7 days',
      );
      expect(await repo.correctedObservances('surya_siddhanta', at), isEmpty);
    });

    test('a first install flags nothing; re-import keeps the flags', () async {
      final fix = manifest('manifest_correction.json').packs.single;
      final (gz, sig) = files(fix);
      await fixer.import(fix, gz, sig);
      final repo = DriftPanjikaRepository(db);
      expect(await repo.correctedObservances(drik, at), isEmpty);
    });

    test('old flags are pruned on the next import', () async {
      await db
          .into(db.observanceCorrections)
          .insert(
            ObservanceCorrectionsCompanion.insert(
              tradition: drik,
              observanceId: 'old',
              correctedAt: '2026-01-01T00:00:00.000Z',
            ),
          );
      await importAll(manifest());
      final fix = manifest('manifest_correction.json').packs.single;
      final (gz, sig) = files(fix);
      await fixer.import(fix, gz, sig);
      final ids = (await db.select(db.observanceCorrections).get()).map(
        (r) => r.observanceId,
      );
      expect(ids, ['kali_puja']);
    });
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
