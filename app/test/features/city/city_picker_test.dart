// T-405: city picker — search in both scripts with aliases, sections, today's sunrise,
// choosing a city (toast, recent list); goldens bn/en × light/dark × 100/200 %.
// Data: the watermarked sample pack (Kolkata, Howrah, Siliguri).
// Update goldens intentionally with: flutter test --update-goldens test/features/city
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/app/widgets/date_header.dart';
import 'package:panjika/app/widgets/panjika_widgets.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/features/city/city_picker_screen.dart';

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
        ],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CityChip));
    await tester.pumpAndSettle();
  }

  testWidgets('the city chip opens the picker; West Bengal with sunrise', (
    tester,
  ) async {
    await openPicker(tester);
    expect(find.byType(CityPickerScreen), findsOneWidget);
    expect(find.text('পশ্চিমবঙ্গ'), findsOneWidget);
    // A city and its district can share a name (কলকাতা, হাওড়া).
    for (final city in ['কলকাতা', 'হাওড়া', 'শিলিগুড়ি']) {
      expect(find.text(city), findsWidgets, reason: city);
    }
    expect(find.textContaining('সূর্যোদয় '), findsNWidgets(3));
    expect(
      find.byIcon(Icons.check),
      findsOneWidget,
      reason: 'Kolkata is current',
    );
  });

  testWidgets('sunrise times carry their provenance and the sample mark', (
    tester,
  ) async {
    await openPicker(tester);
    await tester.scrollUntilVisible(
      find.textContaining('প্রতিটি শহরের আজকের সূর্যোদয়, IST'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('বিশুদ্ধ সিদ্ধান্ত (দৃক)'), findsOneWidget);
    expect(find.textContaining('sample-cities'), findsOneWidget);
    expect(find.textContaining('নমুনা তথ্য'), findsOneWidget);
    expect(find.byType(SampleWatermark), findsOneWidget);
  });

  testWidgets('search: English, alias, Bengali; no match says so', (
    tester,
  ) async {
    await openPicker(tester);
    Future<void> type(String q) async {
      await tester.enterText(find.byType(TextField), q);
      await tester.pump();
    }

    await type('HOWRAH');
    expect(find.text('হাওড়া'), findsWidgets);
    expect(find.text('কলকাতা'), findsNothing);
    await type('calcutta');
    expect(find.text('কলকাতা'), findsWidgets);
    expect(find.text('হাওড়া'), findsNothing);
    await type('শিলিগুড়ি'); // also shown in the field itself
    expect(
      find.text('দার্জিলিং'),
      findsOneWidget,
      reason: 'its row, by district',
    );
    expect(find.text('কলকাতা'), findsNothing);
    await type('zzz');
    expect(find.text('এই নামে কোনো শহর পাওয়া যায়নি'), findsOneWidget);
  });

  testWidgets('choosing a city: back on Today, toast, recent list', (
    tester,
  ) async {
    await openPicker(tester, language: 'en');
    await tester.tap(find.text('Howrah').first);
    await tester.pumpAndSettle();
    expect(find.byType(CityPickerScreen), findsNothing);
    expect(
      find.text(
        'Sunrise and Rahu Kaal times changed; tithi and festival dates stay the same',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(CityChip, 'Howrah'), findsOneWidget);
    expect(settings.read(SettingKey.cityId), 'howrah');
    expect(settings.read(SettingKey.recentCities), 'howrah');

    await tester.tap(find.byType(CityChip));
    await tester.pumpAndSettle();
    expect(find.text('Recent'), findsOneWidget);
  });

  testWidgets('choosing the current city changes nothing and shows no toast', (
    tester,
  ) async {
    await openPicker(tester, language: 'en');
    await tester.tap(find.text('Kolkata').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Sunrise and Rahu Kaal'), findsNothing);
  });

  for (final language in ['bn', 'en']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in [1.0, 2.0]) {
        final id = 'city_${language}_${theme.name}_${(scale * 100).round()}';
        testWidgets('golden $id', (tester) async {
          await openPicker(
            tester,
            language: language,
            theme: theme,
            textScale: scale,
            size: Size(360, scale > 1.5 ? 1000 : 640),
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
