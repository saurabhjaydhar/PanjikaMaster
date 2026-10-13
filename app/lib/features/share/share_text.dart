import '../../core/l10n/app_language.dart';
import '../../core/l10n/panjika_formatter.dart';
import '../../domain/entities/name_ref.dart';
import '../../l10n/gen/app_localizations.dart';
import 'share_render.dart';

/// The share message in the chosen language(s), not the UI language (spec §11.8):
/// for [ShareLanguage.both], a Bengali block then an English one. Each block is
/// [line] followed by its provenance; the link, if any, comes last.
String shareMessage(
  ShareLanguage share, {
  required String Function(
    AppLocalizations l,
    PanjikaFormatter f,
    AppLanguage a,
  )
  line,
  required String Function(AppLocalizations l, AppLanguage a) provenance,
  String? link,
}) {
  final languages = switch (share) {
    ShareLanguage.bn => [AppLanguage.bn],
    ShareLanguage.en => [AppLanguage.en],
    ShareLanguage.both => [AppLanguage.bn, AppLanguage.en],
  };
  final blocks = [
    for (final a in languages)
      () {
        final l = lookupAppLocalizations(a.locale);
        final f = formatterFor(a);
        return '${line(l, f, a)}\n${provenance(l, a)}';
      }(),
  ];
  return [...blocks, ?link].join('\n\n');
}

/// The card's formatter: the card language with its own numerals and 12-hour time,
/// so a shared card reads the same whoever receives it.
PanjikaFormatter formatterFor(AppLanguage a) =>
    PanjikaFormatter(language: a, numerals: a.defaultNumerals);

/// "{tradition} মতে" in [a], for a tradition name from the packs.
String provenanceLine(AppLocalizations l, AppLanguage a, NameRef tradition) =>
    l.shareProvenance(tradition.of(a));
