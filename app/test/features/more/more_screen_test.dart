// T-407: More — quick language switch, every §10 destination reachable, About with
// version and licences. Goldens bn/en × light/dark × 100/200 % for More and About.
// Data: the watermarked sample pack.
// Update goldens intentionally with: flutter test --update-goldens test/features/more
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
import 'package:panjika/features/city/city_picker_screen.dart';
import 'package:panjika/features/glossary/glossary_screen.dart';
import 'package:panjika/features/more/about_screen.dart';
import 'package:panjika/features/more/app_version.dart';
import 'package:panjika/features/more/coming_soon_screen.dart';
import 'package:panjika/features/more/more_screen.dart';
import 'package:panjika/features/reminders/reminders_screen.dart';
import 'package:panjika/features/settings/settings_screen.dart';
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
    String language = 'bn',
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
    Size size = const Size(360, 1200),
    String route = '/more',
  }) async {
    settings = MemorySettings({
      SettingKey.onboardingDone: '1',
      SettingKey.theme: theme.name,
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
          deviceLocalesProvider.overrideWithValue([Locale(language)]),
          settingsSourceProvider.overrideWithValue(settings),
          appLocaleChannelProvider.overrideWithValue(FakeAppLocaleChannel()),
          clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 12, 5)),
          appVersionProvider.overrideWith((ref) async => '1.0.0'),
        ],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
    final router = GoRouter.of(tester.element(find.byType(TodayScreen)));
    if (route == '/more') {
      router.go(route);
    } else {
      router.go('/more');
      await tester.pumpAndSettle();
      unawaited(router.push(route));
    }
    await tester.pumpAndSettle();
  }

  testWidgets('every §10 destination opens and returns to More', (
    tester,
  ) async {
    await open(tester, language: 'en');
    final destinations = <String, Type>{
      'Reminders': RemindersScreen,
      'Search': ComingSoonScreen,
      'City': CityPickerScreen,
      'Glossary': GlossaryScreen,
      'Settings': SettingsScreen,
      'Sources & verification': ComingSoonScreen,
      'Report an error': ComingSoonScreen,
      'Remove ads': ComingSoonScreen,
      'About': AboutScreen,
      'Privacy': ComingSoonScreen,
    };
    for (final MapEntry(key: label, value: screen) in destinations.entries) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.byType(screen), findsOneWidget, reason: label);
      if (screen == ComingSoonScreen) {
        // Its own title, so the user knows where they are.
        expect(
          find.descendant(of: find.byType(AppBar), matching: find.text(label)),
          findsOneWidget,
        );
        expect(find.text('Coming soon'), findsOneWidget);
      }
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(MoreScreen), findsOneWidget, reason: label);
    }
  });

  testWidgets('the quick language switch applies at once and persists', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('অনুস্মারক'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Reminders'), findsOneWidget);
    expect(settings.read(SettingKey.locale), 'en');
  });

  testWidgets('the City row shows the chosen city', (tester) async {
    await open(tester, language: 'en');
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'City'),
        matching: find.text('Kolkata'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('About: version in the UI numerals; licences open', (
    tester,
  ) async {
    await open(tester, route: '/about');
    expect(find.text('সংস্করণ ১.০.০'), findsOneWidget);
    await tester.tap(find.text('লাইসেন্স'));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
  });

  for (final (name, route) in [('more', '/more'), ('about', '/about')]) {
    for (final language in ['bn', 'en']) {
      for (final theme in [ThemeMode.light, ThemeMode.dark]) {
        for (final scale in [1.0, 2.0]) {
          final id =
              '${name}_${language}_${theme.name}_${(scale * 100).round()}';
          testWidgets('golden $id', (tester) async {
            await open(
              tester,
              language: language,
              theme: theme,
              textScale: scale,
              route: route,
              size: Size(360, scale > 1.5 ? 2000 : 1000),
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
