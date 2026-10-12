import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/app_language.dart';
import '../core/l10n/l10n_providers.dart';
import '../l10n/gen/app_localizations.dart';

/// Root widget. Theme arrives in T-109 and routing in T-111.
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
