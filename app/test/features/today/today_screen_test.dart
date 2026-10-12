// T-112: basic Today screen — both languages, watermark, missing-data state, US-01
// visibility at 130 % text, and goldens (bn/en × light/dark).
// Update goldens intentionally with: flutter test --update-goldens test/features/today
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/app/widgets/panjika_widgets.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/features/today/today_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fonts.dart';

final sampleNow = DateTime.utc(2026, 10, 12, 5, 0); // 10:30 IST, PRD sample day

void main() {
  setUpAll(loadAppFonts);

  late AppDatabase db;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
  });
  tearDown(() => db.close());

  Future<void> pump(
    WidgetTester tester, {
    String language = 'bn',
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
    DateTime? now,
  }) async {
    tester.view
      ..physicalSize = const Size(360, 640) * 2
      ..devicePixelRatio = 2;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          deviceLocalesProvider.overrideWithValue([Locale(language)]),
          settingsSourceProvider.overrideWithValue(
            MemorySettings({SettingKey.theme: theme.name}),
          ),
          appLocaleChannelProvider.overrideWithValue(FakeAppLocaleChannel()),
          clockProvider.overrideWithValue(() => now ?? sampleNow),
        ],
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Bengali: dates, provenance and sample watermark', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('২৫ আশ্বিন ১৪৩৩'), findsOneWidget);
    expect(find.text('১২ অক্টোবর ২০২৬'), findsOneWidget);
    expect(find.text('সোমবার'), findsOneWidget);
    final footer = find.text('বিশুদ্ধ সিদ্ধান্ত (দৃক) · কলকাতা · IST');
    await tester.scrollUntilVisible(
      footer,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(footer, findsOneWidget);
    expect(find.byType(SampleWatermark), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('English: same day, romanised names, Latin numerals', (
    tester,
  ) async {
    await pump(tester, language: 'en');
    expect(find.text('25 Ashwin 1433'), findsOneWidget);
    expect(find.text('12 October 2026'), findsOneWidget);
    expect(find.text('Monday'), findsOneWidget);
    expect(
      find.text('Bishuddha Siddhanta (Drik) · Kolkata · IST'),
      findsOneWidget,
    );
  });

  testWidgets('no data: explicit message and retry, no numbers (US-01)', (
    tester,
  ) async {
    await pump(tester, now: DateTime.utc(2030));
    expect(find.text('আজকের তথ্য পাওয়া যায়নি'), findsOneWidget);
    expect(find.text('আবার চেষ্টা করুন'), findsOneWidget);
    final texts = tester.widgetList<Text>(
      find.descendant(
        of: find.byType(TodayScreen),
        matching: find.byType(Text),
      ),
    );
    for (final t in texts) {
      expect(
        RegExp('[0-9০-৯]').hasMatch(t.data ?? ''),
        isFalse,
        reason: 'no numbers: ${t.data}',
      );
    }
  });

  testWidgets(
    'US-01: at 130 % on 360×640 the tithi seal is visible without scrolling',
    (tester) async {
      for (final language in ['bn', 'en']) {
        await pump(tester, language: language, textScale: 1.3);
        final seal = tester.getRect(find.byType(TithiRing).first);
        final nav = tester.getRect(find.byType(NavigationBar));
        expect(
          seal.bottom,
          lessThan(nav.top),
          reason: '$language: seal above the navigation bar',
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('200 % text: no overflow in either language', (tester) async {
    for (final language in ['bn', 'en']) {
      await pump(tester, language: language, textScale: 2.0);
      expect(tester.takeException(), isNull, reason: language);
    }
  });

  for (final language in ['bn', 'en']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('golden today $language ${theme.name}', (tester) async {
        await pump(tester, language: language, theme: theme);
        await expectLater(
          find.byType(PanjikaApp),
          matchesGoldenFile('goldens/today_${language}_${theme.name}.png'),
        );
      });
    }
  }
}
