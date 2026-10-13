import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/widgets/name_text.dart';
import '../../app/widgets/observance_widgets.dart';
import '../../app/widgets/panjika_widgets.dart';
import '../../app/widgets/system_states.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../data/packs/update_providers.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/entities/name_ref.dart';
import '../../domain/entities/name_table.dart';
import '../../domain/entities/panjika.dart';
import '../../domain/usecases/get_festival_year.dart';
import '../../l10n/gen/app_localizations.dart';
import 'festival_providers.dart';

/// Festivals (পার্বণ, spec §11.5, FR-FEST-01..02): a Bengali year of observances
/// grouped by month under sticky headers, filtered by category, month and importance,
/// opening on the current month.
class FestivalsScreen extends ConsumerWidget {
  const FestivalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayBengaliProvider);
    final filter = ref.watch(festivalFilterProvider);
    final year = filter.year ?? today.value?.year;
    return Scaffold(
      body: SafeArea(
        child: switch ((today, year)) {
          (_, final int y) => _YearView(year: y, today: today.value),
          (AsyncValue(isLoading: true), _) => const SizedBox.expand(),
          _ => SystemStateMessage(
            SystemState.notDownloaded,
            onAction: ref.read(updateControllerProvider.notifier).available
                ? ref.read(updateControllerProvider.notifier).downloadNow
                : null,
          ),
        },
      ),
    );
  }
}

class _YearView extends ConsumerStatefulWidget {
  const _YearView({required this.year, required this.today});

  final int year;
  final BengaliDate? today;

  @override
  ConsumerState<_YearView> createState() => _YearViewState();
}

class _YearViewState extends ConsumerState<_YearView> {
  final _currentMonth = GlobalKey();
  int? _scrolledFor;

  /// Opens on the current month (spec §11.5), once per year shown.
  void _scrollToCurrentMonth() {
    if (_scrolledFor == widget.year) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _currentMonth.currentContext;
      if (target == null || !mounted) return;
      _scrolledFor = widget.year;
      Scrollable.ensureVisible(target);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatterProvider);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final filter = ref.watch(festivalFilterProvider);
    final controller = ref.read(festivalFilterProvider.notifier);
    final names = ref.watch(namesProvider).value;
    final data = ref.watch(festivalYearProvider(widget.year));
    final margin = contentInset(MediaQuery.sizeOf(context).width);

    final header = Padding(
      padding: EdgeInsets.fromLTRB(
        margin - Space.s,
        Space.s,
        margin - Space.s,
        0,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: l.previousYear,
            icon: const Icon(Icons.chevron_left),
            onPressed: () => controller.year(widget.year - 1),
          ),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                l.festivalsTitle(f.digits('${widget.year}')),
                style: t.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          IconButton(
            tooltip: l.nextYear,
            icon: const Icon(Icons.chevron_right),
            onPressed: () => controller.year(widget.year + 1),
          ),
        ],
      ),
    );

    final chipList = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsetsDirectional.only(
        start: margin,
        top: Space.s,
        bottom: Space.s,
      ),
      child: Row(
        children: [
          _CategoryChip(
            label: l.filterAll,
            selected: filter.category == null,
            onSelected: () => controller.category(null),
          ),
          if (names != null)
            for (final category in ObservanceCategory.values)
              _CategoryChip(
                label: names
                    .of('category', category.index)
                    .of(ref.watch(appLanguageProvider)),
                color: categoryColor(c, category),
                selected: filter.category == category,
                onSelected: () => controller.category(category),
              ),
        ],
      ),
    );

    final chips = Row(
      children: [
        Expanded(child: chipList),
        IconButton(
          tooltip: l.menuSearch,
          icon: const Icon(Icons.search),
          onPressed: () => context.push(Routes.search),
        ),
        IconButton(
          tooltip: l.filterTitle,
          isSelected: filter.narrowed,
          icon: const Icon(Icons.filter_list),
          selectedIcon: Icon(Icons.filter_list, color: c.haldiStrong),
          onPressed: names == null ? null : () => _showFilters(context, names),
        ),
        SizedBox(width: margin - Space.s),
      ],
    );

    final body = switch (data) {
      AsyncValue(value: final FestivalYear year) => _list(year, filter, margin),
      AsyncValue(isLoading: true) => const SizedBox.expand(),
      _ => SystemStateMessage(
        SystemState.notDownloaded,
        onAction: ref.read(updateControllerProvider.notifier).available
            ? ref.read(updateControllerProvider.notifier).downloadNow
            : null,
      ),
    };

    return Column(
      children: [
        header,
        chips,
        Expanded(child: body),
      ],
    );
  }

  Widget _list(FestivalYear year, FestivalFilter filter, double margin) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final months = [
      for (final m in year.months)
        if (filter.month == null || filter.month == m.monthIdx)
          (m, m.items.where((i) => filter.shows(i.observance)).toList()),
    ].where((e) => e.$2.isNotEmpty).toList();

    if (months.isEmpty) {
      return StateMessage(
        message: l.noFestivalsMatch,
        actionLabel: filter.narrowed || filter.category != null
            ? l.showAll
            : null,
        onAction: () {
          ref.read(festivalFilterProvider.notifier)
            ..clear()
            ..category(null);
        },
      );
    }
    final current = widget.today?.year == year.year
        ? widget.today?.monthIdx
        : null;
    if (current != null && months.any((m) => m.$1.monthIdx == current)) {
      _scrollToCurrentMonth();
    }

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            if (!year.complete)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(margin, 0, margin, Space.s),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    l.festivalYearPartial,
                    style: t.bodyMedium?.copyWith(color: c.inkMuted),
                  ),
                ),
              ),
            for (final (month, items) in months)
              SliverMainAxisGroup(
                slivers: [
                  // Sticky within its month (spec §11.5); sized by its text.
                  PinnedHeaderSliver(
                    child: _MonthHeader(
                      key: month.monthIdx == current ? _currentMonth : null,
                      name: month.monthName,
                      margin: margin,
                    ),
                  ),
                  SliverList.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) =>
                        _FestivalRow(item: items[i], margin: margin),
                  ),
                ],
              ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(margin, 0, margin, Space.xl),
              sliver: SliverToBoxAdapter(
                child: ProvenanceFooter(provenance: year.provenance),
              ),
            ),
          ],
        ),
        if (year.provenance.isSample) const SampleWatermark(),
      ],
    );
  }

  Future<void> _showFilters(
    BuildContext context,
    NameTable names,
  ) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheet) => Consumer(
      builder: (sheet, ref, _) {
        final l = AppLocalizations.of(sheet);
        final t = Theme.of(sheet).textTheme;
        final language = ref.watch(appLanguageProvider);
        final filter = ref.watch(festivalFilterProvider);
        final controller = ref.read(festivalFilterProvider.notifier);
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(Space.xl, 0, Space.xl, Space.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.filterTitle, style: t.titleLarge),
                const SizedBox(height: Space.l),
                Text(l.filterMonth, style: t.titleSmall),
                const SizedBox(height: Space.s),
                Wrap(
                  spacing: Space.s,
                  runSpacing: Space.s,
                  children: [
                    ChoiceChip(
                      label: Text(l.filterAll),
                      selected: filter.month == null,
                      onSelected: (_) => controller.month(null),
                    ),
                    for (var m = 0; m < 12; m++)
                      ChoiceChip(
                        label: Text(names.of('solar_month', m).of(language)),
                        selected: filter.month == m,
                        onSelected: (_) => controller.month(m),
                      ),
                  ],
                ),
                const SizedBox(height: Space.xl),
                Text(l.filterImportance, style: t.titleSmall),
                const SizedBox(height: Space.s),
                Wrap(
                  spacing: Space.s,
                  runSpacing: Space.s,
                  children: [
                    for (final (tier, label) in [
                      (1, l.tierMajor),
                      (2, l.tierOther),
                      (3, l.tierCivic),
                    ])
                      FilterChip(
                        label: Text(label),
                        selected: filter.tiers.contains(tier),
                        onSelected: (_) => controller.toggleTier(tier),
                      ),
                  ],
                ),
                const SizedBox(height: Space.xl),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: filter.narrowed ? controller.clear : null,
                    child: Text(l.showAll),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(end: Space.s),
    child: ChoiceChip(
      avatar: color == null
          ? null
          : ExcludeSemantics(
              child: Icon(Icons.circle, size: Space.m, color: color),
            ),
      showCheckmark: false,
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    ),
  );
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({super.key, required this.name, required this.margin});

  final NameRef name;
  final double margin;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    return Material(
      color: c.paper,
      child: Padding(
        padding: EdgeInsets.fromLTRB(margin, Space.m, margin, Space.s),
        child: Row(
          children: [
            Semantics(
              header: true,
              child: NameText(name, style: t.titleMedium),
            ),
            const SizedBox(width: Space.m),
            Expanded(child: Divider(color: c.rule)),
          ],
        ),
      ),
    );
  }
}

class _FestivalRow extends ConsumerWidget {
  const _FestivalRow({required this.item, required this.margin});

  final FestivalYearItem item;
  final double margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatterProvider);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final names = ref.watch(namesProvider).value;
    final language = ref.watch(appLanguageProvider);
    final o = item.observance;
    final bn = item.bengaliDate;
    final month = names?.of('solar_month', bn.monthIdx).of(language) ?? '';
    final dates = l.festivalRowDates(
      f.gregorianDateShort(o.date),
      f.bengaliDayMonth(bn.day, month),
    );
    return InkWell(
      onTap: () => context.push(Routes.festival(o.observance.id, date: o.date)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Space.minTouch),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: margin, vertical: Space.s),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: Space.xs,
                  decoration: BoxDecoration(
                    color: categoryColor(c, o.observance.category),
                    borderRadius: BorderRadius.circular(Space.xs),
                  ),
                ),
                const SizedBox(width: Space.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NameText(o.observance.name, style: t.bodyLarge),
                      Text(
                        o.dayIndex > 0
                            ? l.nameWithUntil(
                                dates,
                                l.festivalDayOf(f.number(o.dayIndex + 1)),
                              )
                            : dates,
                        style: t.bodyMedium?.copyWith(color: c.inkMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Space.m),
                Center(child: VerificationBadge(o.status)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
