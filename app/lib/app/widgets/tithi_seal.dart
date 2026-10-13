import 'package:flutter/material.dart';

import '../../domain/entities/name_ref.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'name_text.dart';
import 'panjika_widgets.dart';

/// The one bold element on Today (FR-HOME-02, spec §12.1, §12.5): ring, tithi name,
/// until when, what follows, and any notes (kshaya, vriddhi). Read as one sentence by
/// screen readers.
class TithiSeal extends StatelessWidget {
  const TithiSeal({
    super.key,
    required this.name,
    required this.nameText,
    required this.until,
    required this.then,
    required this.progress,
    this.notes = const [],
  });

  final NameRef name;

  /// [name] in the UI language, for the semantics sentence.
  final String nameText;
  final String until;
  final String then;
  final double progress;

  /// Extra lines such as "ক্ষয় তিথি: অষ্টমী".
  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    // The sentence is the container's label; notes stay separate nodes, read after it.
    return Semantics(
      container: true,
      label: l.tithiSealSemantics(nameText, until, then),
      child: Container(
        padding: const EdgeInsets.all(Space.l),
        decoration: BoxDecoration(
          color: c.haldiContainer,
          borderRadius: BorderRadius.circular(Radii.large),
        ),
        child: Row(
          children: [
            TithiRing(progress: progress),
            const SizedBox(width: Space.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NameText(name, style: t.headlineSmall),
                        Text(
                          until,
                          style: t.bodyLarge?.copyWith(
                            color: c.onHaldiContainer,
                          ),
                        ),
                        Text(
                          then,
                          style: t.labelLarge?.copyWith(color: c.inkMuted),
                        ),
                      ],
                    ),
                  ),
                  for (final note in notes)
                    Text(note, style: t.bodyMedium?.copyWith(color: c.ink)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
