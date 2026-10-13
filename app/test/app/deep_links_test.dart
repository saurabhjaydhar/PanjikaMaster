// T-411: deep-link routes for share links — /day/YYYY-MM-DD and /festival/<id> open
// their screens; bad dates, unknown festivals and unknown addresses say so and offer
// Today. Goldens of the not-found screen bn/en × light/dark × 100/200 %.
// Data: the watermarked sample pack.
// Update goldens intentionally with: flutter test --update-goldens test/app/deep_links_test.dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/app/router.dart';
import 'package:panjika/app/shell/not_found_screen.dart';
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

import '../helpers/fakes.dart';
import '../helpers/fonts.dart';

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
    String location, {
    String language = 'bn',
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
  }) async {
    tester.view
      ..physicalSize = const Size(360, 800)
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
    GoRouter.of(tester.element(find.byType(TodayScreen))).go(location);
    await tester.pumpAndSettle();
  }

  test('link forms', () {
    expect(Routes.day(const CivilDate(2026, 10, 12)), '/day/2026-10-12');
    expect(Routes.festival('mahalaya'), '/festival/mahalaya');
    expect(Routes.festivalId.hasMatch('durga_puja'), isTrue);
    expect(Routes.festivalId.hasMatch('../etc'), isFalse);
    expect(Routes.festivalId.hasMatch(''), isFalse);
  });

  testWidgets('/day/YYYY-MM-DD opens that day', (tester) async {
    await open(tester, '/day/2026-10-20');
    final day = tester.widget<DayScreen>(find.byType(DayScreen));
    expect(day.date, const CivilDate(2026, 10, 20));
  });

  testWidgets('an impossible date says so and offers Today', (tester) async {
    await open(tester, '/day/2026-02-30');
    expect(find.byType(NotFoundScreen), findsOneWidget);
    expect(find.text('এই পাতাটি পাওয়া যায়নি।'), findsOneWidget);
    await tester.tap(find.text('আজকের পঞ্জিকা দেখুন'));
    await tester.pumpAndSettle();
    expect(find.byType(TodayScreen), findsOneWidget);
  });

  testWidgets('/festival/<id> opens the festival', (tester) async {
    await open(tester, '/festival/mahalaya', language: 'en');
    expect(find.byType(FestivalDetailScreen), findsOneWidget);
    expect(find.text('Mahalaya'), findsOneWidget);
  });

  testWidgets('an unknown festival says it isn\'t in the data', (tester) async {
    await open(tester, '/festival/not_a_festival');
    expect(find.text('এই উৎসবের তথ্য এই ফোনে নেই।'), findsOneWidget);
  });

  testWidgets('a malformed festival id and an unknown address say so', (
    tester,
  ) async {
    await open(tester, '/festival/BAD-ID');
    expect(find.byType(NotFoundScreen), findsOneWidget);
    await open(tester, '/no/such/page');
    expect(find.byType(NotFoundScreen), findsOneWidget);
  });

  for (final language in ['bn', 'en']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in [1.0, 2.0]) {
        final id =
            'not_found_${language}_${theme.name}_${(scale * 100).round()}';
        testWidgets('golden $id', (tester) async {
          await open(
            tester,
            '/no/such/page',
            language: language,
            theme: theme,
            textScale: scale,
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
