// T-614: "সংশোধিত / Corrected" on observances whose dates changed in a correction pack
// within the last 7 days (§18): Day detail, Today, the festival list and Festival
// detail. Goldens of Day detail with the tag, bn/en × light/dark × 100/200 %. Data: the
// sample pack, with a correction recorded here (test input, not calendar data).
// Update goldens intentionally with: flutter test --update-goldens test/features/corrections
import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/app/widgets/observance_widgets.dart';
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
    // Durga Shashthi falls on the sample day; its date was "corrected" two days ago.
    await db
        .into(db.observanceCorrections)
        .insert(
          ObservanceCorrectionsCompanion.insert(
            tradition: 'drik_bishuddha',
            observanceId: 'durga_shashthi',
            correctedAt: '2026-10-10T05:00:00.000Z',
          ),
        );
  });
  tearDown(() => db.close());

  Future<void> open(
    WidgetTester tester, {
    String language = 'en',
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
    Size size = const Size(360, 3000),
    String route = '/day/2026-10-12',
    DateTime? now,
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
          clockProvider.overrideWithValue(
            () => now ?? DateTime.utc(2026, 10, 12, 5),
          ),
        ],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
    if (route != '/today') {
      unawaited(
        GoRouter.of(tester.element(find.byType(TodayScreen))).push(route),
      );
      await tester.pumpAndSettle();
    }
  }

  testWidgets('Day detail tags only the corrected observance', (tester) async {
    await open(tester);
    expect(find.text('Durga Shashthi'), findsOneWidget);
    expect(find.text('Corrected'), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(ObservanceChip, 'Durga Shashthi'),
        matching: find.byType(CorrectedTag),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Today shows it too', (tester) async {
    await open(tester, route: '/today');
    expect(find.byType(CorrectedTag), findsOneWidget);
  });

  testWidgets('Festival detail explains it', (tester) async {
    await open(tester, route: '/festival/durga_shashthi?date=2026-10-12');
    expect(find.byType(CorrectedTag), findsOneWidget);
    expect(
      find.text(
        "This festival's date was recently corrected. If you noted the old "
        'date, please check it again.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the festival list tags it', (tester) async {
    await open(tester, route: '/festivals');
    expect(find.byType(CorrectedTag), findsOneWidget);
  });

  testWidgets('after 7 days the tag is gone', (tester) async {
    await open(
      tester,
      route: '/day/2026-10-12',
      now: DateTime.utc(2026, 10, 18, 5),
    );
    expect(find.byType(CorrectedTag), findsNothing);
  });

  for (final language in ['bn', 'en']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in [1.0, 2.0]) {
        final id =
            'corrected_day_${language}_${theme.name}_${(scale * 100).round()}';
        testWidgets('golden $id', (tester) async {
          await open(
            tester,
            language: language,
            theme: theme,
            textScale: scale,
            size: Size(360, scale > 1.5 ? 3000 : 1400),
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
