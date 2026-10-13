import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../app/widgets/language_switch.dart';
import '../../app/widgets/name_text.dart';
import '../../app/widgets/panjika_widgets.dart';
import '../../core/l10n/app_language.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../core/l10n/panjika_formatter.dart';
import '../../core/settings/settings.dart';
import '../../data/packs/update_providers.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/usecases/assess_coverage.dart';
import '../../l10n/gen/app_localizations.dart';
import '../city/city_providers.dart';
import 'tradition.dart';

/// Every installed pack's range, for the "Downloaded data" row.
final installedPacksProvider = FutureProvider<List<PackRange>>(
  (ref) => ref.watch(panjikaRepositoryProvider).installedPacks(),
);

/// Settings (সেটিংস, spec §11.15, FR-SET-01, FR-SET-05/06, FR-L10N-04).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatterProvider);
    final language = ref.watch(appLanguageProvider);
    final names = ref.watch(namesProvider).value;
    final t = Theme.of(context).textTheme;
    final c = context.colors;
    final updates = ref.read(updateControllerProvider.notifier);
    final city = ref.watch(cityNameProvider).value;
    final packs = ref.watch(installedPacksProvider).value ?? const [];
    final globals = [
      for (final p in packs)
        if (p.kind == 'global') p,
    ];

    Widget label(String text) => Text(text, style: t.bodyLarge);

    Widget row(String title, Widget trailing) => ConstrainedBox(
      constraints: const BoxConstraints(minHeight: Space.minTouch),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.s),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: Space.s,
          spacing: Space.m,
          children: [label(title), trailing],
        ),
      ),
    );

    Widget link(String title, String? value, VoidCallback? onTap) => InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Space.minTouch),
        child: Row(
          children: [
            Expanded(child: label(title)),
            if (value != null)
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: t.bodyMedium?.copyWith(color: c.inkMuted),
                ),
              ),
            if (onTap != null) const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );

    final themeMode = ref.watch(themeModeProvider);
    final timeFormat = ref.watch(timeFormatProvider);
    final numerals = ref.watch(numeralOverrideProvider);
    final scale = ref.watch(textScaleProvider) ?? 1.0;
    final bnDigits = const PanjikaFormatter(
      language: AppLanguage.bn,
      numerals: NumeralStyle.bengali,
    ).digits('123');

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: contentInset(MediaQuery.sizeOf(context).width),
        ),
        children: [
          row(l.languageSetting, const LanguageSwitch()),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: label(l.settingNamesBoth),
            // FR-SET-06: preview line with a real name from the packs.
            subtitle: names == null
                ? null
                : NameText(
                    names.of('tithi', 6),
                    forceBoth: true,
                    style: t.bodyMedium?.copyWith(color: c.inkMuted),
                  ),
            value: ref.watch(showBothScriptsProvider),
            onChanged: (v) =>
                ref.read(namesBothScriptsProvider.notifier).set(v),
          ),
          link(
            l.settingTradition,
            names?.tradition(ref.watch(traditionProvider)).of(language),
            names == null ? null : () => _showTraditions(context, ref),
          ),
          link(
            l.settingCity,
            city?.of(language),
            () => context.push(Routes.city),
          ),
          row(
            l.settingTheme,
            SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(l.themeSystem),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(l.themeLight),
                ),
                ButtonSegment(value: ThemeMode.dark, label: Text(l.themeDark)),
              ],
              selected: {themeMode},
              onSelectionChanged: (s) =>
                  ref.read(themeModeProvider.notifier).set(s.single),
            ),
          ),
          label(l.settingTextSize),
          Row(
            children: [
              const ExcludeSemantics(child: Icon(Icons.text_decrease)),
              Expanded(
                child: Slider(
                  value: scale,
                  min: 0.85,
                  max: 2.0,
                  divisions: 23,
                  label: f.digits('${(scale * 100).round()}%'),
                  semanticFormatterCallback: (v) =>
                      f.digits('${(v * 100).round()}%'),
                  onChanged: (v) => ref.read(textScaleProvider.notifier).set(v),
                ),
              ),
              const ExcludeSemantics(child: Icon(Icons.text_increase)),
            ],
          ),
          Text(l.textSizePreview, style: t.bodyLarge),
          const SizedBox(height: Space.m),
          row(
            l.settingTimeFormat,
            SegmentedButton<TimeFormat>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: TimeFormat.h12,
                  label: Text(l.timeFormatHours(f.digits('12'))),
                ),
                ButtonSegment(
                  value: TimeFormat.h24,
                  label: Text(l.timeFormatHours(f.digits('24'))),
                ),
              ],
              selected: {timeFormat},
              onSelectionChanged: (s) =>
                  ref.read(timeFormatProvider.notifier).set(s.single),
            ),
          ),
          label(l.settingNumerals),
          RadioGroup<NumeralStyle?>(
            groupValue: numerals,
            onChanged: (v) => ref.read(numeralOverrideProvider.notifier).set(v),
            child: Column(
              children: [
                RadioListTile<NumeralStyle?>(
                  contentPadding: EdgeInsets.zero,
                  value: null,
                  title: Text(l.numeralsAuto),
                ),
                RadioListTile<NumeralStyle?>(
                  contentPadding: EdgeInsets.zero,
                  value: NumeralStyle.bengali,
                  title: Text(
                    l.numeralsBengali(bnDigits),
                    semanticsLabel: l.numeralsBengaliSemantics,
                  ),
                ),
                RadioListTile<NumeralStyle?>(
                  contentPadding: EdgeInsets.zero,
                  value: NumeralStyle.latin,
                  title: Text(
                    l.numeralsLatin('123'), // l10n-ok: digits sample
                    semanticsLabel: l.numeralsLatinSemantics,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.l),
          SectionHeader(title: l.sectionData),
          if (updates.available) link(l.checkDataNow, null, updates.refresh),
          link(
            l.installedData,
            globals.isEmpty
                ? null
                : l.dataRange(
                    f.gregorianDate(
                      globals
                          .map((p) => p.from)
                          .reduce((a, b) => a.compareTo(b) < 0 ? a : b),
                    ),
                    f.gregorianDate(
                      globals
                          .map((p) => p.to)
                          .reduce((a, b) => a.compareTo(b) > 0 ? a : b),
                    ),
                  ),
            null,
          ),
          const SizedBox(height: Space.l),
          SectionHeader(title: l.sectionOther),
          link(l.menuRemoveAds, null, () => context.push(Routes.removeAds)),
          link(l.menuPrivacy, null, () => context.push(Routes.privacy)),
          link(l.licences, null, () => showLicensePage(context: context)),
          link(l.menuAbout, null, () => context.push(Routes.about)),
          const SizedBox(height: Space.xl),
        ],
      ),
    );
  }
}

/// Tradition list; unavailable ones say "coming soon" (T-410); a change asks first
/// (spec §11.15).
Future<void> _showTraditions(
  BuildContext context,
  WidgetRef ref,
) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (sheet) => Consumer(
    // The sheet's own ref dies with the sheet: the change itself uses [ref].
    builder: (sheet, sheetRef, _) {
      final l = AppLocalizations.of(sheet);
      final names = sheetRef.watch(namesProvider).value;
      final language = sheetRef.watch(appLanguageProvider);
      final current = sheetRef.watch(traditionProvider);
      final available = sheetRef.watch(availableTraditionsProvider);
      if (names == null) return const SizedBox.shrink();
      return SafeArea(
        child: RadioGroup<String>(
          groupValue: current,
          onChanged: (id) async {
            if (id == null || id == current || !available.contains(id)) return;
            Navigator.of(sheet).pop();
            final ok = await _confirmChange(context);
            if (ok) await ref.read(traditionChangerProvider)(id);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final id in names.traditionIds)
                RadioListTile<String>(
                  value: id,
                  enabled: available.contains(id),
                  title: Text(names.tradition(id).of(language)),
                  subtitle: available.contains(id) ? null : Text(l.comingSoon),
                ),
            ],
          ),
        ),
      );
    },
  ),
);

Future<bool> _confirmChange(BuildContext context) async {
  final l = AppLocalizations.of(context);
  final ok = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.xl, 0, Space.xl, Space.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.traditionConfirm,
              style: Theme.of(sheet).textTheme.bodyLarge,
            ),
            const SizedBox(height: Space.l),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: Space.s,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(sheet).pop(false),
                  child: Text(l.actionKeep),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(sheet).pop(true),
                  child: Text(l.actionChange),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return ok ?? false;
}
