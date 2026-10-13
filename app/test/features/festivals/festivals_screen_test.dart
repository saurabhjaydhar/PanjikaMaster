// T-510: Festivals list — a Bengali year grouped by whole months under sticky headers,
// Gregorian and Bengali dates, verification badges, category chips, month/importance
// filters, opening on the current month, year arrows, rows open the festival.
// Goldens bn/en × light/dark × 100/200 %. Data: the watermarked sample pack
// (Sep–Dec 2026: Ashwin, Kartik and Agrahayan 1433 are whole).
// Update goldens intentionally with: flutter test --update-goldens test/features/festivals
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/app/widgets/system_states.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/features/festivals/festival_detail_screen.dart';
import 'package:panjika/features/festivals/festivals_screen.dart';
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
    Size size = const Size(360, 1400),
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
        ],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(TodayScreen))).go('/festivals');
    await tester.pumpAndSettle();
  }

  testWidgets('the current year, whole months only, both dates per row', (
    tester,
  ) async {
    await open(tester);
    expect(find.byType(FestivalsScreen), findsOneWidget);
    expect(find.text('পার্বণ ১৪৩৩'), findsOneWidget);
    // Bhadro and Poush are cut by the sample's edges, so they aren't shown.
    expect(find.text('আশ্বিন'), findsOneWidget);
    expect(find.text('কার্তিক'), findsOneWidget);
    expect(find.text('ভাদ্র'), findsNothing);
    expect(
      find.text('এই বছরের কয়েকটি মাসের তথ্য এই ফোনে নেই।'),
      findsOneWidget,
    );
    expect(find.text('দুর্গাষষ্ঠী'), findsOneWidget);
    expect(find.text('সোম, ১২ অক্টো · ২৫ আশ্বিন'), findsOneWidget);
    expect(find.text('কালীপূজা'), findsOneWidget);
  });

  testWidgets('category chips narrow the list', (tester) async {
    await open(tester, language: 'en');
    Future<void> chip(String label) async {
      final f = find.widgetWithText(ChoiceChip, label);
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    await chip('Festival');
    expect(find.text('Bhai Phonta'), findsOneWidget);
    expect(find.text('Kali Puja'), findsNothing);
    await chip('Jayanti');
    expect(find.text('No observances match these filters.'), findsOneWidget);
    await tester.tap(find.text('Show all'));
    await tester.pumpAndSettle();
    expect(find.text('Kali Puja'), findsOneWidget);
  });

  testWidgets('month and importance filters', (tester) async {
    await open(tester, language: 'en');
    await tester.tap(find.byTooltip('Filter'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Kartik'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Other observances'));
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.text('Importance'))).pop();
    await tester.pumpAndSettle();
    expect(find.text('Bhai Phonta'), findsOneWidget); // Kartik, tier 2
    expect(find.text('Kali Puja'), findsNothing); // Kartik, tier 1
    expect(find.text('Durga Shashthi'), findsNothing); // Ashwin
  });

  testWidgets('a row opens its festival', (tester) async {
    await open(tester, language: 'en');
    await tester.tap(find.text('Kali Puja'));
    await tester.pumpAndSettle();
    expect(find.byType(FestivalDetailScreen), findsOneWidget);
  });

  testWidgets('a year outside the packs says it is not downloaded', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.byTooltip('পরের বছর'));
    await tester.pumpAndSettle();
    expect(find.text('পার্বণ ১৪৩৪'), findsOneWidget);
    expect(find.byType(SystemStateMessage), findsOneWidget);
  });

  testWidgets('opens scrolled to the current month', (tester) async {
    await open(tester, size: const Size(360, 400));
    // Ashwin is the current month and the first shown, so its header is at the top.
    final header = tester.getTopLeft(find.text('আশ্বিন'));
    final chips = tester.getBottomLeft(find.widgetWithText(ChoiceChip, 'সব'));
    expect(header.dy, greaterThanOrEqualTo(chips.dy));
  });

  for (final language in ['bn', 'en']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in [1.0, 2.0]) {
        final id =
            'festivals_${language}_${theme.name}_${(scale * 100).round()}';
        testWidgets('golden $id', (tester) async {
          await open(
            tester,
            language: language,
            theme: theme,
            textScale: scale,
            size: Size(360, scale > 1.5 ? 2600 : 1400),
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
