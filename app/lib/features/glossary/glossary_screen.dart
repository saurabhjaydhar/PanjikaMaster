import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/widgets/name_text.dart';
import '../../app/widgets/panjika_widgets.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../core/search/search_key.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/entities/name_ref.dart';
import '../../domain/entities/name_table.dart';
import '../../l10n/gen/app_localizations.dart';

/// One glossary entry: a name from the packs and its plain-language explanation.
typedef GlossaryEntry = ({NameRef name, NameRef gloss});

/// Every entry of [kind] that has an explanation, in pack order.
List<GlossaryEntry> glossaryEntries(NameTable names, String kind) => [
  for (var i = 0; i < names.countOf(kind); i++)
    if (names.glossOf(kind, i) case final gloss?)
      (name: names.of(kind, i), gloss: gloss),
];

/// Glossary (শব্দকোষ, FR-SET-07, FR-L10N-05): every panchanga term and period with its
/// explanation in the UI language and its name in both scripts; search in either.
class GlossaryScreen extends ConsumerStatefulWidget {
  const GlossaryScreen({super.key});

  @override
  ConsumerState<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends ConsumerState<GlossaryScreen> {
  String _query = '';

  bool _matches(GlossaryEntry e) {
    final q = searchKey(_query);
    if (q.isEmpty) return true;
    return [e.name.bn, e.name.en].any((s) => searchKey(s).contains(q));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final names = ref.watch(namesProvider).value;
    final margin = contentInset(MediaQuery.sizeOf(context).width);
    final sections = names == null
        ? const <(String, List<GlossaryEntry>)>[]
        : [
            (
              l.sectionTerms,
              glossaryEntries(names, 'term').where(_matches).toList(),
            ),
            (
              l.sectionPeriods,
              glossaryEntries(names, 'period').where(_matches).toList(),
            ),
          ].where((s) => s.$2.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l.glossaryTitle)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(margin, Space.s, margin, Space.xl),
        children: [
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l.glossarySearchHint,
            ),
            onChanged: (q) => setState(() => _query = q),
          ),
          const SizedBox(height: Space.m),
          if (names != null && sections.isEmpty)
            Padding(
              padding: const EdgeInsets.all(Space.xl),
              child: Text(
                l.noGlossaryMatches,
                style: t.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          for (final (title, entries) in sections) ...[
            SectionHeader(title: title),
            for (final e in entries) _Entry(entry: e),
            const SizedBox(height: Space.l),
          ],
        ],
      ),
    );
  }
}

class _Entry extends ConsumerWidget {
  const _Entry({required this.entry});

  final GlossaryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final language = ref.watch(appLanguageProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.m),
      child: Container(
        padding: const EdgeInsets.all(Space.l),
        decoration: BoxDecoration(
          color: c.paperRaised,
          borderRadius: BorderRadius.circular(Radii.medium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Both scripts here, as in the term sheets (FR-L10N-05).
            NameText(entry.name, style: t.titleMedium, forceBoth: true),
            const SizedBox(height: Space.s),
            Text(entry.gloss.of(language), style: t.bodyLarge),
          ],
        ),
      ),
    );
  }
}
