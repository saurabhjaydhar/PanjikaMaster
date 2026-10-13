// T-612: Glossary — every panchanga term and period from the packs with its
// explanation in the UI language and its name in both scripts; search in either
// script. Goldens bn/en × light/dark × 100/200 %. Data: the sample pack's names
// (the same content as data/content/names.toml).
// Update goldens intentionally with: flutter test --update-goldens test/features/glossary
import 'dart:async';

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
import 'package:panjika/data/repositories/panjika_repository.dart';
import 'package:panjika/domain/entities/terms.dart';
import 'package:panjika/features/glossary/glossary_screen.dart';
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
    Size size = const Size(360, 1200),
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
      GoRouter.of(tester.element(find.byType(TodayScreen))).push('/glossary'),
    );
    await tester.pumpAndSettle();
  }

  test('every term and every period has an explanation (FR-SET-07)', () async {
    final names = await DriftPanjikaRepository(db).names();
    expect(glossaryEntries(names, 'term'), hasLength(Term.values.length));
    expect(
      glossaryEntries(names, 'period'),
      hasLength(names.countOf('period')),
    );
  });

  testWidgets('names in both scripts, explanation in the UI language', (
    tester,
  ) async {
    await open(tester, language: 'en', size: const Size(360, 4000));
    expect(find.byType(GlossaryScreen), findsOneWidget);
    expect(find.text('Panjika terms'), findsOneWidget);
    expect(find.text('Tithi'), findsWidgets);
    expect(find.text('তিথি'), findsWidgets, reason: 'second script shown');
    expect(find.textContaining('One eighth of the daytime'), findsOneWidget);
  });

  testWidgets('search in either script; no match says so', (tester) async {
    await open(tester, language: 'en');
    await tester.enterText(find.byType(TextField), 'রাহু');
    await tester.pumpAndSettle();
    expect(find.text('Rahu Kaal'), findsOneWidget);
    expect(find.text('Panjika terms'), findsNothing);
    await tester.enterText(find.byType(TextField), 'KARANA');
    await tester.pumpAndSettle();
    expect(find.text('Karana'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No term matches that'), findsOneWidget);
  });

  for (final language in ['bn', 'en']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in [1.0, 2.0]) {
        final id =
            'glossary_${language}_${theme.name}_${(scale * 100).round()}';
        testWidgets('golden $id', (tester) async {
          await open(
            tester,
            language: language,
            theme: theme,
            textScale: scale,
            size: Size(360, scale > 1.5 ? 1600 : 1000),
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
