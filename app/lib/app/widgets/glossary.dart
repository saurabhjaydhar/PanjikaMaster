import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_providers.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/entities/terms.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'name_text.dart';

/// Wraps a label that names a panjika term. Long-press, or the (i) button, opens its
/// glossary entry (FR-SET-07, spec §12.5). Without an entry in the packs it is just
/// the label.
class GlossaryTerm extends ConsumerWidget {
  const GlossaryTerm({super.key, required this.term, required this.child});

  final Term term;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names = ref.watch(namesProvider).value;
    if (names?.glossOf('term', term.index) == null) return child;
    final l = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: GestureDetector(
            onLongPress: () => showGlossaryEntry(context, term),
            child: child,
          ),
        ),
        IconButton(
          icon: Icon(Icons.info_outline, color: context.colors.inkMuted),
          iconSize: 18,
          tooltip: l.glossaryOpen,
          onPressed: () => showGlossaryEntry(context, term),
        ),
      ],
    );
  }
}

/// The glossary entry for [term] in a bottom sheet: the name in both scripts and the
/// explanation in the UI language.
Future<void> showGlossaryEntry(BuildContext context, Term term) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _GlossarySheet(term),
    );

class _GlossarySheet extends ConsumerWidget {
  const _GlossarySheet(this.term);

  final Term term;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final language = ref.watch(appLanguageProvider);
    final names = ref.watch(namesProvider).value;
    final gloss = names?.glossOf('term', term.index);
    if (names == null || gloss == null) return const SizedBox.shrink();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.xl, 0, Space.xl, Space.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.glossaryTitle,
              style: t.labelLarge?.copyWith(color: c.inkMuted),
            ),
            const SizedBox(height: Space.s),
            NameText(
              names.of('term', term.index),
              style: t.headlineSmall,
              forceBoth: true,
            ),
            const SizedBox(height: Space.l),
            Text(gloss.of(language), style: t.bodyLarge),
          ],
        ),
      ),
    );
  }
}
