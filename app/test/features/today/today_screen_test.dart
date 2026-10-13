// T-112: basic Today screen — both languages, watermark, missing-data state, US-01
// visibility at 130 % text, and goldens (bn/en × light/dark). T-212: live updates.
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
import 'package:panjika/data/repositories/panjika_repository.dart';
import 'package:panjika/domain/engine/day_assembler.dart';
import 'package:panjika/domain/usecases/get_day_panjika.dart';
import 'package:panjika/features/today/today_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fonts.dart';

final sampleNow = DateTime.utc(2026, 10, 12, 5, 0); // 10:30 IST, PRD sample day

void main() {
  setUpAll(loadAppFonts);

  late AppDatabase db;
  late DayPanjika sampleDay;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
    final repo = DriftPanjikaRepository(db);
    sampleDay = (await GetDayPanjika(
      repo,
      repo,
    ).containing(sampleNow, tradition: 'drik_bishuddha', cityId: 'kolkata'))!;
  });
  tearDown(() => db.close());

  Future<void> pump(
    WidgetTester tester, {
    String language = 'bn',
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
    DateTime? now,
    DateTime Function()? clock,
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
          clockProvider.overrideWithValue(clock ?? () => now ?? sampleNow),
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

  testWidgets('T-212: the tithi changes exactly at its end', (tester) async {
    final ending = sampleDay.tithis
        .map((t) => t.span)
        .firstWhere((s) => s.endUtc.isBefore(sampleDay.nextSunrise));
    final following = sampleDay.nextAfter(ending)!;
    var now = ending.endUtc.subtract(const Duration(seconds: 30));
    await pump(tester, language: 'en', clock: () => now);
    expect(find.text(ending.name.en), findsOneWidget);

    now = ending.endUtc.subtract(const Duration(milliseconds: 1));
    await tester.pump(
      const Duration(seconds: 30) - const Duration(milliseconds: 1),
    );
    expect(find.text(ending.name.en), findsOneWidget, reason: 'not yet');

    now = ending.endUtc;
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text(following.name.en), findsOneWidget);
    // The old name cross-fades out over 250 ms (spec §12.8).
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(ending.name.en), findsNothing);
  });

  testWidgets('T-212: the day rolls over at sunrise', (tester) async {
    var now = sampleDay.nextSunrise.subtract(const Duration(seconds: 10));
    await pump(tester, language: 'en', clock: () => now);
    expect(
      find.text('25 Ashwin 1433'),
      findsOneWidget,
      reason: 'before sunrise',
    );

    now = sampleDay.nextSunrise;
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
    expect(find.text('26 Ashwin 1433'), findsOneWidget);
    expect(find.text('13 October 2026'), findsOneWidget);
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
