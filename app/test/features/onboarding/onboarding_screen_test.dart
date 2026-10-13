// T-401: Onboarding — language (both scripts) → tradition → city → reminders, progress
// dots, Back through the steps, choices saved, a launch link kept for afterwards.
// Goldens: each step × bn/en × light/dark × 100/200 %. Data: the watermarked sample pack.
// Update goldens intentionally with: flutter test --update-goldens test/features/onboarding
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/features/day/day_screen.dart';
import 'package:panjika/features/onboarding/onboarding_screen.dart';
import 'package:panjika/features/today/today_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  late AppDatabase db;
  late MemorySettings settings;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
  });
  tearDown(() => db.close());

  Future<void> open(
    WidgetTester tester, {
    String device = 'en',
    String? language,
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
    Size size = const Size(360, 800),
  }) async {
    settings = MemorySettings({
      SettingKey.theme: theme.name,
      SettingKey.locale: ?language,
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
          deviceLocalesProvider.overrideWithValue([Locale(device)]),
          settingsSourceProvider.overrideWithValue(settings),
          appLocaleChannelProvider.overrideWithValue(FakeAppLocaleChannel()),
          clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 12, 5)),
        ],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'English device: starts in English, Bengali one tap away (US-09)',
    (tester) async {
      await open(tester);
      expect(find.byType(OnboardingScreen), findsOneWidget);
      // Step 1 is in both languages, each option in its own script.
      expect(find.text('ভাষা বেছে নিন'), findsOneWidget);
      expect(find.text('Choose your language'), findsOneWidget);
      expect(find.text('বাংলা'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      // A preview of names in each language, from the pack.
      expect(find.text('For example: Shukla Saptami'), findsOneWidget);
      expect(find.text('যেমন: শুক্লা সপ্তমী'), findsOneWidget);
      expect(find.bySemanticsLabel('Step 1 of 4'), findsOneWidget);

      await next(tester);
      expect(settings.read(SettingKey.locale), 'en', reason: 'confirmed');
      expect(find.text('Which panjika do you follow?'), findsOneWidget);
    },
  );

  testWidgets('the whole flow saves every choice and lands on Today', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('বাংলা'));
    await tester.pumpAndSettle();
    expect(settings.read(SettingKey.locale), 'bn');
    await next(tester);

    // Tradition: each school explained; Surya Siddhanta is "coming soon" (T-410).
    expect(find.text('কোন পঞ্জিকা মেনে চলেন?'), findsOneWidget);
    expect(find.textContaining('আধুনিক জ্যোতির্বিজ্ঞান'), findsOneWidget);
    expect(find.text('শীঘ্রই আসছে'), findsOneWidget);
    await tester.tap(find.text('গুপ্তপ্রেস (সূর্যসিদ্ধান্ত)'));
    await tester.pumpAndSettle();
    expect(settings.read(SettingKey.tradition), isNull, reason: 'Drik stays');
    await next(tester);

    // City: popular cities, search in either script.
    expect(find.text('আপনার শহর কোনটি?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'shiliguri');
    await tester.pumpAndSettle();
    await tester.tap(find.text('শিলিগুড়ি'));
    await tester.pumpAndSettle();
    expect(settings.read(SettingKey.cityId), 'siliguri');
    await next(tester);

    expect(find.text('অনুস্মারক চান?'), findsOneWidget);
    expect(find.bySemanticsLabel('ধাপ ৪/৪'), findsOneWidget);
    await tester.tap(find.text('এখন নয়'));
    await tester.pumpAndSettle();
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(settings.read(SettingKey.onboardingDone), '1');
    expect(settings.read(SettingKey.remindersOptIn), '0');
  });

  testWidgets('"Yes, remind me" records the opt-in', (tester) async {
    await open(tester);
    for (var i = 0; i < 3; i++) {
      await next(tester);
    }
    await tester.tap(find.text('Yes, remind me'));
    await tester.pumpAndSettle();
    expect(settings.read(SettingKey.remindersOptIn), '1');
    expect(find.byType(TodayScreen), findsOneWidget);
  });

  testWidgets('Back walks back through the steps', (tester) async {
    await open(tester);
    await next(tester);
    await next(tester);
    expect(find.text('Which is your city?'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Which panjika do you follow?'), findsOneWidget);
    // System Back too (PopScope).
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Choose your language'), findsOneWidget);
  });

  testWidgets('a link that launched the app opens after onboarding', (
    tester,
  ) async {
    await open(tester);
    GoRouter.of(tester.element(find.byType(OnboardingScreen)))
        .go('/day/2026-10-14');
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await next(tester);
    }
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.byType(DayScreen), findsOneWidget);
  });

  testWidgets('done once, never again', (tester) async {
    await open(tester);
    for (var i = 0; i < 3; i++) {
      await next(tester);
    }
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(TodayScreen))).go('/onboarding');
    await tester.pumpAndSettle();
    expect(find.byType(TodayScreen), findsOneWidget);
  });

  for (var step = 0; step < 4; step++) {
    for (final language in ['bn', 'en']) {
      for (final theme in [ThemeMode.light, ThemeMode.dark]) {
        for (final scale in [1.0, 2.0]) {
          final id =
              'onboarding_${step + 1}_${language}_${theme.name}_'
              '${(scale * 100).round()}';
          testWidgets('golden $id', (tester) async {
            await open(
              tester,
              device: language,
              theme: theme,
              textScale: scale,
              size: Size(360, scale > 1.5 ? 1500 : 800),
            );
            for (var i = 0; i < step; i++) {
              await next(tester);
            }
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
}
