import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// A simple alpona-inspired linework motif for share cards (spec §11.8), drawn in
/// code by us: a centre dot, eight petals, a ring of dots and a scalloped edge. No
/// religious imagery (§19.1 L23). Recorded in docs/assets.md.
class AlponaMotif extends StatelessWidget {
  const AlponaMotif({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _AlponaPainter(line: c.alta, accent: c.haldiStrong),
      ),
    );
  }
}

class _AlponaPainter extends CustomPainter {
  const _AlponaPainter({required this.line, required this.accent});

  final Color line;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final centre = size.center(Offset.zero);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.025
      ..strokeCap = StrokeCap.round
      ..color = line;
    final fill = Paint()..color = accent;

    canvas.drawCircle(centre, r * 0.08, fill);
    canvas.drawCircle(centre, r * 0.16, stroke);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas
        ..save()
        ..translate(centre.dx, centre.dy)
        ..rotate(a);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0, -r * 0.38),
          width: r * 0.22,
          height: r * 0.4,
        ),
        stroke,
      );
      canvas.restore();
    }
    for (var i = 0; i < 16; i++) {
      final a = i * math.pi / 8;
      canvas.drawCircle(
        centre + Offset(math.cos(a), math.sin(a)) * r * 0.7,
        r * 0.035,
        fill,
      );
    }
    final edge = Path();
    const scallops = 24;
    for (var i = 0; i < scallops; i++) {
      final a0 = i * 2 * math.pi / scallops;
      final a1 = (i + 1) * 2 * math.pi / scallops;
      final mid = (a0 + a1) / 2;
      final p0 = centre + Offset(math.cos(a0), math.sin(a0)) * r * 0.86;
      final p1 = centre + Offset(math.cos(a1), math.sin(a1)) * r * 0.86;
      final ctrl = centre + Offset(math.cos(mid), math.sin(mid)) * r * 1.02;
      if (i == 0) edge.moveTo(p0.dx, p0.dy);
      edge.quadraticBezierTo(ctrl.dx, ctrl.dy, p1.dx, p1.dy);
    }
    canvas.drawPath(edge, stroke);
  }

  @override
  bool shouldRepaint(_AlponaPainter old) =>
      old.line != line || old.accent != accent;
}
