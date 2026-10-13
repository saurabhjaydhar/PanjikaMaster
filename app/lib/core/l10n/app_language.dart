import 'dart:ui';

/// The two UI languages (spec §13.1).
enum AppLanguage {
  bn,
  en;

  Locale get locale => Locale(name);

  /// Default numerals for this language (FR-L10N-04).
  NumeralStyle get defaultNumerals =>
      this == bn ? NumeralStyle.bengali : NumeralStyle.latin;

  /// The language's own name, shown untranslated in language switches (spec §12.5).
  String get endonym => switch (this) {
    bn => 'বাংলা',
    en => 'English',
  };

  static AppLanguage? fromTag(String? tag) {
    if (tag == null || tag.isEmpty) return null;
    final code = tag.split(RegExp('[-_,]')).first.toLowerCase();
    for (final language in values) {
      if (language.name == code) return language;
    }
    return null;
  }
}

/// Bengali (০–৯) or Latin (0–9) digits; independent of language (FR-L10N-04).
enum NumeralStyle { bengali, latin }

/// TODO(Q15): UI language when the device locale is neither Bengali nor English.
/// The PRD makes Bengali the default product language, so it is used until decided.
const AppLanguage fallbackLanguage = AppLanguage.bn;

/// First-launch language: the saved choice if any, else the device's primary locale
/// if it is Bengali or English, else [fallbackLanguage] (FR-L10N-02). Only the primary
/// locale counts: a Hindi phone with English as a backup is a Q15 case.
AppLanguage resolveLanguage({
  AppLanguage? saved,
  required List<Locale> deviceLocales,
}) {
  if (saved != null) return saved;
  if (deviceLocales.isEmpty) return fallbackLanguage;
  return AppLanguage.fromTag(deviceLocales.first.languageCode) ??
      fallbackLanguage;
}
