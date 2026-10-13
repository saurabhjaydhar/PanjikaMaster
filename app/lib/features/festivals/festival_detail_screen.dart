import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/shell/not_found_screen.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/widgets/name_text.dart';
import '../../app/widgets/observance_widgets.dart';
import '../../app/widgets/panjika_widgets.dart';
import '../../app/widgets/system_states.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../core/l10n/panjika_formatter.dart';
import '../../core/settings/settings.dart';
import '../../core/time/civil_date.dart';
import '../../core/time/clock.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/entities/panjika.dart';
import '../../domain/usecases/get_festival_detail.dart';
import '../../l10n/gen/app_localizations.dart';
import '../reminders/reminder_prefs.dart';

final getFestivalDetailProvider = Provider<GetFestivalDetail>((ref) {
  final repo = ref.watch(panjikaRepositoryProvider);
  return GetFestivalDetail(repo, repo);
});

typedef FestivalKey = ({String id, CivilDate? date});

final festivalDetailProvider =
    FutureProvider.family<FestivalDetail?, FestivalKey>(
      (ref, key) => ref
          .watch(getFestivalDetailProvider)
          .call(
            tradition: ref.watch(traditionProvider),
            cityId: ref.watch(cityIdProvider),
            id: key.id,
            date: key.date,
            today: CivilDate.ofInstant(ref.read(nowProvider)),
          ),
    );

/// Festival detail (spec §11.6, §11.11, FR-FEST-03..04): category band with the name in
/// both scripts, the day selector for multi-day festivals, the tithi and windows, the
/// description, the verification card and the reminder toggle.
class FestivalDetailScreen extends ConsumerStatefulWidget {
  const FestivalDetailScreen({super.key, required this.id, this.date});

  final String id;
  final CivilDate? date;

  @override
  ConsumerState<FestivalDetailScreen> createState() =>
      _FestivalDetailScreenState();
}

class _FestivalDetailScreenState extends ConsumerState<FestivalDetailScreen> {
  int? _day;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final detail = ref.watch(
      festivalDetailProvider((id: widget.id, date: widget.date)),
    );
    return switch (detail) {
      AsyncValue(value: final FestivalDetail d) => Scaffold(
        appBar: AppBar(title: Text(l.navFestivals)),
        body: Stack(
          children: [
            _body(d),
            if (d.provenance.isSample) const SampleWatermark(),
          ],
        ),
      ),
      AsyncValue(isLoading: true) => const Scaffold(body: SizedBox.expand()),
      _ => NotFoundScreen(message: l.festivalNotFound),
    };
  }

  Widget _body(FestivalDetail d) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatterProvider);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final language = ref.watch(appLanguageProvider);
    final names = ref.watch(namesProvider).value;
    final reminders = ref.watch(festivalRemindersProvider);
    final margin = contentInset(MediaQuery.sizeOf(context).width);
    final index = (_day ?? d.selected).clamp(0, d.days.length - 1);
    final day = d.days[index];
    final o = d.observance;
    final bn = day.bengaliDate;
    final reminderOn = reminders.contains(o.id);

    final dateLine = bn == null || names == null
        ? f.gregorianDate(day.date.date)
        : l.festivalRowDates(
            f.weekday(day.date.date),
            f.bengaliDate(
              bn.day,
              names.of('solar_month', bn.monthIdx).of(language),
              bn.year,
            ),
          );

    Widget row(String label, String value, {String? hint}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PanchangRow(
            label: label,
            value: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: t.bodyLarge),
                if (hint != null)
                  Text(hint, style: t.bodySmall?.copyWith(color: c.inkMuted)),
              ],
            ),
          ),
        ],
      ),
    );

    return ListView(
      children: [
        // Hero band in the category colour (spec §11.6).
        Container(
          color: categoryColor(c, o.category).withValues(alpha: 0.14),
          padding: EdgeInsets.fromLTRB(margin, Space.xl, margin, Space.xl),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: Space.xs,
                height: Space.xxxl,
                decoration: BoxDecoration(
                  color: categoryColor(c, o.category),
                  borderRadius: BorderRadius.circular(Space.xs),
                ),
              ),
              const SizedBox(width: Space.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Both scripts here, whatever the names setting (spec §11.6).
                    Semantics(
                      header: true,
                      child: NameText(
                        o.name,
                        style: t.headlineMedium,
                        forceBoth: true,
                      ),
                    ),
                    const SizedBox(height: Space.s),
                    Text(dateLine, style: t.titleMedium),
                    Text(
                      f.gregorianDate(day.date.date),
                      style: t.bodyMedium?.copyWith(color: c.inkMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (d.days.length > 1)
          Semantics(
            label: l.festivalDaysLabel,
            container: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.fromLTRB(margin, Space.m, margin, 0),
              child: Row(
                children: [
                  for (var i = 0; i < d.days.length; i++)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: Space.s),
                      child: ChoiceChip(
                        showCheckmark: false,
                        selected: i == index,
                        onSelected: (_) => setState(() => _day = i),
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              d.days[i].tithi?.of(language) ??
                                  l.festivalDayOf(f.number(i + 1)),
                            ),
                            Text(
                              f.gregorianDateShort(d.days[i].date.date),
                              style: t.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(margin, Space.l, margin, Space.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._tithiRows(l, f, day, row),
              for (final w in day.windows)
                if (w.kind != 'tithi_span')
                  row(
                    _windowName(l, w.kind),
                    f.timeRange(w.start, w.end),
                    hint: w.kind == 'sandhi_puja'
                        ? l.windowSandhiPujaHint(f.number(24))
                        : null,
                  ),
              if (day.date.note case final note?) ...[
                const SizedBox(height: Space.m),
                _Note(note.of(language)),
              ],
              const SizedBox(height: Space.l),
              Text(o.description.of(language), style: t.bodyLarge),
              const SizedBox(height: Space.xl),
              _VerificationCard(observance: day.date),
              const SizedBox(height: Space.xl),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: reminderOn
                    ? FilledButton.icon(
                        onPressed: () => ref
                            .read(festivalRemindersProvider.notifier)
                            .toggle(o.id),
                        icon: const Icon(Icons.notifications_active),
                        label: Text(l.reminderOn),
                      )
                    : OutlinedButton.icon(
                        onPressed: () => ref
                            .read(festivalRemindersProvider.notifier)
                            .toggle(o.id),
                        icon: const Icon(Icons.notifications_none),
                        label: Text(l.reminderOff),
                      ),
              ),
              // TODO(T-509, T-513): the share button arrives with share cards.
              ProvenanceFooter(provenance: d.provenance, detailed: true),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _tithiRows(
    AppLocalizations l,
    PanjikaFormatter f,
    FestivalDay day,
    Widget Function(String, String, {String? hint}) row,
  ) {
    final language = ref.watch(appLanguageProvider);
    final name = day.tithi?.of(language);
    if (name == null) return const [];
    final span = day.windows.where((w) => w.kind == 'tithi_span').firstOrNull;
    final value = span != null
        ? l.festivalTithiSpan(name, f.time(span.start), f.time(span.end))
        : day.tithiEnd == null
        ? name
        : l.nameWithUntil(name, l.untilTime(f.time(day.tithiEnd!)));
    return [row(l.labelTithi, value)];
  }
}

String _windowName(AppLocalizations l, String kind) => switch (kind) {
  'sandhi_puja' => l.windowSandhiPuja,
  'nishita' => l.windowNishita,
  'pratah' => l.windowPratah,
  'madhyahna' => l.windowMadhyahna,
  'aparahna' => l.windowAparahna,
  'pradosha' => l.windowPradosha,
  _ => kind, // l10n-ok: a window kind newer than this app; shown as its id
};

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(Space.m),
      decoration: BoxDecoration(
        color: c.haldiContainer,
        borderRadius: BorderRadius.circular(Radii.medium),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: c.onHaldiContainer),
          const SizedBox(width: Space.m),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: c.onHaldiContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// How far this date has been checked (spec §11.6, §6.7); unverified tier-2/3 dates
/// carry the §11.9 note.
class _VerificationCard extends ConsumerWidget {
  const _VerificationCard({required this.observance});

  final ObservanceDate observance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatterProvider);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final checked =
        observance.status == VerificationStatus.referenceMatched ||
        observance.status == VerificationStatus.expertReviewed;
    return Container(
      padding: const EdgeInsets.all(Space.l),
      decoration: BoxDecoration(
        color: c.paperRaised,
        borderRadius: BorderRadius.circular(Radii.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VerificationBadge(observance.status, showLabel: true),
          if (observance.reviewedOn case final on?) ...[
            const SizedBox(height: Space.xs),
            Text(
              l.checkedOn(f.gregorianDate(on)),
              style: t.bodyMedium?.copyWith(color: c.inkMuted),
            ),
          ],
          if (!checked && observance.observance.tier > 1) ...[
            const SizedBox(height: Space.s),
            const UnverifiedNote(),
          ],
        ],
      ),
    );
  }
}
