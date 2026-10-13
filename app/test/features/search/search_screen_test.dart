// T-611: Search screen — examples, date results (open Day detail), festival results
// (open Festival detail), dates outside the packs, and the empty state.
// Goldens bn/en × light/dark × 100/200 %. Data: the watermarked sample pack.
// Update goldens intentionally with: flutter test --update-goldens test/features/search
import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/features/day/day_screen.dart';
import 'package:panjika/features/festivals/festival_detail_screen.dart';
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
    unawaited(
      GoRouter.of(tester.element(find.byType(TodayScreen))).push('/search'),
    );
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  testWidgets('a Bengali date opens its day', (tester) async {
    await open(tester, language: 'en');
    expect(find.textContaining('For example:'), findsOneWidget);
    await type(tester, '25 Ashwin');
    expect(find.text('25 Ashwin 1433 = 12 October 2026'), findsOneWidget);
    expect(
      find.textContaining('Bishuddha Siddhanta (Drik) · Kolkata · IST'),
      findsOneWidget,
    );
    await tester.tap(find.text('25 Ashwin 1433 = 12 October 2026'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<DayScreen>(find.byType(DayScreen)).date,
      const CivilDate(2026, 10, 12),
    );
  });

  testWidgets('a festival name in the other script opens the festival', (
    tester,
  ) async {
    await open(tester, language: 'en');
    await type(tester, 'কালী পূজা');
    expect(find.text('Kali Puja'), findsOneWidget);
    await tester.tap(find.text('Kali Puja'));
    await tester.pumpAndSettle();
    expect(find.byType(FestivalDetailScreen), findsOneWidget);
  });

  testWidgets('a date outside the packs is not converted', (tester) async {
    await open(tester);
    await type(tester, '১ বৈশাখ ১৪৩৩');
    expect(
      find.text('১ বৈশাখ ১৪৩৩: এই তারিখের তথ্য এই ফোনে নেই'),
      findsOneWidget,
    );
  });

  testWidgets('nothing found says what to check', (tester) async {
    await open(tester);
    await type(tester, 'zzzz');
    expect(
      find.text('কিছু পাওয়া যায়নি। বানান বা তারিখের ধরন দেখে নিন।'),
      findsOneWidget,
    );
  });

  for (final language in ['bn', 'en']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in [1.0, 2.0]) {
        final id = 'search_${language}_${theme.name}_${(scale * 100).round()}';
        testWidgets('golden $id', (tester) async {
          await open(
            tester,
            language: language,
            theme: theme,
            textScale: scale,
            size: Size(360, scale > 1.5 ? 1300 : 800),
          );
          await type(tester, language == 'bn' ? 'পূজা' : 'puja');
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
