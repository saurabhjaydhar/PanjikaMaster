import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/widgets/name_text.dart';
import '../../app/widgets/observance_widgets.dart';
import '../../app/widgets/panjika_widgets.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../core/settings/settings.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/entities/name_table.dart';
import '../../domain/entities/panjika.dart';
import '../../l10n/gen/app_localizations.dart';
import '../city/city_providers.dart';
import 'search_service.dart';

/// Search (খুঁজুন, spec §11.14, FR-SRCH-01): a date in either calendar or a festival
/// name, typed in either script. Dates open Day detail; festivals open their detail.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  Timer? _debounce;
  String _query = '';
  SearchResults? _results;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _changed(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final results = await ref.read(searchServiceProvider).search(text);
      if (!mounted) return;
      setState(() {
        _query = text;
        _results = results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final names = ref.watch(namesProvider).value;
    final language = ref.watch(appLanguageProvider);
    final city = ref.watch(cityNameProvider).value;
    final margin = contentInset(MediaQuery.sizeOf(context).width);
    final results = _results;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l.searchHint,
            border: InputBorder.none,
          ),
          onChanged: _changed,
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(margin, Space.s, margin, Space.xl),
            children: [
              Text(
                l.searchExamples,
                style: t.bodyMedium?.copyWith(color: c.inkMuted),
              ),
              const SizedBox(height: Space.l),
              if (results != null && _query.trim().isNotEmpty) ...[
                if (results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(Space.xl),
                    child: Text(
                      l.searchNoResults,
                      style: t.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  )
                else ...[
                  SectionHeader(title: l.searchResults),
                  for (final r in results.items)
                    if (names != null) _ResultRow(result: r, names: names),
                  // Conversions and festival dates depend on the tradition (CLAUDE.md).
                  if (names != null && city != null)
                    Padding(
                      padding: const EdgeInsets.only(top: Space.l),
                      child: Text(
                        l.provenance(
                          names
                              .tradition(ref.watch(traditionProvider))
                              .of(language),
                          city.of(language),
                          l.timeZoneLabel,
                        ),
                        style: t.bodySmall?.copyWith(color: c.inkMuted),
                      ),
                    ),
                ],
              ],
            ],
          ),
          if (results?.isSample ?? false) const SampleWatermark(),
        ],
      ),
    );
  }
}

class _ResultRow extends ConsumerWidget {
  const _ResultRow({required this.result, required this.names});

  final SearchResult result;
  final NameTable names;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatterProvider);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final language = ref.watch(appLanguageProvider);

    String bengali(BengaliDate bn) => f.bengaliDate(
      bn.day,
      names.of('solar_month', bn.monthIdx).of(language),
      bn.year,
    );

    Widget row({
      required Widget leading,
      required Widget title,
      Widget? subtitle,
      VoidCallback? onTap,
    }) => InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Space.minTouch),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Space.s),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                leading,
                const SizedBox(width: Space.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [title, ?subtitle],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return switch (result) {
      DateResult(:final date?, :final bengaliDate) => row(
        leading: Icon(Icons.calendar_today_outlined, color: c.inkMuted),
        title: Text(
          bengaliDate == null
              ? l.searchDateNotInstalled(f.gregorianDate(date))
              : l.searchDateEquals(bengali(bengaliDate), f.gregorianDate(date)),
          style: t.bodyLarge,
        ),
        onTap: () => context.push(Routes.day(date)),
      ),
      DateResult(:final asked) => row(
        leading: Icon(Icons.cloud_download_outlined, color: c.inkMuted),
        title: Text(
          l.searchDateNotInstalled(
            asked == null
                ? ''
                : asked.year == null
                ? f.bengaliDayMonth(
                    asked.day,
                    names.of('solar_month', asked.monthIdx).of(language),
                  )
                : f.bengaliDate(
                    asked.day,
                    names.of('solar_month', asked.monthIdx).of(language),
                    asked.year!,
                  ),
          ),
          style: t.bodyLarge?.copyWith(color: c.inkMuted),
        ),
      ),
      FestivalResult(observance: final o) => row(
        leading: Container(
          width: Space.xs,
          decoration: BoxDecoration(
            color: categoryColor(c, o.observance.category),
            borderRadius: BorderRadius.circular(Space.xs),
          ),
        ),
        title: NameText(o.observance.name, style: t.bodyLarge),
        subtitle: Text(
          f.gregorianDate(o.date),
          style: t.bodyMedium?.copyWith(color: c.inkMuted),
        ),
        onTap: () =>
            context.push(Routes.festival(o.observance.id, date: o.date)),
      ),
    };
  }
}
