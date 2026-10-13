// T-614: Bengal periods on Day detail with the T-606 flag on — the auspicious section,
// Bengal periods next to Rahu Kaal, and a night period that ends after midnight marked
// "(next day)". Goldens bn/en × light/dark × 100/200 %. The period rules here are
// synthetic, to exercise the UI; they are not a panjika's table (§6.5.9).
// Update goldens intentionally with: flutter test --update-goldens test/features/day/bengal_periods_test.dart
import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/core/config/feature_flags.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/features/today/today_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  late AppDatabase db;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
    // Monday (weekday 1): Barabela day 4/8, Kalaratri night 5/8, Amrita Yoga day 2/8.
    await db.customStatement(
      'INSERT INTO period_rules VALUES '
      "('drik_bishuddha', 3, 'ashubh', 1, 'day', 8, 4, 1, 'sample-global-drik'), "
      "('drik_bishuddha', 5, 'ashubh', 1, 'night', 8, 5, 1, 'sample-global-drik'), "
      "('drik_bishuddha', 6, 'shubh', 1, 'day', 8, 2, 1, 'sample-global-drik')",
    );
  });
  tearDown(() => db.close());

  Future<void> open(
    WidgetTester tester, {
    String language = 'en',
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
    Size size = const Size(360, 1700),
    bool flag = true,
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
          featureFlagsProvider.overrideWithValue(
            FeatureFlags(bengalPeriods: flag),
          ),
        ],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
    unawaited(
      GoRouter.of(tester.element(find.byType(TodayScreen)))
          .push('/day/2026-10-12'),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('flag on: auspicious section, Bengal periods, next-day end', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Auspicious times'), findsOneWidget);
    expect(find.text('Amrita Yoga'), findsOneWidget);
    expect(find.text('Barabela'), findsOneWidget);
    expect(find.text('Kalaratri'), findsOneWidget);
    expect(find.textContaining('(next day)'), findsWidgets);
    // Barabela and Yamaganda overlap here: both are running, both say so.
    expect(find.text('Now'), findsNWidgets(2));
  });

  testWidgets('flag off: only Rahu Kaal, Yamaganda and Gulika', (tester) async {
    await open(tester, flag: false);
    expect(find.text('Barabela'), findsNothing);
    expect(find.text('Amrita Yoga'), findsNothing);
    expect(find.text('Rahu Kaal'), findsOneWidget);
  });

  for (final language in ['bn', 'en']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in [1.0, 2.0]) {
        final id =
            'bengal_periods_${language}_${theme.name}_${(scale * 100).round()}';
        testWidgets('golden $id', (tester) async {
          await open(
            tester,
            language: language,
            theme: theme,
            textScale: scale,
            size: Size(360, scale > 1.5 ? 3400 : 1700),
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
