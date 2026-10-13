// T-413: on a real Android device/emulator — first run goes through onboarding to
// Today in each language, and a language switch keeps the current screen and the
// back stack (US-09, US-10, FR-SET-05).
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/core/l10n/app_locale_channel.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/features/more/more_screen.dart';
import 'package:panjika/features/onboarding/onboarding_screen.dart';
import 'package:panjika/features/settings/settings_screen.dart';
import 'package:panjika/features/today/today_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late MemorySettings settings;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
    // Start clean in Android's per-app language setting (API 33+; no-op below).
    await const AppLocaleChannel().set('');
  });
  tearDown(() async {
    await db.close();
    await const AppLocaleChannel().set('');
  });

  Future<void> launch(
    WidgetTester tester, {
    required String device,
    bool onboarded = false,
  }) async {
    settings = MemorySettings({
      if (onboarded) SettingKey.onboardingDone: '1',
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          deviceLocalesProvider.overrideWithValue([Locale(device)]),
          settingsSourceProvider.overrideWithValue(settings),
          // The sample data covers Sep–Dec 2026; pin the clock to the PRD's sample day.
          clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 12, 5)),
        ],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> continueStep(WidgetTester tester) async {
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
  }

  testWidgets('Bengali phone: onboarding in Bengali → Today', (tester) async {
    await launch(tester, device: 'bn');
    expect(find.byType(OnboardingScreen), findsOneWidget);
    await continueStep(tester); // language: বাংলা preselected
    expect(find.text('কোন পঞ্জিকা মেনে চলেন?'), findsOneWidget);
    await continueStep(tester);
    expect(find.text('আপনার শহর কোনটি?'), findsOneWidget);
    await continueStep(tester);
    await tester.tap(find.text('এখন নয়'));
    await tester.pumpAndSettle();

    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.text('২৫ আশ্বিন ১৪৩৩'), findsOneWidget);
    expect(settings.read(SettingKey.locale), 'bn');
    expect(settings.read(SettingKey.onboardingDone), '1');
  });

  testWidgets('English phone: onboarding in English → Today', (tester) async {
    await launch(tester, device: 'en');
    expect(find.byType(OnboardingScreen), findsOneWidget);
    await continueStep(tester); // language: English preselected
    expect(find.text('Which panjika do you follow?'), findsOneWidget);
    await continueStep(tester);
    expect(find.text('Which is your city?'), findsOneWidget);
    await continueStep(tester);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.text('25 Ashwin 1433'), findsOneWidget);
    expect(settings.read(SettingKey.locale), 'en');
  });

  testWidgets('a language switch keeps the screen and the back stack', (
    tester,
  ) async {
    await launch(tester, device: 'bn', onboarded: true);
    // Today → More tab → Settings (pushed above the tabs).
    await tester.tap(find.text('আরও'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('সেটিংস'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    await tester.tap(find.text('English').first);
    await tester.pumpAndSettle();
    // Same screen, now in English.
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Back returns to More (in English), then system back to Today.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(MoreScreen), findsOneWidget);
    expect(find.text('Reminders'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.text('25 Ashwin 1433'), findsOneWidget);
  });
}
