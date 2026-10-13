// T-512: Reminders screen — recurring rows with timing, festival reminders, add a
// festival, the empty state and the notifications-off banner; turning a reminder on
// asks for permission first. Goldens bn/en × light/dark × 100/200 %.
// Data: the watermarked sample pack; reminders are settings, not calendar data.
// Update goldens intentionally with: flutter test --update-goldens test/features/reminders
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
import 'package:panjika/data/notifications/notification_permission.dart';
import 'package:panjika/data/notifications/notification_scheduler.dart';
import 'package:panjika/domain/reminders/reminder_config.dart';
import 'package:panjika/features/festivals/festivals_screen.dart';
import 'package:panjika/features/reminders/notifications_off_note.dart';
import 'package:panjika/features/reminders/reminders_screen.dart';
import 'package:panjika/features/today/today_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  late AppDatabase db;
  late MemorySettings settings;
  late FakeNotificationPermission permission;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
    permission = FakeNotificationPermission();
  });
  tearDown(() => db.close());

  ReminderConfig read() =>
      ReminderConfig.decode(settings.read(SettingKey.reminders));

  Future<void> open(
    WidgetTester tester, {
    String language = 'bn',
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
    ReminderConfig config = const ReminderConfig(),
    Size size = const Size(360, 1000),
  }) async {
    settings = MemorySettings({
      SettingKey.onboardingDone: '1',
      SettingKey.theme: theme.name,
      if (!config.isEmpty) SettingKey.reminders: config.encode(),
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
          notificationSchedulerProvider.overrideWithValue(
            FakeNotificationScheduler(),
          ),
          notificationPermissionProvider.overrideWithValue(permission),
        ],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
    unawaited(
      GoRouter.of(tester.element(find.byType(TodayScreen))).push('/reminders'),
    );
    await tester.pumpAndSettle();
  }

  final configured = const ReminderConfig()
      .withFestival('kali_puja', ReminderConfig.festivalDefault)
      .withRecurring(RecurringKind.ekadashi, ReminderConfig.recurringDefault);

  testWidgets('empty: says how to start; recurring rows are there', (
    tester,
  ) async {
    await open(tester);
    expect(find.byType(RemindersScreen), findsOneWidget);
    expect(
      find.text(
        'এখনো কোনো অনুস্মারক নেই। একাদশী বা কোনো উৎসবের জন্য চালু করুন।',
      ),
      findsOneWidget,
    );
    for (final label in ['একাদশী', 'পূর্ণিমা', 'অমাবস্যা']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('turning Ekadashi on asks first, then shows its timing', (
    tester,
  ) async {
    permission.isGranted = false;
    await open(tester, language: 'en');
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(permission.requests, 1);
    expect(read().recurring[RecurringKind.ekadashi], isNotNull);
    expect(find.text('On the day, 6:00 AM'), findsOneWidget);
  });

  testWidgets('refused: stays off, and the banner explains', (tester) async {
    permission
      ..isGranted = false
      ..grantOnRequest = false;
    await open(tester, language: 'en');
    expect(find.byType(NotificationsOffNote), findsOneWidget);
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(read().isEmpty, isTrue);
  });

  testWidgets('festival rows show their timing; the sheet adds a second time', (
    tester,
  ) async {
    await open(tester, language: 'en', config: configured);
    expect(find.text('Kali Puja'), findsOneWidget);
    expect(find.text('The day before, 8:00 PM'), findsOneWidget);
    await tester.tap(find.text('Kali Puja'));
    await tester.pumpAndSettle();
    expect(find.text('When should we remind you?'), findsOneWidget);
    await tester.tap(find.byType(Checkbox).at(1)); // on the morning of the day
    await tester.pumpAndSettle();
    expect(read().festivals['kali_puja'], hasLength(2));
    Navigator.of(tester.element(find.byType(Checkbox).first)).pop();
    await tester.pumpAndSettle();
    expect(
      find.text('The day before, 8:00 PM and On the day, 6:00 AM'),
      findsOneWidget,
    );
  });

  testWidgets('a festival reminder can be turned off', (tester) async {
    await open(tester, language: 'en', config: configured);
    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();
    expect(read().festivals, isEmpty);
    expect(find.text('Kali Puja'), findsNothing);
  });

  testWidgets('"add a festival" opens the festival list', (tester) async {
    await open(tester, language: 'en');
    await tester.tap(find.text('Add a festival'));
    await tester.pumpAndSettle();
    expect(find.byType(FestivalsScreen), findsOneWidget);
  });

  for (final language in ['bn', 'en']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in [1.0, 2.0]) {
        final id =
            'reminders_${language}_${theme.name}_${(scale * 100).round()}';
        testWidgets('golden $id', (tester) async {
          await open(
            tester,
            language: language,
            theme: theme,
            textScale: scale,
            config: configured,
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
