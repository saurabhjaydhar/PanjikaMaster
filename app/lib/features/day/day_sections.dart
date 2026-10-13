import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/tokens.dart';
import '../../app/widgets/date_header.dart';
import '../../app/widgets/glossary.dart';
import '../../app/widgets/name_text.dart';
import '../../app/widgets/observance_widgets.dart';
import '../../app/widgets/panjika_widgets.dart';
import '../../app/widgets/period_row.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/engine/day_assembler.dart';
import '../../domain/entities/panjika.dart';
import '../../domain/entities/terms.dart';
import '../../l10n/gen/app_localizations.dart';

/// Every section of a panjika day in spec §11.4 order: header, tithi block, sun and
/// moon, auspicious and inauspicious periods, observances, provenance. [now] marks the
/// active period and current elements when it falls inside the day.
class DaySections extends ConsumerWidget {
  const DaySections(this.d, {super.key, required this.now});

  final DayPanjika d;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatterProvider);
    final language = ref.watch(appLanguageProvider);
    final names = ref.watch(namesProvider).value;

    String until(DateTime end) {
      final time = f.time(end);
      return l.untilTime(d.isAfterMidnight(end) ? l.nextDayTime(time) : time);
    }

    String timeOrNone(DateTime? t) => t == null ? l.timeNone : f.time(t);
    String nameAt(String kind, int idx) =>
        names?.of(kind, idx).of(language) ?? '';

    final tithi = d.currentOf(TransitionKind.tithi, now);
    final periods = names == null ? const <TimePeriod>[] : d.periods;
    final shubh = [
      for (final p in periods)
        if (p.kind == PeriodKind.shubh) p,
    ];
    final ashubh = [
      for (final p in periods)
        if (p.kind == PeriodKind.ashubh) p,
    ];

    Widget row(String label, String value, {Term? term}) => PanchangRow(
      label: label,
      value: term == null
          ? Text(value)
          : GlossaryTerm(term: term, child: Text(value)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DateHeader(
          date: d.date,
          bengaliDay: d.bengaliDate.day,
          bengaliMonth: d.bengaliMonth,
          bengaliYear: d.bengaliDate.year,
          city: d.provenance.city,
          onCityTap: () => context.push(Routes.city),
        ),
        const SizedBox(height: Space.l),
        SectionHeader(title: l.labelTithi),
        PanchangRow(
          label: l.labelTithi,
          value: GlossaryTerm(
            term: Term.tithi,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NameText(tithi.name),
                Text(until(tithi.endUtc)),
                Text(l.thenName(tithi.next.of(language))),
              ],
            ),
          ),
        ),
        for (final k in d.kshayaTithis)
          if (names != null)
            row(
              names.of('term', Term.kshayaTithi.index).of(language),
              l.nameWithUntil(k.span.name.of(language), until(k.span.endUtc)),
              term: Term.kshayaTithi,
            ),
        if (d.isVriddhi && names != null)
          row(
            names.of('term', Term.vriddhiTithi.index).of(language),
            d.udayaTithi.name.of(language),
            term: Term.vriddhiTithi,
          ),
        row(
          l.labelPaksha,
          nameAt('paksha', tithi.idx < 15 ? 0 : 1),
          term: Term.paksha,
        ),
        for (final (label, kind, term) in [
          (l.labelNakshatra, TransitionKind.nakshatra, Term.nakshatra),
          (l.labelYoga, TransitionKind.yoga, Term.yoga),
          (l.labelKarana, TransitionKind.karana, Term.karana),
        ])
          row(
            label,
            l.nameWithUntil(
              d.currentOf(kind, now).name.of(language),
              until(d.currentOf(kind, now).endUtc),
            ),
            term: term,
          ),
        const SizedBox(height: Space.xl),
        SectionHeader(title: l.sectionSunMoon),
        TimingStrip(
          cells: [
            TimingCell(
              icon: Icons.wb_twilight,
              label: l.labelSunrise,
              time: f.time(d.sun.sunrise),
            ),
            TimingCell(
              icon: Icons.wb_sunny_outlined,
              label: l.labelSunset,
              time: f.time(d.sun.sunset),
            ),
            TimingCell(
              icon: Icons.nightlight_outlined,
              label: l.labelMoonrise,
              time: timeOrNone(d.sun.moonrise),
            ),
            TimingCell(
              icon: Icons.dark_mode_outlined,
              label: l.labelMoonset,
              time: timeOrNone(d.sun.moonset),
            ),
          ],
        ),
        for (final (title, list) in [
          (l.periodShubh, shubh),
          (l.periodAshubh, ashubh),
        ])
          if (list.isNotEmpty) ...[
            const SizedBox(height: Space.xl),
            SectionHeader(title: title),
            for (final p in list)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.xs),
                child: PeriodRow(
                  name: names!.of('period', p.periodId),
                  kind: p.kind,
                  start: p.startUtc,
                  end: p.endUtc,
                  // Periods can overlap; every running one is tagged.
                  active: p.isActiveAt(now.toUtc()),
                  endsNextDay: d.isAfterMidnight(p.endUtc),
                ),
              ),
          ],
        if (d.observances.isNotEmpty) ...[
          const SizedBox(height: Space.xl),
          SectionHeader(title: l.sectionObservances),
          Wrap(
            spacing: Space.s,
            runSpacing: Space.s,
            children: [
              for (final o in d.observances)
                ObservanceChip(
                  observance: o,
                  corrected:
                      ref
                          .watch(correctedObservancesProvider)
                          .value
                          ?.contains(o.observance.id) ??
                      false,
                ),
            ],
          ),
        ],
        ProvenanceFooter(provenance: d.provenance, detailed: true),
      ],
    );
  }
}
