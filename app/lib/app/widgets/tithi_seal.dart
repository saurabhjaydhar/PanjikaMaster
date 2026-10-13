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
    this.animateFill = false,
    this.onTap,
    this.tapHint,
  });

  final NameRef name;

  /// [name] in the UI language, for the semantics sentence.
  final String nameText;
  final String until;
  final String then;
  final double progress;

  /// Extra lines such as "ক্ষয় তিথি: অষ্টমী".
  final List<String> notes;

  /// Fill the ring from empty: once per day, on first view (spec §12.8).
  final bool animateFill;

  /// Opens Day detail (spec §11.2); [tapHint] tells screen readers so.
  final VoidCallback? onTap;
  final String? tapHint;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    // The sentence is the container's label; notes stay separate nodes, read after it.
    return Semantics(
      container: true,
      button: onTap != null,
      label: l.tithiSealSemantics(nameText, until, then),
      hint: tapHint,
      child: Material(
        color: c.haldiContainer,
        borderRadius: BorderRadius.circular(Radii.large),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(Space.l),
            child: Row(
              children: [
                TithiRing(progress: progress, animateFill: animateFill),
                const SizedBox(width: Space.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // The name never moves; old and new cross-fade (§12.8).
                            AnimatedSwitcher(
                              duration: context.motion(Motion.standard),
                              layoutBuilder: (current, previous) => Stack(
                                alignment: AlignmentDirectional.topStart,
                                children: [...previous, ?current],
                              ),
                              child: NameText(
                                name,
                                key: ValueKey(name),
                                style: t.headlineSmall,
                              ),
                            ),
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
        ),
      ),
    );
  }
}
