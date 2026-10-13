import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_language.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../core/settings/settings.dart';
import '../../domain/entities/name_ref.dart';
import '../theme/app_theme.dart';

/// TODO(Q15): default of "names in both scripts" per UI language. Off until decided
/// (the spec's recommendation is off in Bengali, on in English).
bool defaultNamesBothScripts(AppLanguage language) => false;

final showBothScriptsProvider = Provider<bool>(
  (ref) =>
      ref.watch(namesBothScriptsProvider) ??
      defaultNamesBothScripts(ref.watch(appLanguageProvider)),
);

/// The only widget that renders a panchanga or festival name (spec §12.5, §13.4): the
/// UI language on the first line and, with "names in both scripts", the other script
/// below in a smaller, muted style. The second line is hidden from screen readers so
/// TalkBack never reads Bengali with an English voice (§13.7).
class NameText extends ConsumerWidget {
  const NameText(
    this.name, {
    super.key,
    this.style,
    this.secondStyle,
    this.forceBoth = false,
  });

  final NameRef name;
  final TextStyle? style;
  final TextStyle? secondStyle;

  /// Festival detail always shows both scripts (spec §11.6).
  final bool forceBoth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final both = forceBoth || ref.watch(showBothScriptsProvider);
    final primary = Text(name.of(language), style: style);
    if (!both) return primary;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        primary,
        ExcludeSemantics(
          child: Text(
            name.other(language),
            style:
                secondStyle ??
                t.bodySmall?.copyWith(color: context.colors.inkMuted),
          ),
        ),
      ],
    );
  }
}
