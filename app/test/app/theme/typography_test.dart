// T-109: the per-script type scale follows spec §12.3 and the rules in §12.11.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/theme/app_theme.dart';
import 'package:panjika/core/l10n/app_language.dart';

List<TextStyle> styles(TextTheme t) => [
  t.displayLarge!,
  t.displayMedium!,
  t.displaySmall!,
  t.headlineLarge!,
  t.headlineMedium!,
  t.headlineSmall!,
  t.titleLarge!,
  t.titleMedium!,
  t.titleSmall!,
  t.bodyLarge!,
  t.bodyMedium!,
  t.bodySmall!,
  t.labelLarge!,
  t.labelMedium!,
  t.labelSmall!,
];

void main() {
  for (final language in AppLanguage.values) {
    for (final brightness in Brightness.values) {
      final t = buildPanjikaTheme(brightness, language).textTheme;

      test('$language/$brightness: no letter spacing, even leading', () {
        for (final s in styles(t)) {
          expect(s.letterSpacing, 0);
          expect(s.leadingDistribution, TextLeadingDistribution.even);
        }
      });

      test(
        '$language/$brightness: Tiro Bangla is never bold, Noto stays within 400–600',
        () {
          for (final s in styles(t)) {
            if (s.fontFamily == 'TiroBangla') {
              expect(s.fontWeight, FontWeight.w400);
            }
            expect(s.fontWeight!.value, inInclusiveRange(400, 600));
          }
        },
      );

      test(
        '$language/$brightness: every style falls back to the other script',
        () {
          for (final s in styles(t)) {
            final other = language == AppLanguage.bn
                ? 'NotoSans'
                : 'NotoSansBengali';
            expect(s.fontFamilyFallback, contains(other));
          }
        },
      );
    }
  }

  test('Bengali sizes and line heights (spec §12.3)', () {
    final t = buildPanjikaTheme(Brightness.light, AppLanguage.bn).textTheme;
    expect(
      (
        t.displaySmall!.fontSize,
        t.displaySmall!.fontSize! * t.displaySmall!.height!,
      ),
      (34, 48),
    );
    expect(
      (t.bodyLarge!.fontSize, t.bodyLarge!.fontSize! * t.bodyLarge!.height!),
      (16, 26),
    );
    expect(t.bodyLarge!.fontFamily, 'NotoSansBengali');
    expect(t.displaySmall!.fontFamily, 'TiroBangla');
    for (final s in styles(t)) {
      expect(
        s.fontSize,
        greaterThanOrEqualTo(13),
        reason: 'Bengali never below 13 sp',
      );
    }
  });

  test('English sizes and line heights (spec §12.3)', () {
    final t = buildPanjikaTheme(Brightness.light, AppLanguage.en).textTheme;
    expect(
      (
        t.displaySmall!.fontSize,
        t.displaySmall!.fontSize! * t.displaySmall!.height!,
      ),
      (32, 40),
    );
    expect(
      (t.bodySmall!.fontSize, t.bodySmall!.fontSize! * t.bodySmall!.height!),
      (12, 16),
    );
    expect(t.bodyLarge!.fontFamily, 'NotoSans');
  });
}
