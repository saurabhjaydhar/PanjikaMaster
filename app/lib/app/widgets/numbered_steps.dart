import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_providers.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// A genuine sequence of steps, each with a numbered haldi disc (spec §11.16). The
/// number is decorative for screen readers: the text carries the meaning.
class NumberedSteps extends ConsumerWidget {
  const NumberedSteps(this.steps, {super.key});

  /// Each step's title and, optionally, a muted explanation under it.
  final List<(String, String?)> steps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final f = ref.watch(formatterProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, (title, body)) in steps.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.s),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: Space.xxl,
                      minHeight: Space.xxl,
                    ),
                    padding: const EdgeInsets.all(Space.xs),
                    decoration: BoxDecoration(
                      color: c.haldiContainer,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      f.number(i + 1),
                      style: t.titleSmall?.copyWith(color: c.onHaldiContainer),
                    ),
                  ),
                ),
                const SizedBox(width: Space.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: body == null ? t.bodyLarge : t.titleSmall,
                      ),
                      if (body != null)
                        Text(
                          body,
                          style: t.bodyMedium?.copyWith(color: c.inkMuted),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
