// T-613: Help — the Bengali TTS voice, and the phone settings that keep reminders on
// time (general, Xiaomi, Samsung), in both languages, with buttons that open the
// system pages. Goldens bn/en × light/dark × 100/200 %.
// Update goldens intentionally with: flutter test --update-goldens test/features/help
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
import 'package:panjika/features/help/help_screen.dart';
import 'package:panjika/features/today/today_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  late AppDatabase db;
  late FakeSystemSettings system;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
    system = FakeSystemSettings();
  });
  tearDown(() => db.close());

  Future<void> open(
    WidgetTester tester, {
    String language = 'bn',
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
    Size size = const Size(360, 800),
    String route = '/help',
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
          systemSettingsProvider.overrideWithValue(system),
          notificationPermissionProvider.overrideWithValue(
            FakeNotificationPermission(),
          ),
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

  testWidgets('the buttons open the system pages', (tester) async {
    await open(tester, language: 'en', size: const Size(360, 2400));
    expect(find.text('Bengali voice for TalkBack'), findsOneWidget);
    expect(find.text('On Xiaomi, Redmi and POCO phones'), findsOneWidget);
    expect(find.text('On Samsung phones'), findsOneWidget);
    expect(
      find.text(
        'Open Settings › Apps › Bangla Panjika › Battery and choose '
        'Unrestricted.',
      ),
      findsOneWidget,
    );
    for (final label in [
      'Open text-to-speech settings',
      'Open notification settings',
      'Open battery settings',
    ]) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
    expect(system.opened, [
      SystemSettingsPage.tts,
      SystemSettingsPage.notifications,
      SystemSettingsPage.battery,
    ]);
  });

  testWidgets('says so when a page cannot be opened', (tester) async {
    system.opens = false;
    await open(tester, language: 'en');
    await tester.tap(find.text('Open text-to-speech settings'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        "Couldn't open the settings. Please find them in your phone's Settings.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('Reminders links to the reminders section', (tester) async {
    await open(tester, language: 'en', route: '/reminders');
    final link = find.text('Reminders not arriving on time?');
    await tester.scrollUntilVisible(link, 200);
    await tester.tap(link);
    await tester.pumpAndSettle();
    expect(
      tester.widget<HelpScreen>(find.byType(HelpScreen)).topic,
      HelpTopic.reminders,
    );
    final heading = tester.getRect(
      find.text("If reminders don't arrive on time"),
    );
    expect(heading.top, lessThan(200), reason: 'scrolled into view');
  });

  for (final language in ['bn', 'en']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in [1.0, 2.0]) {
        final id = 'help_${language}_${theme.name}_${(scale * 100).round()}';
        testWidgets('golden $id', (tester) async {
          await open(
            tester,
            language: language,
            theme: theme,
            textScale: scale,
            size: Size(360, scale > 1.5 ? 2600 : 1600),
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
