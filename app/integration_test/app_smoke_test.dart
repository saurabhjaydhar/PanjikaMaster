// T-115: on a real Android device/emulator — the app launches on Today in Bengali,
// switches to English instantly (mirrored into Android 13+ per-app language through the
// Kotlin channel), and system back from another tab returns to Today.
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/core/l10n/app_language.dart';
import 'package:panjika/core/l10n/app_locale_channel.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/features/today/today_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('launch → Today in Bengali → English → back', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await loadSamplePackIfEmpty(db);
    // Start clean in Android's per-app language setting (API 33+; no-op below).
    await const AppLocaleChannel().set('');

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        settingsSourceProvider.overrideWithValue(
          MemorySettings({
            SettingKey.onboardingDone: '1',
            SettingKey.locale: 'bn',
          }),
        ),
        // The sample data covers Sep–Dec 2026; pin the clock to the PRD's sample day.
        clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 12, 5)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Launches on Today, in Bengali, with sample data and its watermark.
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.text('পঞ্জিকা'), findsOneWidget);
    expect(find.text('২৫ আশ্বিন ১৪৩৩'), findsOneWidget);

    // Switch to English: instant, same screen, mirrored into the system setting.
    await container.read(appLanguageProvider.notifier).select(AppLanguage.en);
    await tester.pumpAndSettle();
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('25 Ashwin 1433'), findsOneWidget);
    // The raw channel returns null below Android 13 (no per-app language there).
    final systemTag = await const MethodChannel('panjika/app_locale')
        .invokeMethod<String>('get');
    if (systemTag != null) {
      expect(
        systemTag,
        startsWith('en'),
        reason: 'per-app language follows the in-app choice',
      );
    }

    // System back from another tab returns to Today.
    await tester.tap(find.text('Festivals'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(TodayScreen), findsOneWidget);

    await const AppLocaleChannel().set('');
  });
}
