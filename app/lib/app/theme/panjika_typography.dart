import 'package:flutter/material.dart';

import '../../core/l10n/app_language.dart';

/// Per-script type scale (spec §12.3). Bengali needs more line height than Latin
/// (matras, reph, conjuncts) and is never set below 13 sp.
class _Role {
  const _Role(this.size, this.lineHeight);
  final double size;
  final double lineHeight;
}

class _Scale {
  const _Scale({
    required this.display,
    required this.headline,
    required this.title,
    required this.body,
    required this.label,
    required this.caption,
  });
  final _Role display, headline, title, body, label, caption;
}

const _bn = _Scale(
  display: _Role(34, 48),
  headline: _Role(26, 36),
  title: _Role(22, 30),
  body: _Role(16, 26),
  label: _Role(14, 22),
  caption: _Role(13, 20),
);

const _en = _Scale(
  display: _Role(32, 40),
  headline: _Role(24, 32),
  title: _Role(20, 28),
  body: _Role(16, 24),
  label: _Role(14, 20),
  caption: _Role(12, 16),
);

/// Font families. Tiro Bangla (regular only) for display sizes in both scripts; Noto for
/// text. Each falls back to the other script's family, so mixed strings never show tofu.
const tiroBangla = 'TiroBangla';
const notoSansBengali = 'NotoSansBengali';
const notoSans = 'NotoSans';

/// The `TextTheme` for one UI language. Widgets never set `fontFamily` or sizes directly.
TextTheme panjikaTextTheme(AppLanguage language, Color ink) {
  final bn = language == AppLanguage.bn;
  final scale = bn ? _bn : _en;
  final sans = bn ? notoSansBengali : notoSans;
  final sansFallback = [if (bn) notoSans else notoSansBengali];

  TextStyle style(
    _Role role, {
    required bool display,
    FontWeight weight = FontWeight.w400,
  }) => TextStyle(
    fontFamily: display ? tiroBangla : sans,
    fontFamilyFallback: display ? [sans, ...sansFallback] : sansFallback,
    fontSize: role.size,
    height: role.lineHeight / role.size,
    // Tiro Bangla ships one weight; never let Flutter synthesise bold.
    fontWeight: display ? FontWeight.w400 : weight,
    // Never letter-space Bengali (§12.11); English matches for parity.
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
    color: ink,
  );

  final display = style(scale.display, display: true);
  final headline = style(scale.headline, display: true);
  final title = style(scale.title, display: true);
  final body = style(scale.body, display: false);
  final label = style(scale.label, display: false, weight: FontWeight.w500);
  final caption = style(scale.caption, display: false);

  return TextTheme(
    displayLarge: display,
    displayMedium: display,
    displaySmall: display,
    headlineLarge: headline,
    headlineMedium: headline,
    headlineSmall: headline,
    titleLarge: title,
    titleMedium: body.copyWith(fontWeight: FontWeight.w500),
    titleSmall: label,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: caption,
    labelLarge: label,
    labelMedium: label,
    labelSmall: caption.copyWith(fontWeight: FontWeight.w500),
  );
}
