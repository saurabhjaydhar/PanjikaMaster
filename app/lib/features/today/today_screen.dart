import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/widgets/date_header.dart';
import '../../app/widgets/panjika_widgets.dart';
import '../../app/widgets/system_states.dart';
import '../../app/widgets/tithi_seal.dart';
import '../../app/widgets/update_banners.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../core/time/clock.dart';
import '../../data/packs/pack_updater.dart';
import '../../data/packs/update_providers.dart';
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
    final coverage = ref.watch(todayCoverageProvider).value;
    final updates = ref.read(updateControllerProvider.notifier);
    // Download and Update only when a pack server is configured (T-311).
    final download = updates.available ? updates.downloadNow : null;
    return Scaffold(
      body: SafeArea(
        // A reload at sunrise keeps showing the previous day until the new one is in.
        child: switch (today) {
          AsyncValue(value: final day?, hasError: false) => _TodayContent(
            day,
            stale: coverage is Stale,
          ),
          AsyncValue(isLoading: true) => const SizedBox.expand(),
          // No day: say why (spec §11.9, §16). The download action comes with T-311.
          _ => switch (coverage) {
            ClockSuspect() => const SystemStateMessage(SystemState.checkClock),
            NotDownloaded() => SystemStateMessage(
              SystemState.notDownloaded,
              onAction: download,
            ),
            _ => StateMessage(
              message: l.todayDataMissing,
              actionLabel: l.retry,
              onAction: () => ref.invalidate(todayProvider),
            ),
          },
        },
      ),
    );
  }
}

/// Notices, the download prompt, update problems and the stale banner, in that order.
List<Widget> _banners(
  BuildContext context,
  WidgetRef ref, {
  required bool stale,
}) {
  final l = AppLocalizations.of(context);
  final updates = ref.read(updateControllerProvider.notifier);
  final result = ref.watch(updateControllerProvider);
  final notices = ref.read(noticesProvider.notifier);
  return [
    for (final n in ref.watch(noticesProvider))
      NoticeBanner(n, onDismiss: () => notices.dismiss(n.id)),
    if (result case UpdateDone(:final waitingForUser)
        when waitingForUser.isNotEmpty)
      DownloadPrompt(
        bytes: waitingForUser.fold(0, (sum, o) => sum + o.entry.size),
        onDownload: updates.downloadNow,
        onLater: updates.later,
      ),
    if (result is UpdateFailed) UpdateProblem(l.updateFailed),
    if (result is UpdateNeedsNewerApp) UpdateProblem(l.appUpdateRequired),
    if (stale)
      StaleBanner(onUpdate: updates.available ? updates.downloadNow : null),
  ];
}

class _TodayContent extends ConsumerWidget {
  const _TodayContent(this.d, {this.stale = false});

  final DayPanjika d;

  /// A newer pack is offered: the amber banner sits above the data (spec §6.8).
  final bool stale;

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
    // Read, not watch: marking the day must not rebuild the screen.
    final animateFill = ref.read(ringFilledForProvider) != d.date;
    if (animateFill) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ref.read(ringFilledForProvider.notifier).mark(d.date);
        }
      });
    }
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
              for (final banner in _banners(context, ref, stale: stale)) ...[
                banner,
                const SizedBox(height: Space.m),
              ],
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
                animateFill: animateFill,
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
