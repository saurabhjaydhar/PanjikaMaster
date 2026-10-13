// T-403: Calendar — modes, navigation, selection, peek, legend, month chooser, Today,
// year roll-over, "not downloaded"; goldens bn/en × light/dark × 100/200 %.
// Data: the watermarked sample pack (1 Sep – 31 Dec 2026).
// Update goldens intentionally with: flutter test --update-goldens test/features/calendar
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/app/widgets/calendar_day_cell.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/features/day/day_screen.dart';

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
    Size size = const Size(360, 800),
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
            MemorySettings({SettingKey.theme: theme.name}),
          ),
          appLocaleChannelProvider.overrideWithValue(FakeAppLocaleChannel()),
          clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 12, 5)),
        ],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(language == 'bn' ? 'পঞ্জিকা' : 'Calendar').last);
    await tester.pumpAndSettle();
  }

  Finder cellWithLabel(Pattern p) => find.byWidgetPredicate(
    (w) => w is CalendarDayCell && w.semanticsLabel.contains(p),
  );

  testWidgets('opens on the Bengali month with today ringed', (tester) async {
    await open(tester);
    expect(find.text('আশ্বিন ১৪৩৩'), findsOneWidget);
    expect(find.text('রবি'), findsOneWidget);
    final today = tester.widget<CalendarDayCell>(
      cellWithLabel('১২ অক্টোবর ২০২৬'),
    );
    expect(
      (today.isToday, today.isSelected, today.primaryDay),
      (true, true, 25),
    );
    expect(today.semanticsLabel, startsWith('আজ, '));
  });

  testWidgets('Gregorian mode keeps the selected day; numbers swap', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(cellWithLabel('১৫ অক্টোবর ২০২৬'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ইংরেজি মাস'));
    await tester.pumpAndSettle();
    expect(find.text('অক্টোবর ২০২৬'), findsOneWidget);
    final cell = tester.widget<CalendarDayCell>(
      cellWithLabel('১৫ অক্টোবর ২০২৬'),
    );
    expect(
      (cell.isSelected, cell.primaryDay, cell.secondaryDay),
      (true, 15, 28),
    );
  });

  testWidgets('arrows and swipe; a month outside the packs says so', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.byTooltip('পরের মাস'));
    await tester.pumpAndSettle();
    expect(find.text('কার্তিক ১৪৩৩'), findsOneWidget);
    await tester.fling(
      find.byType(CalendarDayCell).first,
      const Offset(400, 0),
      1500,
    );
    await tester.pumpAndSettle();
    expect(find.text('আশ্বিন ১৪৩৩'), findsOneWidget);
    await tester.tap(find.byTooltip('আগের মাস'));
    await tester.pumpAndSettle();
    // ভাদ্র 1433 starts before the sample pack does: not shown half-filled.
    expect(find.text('ভাদ্র ১৪৩৩'), findsOneWidget);
    expect(find.text('এই সময়ের তথ্য ডাউনলোড করা নেই।'), findsOneWidget);
    await tester.tap(find.text('আজ').first);
    await tester.pumpAndSettle();
    expect(find.text('আশ্বিন ১৪৩৩'), findsOneWidget);
  });

  testWidgets('tap selects and updates the strip; tap again opens the day', (
    tester,
  ) async {
    await open(tester, language: 'en');
    await tester.tap(cellWithLabel('15 October 2026'));
    await tester.pumpAndSettle();
    expect(find.text('Selected: 28 Ashwin 1433'), findsOneWidget);
    await tester.tap(cellWithLabel('15 October 2026'));
    await tester.pumpAndSettle();
    expect(find.byType(DayScreen), findsOneWidget);
  });

  testWidgets('long-press peeks; View opens the day', (tester) async {
    await open(tester, language: 'en');
    await tester.longPress(cellWithLabel('16 October 2026'));
    await tester.pumpAndSettle();
    expect(find.text('Vijaya Dashami'), findsWidgets);
    await tester.tap(find.text('View').last);
    await tester.pumpAndSettle();
    expect(find.byType(DayScreen), findsOneWidget);
  });

  testWidgets('legend explains every mark', (tester) async {
    await open(tester);
    await tester.tap(find.byTooltip('চিহ্নের অর্থ'));
    await tester.pumpAndSettle();
    for (final label in [
      'পূর্ণিমা',
      'অমাবস্যা',
      'শুক্লা একাদশী / কৃষ্ণা একাদশী',
      'নির্বাচিত দিন',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.byType(MoonMarkerGlyph), findsAtLeastNWidgets(3));
  });

  testWidgets('month chooser; চৈত্র rolls into বৈশাখ of the next year', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('আশ্বিন ১৪৩৩'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('চৈত্র'));
    await tester.pumpAndSettle();
    expect(find.text('চৈত্র ১৪৩৩'), findsOneWidget);
    await tester.tap(find.byTooltip('পরের মাস'));
    await tester.pumpAndSettle();
    expect(find.text('বৈশাখ ১৪৩৪'), findsOneWidget);
  });

  testWidgets('200 % text: no overflow in either language', (tester) async {
    for (final language in ['bn', 'en']) {
      await open(
        tester,
        language: language,
        textScale: 2.0,
        size: const Size(360, 1600),
      );
      expect(tester.takeException(), isNull, reason: language);
    }
  });

  for (final language in ['bn', 'en']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in [1.0, 2.0]) {
        final id =
            'calendar_${language}_${theme.name}_${(scale * 100).round()}';
        testWidgets('golden $id', (tester) async {
          await open(
            tester,
            language: language,
            theme: theme,
            textScale: scale,
            size: Size(360, scale > 1.5 ? 1700 : 900),
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
