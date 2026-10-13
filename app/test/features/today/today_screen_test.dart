// T-112: basic Today screen — both languages, watermark, missing-data state, US-01
// visibility at 130 % text, and goldens (bn/en × light/dark). T-212: live updates.
// Update goldens intentionally with: flutter test --update-goldens test/features/today
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/panjika_app.dart';
import 'package:panjika/app/widgets/panjika_widgets.dart';
import 'package:panjika/app/widgets/system_states.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/core/time/clock.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/data/packs/manifest.dart';
import 'package:panjika/data/packs/manifest_client.dart';
import 'package:panjika/data/packs/pack_updater.dart';
import 'package:panjika/data/packs/update_providers.dart';
import 'package:panjika/data/repositories/panjika_repository.dart';
import 'package:panjika/domain/engine/day_assembler.dart';
import 'package:panjika/domain/usecases/get_day_panjika.dart';
import 'package:panjika/app/widgets/tithi_seal.dart';
import 'package:panjika/features/day/day_screen.dart';
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
    String? cachedManifest,
    UpdateResult? update,
    MemorySettings? settings,
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
            settings ??
                MemorySettings({
                  SettingKey.onboardingDone: '1',
                  SettingKey.theme: theme.name,
                  SettingKey.lastManifest: ?cachedManifest,
                }),
          ),
          appLocaleChannelProvider.overrideWithValue(FakeAppLocaleChannel()),
          clockProvider.overrideWithValue(clock ?? () => now ?? sampleNow),
          if (update != null)
            updateControllerProvider.overrideWith(() => _FixedUpdate(update)),
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
    final footer = find.text('Bishuddha Siddhanta (Drik) · Kolkata · IST');
    await tester.scrollUntilVisible(
      footer,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(footer, findsOneWidget);
  });

  void expectNoNumbers(WidgetTester tester) {
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
  }

  /// A cached manifest (test input, shape per spec §15.3) offering [packs].
  String manifestOffering(
    List<(String id, String kind, int version, String from, String to)> packs, {
    List<Map<String, String>> notices = const [],
  }) => jsonEncode({
    'schema': 1,
    'generated_at': '2026-10-12T00:00:00Z',
    'min_app_version': '1.0.0',
    'packs': [
      for (final (id, kind, version, from, to) in packs)
        {
          'id': id,
          'kind': kind,
          'tradition': 'drik_bishuddha',
          'version': version,
          'covers': [from, to],
          'url': '/v1/packs/$id.sqlite.gz',
          'size': 1,
          'sha256': '0' * 64,
          'sig_url': '/v1/packs/$id.sqlite.gz.sig',
        },
    ],
    'notices': notices,
  });

  testWidgets(
    'no pack covers the date: "check your phone\'s date", no numbers',
    (tester) async {
      await pump(tester, now: DateTime.utc(2030));
      expect(find.text('ফোনের তারিখ ঠিক আছে কিনা দেখুন'), findsOneWidget);
      expectNoNumbers(tester);
    },
  );

  testWidgets('a pack is offered for the date: "not downloaded" (US-01)', (
    tester,
  ) async {
    await pump(
      tester,
      language: 'en',
      now: DateTime.utc(2030),
      cachedManifest: manifestOffering([
        ('global-drik-2029', 'global', 1, '2029-04-14', '2032-04-13'),
      ]),
    );
    expect(
      find.text("Data for these dates isn't downloaded yet."),
      findsOneWidget,
    );
    expectNoNumbers(tester);
  });

  testWidgets(
    'a newer version is offered: data still shown under the amber banner',
    (tester) async {
      await pump(
        tester,
        cachedManifest: manifestOffering([
          ('sample-global-drik', 'global', 2, '2026-09-01', '2026-12-31'),
        ]),
      );
      expect(find.byType(StaleBanner), findsOneWidget);
      expect(find.text('তথ্য হালনাগাদ প্রয়োজন।'), findsOneWidget);
      expect(find.text('২৫ আশ্বিন ১৪৩৩'), findsOneWidget);
    },
  );

  testWidgets(
    'T-311: a server notice shows in the UI language and stays dismissed',
    (tester) async {
      final settings = MemorySettings({
        SettingKey.onboardingDone: '1',
        SettingKey.lastManifest: manifestOffering(
          const [],
          notices: [
            // Test input, not a real notice.
            {
              'id': 'n1',
              'level': 'info',
              'text_bn': 'নমুনা বিজ্ঞপ্তি',
              'text_en': 'Sample notice',
              'until': '2026-10-31',
            },
          ],
        ),
      });
      await pump(tester, settings: settings);
      expect(find.text('নমুনা বিজ্ঞপ্তি'), findsOneWidget);
      await tester.tap(find.text('বুঝেছি'));
      await tester.pumpAndSettle();
      expect(find.text('নমুনা বিজ্ঞপ্তি'), findsNothing);
      expect(settings.read(SettingKey.dismissedNotices), 'n1');
    },
  );

  testWidgets('T-311: large packs wait for a yes', (tester) async {
    await pump(
      tester,
      language: 'en',
      update: UpdateDone(
        imported: const [],
        waitingForUser: [
          PackOffer(
            ManifestEntry(
              id: 'global-drik-2029',
              kind: 'global',
              tradition: 'drik_bishuddha',
              version: 1,
              coversFrom: const CivilDate(2029, 4, 14),
              coversTo: const CivilDate(2032, 4, 13),
              url: '/v1/packs/x.sqlite.gz',
              size: 5 * 1024 * 1024,
              sha256: '0' * 64,
              sigUrl: '/v1/packs/x.sqlite.gz.sig',
            ),
            OfferAction.ask,
            isUpdate: false,
          ),
        ],
        notices: const [],
      ),
    );
    expect(
      find.text('New data is available (5.0 MB). Download now?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
    expect(find.textContaining('New data is available'), findsNothing);
  });

  testWidgets('T-311: without a pack server there are no download buttons', (
    tester,
  ) async {
    await pump(
      tester,
      language: 'en',
      now: DateTime.utc(2030),
      cachedManifest: manifestOffering([
        ('global-drik-2029', 'global', 1, '2029-04-14', '2032-04-13'),
      ]),
    );
    expect(
      find.text("Data for these dates isn't downloaded yet."),
      findsOneWidget,
    );
    expect(find.text('Download'), findsNothing);
  });

  testWidgets('T-402: periods, today\'s festival and the next three', (
    tester,
  ) async {
    await pump(tester);
    final scrollable = find.byType(Scrollable).first;
    Future<void> see(Finder f) =>
        tester.scrollUntilVisible(f, 200, scrollable: scrollable);
    await see(find.text('রাহুকাল'));
    expect(find.text('অশুভ সময়'), findsOneWidget);
    await see(find.text('দুর্গাষষ্ঠী'));
    await see(find.text('আসছে'));
    // Sample observances after 12 Oct: Maha Saptami (13th), Ashtami, Navami.
    await see(find.text('মহাসপ্তমী'));
    expect(find.text('আগামীকাল'), findsOneWidget);
    await see(find.text('মহানবমী'));
    expect(find.text('বিজয়া দশমী'), findsNothing, reason: 'only three');
  });

  testWidgets('T-402: tapping the tithi seal opens Day detail', (tester) async {
    await pump(tester);
    await tester.tap(find.byType(TithiSeal));
    await tester.pumpAndSettle();
    expect(find.byType(DayScreen), findsOneWidget);
    expect(find.text('দিনের পঞ্জিকা'), findsOneWidget);
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

/// A fixed update result instead of a real check.
class _FixedUpdate extends UpdateController {
  _FixedUpdate(this.initial);
  final UpdateResult initial;

  @override
  UpdateResult? build() => initial;
}
