// T-615 (automated part): every screen meets Flutter's tap-target guidelines in both
// languages and both themes — every tap target ≥ 48 dp (Android) and labelled for
// screen readers. Text contrast is checked exactly, over every colour-token pair, by
// test/app/theme (Flutter's pixel-sampling contrast check misreads the SAMPLE
// watermark, dividers and outlines as text colour). TalkBack on devices stays a human
// gate (§12.6, US-08).
import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/platform/system_settings.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/data/notifications/notification_permission.dart';
import 'package:panjika/features/more/app_version.dart';
import 'package:panjika/features/today/today_screen.dart';

import '../helpers/fakes.dart';
import '../helpers/fonts.dart';

const routes = [
  '/onboarding', // a first run opens here
  '/today',
  '/calendar',
  '/festivals',
  '/more',
  '/day/2026-10-12',
  '/festival/durga_shashthi?date=2026-10-12',
  '/settings',
  '/city',
  '/reminders',
  '/search',
  '/glossary',
  '/sources',
  '/sources/schools',
  '/report?date=2026-10-12',
  '/help',
  '/about',
];

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
    String route, {
    required String language,
    required ThemeMode theme,
  }) async {
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          deviceLocalesProvider.overrideWithValue([Locale(language)]),
          settingsSourceProvider.overrideWithValue(
            MemorySettings({
              if (route != '/onboarding') SettingKey.onboardingDone: '1',
              SettingKey.theme: theme.name,
            }),
          ),
          appLocaleChannelProvider.overrideWithValue(FakeAppLocaleChannel()),
          clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 12, 5)),
          notificationPermissionProvider.overrideWithValue(
            FakeNotificationPermission(),
          ),
          systemSettingsProvider.overrideWithValue(FakeSystemSettings()),
          appVersionProvider.overrideWith((ref) async => '1.0.0'),
        ],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
    if (route != '/today' && route != '/onboarding') {
      final router = GoRouter.of(tester.element(find.byType(TodayScreen)));
      if (const ['/calendar', '/festivals', '/more'].contains(route)) {
        router.go(route);
      } else {
        unawaited(router.push(route));
      }
      await tester.pumpAndSettle();
    }
  }

  for (final language in ['bn', 'en']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final route in routes) {
        testWidgets('$route $language ${theme.name}', (tester) async {
          final handle = tester.ensureSemantics();
          await open(tester, route, language: language, theme: theme);
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          handle.dispose();
        });
      }
    }
  }
}
