import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/widgets/calendar_day_cell.dart';
import '../../app/widgets/name_text.dart';
import '../../app/widgets/observance_widgets.dart';
import '../../app/widgets/panjika_widgets.dart';
import '../../app/widgets/system_states.dart';
import '../../core/l10n/app_language.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../core/l10n/panjika_formatter.dart';
import '../../core/time/civil_date.dart';
import '../../core/time/clock.dart';
import '../../data/packs/update_providers.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/entities/name_table.dart';
import '../../domain/entities/panjika.dart';
import '../../domain/usecases/get_month_grid.dart';
import '../../l10n/gen/app_localizations.dart';
import 'calendar_controller.dart';

/// Calendar (পঞ্জিকা, spec §11.3, FR-CAL-01..07): Bengali or Gregorian month grid with
/// both day numbers, moon markers by shape, festival bars, swipe or arrows, a month
/// chooser on the title, a legend, a peek on long-press and the selected-day strip.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(calendarProvider);
    final calendar = ref.read(calendarProvider.notifier);
    final names = ref.watch(namesProvider).value;
    final month = state.month;
    final grid = month == null ? null : ref.watch(monthGridProvider(month));

    // Wide screens: the calendar is centred and its cells grow up to the content
    // width (§12.10). Landscape phones keep the full width for the grid + strip.
    final landscape = isShortLandscape(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: landscape
                  ? double.infinity
                  : Space.maxContentWidth + 2 * CalendarDayCell.gridMargin,
            ),
            child: Column(
              children: [
                _Header(state: state, names: names, grid: grid?.value),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CalendarDayCell.gridMargin,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<CalendarMode>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: CalendarMode.bengali,
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(l.calendarModeBengali),
                              ),
                            ),
                            ButtonSegment(
                              value: CalendarMode.gregorian,
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(l.calendarModeGregorian),
                              ),
                            ),
                          ],
                          selected: {state.mode},
                          onSelectionChanged: (s) => calendar.setMode(s.single),
                        ),
                      ),
                      IconButton(
                        tooltip: l.legendTitle,
                        icon: const Icon(Icons.info_outline),
                        onPressed: names == null
                            ? null
                            : () => _showLegend(context, names),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Space.s),
                Expanded(
                  child: GestureDetector(
                    // Swipe for the next or previous month (FR-CAL-03).
                    onHorizontalDragEnd: (d) {
                      final v = d.primaryVelocity ?? 0;
                      if (v < -200) calendar.next();
                      if (v > 200) calendar.previous();
                    },
                    child: state.resolving
                        ? const SizedBox.expand()
                        : switch (grid) {
                            AsyncValue(value: final g?) => _MonthBody(
                              grid: g,
                              state: state,
                            ),
                            AsyncValue(isLoading: true) =>
                              const SizedBox.expand(),
                            // Outside the installed packs (or the month lookup found none).
                            _ => _notDownloaded(ref),
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _notDownloaded(WidgetRef ref) {
    final updates = ref.read(updateControllerProvider.notifier);
    return SystemStateMessage(
      SystemState.notDownloaded,
      onAction: updates.available ? updates.downloadNow : null,
    );
  }
}

String _monthTitle(
  AppLocalizations l,
  PanjikaFormatter f,
  AppLanguage language,
  NameTable names,
  MonthRef month,
) => switch (month) {
  BengaliMonthRef(:final year, :final monthIdx) => l.monthTitle(
    names.of('solar_month', monthIdx).of(language),
    f.digits('$year'),
  ),
  GregorianMonthRef(:final year, month: final m) => l.monthTitle(
    names.of('gregorian_month', m - 1).of(language),
    f.digits('$year'),
  ),
};

class _Header extends ConsumerWidget {
  const _Header({required this.state, required this.names, required this.grid});

  final CalendarState state;
  final NameTable? names;
  final MonthGrid? grid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatterProvider);
    final language = ref.watch(appLanguageProvider);
    final calendar = ref.read(calendarProvider.notifier);
    final t = Theme.of(context).textTheme;
    final month = state.month;
    final title = month == null || names == null
        ? ''
        : _monthTitle(l, f, language, names!, month);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.xs),
      child: Row(
        children: [
          IconButton(
            tooltip: l.previousMonth,
            icon: const Icon(Icons.chevron_left),
            onPressed: month == null ? null : calendar.previous,
          ),
          Expanded(
            child: Semantics(
              button: true,
              hint: l.chooseMonth,
              child: TextButton(
                onPressed: month == null || names == null
                    ? null
                    : () => _showJumpSheet(context, ref, month, names!),
                // The title slides with the month; a new year rolls in (§11.3).
                child: AnimatedSwitcher(
                  duration: context.motion(Motion.standard),
                  transitionBuilder: (child, a) => FadeTransition(
                    opacity: a,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.4),
                        end: Offset.zero,
                      ).animate(a),
                      child: child,
                    ),
                  ),
                  child: Text(
                    title,
                    key: ValueKey(title),
                    style: t.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: l.nextMonth,
            icon: const Icon(Icons.chevron_right),
            onPressed: month == null ? null : calendar.next,
          ),
          TextButton(onPressed: calendar.goToday, child: Text(l.labelToday)),
        ],
      ),
    );
  }
}

class _MonthBody extends ConsumerWidget {
  const _MonthBody({required this.grid, required this.state});

  final MonthGrid grid;
  final CalendarState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dir = state.direction.toDouble();
    const padding = EdgeInsets.symmetric(
      horizontal: CalendarDayCell.gridMargin,
    );
    final strip = _SelectedStrip(grid: grid, selected: state.selected);
    final footer = ProvenanceFooter(provenance: grid.provenance);
    // A short (landscape) screen puts the selected day beside the grid (§12.10).
    if (isShortLandscape(context)) {
      return Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ListView(
                  padding: padding,
                  children: [
                    _WeekdayHeads(),
                    _MonthGridView(
                      key: ValueKey(grid.month),
                      grid: grid,
                      state: state,
                    ),
                    footer,
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: ListView(padding: padding, children: [strip]),
              ),
            ],
          ),
          if (grid.provenance.isSample) const SampleWatermark(),
        ],
      );
    }
    return Stack(
      children: [
        ListView(
          padding: padding,
          children: [
            _WeekdayHeads(),
            // Month changes slide horizontally (shared axis, §12.8).
            AnimatedSwitcher(
              duration: context.motion(Motion.standard),
              transitionBuilder: (child, a) => FadeTransition(
                opacity: a,
                child: SlideTransition(
                  position: Tween(
                    begin: Offset(0.15 * dir, 0),
                    end: Offset.zero,
                  ).animate(a),
                  child: child,
                ),
              ),
              child: _MonthGridView(
                key: ValueKey(grid.month),
                grid: grid,
                state: state,
              ),
            ),
            const SizedBox(height: Space.m),
            strip,
            footer,
          ],
        ),
        if (grid.provenance.isSample) const SampleWatermark(),
      ],
    );
  }
}

class _WeekdayHeads extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(formatterProvider);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.xs),
                // At large text a seventh of the width is too narrow for "Wed":
                // shrink the head to fit rather than break the word (§12.11).
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    f.weekdayShort(i),
                    textAlign: TextAlign.center,
                    style: t.labelMedium?.copyWith(
                      color: i == 0 ? c.alta : c.inkMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MonthGridView extends ConsumerWidget {
  const _MonthGridView({super.key, required this.grid, required this.state});

  final MonthGrid grid;
  final CalendarState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatterProvider);
    final language = ref.watch(appLanguageProvider);
    final today = ref.watch(nowProvider.select(CivilDate.ofInstant));
    final calendar = ref.read(calendarProvider.notifier);
    final bengaliMode = state.mode == CalendarMode.bengali;
    final names = ref.watch(namesProvider).value;

    Widget cell(MonthGridDay d) {
      final month =
          names?.of('solar_month', d.bengaliDate.monthIdx).of(language) ?? '';
      final bnDate = f.bengaliDate(
        d.bengaliDate.day,
        month,
        d.bengaliDate.year,
      );
      final festival = d.observances.firstOrNull;
      final label = festival == null
          ? l.calendarCellSemantics(
              bnDate,
              f.gregorianDate(d.date),
              d.udayaTithi.of(language),
            )
          : l.calendarCellWithFestival(
              bnDate,
              f.gregorianDate(d.date),
              d.udayaTithi.of(language),
              festival.observance.name.of(language),
            );
      final selected = d.date == state.selected;
      return CalendarDayCell(
        primaryDay: bengaliMode ? d.bengaliDate.day : d.date.day,
        secondaryDay: bengaliMode ? d.date.day : d.bengaliDate.day,
        semanticsLabel: d.date == today ? l.todayPrefix(label) : label,
        markers: d.markers,
        festivalCategory: festival?.observance.category,
        isToday: d.date == today,
        isSelected: selected,
        isSunday: d.weekday == Weekday.sunday,
        // Tap selects; tapping the selected day opens it (spec §11.3 strip, FR-CAL-05).
        onTap: () => selected
            ? context.push(Routes.day(d.date))
            : calendar.select(d.date),
        onLongPress: () => _showPeek(context, d),
      );
    }

    final cells = <Widget>[
      for (var i = 0; i < grid.leadingBlanks; i++) const SizedBox.shrink(),
      for (final d in grid.days) cell(d),
    ];
    while (cells.length % 7 != 0) {
      cells.add(const SizedBox.shrink());
    }
    return Column(
      children: [
        for (var row = 0; row < cells.length ~/ 7; row++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final c in cells.sublist(row * 7, row * 7 + 7))
                Expanded(child: c),
            ],
          ),
      ],
    );
  }
}

class _SelectedStrip extends ConsumerWidget {
  const _SelectedStrip({required this.grid, required this.selected});

  final MonthGrid grid;
  final CivilDate selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = grid.days.where((d) => d.date == selected).firstOrNull;
    if (day == null) return const SizedBox.shrink();
    return _DaySummary(day: day);
  }
}

/// Bengali date, tithi and festivals of a day, with "দেখুন" (strip and peek sheet).
class _DaySummary extends ConsumerWidget {
  const _DaySummary({required this.day, this.inSheet = false});

  final MonthGridDay day;
  final bool inSheet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatterProvider);
    final language = ref.watch(appLanguageProvider);
    final names = ref.watch(namesProvider).value;
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final month =
        names?.of('solar_month', day.bengaliDate.monthIdx).of(language) ?? '';
    return Container(
      padding: const EdgeInsets.all(Space.l),
      decoration: BoxDecoration(
        color: inSheet ? null : c.paperRaised,
        borderRadius: BorderRadius.circular(Radii.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.selectedDay(
              f.bengaliDate(day.bengaliDate.day, month, day.bengaliDate.year),
            ),
            style: t.titleMedium,
          ),
          Text(
            f.gregorianDate(day.date),
            style: t.bodyMedium?.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: Space.xs),
          NameText(day.udayaTithi, style: t.bodyLarge),
          if (day.observances.isNotEmpty) ...[
            const SizedBox(height: Space.s),
            Wrap(
              spacing: Space.s,
              runSpacing: Space.s,
              children: [
                for (final o in day.observances) ObservanceChip(observance: o),
              ],
            ),
          ],
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () {
                if (inSheet) Navigator.of(context).pop();
                context.push(Routes.day(day.date));
              },
              child: Text(l.actionView),
            ),
          ),
        ],
      ),
    );
  }
}

void _showPeek(BuildContext context, MonthGridDay day) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(child: _DaySummary(day: day, inSheet: true)),
    );

void _showLegend(BuildContext context, NameTable names) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final l = AppLocalizations.of(context);
          final language = ref.watch(appLanguageProvider);
          final c = context.colors;
          final t = Theme.of(context).textTheme;
          Widget row(Widget mark, String label) => ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Space.minTouch),
            child: Row(
              children: [
                SizedBox(width: 40, child: Center(child: mark)),
                const SizedBox(width: Space.m),
                Expanded(child: Text(label, style: t.bodyLarge)),
              ],
            ),
          );
          String tithi(int i) => names.of('tithi', i).of(language);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.xl,
                0,
                Space.xl,
                Space.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.legendTitle, style: t.titleLarge),
                  const SizedBox(height: Space.m),
                  row(
                    const MoonMarkerGlyph(MoonMarker.purnima, size: 12),
                    tithi(14),
                  ),
                  row(
                    const MoonMarkerGlyph(MoonMarker.amavasya, size: 12),
                    tithi(29),
                  ),
                  row(
                    const MoonMarkerGlyph(MoonMarker.ekadashi, size: 12),
                    l.legendEither(tithi(10), tithi(25)),
                  ),
                  row(
                    Container(
                      width: 20,
                      height: 3,
                      decoration: BoxDecoration(
                        color: c.alta,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    l.legendFestival,
                  ),
                  row(
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(color: c.haldiStrong, width: 2),
                        borderRadius: BorderRadius.circular(Radii.small),
                      ),
                    ),
                    l.labelToday,
                  ),
                  row(
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: c.haldiContainer,
                        borderRadius: BorderRadius.circular(Radii.small),
                      ),
                    ),
                    l.legendSelected,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

void _showJumpSheet(
  BuildContext context,
  WidgetRef ref,
  MonthRef current,
  NameTable names,
) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (_) => _JumpSheet(current: current, names: names),
);

/// Year stepper and the twelve months (FR-CAL-03).
class _JumpSheet extends ConsumerStatefulWidget {
  const _JumpSheet({required this.current, required this.names});

  final MonthRef current;
  final NameTable names;

  @override
  ConsumerState<_JumpSheet> createState() => _JumpSheetState();
}

class _JumpSheetState extends ConsumerState<_JumpSheet> {
  late int year = switch (widget.current) {
    BengaliMonthRef(:final year) => year,
    GregorianMonthRef(:final year) => year,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatterProvider);
    final language = ref.watch(appLanguageProvider);
    final t = Theme.of(context).textTheme;
    final bengali = widget.current is BengaliMonthRef;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.chooseMonth, style: t.titleLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: l.previousYear,
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => year--),
                ),
                Text(f.digits('$year'), style: t.titleMedium),
                IconButton(
                  tooltip: l.nextYear,
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => year++),
                ),
              ],
            ),
            Wrap(
              spacing: Space.s,
              runSpacing: Space.s,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < 12; i++)
                  OutlinedButton(
                    onPressed: () {
                      ref
                          .read(calendarProvider.notifier)
                          .jumpTo(
                            bengali
                                ? BengaliMonthRef(year, i)
                                : GregorianMonthRef(year, i + 1),
                          );
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      widget.names
                          .of(bengali ? 'solar_month' : 'gregorian_month', i)
                          .of(language),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
