import 'package:flutter/material.dart';

/// Colour tokens (spec §12.2). Widgets read these via
/// `Theme.of(context).extension<PanjikaColors>()!` and never use hex literals.
@immutable
class PanjikaColors extends ThemeExtension<PanjikaColors> {
  const PanjikaColors({
    required this.ink,
    required this.inkMuted,
    required this.paper,
    required this.paperRaised,
    required this.alta,
    required this.haldi,
    required this.haldiStrong,
    required this.durba,
    required this.rule,
    required this.altaContainer,
    required this.haldiContainer,
    required this.onHaldiContainer,
    required this.durbaContainer,
    required this.neel,
    required this.padma,
  });

  /// Primary text.
  final Color ink;

  /// Secondary text, second-script line.
  final Color inkMuted;

  /// Background.
  final Color paper;

  /// Section backgrounds.
  final Color paperRaised;

  /// Sindoor red: festivals, Sundays, inauspicious.
  final Color alta;

  /// Turmeric: large decorative fills only. Light value is NOT a text or indicator colour.
  final Color haldi;

  /// Tithi ring progress, today marker, focus ring (≥ 3:1 on paper).
  final Color haldiStrong;

  /// Grass green: auspicious, verification ticks.
  final Color durba;

  /// Dividers (decorative).
  final Color rule;

  /// Active inauspicious period row.
  final Color altaContainer;

  /// Tithi seal background, today cell fill.
  final Color haldiContainer;

  /// Text/icons on [haldiContainer] when not [ink].
  final Color onHaldiContainer;

  /// Active auspicious period row, verification card.
  final Color durbaContainer;

  /// Category colour: vrata & fasts.
  final Color neel;

  /// Category colour: festival (utsav).
  final Color padma;

  static const light = PanjikaColors(
    ink: Color(0xFF1F1A3D),
    inkMuted: Color(0xFF5B567A),
    paper: Color(0xFFFFFFFF),
    paperRaised: Color(0xFFF6F4FB),
    alta: Color(0xFFB4232C),
    haldi: Color(0xFFE3A21A),
    haldiStrong: Color(0xFFB07607),
    durba: Color(0xFF2E7A4E),
    rule: Color(0xFFE2DFEE),
    altaContainer: Color(0xFFFBE9EA),
    haldiContainer: Color(0xFFFCF1D6),
    onHaldiContainer: Color(0xFF5C3D00),
    durbaContainer: Color(0xFFE3F2E9),
    neel: Color(0xFF3949AB),
    padma: Color(0xFFAD1457),
  );

  static const dark = PanjikaColors(
    ink: Color(0xFFECEAF7),
    inkMuted: Color(0xFFA9A5C4),
    paper: Color(0xFF15132B),
    paperRaised: Color(0xFF1E1C38),
    alta: Color(0xFFF0707A),
    haldi: Color(0xFFF2BE4E),
    haldiStrong: Color(0xFFF2BE4E),
    durba: Color(0xFF6CC596),
    rule: Color(0xFF2E2B4D),
    altaContainer: Color(0xFF4A1D26),
    haldiContainer: Color(0xFF3D3014),
    onHaldiContainer: Color(0xFFFFE3A3),
    durbaContainer: Color(0xFF173A2A),
    neel: Color(0xFF9FA8DA),
    padma: Color(0xFFF48FB1),
  );

  /// Festival category bar colours (spec §12.2), keyed by `observances.category`.
  Color category(String category) => switch (category) {
    'puja' => alta,
    'vrata' => neel,
    'tithi' => haldiStrong,
    'utsav' => padma,
    _ => inkMuted, // 'jayanti'
  };

  @override
  PanjikaColors copyWith() => this;

  @override
  PanjikaColors lerp(ThemeExtension<PanjikaColors>? other, double t) {
    if (other is! PanjikaColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return PanjikaColors(
      ink: l(ink, other.ink),
      inkMuted: l(inkMuted, other.inkMuted),
      paper: l(paper, other.paper),
      paperRaised: l(paperRaised, other.paperRaised),
      alta: l(alta, other.alta),
      haldi: l(haldi, other.haldi),
      haldiStrong: l(haldiStrong, other.haldiStrong),
      durba: l(durba, other.durba),
      rule: l(rule, other.rule),
      altaContainer: l(altaContainer, other.altaContainer),
      haldiContainer: l(haldiContainer, other.haldiContainer),
      onHaldiContainer: l(onHaldiContainer, other.onHaldiContainer),
      durbaContainer: l(durbaContainer, other.durbaContainer),
      neel: l(neel, other.neel),
      padma: l(padma, other.padma),
    );
  }
}
