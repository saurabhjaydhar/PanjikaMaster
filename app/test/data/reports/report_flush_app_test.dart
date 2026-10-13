// T-604: queued reports go out when the app opens and when it returns to the
// foreground, without the user doing anything.
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/data/reports/report_queue.dart';
import 'package:panjika/data/reports/report_providers.dart';
import 'package:panjika/data/reports/report_sender.dart';
import 'package:panjika/domain/reports/error_report.dart';

import '../../helpers/fakes.dart';

void main() {
  testWidgets('sent on start and on resume', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await loadSamplePackIfEmpty(db);
    final offline = ReportQueue(
      db,
      const UnconfiguredReportSender(),
      now: DateTime.now,
    );
    const report = ErrorReport(
      date: CivilDate(2026, 10, 12),
      cityId: 'kolkata',
      tradition: 'drik_bishuddha',
      packVersions: {},
      kind: ReportKind.other,
      panjikaSays: 'x',
      appVersion: '1.0.0',
    );
    await offline.enqueue(report);

    final sender = FakeReportSender();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          deviceLocalesProvider.overrideWithValue([const Locale('en')]),
          settingsSourceProvider.overrideWithValue(
            MemorySettings({SettingKey.onboardingDone: '1'}),
          ),
          appLocaleChannelProvider.overrideWithValue(FakeAppLocaleChannel()),
          clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 12, 5)),
          reportSenderProvider.overrideWithValue(sender),
        ],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(sender.sent, hasLength(1));

    await offline.enqueue(report);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(sender.sent, hasLength(2));
    expect(await offline.pending(), 0);
  });
}
