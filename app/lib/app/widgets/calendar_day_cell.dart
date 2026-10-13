import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_providers.dart';
import '../../domain/entities/panjika.dart';
import '../../domain/usecases/get_month_grid.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'observance_widgets.dart';

/// One day in the month grid (spec §11.3, §12.5): the day in the month's calendar large,
/// the other calendar's day small, moon markers drawn as shapes, and a bar in the first
/// festival's category colour. Today has a ring, the selected day a fill. Sunday
/// numerals are red by tradition; the column already says it is Sunday.
class CalendarDayCell extends ConsumerWidget {
  const CalendarDayCell({
    super.key,
    required this.primaryDay,
    required this.secondaryDay,
    required this.semanticsLabel,
    this.markers = const {},
    this.festivalCategory,
    this.isToday = false,
    this.isSelected = false,
    this.isSunday = false,
    this.onTap,
    this.onLongPress,
  });

  /// Bengali day in Bengali-month mode, Gregorian day in Gregorian mode.
  final int primaryDay;
  final int secondaryDay;

  /// Full sentence from `calendarCellSemantics` (and `todayPrefix`).
  final String semanticsLabel;
  final Set<MoonMarker> markers;
  final ObservanceCategory? festivalCategory;
  final bool isToday;
  final bool isSelected;
  final bool isSunday;
  final VoidCallback? onTap;

  /// Quick peek (FR-CAL-05).
  final VoidCallback? onLongPress;

  static const minWidth = 48.0;
  static const minHeight = 56.0;

  /// Screen margin around the month grid on compact widths: seven 48 dp cells fit a
  /// 360 dp phone only with 8 dp margins, not the usual 16 (spec §11.3, §12.7).
  static const gridMargin = Space.s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final f = ref.watch(formatterProvider);
    return Semantics(
      button: onTap != null,
      selected: isSelected,
      label: semanticsLabel,
      excludeSemantics: true,
      child: InkWell(
        // Light selection click on day selection (spec §12.8).
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(Radii.small),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: minWidth,
            minHeight: minHeight,
          ),
          decoration: BoxDecoration(
            color: isSelected ? c.haldiContainer : null,
            border: isToday ? Border.all(color: c.haldiStrong, width: 2) : null,
            borderRadius: BorderRadius.circular(Radii.small),
          ),
          padding: const EdgeInsets.symmetric(vertical: Space.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                f.digits('$primaryDay'),
                style: t.titleMedium?.copyWith(
                  color: isSunday ? c.alta : c.ink,
                ),
              ),
              Text(
                f.digits('$secondaryDay'),
                style: t.bodySmall?.copyWith(color: c.inkMuted),
              ),
              const SizedBox(height: Space.xs),
              SizedBox(
                height: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final m in MoonMarker.values)
                      if (markers.contains(m)) MoonMarkerGlyph(m),
                  ],
                ),
              ),
              if (festivalCategory != null)
                Container(
                  margin: const EdgeInsets.only(top: Space.xs),
                  width: 20,
                  height: 3,
                  decoration: BoxDecoration(
                    color: categoryColor(c, festivalCategory!),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ● Purnima, ○ Amavasya, ◐ Ekadashi: told apart by shape, not colour (spec §12.6).
class MoonMarkerGlyph extends StatelessWidget {
  const MoonMarkerGlyph(this.marker, {super.key, this.size = 8});

  final MoonMarker marker;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _MarkerPainter(marker, context.colors.ink)),
    );
  }
}

class _MarkerPainter extends CustomPainter {
  _MarkerPainter(this.marker, this.color);

  final MoonMarker marker;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2 - 0.75;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color;
    final fill = Paint()..color = color;
    switch (marker) {
      case MoonMarker.purnima:
        canvas.drawCircle(center, r, fill);
      case MoonMarker.amavasya:
        canvas.drawCircle(center, r, stroke);
      case MoonMarker.ekadashi:
        canvas.drawCircle(center, r, stroke);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: r),
          -math.pi / 2,
          math.pi,
          true,
          fill,
        );
    }
  }

  @override
  bool shouldRepaint(_MarkerPainter old) =>
      old.marker != marker || old.color != color;
}
