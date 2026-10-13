// T-406 / T-410: Settings — every control persists and applies at once; tradition
// "coming soon" keeps Drik; a supported change asks first, reloads, reschedules.
// Goldens bn/en × light/dark × 100/200 %. Data: the watermarked sample pack.
// Update goldens intentionally with: flutter test --update-goldens test/features/settings
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
import 'package:panjika/features/settings/tradition.dart';
import 'package:panjika/features/today/today_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  late AppDatabase db;
  late MemorySettings settings;
  var reschedules = 0;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
    reschedules = 0;
  });
  tearDown(() => db.close());

  Future<void> open(
    WidgetTester tester, {
    String language = 'bn',
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
    Size size = const Size(360, 1600),
    Set<String>? traditions,
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
          rescheduleRemindersProvider.overrideWithValue(
            () async => reschedules++,
          ),
          if (traditions != null)
            availableTraditionsProvider.overrideWithValue(traditions),
        ],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
    unawaited(
      GoRouter.of(tester.element(find.byType(TodayScreen))).push('/settings'),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('language, names in both scripts, theme apply at once', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(settings.read(SettingKey.locale), 'en');

    await tester.tap(find.text('Names in both scripts'));
    await tester.pumpAndSettle();
    expect(settings.read(SettingKey.namesBothScripts), '1');

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Settings'))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('time format and numerals; digits in labels follow the setting', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('১২ ঘণ্টা'), findsOneWidget);
    await tester.tap(find.text('২৪ ঘণ্টা'));
    await tester.pumpAndSettle();
    expect(settings.read(SettingKey.timeFormat), '24');
    await tester.tap(find.text('ইংরেজি (123)'));
    await tester.pumpAndSettle();
    expect(settings.read(SettingKey.numerals), 'latn');
    expect(
      find.text('12 ঘণ্টা'),
      findsOneWidget,
      reason: 'Latin digits in a Bengali UI',
    );
  });

  testWidgets('text size slider persists', (tester) async {
    await open(tester);
    await tester.drag(find.byType(Slider), const Offset(120, 0));
    await tester.pumpAndSettle();
    expect(
      double.parse(settings.read(SettingKey.textScale)!),
      greaterThan(1.0),
    );
  });

  testWidgets('Surya Siddhanta is "coming soon" and Drik stays', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('পঞ্জিকার মত'));
    await tester.pumpAndSettle();
    expect(find.text('শীঘ্রই আসছে'), findsOneWidget);
    await tester.tap(find.text('গুপ্তপ্রেস (সূর্যসিদ্ধান্ত)'));
    await tester.pumpAndSettle();
    expect(
      settings.read(SettingKey.tradition),
      isNull,
      reason: 'still the Drik default',
    );
    expect(reschedules, 0);
  });

  testWidgets(
    'a supported change asks; Keep keeps, Change reloads and reschedules',
    (tester) async {
      await open(
        tester,
        language: 'en',
        traditions: {'drik_bishuddha', 'surya_siddhanta'},
      );
      Future<void> pick() async {
        await tester.tap(find.text('Panjika tradition'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Gupta Press (Surya Siddhanta)'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Changing the tradition can change'),
          findsOneWidget,
        );
      }

      await pick();
      await tester.tap(find.text('Keep'));
      await tester.pumpAndSettle();
      expect(settings.read(SettingKey.tradition), isNull);
      await pick();
      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();
      expect(settings.read(SettingKey.tradition), 'surya_siddhanta');
      expect(reschedules, 1);
    },
  );

  testWidgets('city row opens the picker; licences open; data range shown', (
    tester,
  ) async {
    await open(tester, language: 'en');
    expect(find.text('1 September 2026 – 31 December 2026'), findsOneWidget);
    await tester.tap(find.text('City'));
    await tester.pumpAndSettle();
    expect(find.byType(CityPickerScreen), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Licences'));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
  });

  for (final language in ['bn', 'en']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in [1.0, 2.0]) {
        final id =
            'settings_${language}_${theme.name}_${(scale * 100).round()}';
        testWidgets('golden $id', (tester) async {
          await open(
            tester,
            language: language,
            theme: theme,
            textScale: scale,
            size: Size(360, scale > 1.5 ? 2600 : 1500),
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
