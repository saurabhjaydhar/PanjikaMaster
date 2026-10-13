import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/widgets/name_text.dart';
import '../../app/widgets/panjika_widgets.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../core/settings/settings.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../data/repositories/panjika_providers.dart';
import 'city_providers.dart';

/// City picker (শহর, spec §11.7, §11.12): search in both scripts, recent cities,
/// West Bengal by district, other cities; each row shows today's sunrise.
class CityPickerScreen extends ConsumerStatefulWidget {
  const CityPickerScreen({super.key});

  @override
  ConsumerState<CityPickerScreen> createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends ConsumerState<CityPickerScreen> {
  String _query = '';

  Future<void> _choose(String id) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    final changed = id != ref.read(cityIdProvider);
    await chooseCity(ref, id);
    if (!mounted) return;
    Navigator.of(context).pop();
    // What changes with a city, and what doesn't (FR-LOC-05).
    if (changed) messenger.showSnackBar(SnackBar(content: Text(l.cityChanged)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rows = ref.watch(cityRowsProvider).value ?? const <CityRowData>[];
    final current = ref.watch(cityIdProvider);
    final language = ref.watch(appLanguageProvider);
    final recent = recentCities(ref.read(settingsSourceProvider));
    final matches = [
      for (final r in rows)
        if (r.matches(_query)) r,
    ];

    Widget tile(CityRowData r) => _CityTile(
      row: r,
      selected: r.city.id == current,
      onTap: () => _choose(r.city.id),
    );

    final searching = _query.trim().isNotEmpty;
    final wb =
        [
          for (final r in matches)
            if (r.city.state == 'West Bengal') r,
        ]..sort(
          (a, b) => a.city.district
              .of(language)
              .compareTo(b.city.district.of(language)),
        );
    final others = [
      for (final r in matches)
        if (r.city.state != 'West Bengal') r,
    ];
    final recentRows = [
      for (final id in recent) ...matches.where((r) => r.city.id == id),
    ];

    final source = ref.watch(cityRowsSourceProvider).value;
    final names = ref.watch(namesProvider).value;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.cityPickerTitle)),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.symmetric(
              horizontal: screenMargin(MediaQuery.sizeOf(context).width),
            ),
            children: [
              TextField(
                autofocus: false,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l.citySearchHint,
                ),
                onChanged: (q) => setState(() => _query = q),
              ),
              const SizedBox(height: Space.m),
              if (searching && matches.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(Space.xl),
                  child: Text(l.noCityMatches, textAlign: TextAlign.center),
                ),
              if (!searching && recentRows.isNotEmpty) ...[
                SectionHeader(title: l.sectionRecent),
                for (final r in recentRows) tile(r),
              ],
              if (wb.isNotEmpty) ...[
                SectionHeader(title: l.sectionWestBengal),
                for (final r in wb) tile(r),
              ],
              if (others.isNotEmpty) ...[
                SectionHeader(title: l.sectionOtherCities),
                for (final r in others) tile(r),
              ],
              // The sunrise times' provenance (CLAUDE.md).
              if (source != null &&
                  names != null &&
                  source.packIds.isNotEmpty) ...[
                const Divider(height: Space.xl),
                Text(
                  l.cityListProvenance(
                    names.tradition(ref.watch(traditionProvider)).of(language),
                    l.timeZoneLabel,
                    source.packIds.join(', '),
                    source.isSample
                        ? l.verificationSample
                        : l.verificationComputed,
                  ),
                  style: t.bodySmall?.copyWith(color: context.colors.inkMuted),
                ),
                const SizedBox(height: Space.xl),
              ],
            ],
          ),
          if (source?.isSample ?? false) const SampleWatermark(),
        ],
      ),
    );
  }
}

class _CityTile extends ConsumerWidget {
  const _CityTile({
    required this.row,
    required this.selected,
    required this.onTap,
  });

  final CityRowData row;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatterProvider);
    final language = ref.watch(appLanguageProvider);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final sunrise = row.sunrise == null
        ? l.timeNone
        : l.sunriseAt(f.time(row.sunrise!));
    return Semantics(
      button: true,
      selected: selected,
      label: l.cityRowSemantics(
        row.city.name.of(language),
        row.city.district.of(language),
        sunrise,
      ),
      value: selected ? l.currentCity : null,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.small),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Space.minTouch),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.s),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NameText(row.city.name, style: t.bodyLarge),
                      Text(
                        row.city.district.of(language),
                        style: t.bodySmall?.copyWith(color: c.inkMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Space.m),
                Text(sunrise, style: t.bodyMedium?.copyWith(color: c.inkMuted)),
                SizedBox(
                  width: 32,
                  child: selected ? Icon(Icons.check, color: c.durba) : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
