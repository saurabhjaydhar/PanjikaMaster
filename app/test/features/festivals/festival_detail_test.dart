// T-511: Festival detail — category band with the name in both scripts, the date in
// both calendars, tithi and windows (Sandhi Puja with its explanation, nishita), the
// description, the verification card (unverified note for tier 2/3), the reminder
// toggle, and the day selector for multi-day festivals.
// Goldens bn/en × light/dark × 100/200 %. Data: the watermarked sample pack; the
// multi-day test adds a sample-status span to the test database.
// Update goldens intentionally with: flutter test --update-goldens test/features/festivals
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
import 'package:panjika/data/notifications/notification_scheduler.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/features/festivals/festival_detail_screen.dart';
import 'package:panjika/features/today/today_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  late AppDatabase db;
  late MemorySettings settings;
  late FakeNotificationScheduler scheduler;
  setUp(() async {
    scheduler = FakeNotificationScheduler();
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
  });
  tearDown(() => db.close());

  Future<void> open(
    WidgetTester tester,
    String location, {
    String language = 'bn',
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
    Size size = const Size(360, 1600),
  }) async {
    settings = MemorySettings({
      SettingKey.onboardingDone: '1',
      SettingKey.theme: theme.name,
    });
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
          settingsSourceProvider.overrideWithValue(settings),
          appLocaleChannelProvider.overrideWithValue(FakeAppLocaleChannel()),
          clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 12, 5)),
          notificationSchedulerProvider.overrideWithValue(scheduler),
        ],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(TodayScreen))).go(location);
    await tester.pumpAndSettle();
  }

  testWidgets('Maha Ashtami: both scripts, both dates, tithi and Sandhi Puja', (
    tester,
  ) async {
    await open(tester, '/festival/maha_ashtami');
    expect(find.byType(FestivalDetailScreen), findsOneWidget);
    expect(find.text('মহাষ্টমী'), findsOneWidget);
    expect(find.text('Maha Ashtami'), findsOneWidget, reason: 'always both');
    expect(find.text('বুধবার · ২৭ আশ্বিন ১৪৩৩'), findsOneWidget);
    expect(find.text('তিথি'), findsOneWidget);
    expect(find.text('সন্ধিপূজা'), findsOneWidget);
    expect(
      find.text('অষ্টমীর শেষ ২৪ মিনিট ও নবমীর প্রথম ২৪ মিনিট'),
      findsOneWidget,
    );
    expect(find.textContaining('নমুনা বিবরণ'), findsOneWidget);
    expect(find.byType(SampleWatermark), findsOneWidget);
    expect(find.byType(ProvenanceFooter), findsOneWidget);
  });

  testWidgets('Kali Puja shows its nishita window', (tester) async {
    await open(tester, '/festival/kali_puja', language: 'en');
    expect(find.text('Nishita (midnight)'), findsOneWidget);
  });

  testWidgets('a tier-2 date that is not checked says so', (tester) async {
    await open(tester, '/festival/bhai_phonta');
    expect(
      find.text('এই তারিখ এখনও পঞ্জিকা মিলিয়ে দেখা হয়নি।'),
      findsOneWidget,
    );
  });

  testWidgets('the reminder toggle is remembered', (tester) async {
    await open(tester, '/festival/kali_puja', language: 'en');
    await tester.tap(find.text('Remind me'));
    await tester.pumpAndSettle();
    expect(find.text('Reminder on'), findsOneWidget);
    expect(settings.read(SettingKey.reminders), contains('kali_puja'));
    expect(scheduler.plans, isNotEmpty, reason: 'a change reschedules');
    await tester.tap(find.text('Reminder on'));
    await tester.pumpAndSettle();
    expect(settings.read(SettingKey.reminders), isNull);
  });

  testWidgets('a multi-day festival has a day selector', (tester) async {
    await db.customStatement(
      "INSERT INTO observances VALUES ('durga_puja', 'দুর্গাপূজা', 'Durga Puja',"
      " 'puja', 1, 'নমুনা বিবরণ। (নমুনা বিবরণ)', 'Sample. (Sample)',"
      " 'sample-observances-drik')",
    );
    for (var i = 0; i < 5; i++) {
      await db.customStatement(
        'INSERT INTO observance_dates (observance_id, tradition, date, day_index,'
        " status, pack_id) VALUES ('durga_puja', 'drik_bishuddha',"
        " '2026-10-${12 + i}', $i, 'sample', 'sample-observances-drik')",
      );
    }
    await open(tester, '/festival/durga_puja?date=2026-10-14', language: 'en');
    final chips = find.byType(ChoiceChip);
    expect(chips, findsNWidgets(5));
    expect(tester.widget<ChoiceChip>(chips.at(2)).selected, isTrue);
    expect(find.text('Wednesday · 27 Ashwin 1433'), findsOneWidget);
    await tester.tap(chips.first);
    await tester.pumpAndSettle();
    expect(find.text('Monday · 25 Ashwin 1433'), findsOneWidget);
  });

  testWidgets('a festival not in the data says so', (tester) async {
    await open(tester, '/festival/no_such_festival');
    expect(find.text('এই উৎসবের তথ্য এই ফোনে নেই।'), findsOneWidget);
  });

  for (final language in ['bn', 'en']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in [1.0, 2.0]) {
        final id =
            'festival_detail_${language}_${theme.name}_${(scale * 100).round()}';
        testWidgets('golden $id', (tester) async {
          await open(
            tester,
            '/festival/maha_ashtami',
            language: language,
            theme: theme,
            textScale: scale,
            size: Size(360, scale > 1.5 ? 2400 : 1300),
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
