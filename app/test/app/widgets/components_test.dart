// T-213: the component kit (spec §12.5). Every component appears on one of three gallery
// pages, rendered as goldens for bn/en × light/dark × 100 %/200 % text, and checked for
// overflow at 100/130/200 %. Data comes from the sample pack or is a synthetic test input.
// Update goldens intentionally with: flutter test --update-goldens test/app/widgets
import 'dart:ui' show Tristate;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/theme/tokens.dart';
import 'package:panjika/app/widgets/calendar_day_cell.dart';
import 'package:panjika/app/widgets/date_header.dart';
import 'package:panjika/app/widgets/glossary.dart';
import 'package:panjika/app/widgets/language_switch.dart';
import 'package:panjika/app/widgets/name_text.dart';
import 'package:panjika/app/widgets/observance_widgets.dart';
import 'package:panjika/app/widgets/panjika_widgets.dart';
import 'package:panjika/app/widgets/period_row.dart';
import 'package:panjika/app/widgets/tithi_seal.dart';
import 'package:panjika/core/l10n/app_language.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/data/repositories/panjika_repository.dart';
import 'package:panjika/domain/engine/day_assembler.dart';
import 'package:panjika/domain/entities/name_table.dart';
import 'package:panjika/domain/entities/panjika.dart';
import 'package:panjika/domain/entities/terms.dart';
import 'package:panjika/domain/usecases/get_day_panjika.dart';
import 'package:panjika/domain/usecases/get_month_grid.dart';
import 'package:panjika/l10n/gen/app_localizations.dart';

import '../../helpers/fonts.dart';
import '../../helpers/harness.dart';

const drik = 'drik_bishuddha';
const sampleDate = CivilDate(2026, 10, 12);

late AppDatabase db;
late NameTable names;
late DayPanjika day;
late MonthGrid october;
late List<ObservanceDate> observances;

/// Synthetic period times (test inputs, not calendar data).
final periodStart = DateTime.utc(2026, 10, 12, 3);
final periodEnd = DateTime.utc(2026, 10, 12, 4, 30);

class _TodayPage extends ConsumerWidget {
  const _TodayPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatterProvider);
    final language = ref.watch(appLanguageProvider);
    final tithi = day.udayaTithi;
    final at = tithi.startUtc.add(
      tithi.endUtc.difference(tithi.startUtc) * 0.4,
    );
    return _Page(
      children: [
        DateHeader(
          date: day.date,
          bengaliDay: day.bengaliDate.day,
          bengaliMonth: day.bengaliMonth,
          bengaliYear: day.bengaliDate.year,
          city: day.provenance.city,
          onCityTap: () {},
        ),
        TithiSeal(
          name: tithi.name,
          nameText: tithi.name.of(language),
          until: l.untilTime(f.time(tithi.endUtc)),
          then: l.thenName(tithi.next.of(language)),
          progress: tithi.progressAt(at),
          notes: [
            l.termWithName(
              names.of('term', Term.kshayaTithi.index).of(language),
              tithi.next.of(language),
            ),
          ],
        ),
        for (final kind in [TransitionKind.nakshatra, TransitionKind.karana])
          PanchangRow(
            label: kind == TransitionKind.nakshatra
                ? l.labelNakshatra
                : l.labelKarana,
            value: NameText(day.currentOf(kind, at).name),
          ),
        TimingStrip(
          cells: [
            TimingCell(
              icon: Icons.wb_twilight,
              label: l.labelSunrise,
              time: f.time(day.sun.sunrise),
            ),
            TimingCell(
              icon: Icons.nightlight_outlined,
              label: l.labelMoonrise,
              time: l.timeNone,
            ),
          ],
        ),
        ProvenanceFooter(provenance: day.provenance),
      ],
    );
  }
}

class _ListsPage extends StatelessWidget {
  const _ListsPage();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _Page(
      children: [
        SectionHeader(title: l.periodAshubh),
        PeriodRow(
          name: names.of('period', 0),
          kind: PeriodKind.ashubh,
          start: periodStart,
          end: periodEnd,
          active: true,
        ),
        PeriodRow(
          name: names.of('period', 1),
          kind: PeriodKind.ashubh,
          start: periodEnd,
          end: periodEnd.add(const Duration(minutes: 90)),
        ),
        SectionHeader(title: l.periodShubh),
        PeriodRow(
          name: names.of('period', 6),
          kind: PeriodKind.shubh,
          start: periodStart,
          end: periodEnd,
          active: true,
        ),
        Wrap(
          spacing: Space.s,
          runSpacing: Space.s,
          children: [
            for (final o in observances.take(2)) ObservanceChip(observance: o),
          ],
        ),
        FestivalCard(observance: observances[1], daysLeft: 1),
        for (final s in VerificationStatus.values)
          VerificationBadge(s, showLabel: true),
      ],
    );
  }
}

class _CalendarPage extends ConsumerWidget {
  const _CalendarPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatterProvider);
    final language = ref.watch(appLanguageProvider);
    // The sample day's week, Sunday first.
    final i = october.days.indexWhere((d) => d.date == sampleDate);
    final week = october.days.sublist(i - 1, i + 6);
    // Show every marker shape once, whatever the sample week's tithis are.
    final shapes = [
      {MoonMarker.purnima},
      {MoonMarker.amavasya},
      {MoonMarker.ekadashi},
    ];
    return _Page(
      // The grid's narrower margin keeps seven cells at 48 dp on a 360 dp phone.
      horizontal: CalendarDayCell.gridMargin,
      children: [
        Row(
          children: [
            for (final (n, d) in week.indexed)
              Expanded(
                child: CalendarDayCell(
                  primaryDay: d.bengaliDate.day,
                  secondaryDay: d.date.day,
                  markers: n < 3 ? shapes[n] : d.markers,
                  festivalCategory:
                      d.observances.firstOrNull?.observance.category,
                  isToday: d.date == sampleDate,
                  isSelected: d.date == sampleDate.addDays(2),
                  isSunday: d.weekday == Weekday.sunday,
                  semanticsLabel: l.calendarCellSemantics(
                    f.bengaliDate(
                      d.bengaliDate.day,
                      october.monthName.of(language),
                      d.bengaliDate.year,
                    ),
                    f.gregorianDate(d.date),
                    d.udayaTithi.of(language),
                  ),
                  onTap: () {},
                ),
              ),
          ],
        ),
        const Center(child: LanguageSwitch()),
        GlossaryTerm(
          term: Term.tithi,
          child: NameText(names.of('term', Term.tithi.index)),
        ),
        CityChip(city: day.provenance.city, onTap: () {}),
        Skeleton.text(style: Theme.of(context).textTheme.bodyLarge, lines: 2),
        const Skeleton.box(width: 120, height: 48),
        StateMessage(
          kind: StateKind.notDownloaded,
          message: l.stateNotDownloaded,
          actionLabel: l.actionDownload,
          onAction: () {},
        ),
      ],
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.children, this.horizontal = Space.l});

  final List<Widget> children;
  final double horizontal;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: Space.l),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final c in children) ...[c, const SizedBox(height: Space.m)],
      ],
    ),
  );
}

const pages = {
  'today': _TodayPage(),
  'lists': _ListsPage(),
  'calendar': _CalendarPage(),
};

/// Tall enough for each page at each scale, so the golden shows everything.
Size pageSize(double scale) => Size(360, scale > 1.5 ? 2000 : 1100);

void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
    final repo = DriftPanjikaRepository(db);
    names = await repo.names();
    day = (await GetDayPanjika(repo, repo)(
      date: sampleDate,
      tradition: drik,
      cityId: 'kolkata',
    ))!;
    october = (await GetMonthGrid(repo, repo)(
      month: const GregorianMonthRef(2026, 10),
      tradition: drik,
      cityId: 'kolkata',
    ))!;
    observances = await repo.observances(
      drik,
      sampleDate,
      const CivilDate(2026, 12, 31),
    );
  });
  tearDown(() => db.close());

  group('goldens', () {
    for (final MapEntry(key: name, value: page) in pages.entries) {
      for (final language in AppLanguage.values) {
        for (final brightness in Brightness.values) {
          for (final scale in [1.0, 2.0]) {
            final id =
                '${name}_${language.name}_${brightness.name}_${(scale * 100).round()}';
            testWidgets('components $id', (tester) async {
              await pumpComponent(
                tester,
                SingleChildScrollView(child: page),
                db: db,
                language: language,
                brightness: brightness,
                textScale: scale,
                size: pageSize(scale),
              );
              expect(tester.takeException(), isNull);
              await expectLater(
                find.byType(MaterialApp),
                matchesGoldenFile('goldens/$id.png'),
              );
            });
          }
        }
      }
    }
  });

  testWidgets('no overflow at 100, 130 and 200 % in either language', (
    tester,
  ) async {
    for (final page in pages.values) {
      for (final language in AppLanguage.values) {
        for (final scale in [1.0, 1.3, 2.0]) {
          await pumpComponent(
            tester,
            SingleChildScrollView(child: page),
            db: db,
            language: language,
            textScale: scale,
            size: pageSize(scale),
          );
          expect(tester.takeException(), isNull, reason: '$language $scale');
        }
      }
    }
  });

  testWidgets(
    'PeriodRow: the running period says so in text, not colour only',
    (tester) async {
      final handle = tester.ensureSemantics();
      await pumpComponent(
        tester,
        const SingleChildScrollView(child: _ListsPage()),
        db: db,
      );
      expect(find.text('এখন'), findsNWidgets(2));
      expect(
        find.bySemanticsLabel(RegExp(r'^রাহুকাল, .*, এখন চলছে$')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp(r'^যমগণ্ড, [^,]*$')), findsOneWidget);
      handle.dispose();
    },
  );

  testWidgets('VerificationBadge: every status has a spoken label', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpComponent(
      tester,
      Column(
        children: [
          for (final s in VerificationStatus.values) VerificationBadge(s),
        ],
      ),
      db: db,
      language: AppLanguage.en,
    );
    for (final label in [
      'Sample data',
      'Calculated, not yet checked',
      'Checked against the panjika',
      'Reviewed by an expert',
    ]) {
      expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
    }
    handle.dispose();
  });

  testWidgets(
    'CalendarDayCell: at least 48×56, selected state and label exposed',
    (tester) async {
      final handle = tester.ensureSemantics();
      await pumpComponent(
        tester,
        const SingleChildScrollView(child: _CalendarPage()),
        db: db,
      );
      for (final cell in tester.widgetList(find.byType(CalendarDayCell))) {
        final size = tester.getSize(find.byWidget(cell));
        expect(size.width, greaterThanOrEqualTo(CalendarDayCell.minWidth));
        expect(size.height, greaterThanOrEqualTo(CalendarDayCell.minHeight));
      }
      final selected = tester.getSemantics(find.byType(CalendarDayCell).at(3));
      expect(selected.flagsCollection.isSelected, Tristate.isTrue);
      expect(selected.label, contains('অক্টোবর'));
      expect(find.byType(MoonMarkerGlyph), findsAtLeastNWidgets(3));
      handle.dispose();
    },
  );

  testWidgets('LanguageSwitch: labels in their own script; tapping switches', (
    tester,
  ) async {
    final container = await pumpComponent(
      tester,
      const Center(child: LanguageSwitch()),
      db: db,
    );
    expect(find.text('বাংলা'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(container.read(appLanguageProvider), AppLanguage.en);
    expect(find.text('বাংলা'), findsOneWidget, reason: 'never translated');
  });

  testWidgets('GlossaryTerm: (i) and long-press open the entry', (
    tester,
  ) async {
    await pumpComponent(
      tester,
      Center(
        child: GlossaryTerm(
          term: Term.tithi,
          child: NameText(names.of('term', Term.tithi.index)),
        ),
      ),
      db: db,
      language: AppLanguage.en,
    );
    final gloss = names.glossOf('term', Term.tithi.index)!;
    await tester.tap(find.byTooltip('What does this mean?'));
    await tester.pumpAndSettle();
    expect(find.text(gloss.en), findsOneWidget);
    expect(
      find.text('তিথি'),
      findsOneWidget,
      reason: 'both scripts in the entry',
    );
    Navigator.of(tester.element(find.text(gloss.en))).pop();
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Tithi'));
    await tester.pumpAndSettle();
    expect(find.text(gloss.en), findsOneWidget);
  });

  testWidgets('SectionHeader is a heading; Skeleton is announced as loading', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpComponent(
      tester,
      const Column(
        children: [
          SectionHeader(title: 'x'), // l10n-ok: test input
          Skeleton.box(width: 40, height: 20),
        ],
      ),
      db: db,
    );
    expect(
      tester.getSemantics(find.text('x')).flagsCollection.isHeader,
      isTrue,
    );
    expect(find.bySemanticsLabel('লোড হচ্ছে'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('CityChip: tells screen readers how to change the city', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var tapped = false;
    await pumpComponent(
      tester,
      Center(
        child: CityChip(city: day.provenance.city, onTap: () => tapped = true),
      ),
      db: db,
      language: AppLanguage.en,
    );
    expect(
      find.bySemanticsLabel('City: Kolkata. Tap to change'),
      findsOneWidget,
    );
    await tester.tap(find.text('Kolkata'));
    expect(tapped, isTrue);
    handle.dispose();
  });
}
