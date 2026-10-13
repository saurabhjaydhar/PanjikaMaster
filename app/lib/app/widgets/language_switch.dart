import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_language.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../l10n/gen/app_localizations.dart';

/// "বাংলা | English": each label in its own script, never translated (spec §12.5).
/// Switching re-renders at once (FR-SET-05).
class LanguageSwitch extends ConsumerWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = ref.watch(appLanguageProvider);
    return SegmentedButton<AppLanguage>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: AppLanguage.bn,
          label: Text(l.languageNameBengali, locale: AppLanguage.bn.locale),
        ),
        ButtonSegment(
          value: AppLanguage.en,
          label: Text(l.languageNameEnglish, locale: AppLanguage.en.locale),
        ),
      ],
      selected: {current},
      onSelectionChanged: (s) =>
          ref.read(appLanguageProvider.notifier).select(s.single),
    );
  }
}
