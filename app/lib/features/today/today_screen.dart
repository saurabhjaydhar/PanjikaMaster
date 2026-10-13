import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/widgets/name_text.dart';
import '../../app/widgets/panjika_widgets.dart';
import '../../core/l10n/app_language.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../core/l10n/panjika_formatter.dart';
import '../../core/time/clock.dart';
import '../../domain/engine/day_assembler.dart';
import '../../domain/entities/panjika.dart';
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
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final language = ref.watch(appLanguageProvider);
    final f = ref.watch(formatterProvider);
    final now = ref.watch(nowProvider);
    final showBoth = ref.watch(showBothScriptsProvider);
    final other = language == AppLanguage.bn ? AppLanguage.en : AppLanguage.bn;
    final otherF = PanjikaFormatter(
      language: other,
      numerals: other.defaultNumerals,
    );

    /// "দুপুর ২:৩২ পর্যন্ত", with "(পরদিন)" when it ends after midnight (spec §12.4).
    String until(DateTime end) {
      final time = f.time(end);
      return l.untilTime(d.isAfterMidnight(end) ? l.nextDayTime(time) : time);
    }

    String timeOrNone(DateTime? instant) =>
        instant == null ? l.timeNone : f.time(instant);

    final tithi = d.currentOf(TransitionKind.tithi, now);
    final tithiUntil = until(tithi.endUtc);
    final tithiThen = l.thenName(tithi.next.of(language));

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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      f.weekday(d.date),
                      style: t.labelLarge?.copyWith(color: c.inkMuted),
                    ),
                  ),
                  Chip(
                    avatar: Icon(Icons.place_outlined, size: 18, color: c.ink),
                    label: Text(d.provenance.city.of(language)),
                  ),
                ],
              ),
              Text(
                f.bengaliDate(
                  d.bengaliDate.day,
                  d.bengaliMonth.of(language),
                  d.bengaliDate.year,
                ),
                style: t.displaySmall,
              ),
              if (showBoth)
                ExcludeSemantics(
                  child: Text(
                    otherF.bengaliDate(
                      d.bengaliDate.day,
                      d.bengaliMonth.of(other),
                      d.bengaliDate.year,
                    ),
                    style: t.bodySmall?.copyWith(color: c.inkMuted),
                  ),
                ),
              Text(
                f.gregorianDate(d.date),
                style: t.bodyLarge?.copyWith(color: c.inkMuted),
              ),
              const SizedBox(height: Space.l),

              // Tithi seal: the one bold element (FR-HOME-02, spec §12.1)
              Semantics(
                container: true,
                label: l.tithiSealSemantics(
                  tithi.name.of(language),
                  tithiUntil,
                  tithiThen,
                ),
                child: ExcludeSemantics(
                  child: Container(
                    padding: const EdgeInsets.all(Space.l),
                    decoration: BoxDecoration(
                      color: c.haldiContainer,
                      borderRadius: BorderRadius.circular(Radii.large),
                    ),
                    child: Row(
                      children: [
                        TithiRing(progress: tithi.progressAt(now)),
                        const SizedBox(width: Space.l),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              NameText(tithi.name, style: t.headlineSmall),
                              Text(
                                tithiUntil,
                                style: t.bodyLarge?.copyWith(
                                  color: c.onHaldiContainer,
                                ),
                              ),
                              Text(
                                tithiThen,
                                style: t.labelLarge?.copyWith(
                                  color: c.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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

              ProvenanceFooter(
                text: l.provenance(
                  d.provenance.tradition.of(language),
                  d.provenance.city.of(language),
                  l.timeZoneLabel,
                ),
              ),
            ],
          ),
        ),
        if (d.provenance.isSample) const SampleWatermark(),
      ],
    );
  }
}
