// T-409: "Use my location" — rationale before the first prompt, nearest city with
// distance, the > 50 km warning, and denials that never block (FR-LOC-02..04).
// Goldens of the nearest-city sheet bn/en × light/dark × 100/200 %.
// Data: the watermarked sample pack (Kolkata 22.57/88.36, Siliguri 26.73/88.40).
// Update goldens intentionally with: flutter test --update-goldens test/features/city
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/app/widgets/date_header.dart';
import 'package:panjika/core/l10n/app_language.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/l10n/panjika_formatter.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/data/location/platform_location_service.dart';
import 'package:panjika/domain/location/location.dart';
import 'package:panjika/features/city/city_picker_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  late AppDatabase db;
  late MemorySettings settings;
  late FakeLocationService location;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
    location = FakeLocationService();
  });
  tearDown(() => db.close());

  Future<void> openPicker(
    WidgetTester tester, {
    String language = 'bn',
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
    Size size = const Size(360, 800),
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
          locationServiceProvider.overrideWithValue(location),
        ],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CityChip));
    await tester.pumpAndSettle();
  }

  Future<void> tapUseLocation(WidgetTester tester) async {
    await tester.tap(find.text('আমার অবস্থান ব্যবহার করুন'));
    await tester.pumpAndSettle();
  }

  String km(double lat, double lon, double cityLat, double cityLon) =>
      const PanjikaFormatter(
        language: AppLanguage.bn,
        numerals: NumeralStyle.bengali,
      ).number(distanceKm(lat, lon, cityLat, cityLon).round());

  testWidgets('nearest city with its distance; choosing it closes the picker', (
    tester,
  ) async {
    location.result = const Located(26.70, 88.43);
    await openPicker(tester);
    await tapUseLocation(tester);
    expect(
      find.text(
        'নিকটতম শহর: শিলিগুড়ি, ${km(26.70, 88.43, 26.73, 88.40)} কিমি',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('৫০ কিমির বেশি'), findsNothing);
    await tester.tap(find.text('এই শহর বেছে নিন'));
    await tester.pumpAndSettle();
    expect(settings.read(SettingKey.cityId), 'siliguri');
    expect(find.byType(CityPickerScreen), findsNothing);
  });

  testWidgets('more than 50 km away: a warning; "Not now" keeps the city', (
    tester,
  ) async {
    location.result = const Located(24.0, 88.0);
    await openPicker(tester);
    await tapUseLocation(tester);
    expect(
      find.text(
        'এই শহর ৫০ কিমির বেশি দূরে, তাই সময় কয়েক মিনিট আলাদা হতে পারে।',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('এখন নয়'));
    await tester.pumpAndSettle();
    expect(settings.read(SettingKey.cityId), isNull);
    expect(find.byType(CityPickerScreen), findsOneWidget);
  });

  testWidgets('first time: the rationale comes before any prompt', (
    tester,
  ) async {
    location.permissionState = LocationPermission.notAsked;
    await openPicker(tester);
    await tapUseLocation(tester);
    expect(find.textContaining('আনুমানিক অবস্থান লাগবে'), findsOneWidget);
    await tester.tap(find.text('এখন নয়'));
    await tester.pumpAndSettle();
    expect(location.locateCalls, 0, reason: 'no system prompt');

    location.result = const Located(22.58, 88.35);
    await tapUseLocation(tester);
    await tester.tap(find.text('এগিয়ে যান'));
    await tester.pumpAndSettle();
    expect(location.locateCalls, 1);
    expect(find.textContaining('নিকটতম শহর: কলকাতা'), findsOneWidget);
  });

  testWidgets('denied: says the list works, never blocks', (tester) async {
    location.result = const LocationDenied(permanently: false);
    await openPicker(tester);
    await tapUseLocation(tester);
    expect(
      find.text('অনুমতি ছাড়াও অ্যাপ চলবে। তালিকা থেকে শহর বেছে নিন।'),
      findsOneWidget,
    );
    expect(find.byType(CityPickerScreen), findsOneWidget);
    await tester.tap(find.text('হাওড়া').first);
    await tester.pumpAndSettle();
    expect(settings.read(SettingKey.cityId), 'howrah');
  });

  testWidgets('denied for good: no prompt, offers the app settings', (
    tester,
  ) async {
    location.permissionState = LocationPermission.deniedForever;
    await openPicker(tester);
    await tapUseLocation(tester);
    expect(location.locateCalls, 0);
    expect(find.textContaining('অবস্থানের অনুমতি বন্ধ আছে'), findsOneWidget);
    await tester.tap(find.text('সেটিংস খুলুন'));
    await tester.pumpAndSettle();
    expect(location.appSettingsOpened, 1);
  });

  testWidgets('location off: offers to turn it on', (tester) async {
    location.result = const LocationServiceOff();
    await openPicker(tester);
    await tapUseLocation(tester);
    expect(find.text('ফোনের লোকেশন বন্ধ আছে।'), findsOneWidget);
    await tester.tap(find.text('চালু করুন'));
    await tester.pumpAndSettle();
    expect(location.locationSettingsOpened, 1);
  });

  testWidgets('no fix: says so', (tester) async {
    await openPicker(tester);
    await tapUseLocation(tester);
    expect(
      find.text('অবস্থান পাওয়া যায়নি। তালিকা থেকে শহর বেছে নিন।'),
      findsOneWidget,
    );
  });

  for (final language in ['bn', 'en']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in [1.0, 2.0]) {
        final id =
            'nearest_city_${language}_${theme.name}_${(scale * 100).round()}';
        testWidgets('golden $id', (tester) async {
          location.result = const Located(24.0, 88.0); // far: shows the warning
          await openPicker(
            tester,
            language: language,
            theme: theme,
            textScale: scale,
            size: Size(360, scale > 1.5 ? 1200 : 800),
          );
          await tester.tap(find.byIcon(Icons.my_location));
          await tester.pumpAndSettle();
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
