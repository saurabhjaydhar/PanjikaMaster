// T-109: every token pair meets WCAG 2.x contrast (spec §12.2, §12.6):
// text ≥ 4.5:1, meaningful graphics ≥ 3:1.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/theme/app_theme.dart';
import 'package:panjika/app/theme/panjika_colors.dart';
import 'package:panjika/core/l10n/app_language.dart';

double _channel(double c) =>
    c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4).toDouble();

double luminance(Color c) =>
    0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

double contrast(Color a, Color b) {
  final (la, lb) = (luminance(a), luminance(b));
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

void main() {
  for (final (name, c) in [
    ('light', PanjikaColors.light),
    ('dark', PanjikaColors.dark),
  ]) {
    group('$name tokens', () {
      final text = <String, (Color, Color)>{
        'ink/paper': (c.ink, c.paper),
        'ink/paperRaised': (c.ink, c.paperRaised),
        'inkMuted/paper': (c.inkMuted, c.paper),
        'inkMuted/paperRaised': (c.inkMuted, c.paperRaised),
        'alta/paper': (c.alta, c.paper),
        'alta/paperRaised': (c.alta, c.paperRaised),
        'durba/paper': (c.durba, c.paper),
        'durba/paperRaised': (c.durba, c.paperRaised),
        'ink/altaContainer': (c.ink, c.altaContainer),
        'ink/haldiContainer': (c.ink, c.haldiContainer),
        'ink/durbaContainer': (c.ink, c.durbaContainer),
        'onHaldiContainer/haldiContainer': (
          c.onHaldiContainer,
          c.haldiContainer,
        ),
        'alta/altaContainer': (
          c.alta,
          c.altaContainer,
        ), // "Now" label on the active period
        'inkMuted/haldiContainer': (
          c.inkMuted,
          c.haldiContainer,
        ), // seal's second line
      };
      final graphics = <String, (Color, Color)>{
        'haldiStrong/paper': (c.haldiStrong, c.paper),
        'haldiStrong/paperRaised': (c.haldiStrong, c.paperRaised),
        'haldiStrong/haldiContainer': (
          c.haldiStrong,
          c.haldiContainer,
        ), // tithi ring on seal
        'durba/durbaContainer': (
          c.durba,
          c.durbaContainer,
        ), // ✓✓ on verification card
        for (final cat in ['puja', 'vrata', 'tithi', 'utsav', 'jayanti']) ...{
          '$cat/paper': (c.category(cat), c.paper),
          '$cat/paperRaised': (c.category(cat), c.paperRaised),
        },
      };
      text.forEach((pair, colors) {
        test('text $pair ≥ 4.5', () {
          expect(contrast(colors.$1, colors.$2), greaterThanOrEqualTo(4.5));
        });
      });
      graphics.forEach((pair, colors) {
        test('graphic $pair ≥ 3', () {
          expect(contrast(colors.$1, colors.$2), greaterThanOrEqualTo(3.0));
        });
      });
    });

    test('$name ColorScheme on-colours are readable (≥ 4.5)', () {
      final brightness = name == 'light' ? Brightness.light : Brightness.dark;
      final s = buildPanjikaTheme(brightness, AppLanguage.bn).colorScheme;
      final pairs = {
        'onPrimary': (s.onPrimary, s.primary),
        'onSecondary': (s.onSecondary, s.secondary),
        'onSecondaryContainer': (s.onSecondaryContainer, s.secondaryContainer),
        'onTertiary': (s.onTertiary, s.tertiary),
        'onError': (s.onError, s.error),
        'onSurface': (s.onSurface, s.surface),
        'onSurfaceVariant': (s.onSurfaceVariant, s.surface),
      };
      pairs.forEach(
        (k, v) =>
            expect(contrast(v.$1, v.$2), greaterThanOrEqualTo(4.5), reason: k),
      );
    });
  }

  test('light haldi is decorative only: it fails 3:1 on white, as the spec records', () {
    expect(
      contrast(PanjikaColors.light.haldi, PanjikaColors.light.paper),
      lessThan(3.0),
    );
  });
}
