// T-604: the error-report queue works offline and sends when it can (US-07). Reports
// carry only the §15.3 fields. The sender's outcomes decide what stays queued.
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/reports/report_queue.dart';
import 'package:panjika/data/reports/report_sender.dart';
import 'package:panjika/domain/reports/error_report.dart';

import '../../helpers/fakes.dart';

ErrorReport report(String text, {String? panjika}) => ErrorReport(
  date: const CivilDate(2026, 10, 12),
  cityId: 'kolkata',
  tradition: 'drik_bishuddha',
  packVersions: const {'global-drik': 1, 'cities': 2},
  kind: ReportKind.tithiTime,
  panjikaSays: text,
  panjikaName: panjika,
  appVersion: '1.0.0',
);

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  ReportQueue queue(ReportSender sender) =>
      ReportQueue(db, sender, now: () => DateTime.utc(2026, 10, 12, 5));

  test('a report has only the §15.3 fields, nothing personal', () {
    final json = report('  ends later  ', panjika: 'Bishuddha').toJson();
    expect(json.keys.toSet(), {
      'date',
      'city_id',
      'tradition',
      'pack_versions',
      'message',
      'app_version',
    });
    expect(json['date'], '2026-10-12');
    expect(
      json['message'],
      'kind: tithi_time\npanjika: Bishuddha\n\nends later',
    );
    expect(
      report('x', panjika: ' ').message,
      'kind: tithi_time\n\nx',
      reason: 'a blank panjika name is left out',
    );
  });

  test(
    'offline: reports stay queued, in order, until they can be sent',
    () async {
      final offline = queue(const UnconfiguredReportSender());
      await offline.enqueue(report('one'));
      await offline.enqueue(report('two'));
      expect(await offline.flush(), 0);
      expect(await offline.pending(), 2);

      final sender = FakeReportSender([
        SendOutcome.sent,
        SendOutcome.retryLater,
      ]);
      final q = queue(sender);
      expect(await q.flush(), 1);
      expect(await q.pending(), 1, reason: 'stops at the first that must wait');
      expect(await q.flush(), 1);
      expect(await q.pending(), 0);
      expect(sender.sent.map((p) => (jsonDecode(p) as Map)['message']), [
        'kind: tithi_time\n\none',
        'kind: tithi_time\n\ntwo',
        'kind: tithi_time\n\ntwo',
      ]);
    },
  );

  test('a report the server refuses for good is dropped', () async {
    final q = queue(FakeReportSender([SendOutcome.rejected]));
    await q.enqueue(report('bad'));
    await q.enqueue(report('good'));
    expect(await q.flush(), 1);
    expect(await q.pending(), 0);
  });

  test('concurrent flushes share one run', () async {
    final sender = FakeReportSender([]);
    final q = queue(sender);
    await q.enqueue(report('once'));
    await Future.wait([q.flush(), q.flush()]);
    expect(sender.sent, hasLength(1));
  });

  test('the queue keeps at most the newest ${ReportQueue.maxQueued}', () async {
    final q = queue(const UnconfiguredReportSender());
    for (var i = 0; i < ReportQueue.maxQueued + 3; i++) {
      await q.enqueue(report('r$i'));
    }
    expect(await q.pending(), ReportQueue.maxQueued);
    final sender = FakeReportSender([]);
    await queue(sender).flush();
    expect((jsonDecode(sender.sent.first) as Map)['message'], endsWith('r3'));
  });

  group('HTTP sender', () {
    final endpoint = Uri.parse('https://example.invalid/v1/reports');

    Future<SendOutcome> answer(http.Response Function() respond) =>
        HttpReportSender(
          MockClient((_) async => respond()),
          endpoint,
        ).send('{}');

    test('posts the JSON as is', () async {
      late http.Request seen;
      final outcome = await HttpReportSender(
        MockClient((r) async {
          seen = r;
          return http.Response('', 201);
        }),
        endpoint,
      ).send(jsonEncode(report('x').toJson()));
      expect(outcome, SendOutcome.sent);
      expect(seen.method, 'POST');
      expect(seen.url, endpoint);
      expect(seen.headers['content-type'], startsWith('application/json'));
      expect((jsonDecode(seen.body) as Map)['city_id'], 'kolkata');
    });

    test('busy or offline waits; a bad request is dropped', () async {
      expect(
        await answer(() => http.Response('', 503)),
        SendOutcome.retryLater,
      );
      expect(
        await answer(() => http.Response('', 429)),
        SendOutcome.retryLater,
      );
      expect(
        await answer(() => http.Response('', 408)),
        SendOutcome.retryLater,
      );
      expect(await answer(() => http.Response('', 400)), SendOutcome.rejected);
      expect(
        await answer(() => throw const SocketException('offline')),
        SendOutcome.retryLater,
      );
    });
  });
}
