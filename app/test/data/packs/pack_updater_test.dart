// T-311: manifest check → download → verify → import, against a fake pack server
// serving the pack builder's signed SAMPLE packs (test-only key).
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/packs/manifest_client.dart';
import 'package:panjika/data/packs/pack_importer.dart';
import 'package:panjika/data/packs/pack_updater.dart';
import 'package:panjika/data/repositories/panjika_repository.dart';

const dir = 'test/fixtures/packs';
final base = Uri.parse('https://packs.example.test');

void main() {
  late AppDatabase db;
  late Directory tmp;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    tmp = Directory.systemTemp.createTempSync('upd');
  });
  tearDown(() async {
    await db.close();
    tmp.deleteSync(recursive: true);
  });

  /// Serves the fixtures; [broken] paths answer 500, [tamper] paths get a flipped byte.
  http.Client server({
    Set<String> broken = const {},
    Set<String> tamper = const {},
  }) => MockClient.streaming((req, _) async {
    final path = req.url.path;
    if (broken.contains(path)) {
      return http.StreamedResponse(const Stream.empty(), 500);
    }
    final file = path == '/v1/manifest.json'
        ? File('$dir/manifest.json')
        : File('$dir/packs/${path.split('/').last}');
    List<int> bytes = file.readAsBytesSync();
    if (tamper.contains(path)) bytes = [...bytes]..[bytes.length ~/ 2] ^= 1;
    return http.StreamedResponse(Stream.value(bytes), 200);
  });

  PackUpdater updater(
    http.Client client, {
    int silentLimit = silentDownloadLimit,
  }) {
    final repo = DriftPanjikaRepository(db);
    return PackUpdater(
      manifests: ManifestClient(
        client: client,
        baseUrl: base,
        settings: MemorySettings(),
        now: () => DateTime.utc(2026, 10, 13, 6),
        appVersion: '1.0.0',
        silentLimit: silentLimit,
      ),
      downloader: PackDownloader(client, base, dir: tmp),
      importer: PackImporter(
        db,
        publicKey: base64Decode(
          File('$dir/test_public_key.txt').readAsStringSync().trim(),
        ),
        allowSample: true,
      ),
      repository: repo,
    );
  }

  Future<UpdateResult> run(PackUpdater u, {bool confirmed = false}) => u.run(
    tradition: 'drik_bishuddha',
    cityId: 'kolkata',
    confirmed: confirmed,
    force: true,
  );

  test('small packs download and import without asking', () async {
    final r = await run(updater(server())) as UpdateDone;
    // Only the global and observances packs: the city pack is offered once a city
    // pack is installed (the user's city decides which one).
    expect(
      r.imported,
      containsAll(['sample-global-drik', 'sample-observances-drik']),
    );
    expect(r.waitingForUser, isEmpty);
    final packs = await db.customSelect('SELECT id FROM packs').get();
    expect(packs, hasLength(r.imported.length));
  });

  test('large packs wait for the user, then download when confirmed', () async {
    final u = updater(
      server(),
      silentLimit: 20 * 1024,
    ); // global (~31 KB) is "large"
    final first = await run(u) as UpdateDone;
    expect(first.waitingForUser.map((o) => o.entry.id), ['sample-global-drik']);
    expect(first.imported, isNot(contains('sample-global-drik')));
    final second = await run(u, confirmed: true) as UpdateDone;
    expect(second.imported, contains('sample-global-drik'));
  });

  test(
    'a server error or a tampered pack fails the run, nothing half-imported',
    () async {
      const url = '/v1/packs/sample-global-drik.sqlite.gz';
      expect(await run(updater(server(broken: {url}))), isA<UpdateFailed>());
      expect(await run(updater(server(tamper: {url}))), isA<UpdateFailed>());
      final globals = await db
          .customSelect("SELECT id FROM packs WHERE kind = 'global'")
          .get();
      expect(globals, isEmpty);
    },
  );

  test('offline: the check fails quietly', () async {
    final r = await run(updater(server(broken: {'/v1/manifest.json'})));
    expect(r, isA<UpdateFailed>());
  });

  test('without a URL and key, updates are off', () {
    expect(const PackSourceConfig().enabled, isFalse);
    expect(
      PackSourceConfig(baseUrl: base, publicKey: List.filled(32, 1)).enabled,
      isTrue,
    );
    expect(
      PackSourceConfig.fromEnvironment().enabled,
      isFalse,
      reason: 'no defines in tests',
    );
  });
}
