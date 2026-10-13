import 'package:flutter/material.dart';

import '../../core/l10n/app_language.dart';
import 'panjika_colors.dart';
import 'panjika_typography.dart';
import 'tokens.dart';

/// Builds the Material 3 theme from the tokens (spec §12.2–12.3). No dynamic colour
/// (Material You): the ink-and-alta identity and measured contrast matter more.
ThemeData buildPanjikaTheme(Brightness brightness, AppLanguage language) {
  final light = brightness == Brightness.light;
  final c = light ? PanjikaColors.light : PanjikaColors.dark;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.ink,
    onPrimary: c.paper,
    primaryContainer: c.paperRaised,
    onPrimaryContainer: c.ink,
    // haldi-strong is a graphic colour; if text ever sits on it, only black passes
    // 4.5:1 in light mode (checked by the contrast test).
    secondary: c.haldiStrong,
    onSecondary: light ? const Color(0xFF000000) : c.paper,
    secondaryContainer: c.haldiContainer,
    onSecondaryContainer: c.onHaldiContainer,
    tertiary: c.durba,
    onTertiary: c.paper,
    tertiaryContainer: c.durbaContainer,
    onTertiaryContainer: c.ink,
    error: c.alta,
    onError: c.paper,
    errorContainer: c.altaContainer,
    onErrorContainer: c.ink,
    surface: c.paper,
    onSurface: c.ink,
    onSurfaceVariant: c.inkMuted,
    surfaceContainerLowest: c.paper,
    surfaceContainerLow: c.paper,
    surfaceContainer: c.paperRaised,
    surfaceContainerHigh: c.paperRaised,
    surfaceContainerHighest: c.paperRaised,
    outline: c.inkMuted,
    outlineVariant: c.rule,
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    inverseSurface: c.ink,
    onInverseSurface: c.paper,
    inversePrimary: c.paper,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.paper,
    textTheme: panjikaTextTheme(language, c.ink),
    dividerTheme: DividerThemeData(color: c.rule, space: 1, thickness: 1),
    // Flat by default: hierarchy from tonal surfaces, not shadows (§12.7).
    cardTheme: CardThemeData(
      color: c.paperRaised,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.medium),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.large)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.paper,
      indicatorColor: c.haldiContainer,
      // Labels always visible (spec §10).
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
    extensions: [c],
  );
}

/// Convenience accessor for widgets.
extension PanjikaThemeX on BuildContext {
  PanjikaColors get colors => Theme.of(this).extension<PanjikaColors>()!;

  /// [duration], or zero when the system asks for reduced motion (spec §12.6, §12.8).
  Duration motion(Duration duration) =>
      MediaQuery.disableAnimationsOf(this) ? Duration.zero : duration;
}

/// The minimum content padding for the current width class (§12.7).
double screenMargin(double width) =>
    width >= 600 ? Space.screenWide : Space.screenCompact;
