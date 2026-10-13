// T-513: share sheet (বাংলা / English / দুই ভাষায় · Both, default = UI language) and
// card layouts for a festival and a day. Card goldens are full-size (1080 × 1350) in
// each share language with the longest festival name in the catalogue; sheet
// goldens bn/en × light/dark × 100/200 %. Data: the watermarked sample pack.
// Update goldens intentionally with: flutter test --update-goldens test/features/share
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/data/repositories/panjika_providers.dart';
import 'package:panjika/domain/engine/day_assembler.dart';
import 'package:panjika/domain/entities/name_ref.dart';
import 'package:panjika/domain/entities/name_table.dart';
import 'package:panjika/domain/entities/panjika.dart';
import 'package:panjika/features/share/share_cards.dart';
import 'package:panjika/features/share/share_render.dart';
import 'package:panjika/features/today/today_screen.dart';
import 'package:panjika/l10n/gen/app_localizations.dart';

import '../../helpers/fakes.dart';
import '../../helpers/fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  late AppDatabase db;
  late FakeSharer sharer;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
    sharer = FakeSharer();
  });
  tearDown(() => db.close());

  List<Override> overrides(
    String language, {
    ThemeMode theme = ThemeMode.light,
  }) => [
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
    sharerProvider.overrideWithValue(sharer),
  ];

  Future<void> openApp(
    WidgetTester tester,
    String location, {
    String language = 'bn',
    ThemeMode theme = ThemeMode.light,
    double textScale = 1.0,
    Size size = const Size(360, 1200),
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
        overrides: overrides(language, theme: theme),
        child: const PanjikaApp(),
      ),
    );
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(TodayScreen))).go(location);
    await tester.pumpAndSettle();
  }

  Future<void> tapShareAndWait(WidgetTester tester, Finder button) async {
    await tester.runAsync(() async {
      await tester.tap(button);
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();
  }

  testWidgets('festival: the sheet defaults to the UI language; Both shares a '
      '1080 × 1350 card and a message in both languages', (tester) async {
    await openApp(tester, '/festival/kali_puja?date=2026-11-08');
    await tester.tap(find.widgetWithText(OutlinedButton, 'শেয়ার করুন'));
    await tester.pumpAndSettle();
    expect(find.text('শেয়ার কার্ড'), findsOneWidget);
    final segmented = tester.widget<SegmentedButton<ShareLanguage>>(
      find.byType(SegmentedButton<ShareLanguage>),
    );
    expect(segmented.selected, {ShareLanguage.bn});
    await tester.tap(find.textContaining('দুই ভাষায়', findRichText: true));
    await tester.pumpAndSettle();
    await tapShareAndWait(
      tester,
      find.widgetWithText(FilledButton, 'শেয়ার করুন'),
    );

    final sent = sharer.shared.single;
    expect(sent.fileName, 'kali_puja-2026-11-08.png');
    expect(sent.text, contains('কালীপূজা'));
    expect(sent.text, contains('Kali Puja'));
    expect(sent.text, contains('বিশুদ্ধ সিদ্ধান্ত (দৃক) মতে'));
    expect(sent.text, contains('As per Bishuddha Siddhanta (Drik)'));
    expect(sent.text, isNot(contains('http')), reason: 'no share domain yet');
    final size = await tester.runAsync(() async {
      final frame = await (await ui.instantiateImageCodec(sent.png))
          .getNextFrame();
      return Size(frame.image.width.toDouble(), frame.image.height.toDouble());
    });
    expect(size, shareCardSize);
  });

  testWidgets('day: the share action shares the day with city and IST', (
    tester,
  ) async {
    await openApp(tester, '/day/2026-10-12', language: 'en');
    await tester.tap(find.byTooltip('Share'));
    await tester.pumpAndSettle();
    await tapShareAndWait(tester, find.widgetWithText(FilledButton, 'Share'));
    final sent = sharer.shared.single;
    expect(sent.fileName, 'panjika-2026-10-12.png');
    expect(sent.text, contains('25 Ashwin 1433'));
    expect(sent.text, contains('Kolkata · IST'));
  });

  // Full-size card goldens: the longest festival name in the catalogue (sample data,
  // so the watermark shows) and a sample day.
  Future<void> pumpCard(
    WidgetTester tester,
    Widget card,
    String language,
  ) async {
    tester.view
      ..physicalSize = shareCardSize
      ..devicePixelRatio = shareCardPixelRatio;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(language),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('bn'), Locale('en')],
          home: card,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<({NameTable names, BengaliDate bn, DayPanjika day})> sample(
    WidgetTester tester,
  ) async => (await tester.runAsync(() async {
    final c = ProviderContainer(overrides: overrides('bn'));
    addTearDown(c.dispose);
    final repo = c.read(panjikaRepositoryProvider);
    return (
      names: await repo.names(),
      bn: (await repo.bengaliDate(
        'drik_bishuddha',
        const CivilDate(2026, 10, 20),
      ))!,
      day: (await c.read(
        dayPanjikaProvider(const CivilDate(2026, 10, 12)).future,
      ))!,
    );
  }))!;

  for (final share in ShareLanguage.values) {
    testWidgets('golden share_festival_${share.name}', (tester) async {
      final s = await sample(tester);
      // The longest name in the catalogue (data/observances), on a sample date.
      final data = FestivalShareData(
        id: 'kojagari_lakshmi_puja',
        name: const NameRef('কোজাগরী লক্ষ্মীপূজা', 'Kojagari Lakshmi Puja'),
        category: ObservanceCategory.puja,
        date: const CivilDate(2026, 10, 20),
        bengaliDate: s.bn,
        names: s.names,
        tradition: s.day.provenance.tradition,
        isSample: true,
      );
      await pumpCard(
        tester,
        ShareCardFrame(
          language: share.primary,
          child: FestivalShareCard(data: data, share: share),
        ),
        share.primary.name,
      );
      await expectLater(
        find.byType(ShareCardFrame),
        matchesGoldenFile('goldens/share_festival_${share.name}.png'),
      );
    });

    testWidgets('golden share_day_${share.name}', (tester) async {
      final s = await sample(tester);
      final data = DayShareData(day: s.day, names: s.names);
      await pumpCard(
        tester,
        ShareCardFrame(
          language: share.primary,
          child: DayShareCard(data: data, share: share),
        ),
        share.primary.name,
      );
      await expectLater(
        find.byType(ShareCardFrame),
        matchesGoldenFile('goldens/share_day_${share.name}.png'),
      );
    });
  }

  for (final language in ['bn', 'en']) {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in [1.0, 2.0]) {
        final id =
            'share_sheet_${language}_${theme.name}_${(scale * 100).round()}';
        testWidgets('golden $id', (tester) async {
          await openApp(
            tester,
            '/festival/kali_puja?date=2026-11-08',
            language: language,
            theme: theme,
            textScale: scale,
            size: Size(360, scale > 1.5 ? 1600 : 1000),
          );
          await tester.tap(find.byIcon(Icons.share));
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
