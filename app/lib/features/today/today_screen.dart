import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/widgets/date_header.dart';
import '../../app/widgets/panjika_widgets.dart';
import '../../app/widgets/tithi_seal.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../core/time/clock.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/engine/day_assembler.dart';
import '../../domain/entities/panjika.dart';
import '../../domain/entities/terms.dart';
import '../../l10n/gen/app_localizations.dart';
import 'today_providers.dart';

/// Today (আজ), basic version (T-112; spec §11.2). Updates while open (T-212). Periods
/// and observances arrive in Phase 4.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final today = ref.watch(todayProvider);
    return Scaffold(
      body: SafeArea(
        // A reload at sunrise keeps showing the previous day until the new one is in.
        child: switch (today) {
          AsyncValue(value: final day?, hasError: false) => _TodayContent(day),
          AsyncValue(isLoading: true) => const SizedBox.expand(),
          _ => StateMessage(
            message: l.todayDataMissing,
            actionLabel: l.retry,
            onAction: () => ref.invalidate(todayProvider),
          ),
        },
      ),
    );
  }
}

class _TodayContent extends ConsumerWidget {
  const _TodayContent(this.d);

  final DayPanjika d;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final language = ref.watch(appLanguageProvider);
    final f = ref.watch(formatterProvider);
    final now = ref.watch(nowProvider);
    final names = ref.watch(namesProvider).value;

    /// "দুপুর ২:৩২ পর্যন্ত", with "(পরদিন)" when it ends after midnight (spec §12.4).
    String until(DateTime end) {
      final time = f.time(end);
      return l.untilTime(d.isAfterMidnight(end) ? l.nextDayTime(time) : time);
    }

    String timeOrNone(DateTime? instant) =>
        instant == null ? l.timeNone : f.time(instant);

    String term(Term t) => names!.of('term', t.index).of(language);

    final tithi = d.currentOf(TransitionKind.tithi, now);
    // Kshaya tithis get a second line; a vriddhi tithi is noted (spec §16).
    final notes = names == null
        ? const <String>[]
        : [
            for (final k in d.kshayaTithis)
              l.termWithName(term(Term.kshayaTithi), k.span.name.of(language)),
            if (d.isVriddhi) term(Term.vriddhiTithi),
          ];

    return Stack(
      children: [
        RefreshIndicator(
          // Pull-to-refresh only re-reads local data (spec §11.2).
          onRefresh: () => ref.refresh(todayProvider.future),
          child: ListView(
            padding: EdgeInsets.all(
              screenMargin(MediaQuery.sizeOf(context).width),
            ),
            children: [
              // Date header (FR-HOME-01)
              DateHeader(
                date: d.date,
                bengaliDay: d.bengaliDate.day,
                bengaliMonth: d.bengaliMonth,
                bengaliYear: d.bengaliDate.year,
                city: d.provenance.city,
              ),
              const SizedBox(height: Space.l),

              // Tithi seal: the one bold element (FR-HOME-02, spec §12.1)
              TithiSeal(
                name: tithi.name,
                nameText: tithi.name.of(language),
                until: until(tithi.endUtc),
                then: l.thenName(tithi.next.of(language)),
                progress: tithi.progressAt(now),
                notes: notes,
              ),
              const SizedBox(height: Space.s),

              // Nakshatra, yoga, karana (FR-HOME-03)
              for (final (label, e) in [
                (l.labelNakshatra, d.currentOf(TransitionKind.nakshatra, now)),
                (l.labelYoga, d.currentOf(TransitionKind.yoga, now)),
                (l.labelKarana, d.currentOf(TransitionKind.karana, now)),
              ])
                PanchangRow(
                  label: label,
                  value: Text(
                    l.nameWithUntil(e.name.of(language), until(e.endUtc)),
                  ),
                ),
              const SizedBox(height: Space.l),

              // Sun and moon for the city (FR-HOME-04)
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
                    iconColor: c.inkMuted,
                  ),
                  TimingCell(
                    icon: Icons.dark_mode_outlined,
                    label: l.labelMoonset,
                    time: timeOrNone(d.sun.moonset),
                    iconColor: c.inkMuted,
                  ),
                ],
              ),

              ProvenanceFooter(provenance: d.provenance),
            ],
          ),
        ),
        if (d.provenance.isSample) const SampleWatermark(),
      ],
    );
  }
}
