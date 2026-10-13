import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_providers.dart';
import '../../domain/entities/name_ref.dart';
import '../../domain/entities/panjika.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'name_text.dart';

/// A timed period: name left, time range right (spec §11.4, §12.5). The running one is
/// filled with the kind's container colour and tagged "এখন" / "Now", so the state is
/// never shown by colour alone.
class PeriodRow extends ConsumerWidget {
  const PeriodRow({
    super.key,
    required this.name,
    required this.kind,
    required this.start,
    required this.end,
    this.active = false,
  });

  final NameRef name;
  final PeriodKind kind;
  final DateTime start;
  final DateTime end;
  final bool active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final f = ref.watch(formatterProvider);
    final language = ref.watch(appLanguageProvider);
    final range = f.timeRange(start, end);
    final fill = kind == PeriodKind.ashubh ? c.altaContainer : c.durbaContainer;
    final accent = kind == PeriodKind.ashubh ? c.alta : c.durba;
    return Semantics(
      container: true,
      label: l.periodSemantics(name.of(language), range, active ? 'yes' : 'no'),
      child: ExcludeSemantics(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: Space.minTouch),
          padding: const EdgeInsets.symmetric(
            horizontal: Space.m,
            vertical: Space.s,
          ),
          decoration: BoxDecoration(
            color: active ? fill : null,
            borderRadius: BorderRadius.circular(Radii.medium),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: Space.m,
            runSpacing: Space.xs,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: NameText(name, style: t.bodyLarge)),
                  if (active) ...[
                    const SizedBox(width: Space.s),
                    _NowTag(color: accent, label: l.labelNow),
                  ],
                ],
              ),
              Text(range, style: t.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _NowTag extends StatelessWidget {
  const _NowTag({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.s),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(Radii.small),
      ),
      child: Text(label, style: t.labelMedium?.copyWith(color: color)),
    );
  }
}
