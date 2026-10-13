/// Glossary terms: indices into `names(kind='term')` (data/content/names.toml, where
/// `translit` holds the same id). Order = index; a test checks them against the pack.
enum Term {
  tithi,
  paksha,
  nakshatra,
  yoga,
  karana,
  sankranti,
  udayaTithi,
  kshayaTithi,
  vriddhiTithi,
  malaMasa,
  ayanamsa,
  dandaPala,
  panjika,
  bishuddhaSiddhanta,
  suryaSiddhanta;

  /// The id stored in `names.translit`, e.g. `udaya_tithi`.
  String get id =>
      name.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');
}
