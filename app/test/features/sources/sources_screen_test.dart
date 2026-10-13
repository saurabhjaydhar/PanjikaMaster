// T-609: Sources & verification (FR-SET-02) — tradition, the numbered steps, the
// marks legend, every pack's version, dates and validation state, the "why do the two
// schools differ?" explainer (about 150 words in each language) and the report link.
// Goldens bn/en × light/dark × 100/200 % for both screens. Data: the sample pack.
// Update goldens intentionally with: flutter test --update-goldens test/features/sources
import 'dart:async';

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
import 'package:panjika/features/report/report_screen.dart';
import 'package:panjika/features/sources/sources_screen.dart';
import 'package:panjika/features/today/today_screen.dart';
import 'package:panjika/l10n/gen/app_localizations.dart';

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
    String route = '/sources',
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
      GoRouter.of(tester.element(find.byType(TodayScreen))).push(route),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('says which tradition, how, the marks and every pack', (
    tester,
  ) async {
    await open(tester, language: 'en', size: const Size(360, 2000));
    expect(
      find.text(
        'Every date and time in this app follows Bishuddha Siddhanta (Drik), '
        'the tradition chosen in Settings.',
      ),
      findsOneWidget,
    );
    for (final step in [
      'Astronomical calculation (NASA JPL)',
      'Checked against the Rashtriya Panchang',
      'Checked against the printed panjika',
      'Major festivals reviewed by an expert',
    ]) {
      expect(find.text(step), findsOneWidget, reason: step);
    }
    expect(find.text('Reviewed by an expert'), findsOneWidget);
    expect(find.text('Calculated, not yet checked'), findsOneWidget);
    for (final kind in ['Panchanga data', 'City data', 'Festival data']) {
      expect(find.text('$kind · version 1'), findsOneWidget, reason: kind);
    }
    // Sample packs say so, and the screen carries the watermark.
    expect(find.text('Sample data'), findsNWidgets(3));
    expect(find.byType(SampleWatermark), findsOneWidget);
  });

  testWidgets('a validated pack shows its date; others say not yet', (
    tester,
  ) async {
    await db.customStatement(
      'UPDATE packs SET is_sample = 0, validation_summary ='
      " '{\"validated_on\": \"2026-09-30\"}' WHERE kind = 'global'",
    );
    await db.customStatement(
      "UPDATE packs SET is_sample = 0 WHERE kind <> 'global'",
    );
    await open(tester, language: 'en', size: const Size(360, 2000));
    expect(find.text('Last checked: 30 September 2026'), findsOneWidget);
    expect(
      find.text('Not yet checked against the references'),
      findsNWidgets(2),
    );
    expect(find.byType(SampleWatermark), findsNothing);
  });

  testWidgets('opens the explainer and the report form', (tester) async {
    await open(tester, language: 'en', size: const Size(360, 2000));
    await tester.tap(find.text('Why do the two schools differ?'));
    await tester.pumpAndSettle();
    expect(find.byType(SchoolsExplainerScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report an error'));
    await tester.pumpAndSettle();
    expect(find.byType(ReportScreen), findsOneWidget);
  });

  test('the explainer is about 150 words in each language', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final l = lookupAppLocalizations(locale);
      final words = [l.schoolsPara1, l.schoolsPara2, l.schoolsPara3]
          .join(' ')
          .split(RegExp(r'\s+'))
          .where((w) => RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(w))
          .length;
      expect(words, inInclusiveRange(120, 180), reason: '$locale: $words');
    }
  });

  for (final screen in ['sources', 'schools']) {
    for (final language in ['bn', 'en']) {
      for (final theme in [ThemeMode.light, ThemeMode.dark]) {
        for (final scale in [1.0, 2.0]) {
          final id =
              '${screen}_${language}_${theme.name}_${(scale * 100).round()}';
          testWidgets('golden $id', (tester) async {
            final tall = screen == 'sources' ? 2 : 1;
            await open(
              tester,
              language: language,
              theme: theme,
              textScale: scale,
              size: Size(360, (scale > 1.5 ? 1300 : 800) * tall.toDouble()),
              route: screen == 'sources' ? '/sources' : '/sources/schools',
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
}
