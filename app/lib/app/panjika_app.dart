import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/app_language.dart';
import '../core/l10n/l10n_providers.dart';
import '../core/settings/settings.dart';
import '../l10n/gen/app_localizations.dart';
import 'theme/app_theme.dart';

/// Root widget. Routing arrives in T-111.
class PanjikaApp extends ConsumerStatefulWidget {
  const PanjikaApp({super.key});

  @override
  ConsumerState<PanjikaApp> createState() => _PanjikaAppState();
}

class _PanjikaAppState extends ConsumerState<PanjikaApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(appLanguageProvider.notifier).syncFromSystem();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Android 13+ reports a per-app language change made in system settings as a
  /// locale change (FR-L10N-03).
  @override
  void didChangeLocales(List<Locale>? locales) {
    ref.read(appLanguageProvider.notifier).syncFromSystem();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final userScale = ref.watch(textScaleProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildPanjikaTheme(Brightness.light, language),
      darkTheme: buildPanjikaTheme(Brightness.dark, language),
      themeMode: ref.watch(themeModeProvider),
      // The in-app text size multiplies the system setting (incl. Android 14+ nonlinear
      // scaling); it is never clamped (spec §12.6).
      builder: (context, child) {
        if (userScale == null || userScale == 1.0) return child!;
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: _MultipliedTextScaler(media.textScaler, userScale),
          ),
          child: child!,
        );
      },
      locale: language.locale,
      supportedLocales: [for (final l in AppLanguage.values) l.locale],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      home: const _Placeholder(),
    );
  }
}

/// Stand-in home until the app shell (T-111): shows the app title so language
/// switching is visible and testable.
class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(child: Text(AppLocalizations.of(context).appTitle)),
      ),
    );
  }
}

/// Applies the user's in-app multiplier on top of the system [TextScaler].
class _MultipliedTextScaler extends TextScaler {
  const _MultipliedTextScaler(this.system, this.factor);

  final TextScaler system;
  final double factor;

  @override
  double scale(double fontSize) => system.scale(fontSize) * factor;

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => system.textScaleFactor * factor;

  @override
  bool operator ==(Object other) =>
      other is _MultipliedTextScaler &&
      other.system == system &&
      other.factor == factor;

  @override
  int get hashCode => Object.hash(system, factor);
}
