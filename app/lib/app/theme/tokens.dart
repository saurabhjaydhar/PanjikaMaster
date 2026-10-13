import 'package:flutter/animation.dart';

/// Spacing, shape and motion tokens (spec §12.7, §12.8). 4 dp grid.
abstract final class Space {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 12.0;
  static const l = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;

  /// Screen margin on compact widths; 24 dp on medium/expanded (§12.7).
  static const screenCompact = l;
  static const screenWide = xl;

  /// Content max width on wide screens.
  static const maxContentWidth = 640.0;

  /// Minimum touch target (§12.6).
  static const minTouch = 48.0;
}

abstract final class Radii {
  static const small = 8.0; // chips, small buttons
  static const medium = 12.0; // cards, rows with fills
  static const large = 20.0; // sheets, tithi seal
}

abstract final class Motion {
  static const micro = Duration(milliseconds: 150);
  static const standard = Duration(milliseconds: 250);
  static const emphasis = Duration(milliseconds: 500);

  /// Material 3 emphasised easing (decelerate variant for things entering).
  static const emphasisedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);
}
