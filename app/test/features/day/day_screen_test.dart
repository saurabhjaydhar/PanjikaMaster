// T-404: Day detail — §11.4 section order, kshaya/vriddhi lines, "(next day)", detailed
// provenance footer, swipe and arrows between days; goldens bn/en × light/dark ×
// 100/200 %. Data: the watermarked sample pack.
// Update goldens intentionally with: flutter test --update-goldens test/features/day
import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/app/router.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/features/day/day_screen.dart';
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
    WidgetTester tester,
    String date, {
    String language = 'bn',
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
    Size size = const Size(360, 1800),
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      const SizedBox(),
    ); // a fresh app (and router) each time
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          deviceLocalesProvider.overrideWithValue([Locale(language)]),
          settingsSourceProvider.overrideWithValue(
            MemorySettings({SettingKey.theme: theme.name}),
          ),
          appLocaleChannelProvider.overrideWithValue(FakeAppLocaleChannel()),
          clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 12, 5)),
        ],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
    unawaited(
      GoRouter.of(tester.element(find.byType(TodayScreen))).push('/day/$date'),
    );
    await tester.pumpAndSettle();
  }

  double top(WidgetTester tester, String text) =>
      tester.getTopLeft(find.text(text).first).dy;

  testWidgets('sections in spec order, with the day\'s observance', (
    tester,
  ) async {
    await open(tester, '2026-10-12');
    expect(find.text('২৫ আশ্বিন ১৪৩৩'), findsOneWidget);
    final order = [
      'সূর্য ও চন্দ্র',
      'অশুভ সময়',
      'উৎসব ও ব্রত',
    ].map((t) => top(tester, t)).toList();
    expect(order, orderedEquals([...order]..sort()));
    expect(top(tester, 'পক্ষ'), lessThan(order.first));
    expect(find.text('দুর্গাষষ্ঠী'), findsOneWidget);
    expect(find.text('রাহুকাল'), findsOneWidget);
  });

  testWidgets('detailed footer: coordinates, packs and status (FR-DAY-04)', (
    tester,
  ) async {
    await open(tester, '2026-10-12', language: 'en');
    expect(
      find.textContaining(
        '22.57° N, 88.36° E · data: sample-cities, sample-global-drik',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Sample data'), findsOneWidget);
  });

  testWidgets('kshaya, vriddhi and "(next day)" lines', (tester) async {
    await open(tester, '2026-10-20', language: 'en');
    expect(find.text('Kshaya Tithi'), findsOneWidget);
    expect(find.textContaining('(next day)'), findsWidgets);
    await tester.tap(find.byTooltip('Next day'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next day'));
    await tester.pumpAndSettle();
    expect(find.text('Vriddhi Tithi'), findsOneWidget);
    expect(find.text('Kshaya Tithi'), findsNothing);
  });

  testWidgets('swipe for the next day, arrow for the previous', (tester) async {
    await open(tester, '2026-10-12');
    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('২৬ আশ্বিন ১৪৩৩'), findsOneWidget);
    await tester.tap(find.byTooltip('আগের দিন'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('আগের দিন'));
    await tester.pumpAndSettle();
    expect(find.text('২৪ আশ্বিন ১৪৩৩'), findsOneWidget);
  });

  testWidgets('outside the packs: "not downloaded", no numbers', (
    tester,
  ) async {
    await open(tester, '2030-01-01', language: 'en');
    expect(
      find.text("Data for these dates isn't downloaded yet."),
      findsOneWidget,
    );
  });

  testWidgets('back returns to the tab that opened it', (tester) async {
    await open(tester, '2026-10-12');
    expect(find.byType(DayScreen), findsOneWidget);
    // pageBack() looks for an English "Back" tooltip; this app is in Bengali.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(DayScreen), findsNothing);
    expect(find.byType(TodayScreen), findsOneWidget);
  });

  test('routes and strict date parsing', () {
    expect(Routes.day(const CivilDate(2026, 10, 12)), '/day/2026-10-12');
    expect(CivilDate.tryParse('2026-10-12'), const CivilDate(2026, 10, 12));
    for (final bad in [
      '2026-02-30',
      '2026-1-12',
      '12-10-2026',
      'x',
      '2026-13-01',
    ]) {
      expect(CivilDate.tryParse(bad), isNull, reason: bad);
    }
  });

  testWidgets('200 % text: no overflow in either language', (tester) async {
    for (final language in ['bn', 'en']) {
      await open(
        tester,
        '2026-10-20',
        language: language,
        textScale: 2.0,
        size: const Size(360, 3600),
      );
      expect(tester.takeException(), isNull, reason: language);
    }
  });

  for (final language in ['bn', 'en']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in [1.0, 2.0]) {
        final id = 'day_${language}_${theme.name}_${(scale * 100).round()}';
        testWidgets('golden $id', (tester) async {
          await open(
            tester,
            '2026-10-12',
            language: language,
            theme: theme,
            textScale: scale,
            size: Size(360, scale > 1.5 ? 3200 : 1700),
          );
          await expectLater(
            find.byType(PanjikaApp),
            matchesGoldenFile('goldens/$id.png'),
          );
        });
      }
    }
  }
}
