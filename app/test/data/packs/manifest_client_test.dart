// T-308: manifest client and resumable downloads, against a fake server.
// Manifest contents are test inputs (shape per spec §15.3, not real packs).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/data/packs/manifest_client.dart';
import 'package:panjika/domain/usecases/assess_coverage.dart';

final base = Uri.parse('https://packs.example.test');
final now = DateTime.utc(2026, 10, 13, 6);

Map<String, Object?> entry(
  String id,
  String kind,
  int version, {
  int size = 1000,
  String to = '2029-04-13',
}) => {
  'id': id,
  'kind': kind,
  'tradition': 'drik_bishuddha',
  'version': version,
  'covers': ['2026-04-14', to],
  'url': '/v1/packs/$id-v$version.sqlite.gz',
  'size': size,
  'sha256': '0' * 64,
  'sig_url': '/v1/packs/$id-v$version.sqlite.gz.sig',
};

String manifestJson({
  String minApp = '1.0.0',
  int schema = 1,
  List<Map<String, Object?>>? packs,
  List<Map<String, Object?>> notices = const [],
}) => jsonEncode({
  'schema': schema,
  'generated_at': '2026-10-12T00:00:00Z',
  'min_app_version': minApp,
  'packs': packs ?? [entry('global-drik', 'global', 2)],
  'notices': notices,
});

/// A UTF-8 JSON response, as the real server sends (Bengali notice text included).
http.Response ok(String body) => http.Response.bytes(
  utf8.encode(body),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

PackRange installed(String id, String kind, int version) => PackRange(
  id: id,
  kind: kind,
  tradition: 'drik_bishuddha',
  version: version,
  from: const CivilDate(2026, 4, 14),
  to: const CivilDate(2029, 4, 13),
);

void main() {
  late MemorySettings settings;
  var requests = 0;

  setUp(() {
    settings = MemorySettings();
    requests = 0;
  });

  ManifestClient client(Future<http.Response> Function(http.Request) handler) =>
      ManifestClient(
        client: MockClient((req) {
          requests++;
          return handler(req);
        }),
        baseUrl: base,
        settings: settings,
        now: () => now,
        appVersion: '1.0.0',
      );

  Future<ManifestCheck> check(ManifestClient c, {bool force = false}) =>
      c.check(
        installed: [
          installed('global-drik', 'global', 1),
          installed('cities-wb', 'cities', 1),
        ],
        tradition: 'drik_bishuddha',
        cityPackId: 'cities-wb',
        force: force,
      );

  test('fetches, caches, and then waits a day', () async {
    final c = client((req) async {
      expect(req.url.path, '/v1/manifest.json');
      return ok(manifestJson());
    });
    expect(await check(c), isA<ManifestChecked>());
    expect(c.cached()?.packs.single.version, 2);
    expect(await check(c), isA<CheckSkipped>());
    expect(requests, 1);
    expect(await check(c, force: true), isA<ManifestChecked>());
    expect(requests, 2);
  });

  test('a day later it checks again', () async {
    await settings.write(
      SettingKey.lastManifestCheck,
      now.subtract(const Duration(hours: 25)).toIso8601String(),
    );
    final c = client((_) async => ok(manifestJson()));
    expect(await check(c), isA<ManifestChecked>());
  });

  test('offline or server error: failed, and retried next time', () async {
    final offline = client((_) async => throw const SocketException('offline'));
    expect(await check(offline), isA<CheckFailed>());
    expect(settings.read(SettingKey.lastManifestCheck), isNull);
    final broken = client((_) async => http.Response('oops', 503));
    expect(await check(broken), isA<CheckFailed>());
    final garbage = client((_) async => http.Response('{not json', 200));
    expect(await check(garbage), isA<CheckFailed>());
    final future = client((_) async => ok(manifestJson(schema: 2)));
    expect(await check(future), isA<CheckFailed>());
  });

  test('min_app_version above this app: update required', () async {
    final c = client((_) async => ok(manifestJson(minApp: '1.2.0')));
    final r = await check(c);
    expect(r, isA<AppTooOld>());
    expect((r as AppTooOld).minAppVersion, '1.2.0');
    expect(compareVersions('1.10.0', '1.9.2'), 1);
    expect(compareVersions('1.0.0+5', '1.0.0'), 0);
  });

  test(
    'offers: small update silently, large new pack asks, others ignored',
    () async {
      final c = client(
        (_) async => ok(
          manifestJson(
            packs: [
              entry(
                'global-drik',
                'global',
                2,
                size: 900 * 1024,
              ), // update, small
              entry(
                'global-drik-2029',
                'global',
                1,
                size: 3 * 1024 * 1024,
              ), // new, large
              entry('cities-wb', 'cities', 1), // same version: nothing to do
              entry('cities-metros', 'cities', 1), // not the user's city pack
              entry(
                'global-drik-2020',
                'global',
                1,
                to: '2023-04-13',
              ), // in the past
            ],
          ),
        ),
      );
      final r = await check(c) as ManifestChecked;
      expect(r.offers.map((o) => (o.entry.id, o.action, o.isUpdate)), [
        ('global-drik', OfferAction.downloadSilently, true),
        ('global-drik-2029', OfferAction.ask, false),
      ]);
    },
  );

  test('notices come in both languages; expired ones are dropped', () async {
    final c = client(
      (_) async => ok(
        manifestJson(
          notices: [
            {
              'id': 'n1',
              'level': 'info',
              'text_bn': 'বাংলা',
              'text_en': 'English',
              'until': '2026-10-31',
            },
            {
              'id': 'n0',
              'level': 'info',
              'text_bn': 'পুরনো',
              'text_en': 'Old',
              'until': '2026-09-30',
            },
          ],
        ),
      ),
    );
    final r = await check(c) as ManifestChecked;
    expect(r.notices.map((n) => (n.id, n.text.bn, n.text.en)), [
      ('n1', 'বাংলা', 'English'),
    ]);
  });

  group('PackDownloader', () {
    late Directory dir;
    final payload = List.generate(5000, (i) => i % 251);
    setUp(() => dir = Directory.systemTemp.createTempSync('dl'));
    tearDown(() => dir.deleteSync(recursive: true));

    http.Client server({required bool honoursRange, List<String>? ranges}) =>
        MockClient.streaming((req, _) async {
          final range = req.headers['range'];
          ranges?.add(range ?? '');
          if (range != null && honoursRange) {
            final from = int.parse(range.substring(6, range.length - 1));
            return http.StreamedResponse(
              Stream.value(payload.sublist(from)),
              206,
            );
          }
          return http.StreamedResponse(Stream.value(payload), 200);
        });

    test('downloads a whole file', () async {
      final d = PackDownloader(server(honoursRange: true), base, dir: dir);
      expect(await d.fetch('/v1/packs/a.gz', expectedSize: 5000), payload);
      expect(dir.listSync(), isEmpty, reason: 'no partial file left');
    });

    test('resumes from a partial file with a Range request', () async {
      File('${dir.path}/_v1_packs_a.gz.part')
          .writeAsBytesSync(payload.sublist(0, 1200));
      final ranges = <String>[];
      final d = PackDownloader(
        server(honoursRange: true, ranges: ranges),
        base,
        dir: dir,
      );
      expect(await d.fetch('/v1/packs/a.gz', expectedSize: 5000), payload);
      expect(ranges, ['bytes=1200-']);
    });

    test('starts again if the server ignores the range', () async {
      File('${dir.path}/_v1_packs_a.gz.part')
          .writeAsBytesSync(payload.sublist(0, 1200));
      final d = PackDownloader(server(honoursRange: false), base, dir: dir);
      expect(await d.fetch('/v1/packs/a.gz', expectedSize: 5000), payload);
    });

    test('an interrupted download keeps its partial file', () async {
      final d = PackDownloader(
        MockClient.streaming((req, _) async {
          final controller = StreamController<List<int>>();
          controller
            ..add(payload.sublist(0, 700))
            ..addError(const SocketException('dropped'));
          unawaited(controller.close());
          return http.StreamedResponse(controller.stream, 200);
        }),
        base,
        dir: dir,
      );
      await expectLater(
        d.fetch('/v1/packs/a.gz', expectedSize: 5000),
        throwsA(isA<DownloadFailed>()),
      );
      expect(File('${dir.path}/_v1_packs_a.gz.part').lengthSync(), 700);
    });

    test('wrong size and HTTP errors fail', () async {
      final d = PackDownloader(server(honoursRange: true), base, dir: dir);
      await expectLater(
        d.fetch('/v1/packs/a.gz', expectedSize: 4000),
        throwsA(isA<DownloadFailed>()),
      );
      final missing = PackDownloader(
        MockClient.streaming(
          (_, _) async => http.StreamedResponse(const Stream.empty(), 404),
        ),
        base,
        dir: dir,
      );
      await expectLater(
        missing.fetch('/v1/packs/b.gz'),
        throwsA(isA<DownloadFailed>()),
      );
    });
  });
}
