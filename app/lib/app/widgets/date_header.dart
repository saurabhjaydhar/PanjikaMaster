import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_language.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../core/l10n/panjika_formatter.dart';
import '../../core/time/civil_date.dart';
import '../../domain/entities/name_ref.dart';
import '../../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import 'name_text.dart';

/// Weekday and city, the Bengali date in the display face, the Gregorian date below
/// (FR-HOME-01, spec §12.5). With "names in both scripts" the Bengali date is repeated
/// in the other script.
class DateHeader extends ConsumerWidget {
  const DateHeader({
    super.key,
    required this.date,
    required this.bengaliDay,
    required this.bengaliMonth,
    required this.bengaliYear,
    required this.city,
    this.onCityTap,
  });

  final CivilDate date;
  final int bengaliDay;
  final NameRef bengaliMonth;
  final int bengaliYear;
  final NameRef city;
  final VoidCallback? onCityTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final language = ref.watch(appLanguageProvider);
    final f = ref.watch(formatterProvider);
    final other = language == AppLanguage.bn ? AppLanguage.en : AppLanguage.bn;
    final otherF = PanjikaFormatter(
      language: other,
      numerals: other.defaultNumerals,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                f.weekday(date),
                style: t.labelLarge?.copyWith(color: c.inkMuted),
              ),
            ),
            CityChip(city: city, onTap: onCityTap),
          ],
        ),
        Text(
          f.bengaliDate(bengaliDay, bengaliMonth.of(language), bengaliYear),
          style: t.displaySmall,
        ),
        if (ref.watch(showBothScriptsProvider))
          ExcludeSemantics(
            child: Text(
              otherF.bengaliDate(
                bengaliDay,
                bengaliMonth.of(other),
                bengaliYear,
              ),
              style: t.bodySmall?.copyWith(color: c.inkMuted),
            ),
          ),
        Text(
          f.gregorianDate(date),
          style: t.bodyLarge?.copyWith(color: c.inkMuted),
        ),
      ],
    );
  }
}

/// The chosen city; tapping opens the city picker (spec §11.7).
class CityChip extends ConsumerWidget {
  const CityChip({super.key, required this.city, this.onTap});

  final NameRef city;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final name = city.of(ref.watch(appLanguageProvider));
    final avatar = Icon(
      Icons.place_outlined,
      size: 18,
      color: context.colors.ink,
    );
    return Semantics(
      button: onTap != null,
      label: l.cityChipSemantics(name),
      excludeSemantics: true,
      // Without a handler an ActionChip looks disabled; a plain chip reads as a label.
      child: onTap == null
          ? Chip(avatar: avatar, label: Text(name))
          : ActionChip(avatar: avatar, label: Text(name), onPressed: onTap),
    );
  }
}
