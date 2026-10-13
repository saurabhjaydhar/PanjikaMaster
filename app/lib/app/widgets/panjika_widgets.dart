import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Thin moon-phase ring showing progress through the tithi (spec §12.1, §12.5).
class TithiRing extends StatelessWidget {
  const TithiRing({super.key, required this.progress, this.size = 64});

  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(
            progress: progress,
            track: c.haldiStrong.withValues(alpha: 0.22),
            fill: c.haldiStrong,
            moon: c.haldiStrong,
            disc: c.paper,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.track,
    required this.fill,
    required this.moon,
    required this.disc,
  });

  final double progress;
  final Color track;
  final Color fill;
  final Color moon;
  final Color disc;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.075;
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - stroke / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = fill,
    );
    // A small half-lit moon in the middle (decorative).
    final moonRadius = radius * 0.42;
    canvas.drawCircle(
      center,
      moonRadius,
      Paint()..color = Color.alphaBlend(moon.withValues(alpha: 0.18), disc),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: moonRadius),
      -math.pi / 2,
      math.pi,
      true,
      Paint()..color = moon,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.fill != fill || old.track != track;
}

/// Label + value row, ≥ 48 dp (spec §12.5). Normally a fixed label column with the value
/// wrapping beside it; at large text sizes the value moves under the label, because a
/// narrow label column would break words mid-way (spec §11.2, §12.11).
class PanchangRow extends StatelessWidget {
  const PanchangRow({super.key, required this.label, required this.value});

  final String label;
  final Widget value;

  /// Above roughly 140 % text, stack label over value.
  static const _stackAboveScale = 1.4;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final labelText = Text(
      label,
      style: t.labelLarge?.copyWith(color: context.colors.inkMuted),
    );
    final valueText = DefaultTextStyle.merge(style: t.bodyLarge, child: value);
    final stacked =
        MediaQuery.textScalerOf(context).scale(10) / 10 > _stackAboveScale;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: Space.minTouch),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.s),
        child: MergeSemantics(
          child: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    labelText,
                    const SizedBox(height: Space.xs),
                    valueText,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    SizedBox(width: _labelWidth, child: labelText),
                    const SizedBox(width: Space.m),
                    Expanded(child: valueText),
                  ],
                ),
        ),
      ),
    );
  }

  /// Fits "Nakshatra" at Label size; Bengali labels are shorter.
  static const _labelWidth = 92.0;
}

/// One cell of the sun/moon timing strip.
class TimingCell extends StatelessWidget {
  const TimingCell({
    super.key,
    required this.icon,
    required this.label,
    required this.time,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String time;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(
        horizontal: Space.m,
        vertical: Space.s,
      ),
      decoration: BoxDecoration(
        color: c.paperRaised,
        borderRadius: BorderRadius.circular(Radii.medium),
      ),
      child: MergeSemantics(
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? c.haldiStrong, size: 22),
            const SizedBox(width: Space.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: t.bodySmall?.copyWith(color: c.inkMuted)),
                  Text(time, style: t.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two columns of [TimingCell]s that grow in height (never shrink text) at large scales.
class TimingStrip extends StatelessWidget {
  const TimingStrip({super.key, required this.cells});

  final List<Widget> cells;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final width = (box.maxWidth - Space.s) / 2;
        return Wrap(
          spacing: Space.s,
          runSpacing: Space.s,
          children: [
            for (final cell in cells) SizedBox(width: width, child: cell),
          ],
        );
      },
    );
  }
}

/// Tradition · city · IST, on every date screen (spec §6.8, US-02).
class ProvenanceFooter extends StatelessWidget {
  const ProvenanceFooter({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: Space.s),
          Text(
            text,
            style: t.bodySmall?.copyWith(color: context.colors.inkMuted),
          ),
        ],
      ),
    );
  }
}

/// Explicit system state (spec §11.9): a message and an optional action, never numbers.
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: t.titleLarge, textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: Space.l),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Diagonal "নমুনা · SAMPLE" over sample data (spec §6.8). Only sample packs trigger it,
/// and sample packs exist only in debug builds.
class SampleWatermark extends StatelessWidget {
  const SampleWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Center(
          child: Transform.rotate(
            angle: -0.56,
            child: Text(
              AppLocalizations.of(context).sampleWatermark,
              style: t.displayLarge?.copyWith(
                color: context.colors.alta.withValues(alpha: 0.12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
