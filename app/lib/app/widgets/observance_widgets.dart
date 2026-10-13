import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_providers.dart';
import '../../domain/entities/panjika.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/panjika_colors.dart';
import '../theme/tokens.dart';
import 'name_text.dart';

/// Category colour of the bar on chips, cards and calendar cells (spec §12.2). Always
/// shown with the name, never alone.
Color categoryColor(PanjikaColors c, ObservanceCategory category) =>
    switch (category) {
      ObservanceCategory.puja => c.alta,
      ObservanceCategory.vrata => c.neel,
      ObservanceCategory.tithi => c.haldiStrong,
      ObservanceCategory.utsav => c.padma,
      ObservanceCategory.jayanti => c.inkMuted,
    };

String verificationLabel(AppLocalizations l, VerificationStatus status) =>
    switch (status) {
      VerificationStatus.sample => l.verificationSample,
      VerificationStatus.computed => l.verificationComputed,
      VerificationStatus.referenceMatched => l.verificationReferenceMatched,
      VerificationStatus.expertReviewed => l.verificationExpertReviewed,
    };

/// ✓ reference matched, ✓✓ expert reviewed, a grey dot otherwise (spec §11.5, §12.5).
/// The text label is always available to screen readers, and shown with [showLabel].
class VerificationBadge extends StatelessWidget {
  const VerificationBadge(this.status, {super.key, this.showLabel = false});

  final VerificationStatus status;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    final label = verificationLabel(l, status);
    final icon = switch (status) {
      VerificationStatus.expertReviewed => Icon(
        Icons.done_all,
        size: 18,
        color: c.durba,
      ),
      VerificationStatus.referenceMatched => Icon(
        Icons.done,
        size: 18,
        color: c.durba,
      ),
      _ => Icon(Icons.circle, size: 8, color: c.inkMuted),
    };
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 18, height: 18, child: Center(child: icon)),
          if (showLabel) ...[
            const SizedBox(width: Space.xs),
            Flexible(
              child: Text(
                label,
                style: t.bodySmall?.copyWith(color: c.inkMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A festival on a day: category bar, name, verification (spec §12.5).
class ObservanceChip extends StatelessWidget {
  const ObservanceChip({super.key, required this.observance, this.onTap});

  final ObservanceDate observance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    return Material(
      color: c.paperRaised,
      borderRadius: BorderRadius.circular(Radii.small),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Space.minTouch),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  color: categoryColor(c, observance.observance.category),
                ),
                const SizedBox(width: Space.s),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.s),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: NameText(
                        observance.observance.name,
                        style: t.labelLarge,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Space.s),
                Center(child: VerificationBadge(observance.status)),
                const SizedBox(width: Space.s),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// An upcoming festival with its date and countdown (Today and lists, spec §12.5).
class FestivalCard extends ConsumerWidget {
  const FestivalCard({
    super.key,
    required this.observance,
    required this.daysLeft,
    this.onTap,
  });

  final ObservanceDate observance;
  final int daysLeft;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    final f = ref.watch(formatterProvider);
    return Material(
      color: c.paperRaised,
      borderRadius: BorderRadius.circular(Radii.medium),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 6,
                color: categoryColor(c, observance.observance.category),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(Space.l),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NameText(
                        observance.observance.name,
                        style: t.titleMedium,
                      ),
                      const SizedBox(height: Space.xs),
                      Text(
                        f.gregorianDateShort(observance.date),
                        style: t.bodyMedium?.copyWith(color: c.inkMuted),
                      ),
                      const SizedBox(height: Space.s),
                      Wrap(
                        spacing: Space.m,
                        runSpacing: Space.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            l.countdownDays(daysLeft, f.countText(daysLeft)),
                            style: t.labelLarge?.copyWith(color: c.ink),
                          ),
                          VerificationBadge(observance.status, showLabel: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
