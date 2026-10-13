import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_providers.dart';
import '../../core/l10n/panjika_formatter.dart';
import '../../domain/entities/panjika.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Thin moon-phase ring showing progress through the tithi (spec §12.1, §12.5). With
/// [animateFill] it fills from empty on first build (500 ms, emphasised easing); after
/// that, and whenever reduced motion is on, it follows [progress] without animating
/// (spec §12.8).
class TithiRing extends StatefulWidget {
  const TithiRing({
    super.key,
    required this.progress,
    this.size = 64,
    this.animateFill = false,
  });

  final double progress;
  final double size;
  final bool animateFill;

  @override
  State<TithiRing> createState() => TithiRingState();
}

class TithiRingState extends State<TithiRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fill = AnimationController(
    vsync: this,
    duration: Motion.emphasis,
    value: 1,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _fill,
    curve: Motion.emphasisedDecelerate,
  );

  /// What the ring shows right now.
  @visibleForTesting
  double get displayedProgress => widget.progress * _curve.value;

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery is not available in initState.
    if (widget.animateFill && !_started) {
      _started = true;
      if (!MediaQuery.disableAnimationsOf(context)) _fill.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _curve,
          builder: (context, _) => CustomPaint(
            painter: _RingPainter(
              progress: displayedProgress,
              track: c.haldiStrong.withValues(alpha: 0.22),
              fill: c.haldiStrong,
              moon: c.haldiStrong,
              disc: c.paper,
            ),
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
    // Two per row; at large text a single column, so labels like "Moonrise" never
    // break mid-word (§12.10: no side-by-side rows at 200 % on 360 dp).
    final large = MediaQuery.textScalerOf(context).scale(10) > 15;
    return LayoutBuilder(
      builder: (context, box) {
        final width = large ? box.maxWidth : (box.maxWidth - Space.s) / 2;
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
class ProvenanceFooter extends ConsumerWidget {
  const ProvenanceFooter({
    super.key,
    required this.provenance,
    this.detailed = false,
  });

  final Provenance provenance;

  /// Adds coordinates, data packs and verification status (Day detail, FR-DAY-04).
  final bool detailed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final language = ref.watch(appLanguageProvider);
    return Padding(
      padding: const EdgeInsets.only(top: Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: Space.s),
          Text(
            l.provenance(
              provenance.tradition.of(language),
              provenance.city.of(language),
              l.timeZoneLabel,
            ),
            style: t.bodySmall?.copyWith(color: context.colors.inkMuted),
          ),
          if (detailed)
            Text(
              _detail(l, ref.watch(formatterProvider)),
              style: t.bodySmall?.copyWith(color: context.colors.inkMuted),
            ),
        ],
      ),
    );
  }

  String _detail(AppLocalizations l, PanjikaFormatter f) {
    final lat = provenance.latitude, lon = provenance.longitude;
    final coordinates = lat == null || lon == null
        ? ''
        : l.coordinates(
            f.digits(lat.toStringAsFixed(2)),
            f.digits(lon.toStringAsFixed(2)),
          );
    // Transitions are computed until the validation harness matches them (§6.8).
    final status = provenance.isSample
        ? l.verificationSample
        : l.verificationComputed;
    return l.footerDetail(coordinates, provenance.packIds.join(', '), status);
  }
}

/// The system states of spec §11.9, each with its own icon.
enum StateKind {
  noData(Icons.event_busy_outlined),
  notDownloaded(Icons.cloud_download_outlined),
  offline(Icons.cloud_off_outlined),
  stale(Icons.update),
  signatureFailed(Icons.gpp_maybe_outlined),
  checkClock(Icons.schedule),
  comingSoon(Icons.hourglass_empty);

  const StateKind(this.icon);
  final IconData icon;
}

/// Explicit system state (spec §11.9): an icon, a message and an optional action, never
/// numbers.
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.message,
    this.kind = StateKind.noData,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final StateKind kind;
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
            ExcludeSemantics(
              child: Icon(kind.icon, size: 40, color: context.colors.inkMuted),
            ),
            const SizedBox(height: Space.l),
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

/// Section title in lists and Day detail (spec §12.5, §12.7); sticky headers use it too.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Semantics(
      header: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Space.minTouch),
        child: Row(
          children: [
            Expanded(child: Text(title, style: t.titleMedium)),
            ?action,
          ],
        ),
      ),
    );
  }
}

/// Loading placeholder exactly the size of what it stands for, so nothing shifts when
/// the content arrives (spec §12.5). Text lines take their height from [style] and the
/// current text scale.
class Skeleton extends StatelessWidget {
  const Skeleton.box({super.key, required this.width, required this.height})
    : style = null,
      lines = 1;

  /// [lines] lines of text in [style]; [width] is the share of the available width.
  const Skeleton.text({super.key, required this.style, this.lines = 1})
    : width = null,
      height = null;

  final double? width;
  final double? height;
  final TextStyle? style;
  final int lines;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final shape = BoxDecoration(
      color: c.rule,
      borderRadius: BorderRadius.circular(Radii.small),
    );
    final Widget body;
    if (style == null) {
      body = Container(width: width, height: height, decoration: shape);
    } else {
      final scaler = MediaQuery.textScalerOf(context);
      final size = scaler.scale(style!.fontSize ?? 14);
      final lineHeight = size * (style!.height ?? 1.2);
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < lines; i++)
            Padding(
              padding: EdgeInsets.symmetric(vertical: (lineHeight - size) / 2),
              child: FractionallySizedBox(
                widthFactor: i == lines - 1 && lines > 1 ? 0.6 : 1,
                child: Container(height: size, decoration: shape),
              ),
            ),
        ],
      );
    }
    return Semantics(
      label: l.loading,
      child: ExcludeSemantics(child: body),
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
