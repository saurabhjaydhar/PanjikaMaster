// T-610: Report an error (FR-SET-03, US-07) — pre-filled date, city, tradition and data
// versions; no personal data; sends, or queues offline and says so. Goldens bn/en ×
// light/dark × 100/200 %. Data: the watermarked sample pack.
// Update goldens intentionally with: flutter test --update-goldens test/features/report
import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/app/widgets/panjika_widgets.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/data/reports/report_providers.dart';
import 'package:panjika/data/reports/report_queue.dart';
import 'package:panjika/data/reports/report_sender.dart';
import 'package:panjika/features/day/day_screen.dart';
import 'package:panjika/features/report/report_screen.dart';
import 'package:panjika/features/today/today_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  late AppDatabase db;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
  });
  tearDown(() => db.close());

  Future<void> open(
    WidgetTester tester, {
    String language = 'bn',
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
    Size size = const Size(360, 1000),
    String route = '/report?date=2026-10-12',
    ReportSender sender = const UnconfiguredReportSender(),
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          deviceLocalesProvider.overrideWithValue([Locale(language)]),
          settingsSourceProvider.overrideWithValue(
            MemorySettings({
              SettingKey.onboardingDone: '1',
              SettingKey.theme: theme.name,
            }),
          ),
          appLocaleChannelProvider.overrideWithValue(FakeAppLocaleChannel()),
          clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 12, 5)),
          reportSenderProvider.overrideWithValue(sender),
        ],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
    unawaited(
      GoRouter.of(tester.element(find.byType(TodayScreen))).push(route),
    );
    await tester.pumpAndSettle();
  }

  Future<void> fill(WidgetTester tester) async {
    await tester.tap(find.text('Tithi time'));
    await tester.enterText(find.byType(TextField).first, 'Ends later');
    await tester.enterText(find.byType(TextField).last, 'Bishuddha');
    await tester.pump();
  }

  testWidgets('pre-filled from Day detail; says what goes with it', (
    tester,
  ) async {
    await open(
      tester,
      language: 'en',
      route: '/day/2026-10-12',
      size: const Size(360, 4000),
    );
    await tester.tap(find.text('Report an error'));
    await tester.pumpAndSettle();
    expect(find.byType(ReportScreen), findsOneWidget);
    expect(find.text('25 Ashwin 1433 (12 October 2026)'), findsOneWidget);
    expect(
      find.text(
        'Sent with it: Kolkata · Bishuddha Siddhanta (Drik) · Panchanga '
        'version 1, Cities version 1, Festivals version 1',
      ),
      findsOneWidget,
    );
    expect(
      find.text("We don't ask for or send your name, phone number or e-mail."),
      findsOneWidget,
    );
    expect(find.byType(SampleWatermark), findsOneWidget);
  });

  testWidgets('sends only the §15.3 fields and says it was sent', (
    tester,
  ) async {
    final sender = FakeReportSender();
    await open(tester, language: 'en', sender: sender);
    final send = find.widgetWithText(FilledButton, 'Send');
    expect(tester.widget<FilledButton>(send).onPressed, isNull);
    await fill(tester);
    await tester.tap(send);
    await tester.pumpAndSettle();

    final json = jsonDecode(sender.sent.single) as Map<String, dynamic>;
    expect(json.keys.toSet(), {
      'date',
      'city_id',
      'tradition',
      'pack_versions',
      'message',
      'app_version',
    });
    expect(
      (json['date'], json['city_id'], json['tradition']),
      ('2026-10-12', 'kolkata', 'drik_bishuddha'),
    );
    expect(
      json['message'],
      'kind: tithi_time\npanjika: Bishuddha\n\nEnds later',
    );
    expect((json['pack_versions'] as Map).length, 3);
    expect(
      find.text("Sent. We'll check it and correct the data if needed."),
      findsOneWidget,
    );
    expect(find.byType(ReportScreen), findsNothing);
  });

  testWidgets('offline: queued, and the user is told', (tester) async {
    await open(tester, language: 'en');
    await fill(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Send'));
    await tester.pumpAndSettle();
    expect(find.text("It will be sent when you're online."), findsOneWidget);
    final queue = ReportQueue(
      db,
      const UnconfiguredReportSender(),
      now: DateTime.now,
    );
    expect(await tester.runAsync(queue.pending), 1);
  });

  testWidgets('opened from the menu, it is about today', (tester) async {
    await open(tester, language: 'en', route: '/report');
    expect(find.text('25 Ashwin 1433 (12 October 2026)'), findsOneWidget);
  });

  testWidgets('the date can be changed', (tester) async {
    await open(tester, language: 'en');
    await tester.tap(find.text('Change date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('13'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('26 Ashwin 1433 (13 October 2026)'), findsOneWidget);
    expect(find.byType(DayScreen), findsNothing);
  });

  for (final language in ['bn', 'en']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in [1.0, 2.0]) {
        final id = 'report_${language}_${theme.name}_${(scale * 100).round()}';
        testWidgets('golden $id', (tester) async {
          await open(
            tester,
            language: language,
            theme: theme,
            textScale: scale,
            size: Size(360, scale > 1.5 ? 2000 : 1000),
          );
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byType(PanjikaApp),
            matchesGoldenFile('goldens/$id.png'),
          );
        });
      }
    }
  }
}
