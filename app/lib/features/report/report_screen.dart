import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/widgets/panjika_widgets.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../core/settings/settings.dart';
import '../../core/time/civil_date.dart';
import '../../core/time/clock.dart';
import '../../data/packs/update_providers.dart';
import '../../data/reports/report_providers.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/entities/panjika.dart';
import '../../domain/reports/error_report.dart';
import '../../l10n/gen/app_localizations.dart';
import '../city/city_providers.dart';
import '../sources/sources_screen.dart';

/// The Bengali date of a civil date in the chosen tradition, and whether it comes from
/// a sample pack (for the watermark).
final _bengaliDateProvider =
    FutureProvider.family<(BengaliDate, bool)?, CivilDate>((ref, date) async {
      final repo = ref.watch(panjikaRepositoryProvider);
      final bn = await repo.bengaliDate(ref.watch(traditionProvider), date);
      if (bn == null) return null;
      return (bn, await repo.anySample([bn.packId]));
    });

/// Report an error (ভুল জানান, spec §11.17, FR-SET-03, US-07): pre-filled with the
/// date, city, tradition and data versions; asks for no personal data; queued when
/// offline (T-604).
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key, this.date});

  /// The day the user was looking at; today when opened from the menu.
  final CivilDate? date;

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  late CivilDate _date =
      widget.date ?? CivilDate.ofInstant(ref.read(nowProvider));
  ReportKind? _kind;
  final _says = TextEditingController();
  final _panjika = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _says.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _says.dispose();
    _panjika.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_date.year, _date.month, _date.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null && mounted) {
      setState(() => _date = CivilDate(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _sending = true);
    final packs = await ref.read(packDetailsProvider.future);
    final queue = ref.read(reportQueueProvider);
    await queue.enqueue(
      ErrorReport(
        date: _date,
        cityId: ref.read(cityIdProvider),
        tradition: ref.read(traditionProvider),
        packVersions: {for (final p in packs) p.id: p.version},
        kind: _kind ?? ReportKind.other,
        panjikaSays: _says.text,
        panjikaName: _panjika.text,
        appVersion: appVersion,
      ),
    );
    await queue.flush();
    final queued = await queue.pending() > 0;
    messenger.showSnackBar(
      SnackBar(content: Text(queued ? l.reportQueued : l.reportSent)),
    );
    if (mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final f = ref.watch(formatterProvider);
    final language = ref.watch(appLanguageProvider);
    final names = ref.watch(namesProvider).value;
    final city = ref.watch(cityNameProvider).value;
    final packs = ref.watch(packDetailsProvider).value;
    final bengali = ref.watch(_bengaliDateProvider(_date)).value;
    final margin = contentInset(MediaQuery.sizeOf(context).width);
    final muted = t.bodyMedium?.copyWith(color: c.inkMuted);

    String shortKind(String kind) => switch (kind) {
      'global' => l.packKindShortGlobal,
      'cities' => l.packKindShortCities,
      _ => l.packKindShortObservances,
    };

    final gregorian = f.gregorianDate(_date);
    final dateText = bengali == null || names == null
        ? gregorian
        : l.reportDateBoth(
            f.bengaliDate(
              bengali.$1.day,
              names.of('solar_month', bengali.$1.monthIdx).of(language),
              bengali.$1.year,
            ),
            gregorian,
          );

    final kinds = {
      ReportKind.tithiTime: l.reportKindTithiTime,
      ReportKind.festivalDay: l.reportKindFestivalDay,
      ReportKind.bengaliDate: l.reportKindBengaliDate,
      ReportKind.other: l.reportKindOther,
    };

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: Space.l, bottom: Space.s),
      child: Text(text, style: t.titleSmall),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.menuReport)),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(margin, Space.s, margin, Space.xl),
            children: [
              label(l.reportDateLabel),
              Text(dateText, style: t.bodyLarge),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  icon: const Icon(Icons.edit_calendar_outlined),
                  label: Text(l.reportChangeDate),
                  onPressed: _pickDate,
                ),
              ),
              label(l.reportKindLabel),
              Wrap(
                spacing: Space.s,
                runSpacing: Space.s,
                children: [
                  for (final MapEntry(key: kind, value: text) in kinds.entries)
                    ChoiceChip(
                      label: Text(text),
                      selected: _kind == kind,
                      onSelected: (on) =>
                          setState(() => _kind = on ? kind : null),
                    ),
                ],
              ),
              label(l.reportPanjikaSaysLabel),
              TextField(
                controller: _says,
                minLines: 3,
                maxLines: 8,
                maxLength: 1000,
                textCapitalization: TextCapitalization.sentences,
                // The limit stays; the counter would show Latin digits (§13.3).
                decoration: InputDecoration(
                  hintText: l.reportPanjikaSaysHint,
                  border: const OutlineInputBorder(),
                  counterText: '',
                ),
              ),
              label(l.reportPanjikaNameLabel),
              TextField(
                controller: _panjika,
                maxLength: 100,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),
              const SizedBox(height: Space.s),
              if (names != null && city != null && packs != null)
                Text(
                  l.reportSentWith(
                    city.of(language),
                    names.tradition(ref.watch(traditionProvider)).of(language),
                    [
                      for (final p in packs)
                        l.reportPackVersion(
                          shortKind(p.kind),
                          f.number(p.version),
                        ),
                    ].join(', '),
                  ),
                  style: muted,
                ),
              const SizedBox(height: Space.s),
              Text(l.reportPrivacy, style: muted),
              const SizedBox(height: Space.l),
              FilledButton(
                onPressed: _says.text.trim().isEmpty || _sending
                    ? null
                    : () => unawaited(_send()),
                child: Text(l.reportSend),
              ),
            ],
          ),
          if (bengali?.$2 ?? false) const SampleWatermark(),
        ],
      ),
    );
  }
}
