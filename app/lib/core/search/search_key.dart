/// Search normalisation (spec §13.6): case-, diacritic-, space- and hyphen-insensitive,
/// Bengali and Latin digits alike, the composed and decomposed forms of য়, ড়, ঢ়
/// treated as one, and common spelling variants folded together. Compare keys with
/// [String.contains].
String searchKey(String text) {
  final out = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    final ch = String.fromCharCode(rune);
    if (_skip.contains(ch)) continue;
    out.write(_fold[ch] ?? ch);
  }
  var key = out.toString();
  for (final (from, to) in _spellings) {
    key = key.replaceAll(from, to);
  }
  return key;
}

/// Common spelling variants, folded the same way on both sides of a match (spec
/// §13.6): লক্ষ্মী / লক্ষী, Lakshmi / Laxmi, Vishwakarma / Bishwakarma, Phalgun / Falgun,
/// doubled vowels in romanisations.
const _spellings = [
  ('ক্ষ্ম', 'ক্ষ'),
  ('ksh', 'x'),
  ('ph', 'f'),
  ('v', 'b'),
  ('aa', 'a'),
  ('ee', 'i'),
  ('oo', 'u'),
];

/// Spaces, hyphens, punctuation and joiners that never matter for a match.
const _skip = {' ', '-', '‐', '–', '.', ',', "'", '’', '‌', '‍'};

const _fold = <String, String>{
  // Bengali digits → Latin.
  '০': '0', '১': '1', '২': '2', '৩': '3', '৪': '4', //
  '৫': '5', '৬': '6', '৭': '7', '৮': '8', '৯': '9', //
  // Precomposed nukta letters → base + nukta, so both spellings meet.
  'ড়': 'ড়', 'ঢ়': 'ঢ়', 'য়': 'য়',
  // Latin diacritics used in IAST and common names → plain letters.
  'ā': 'a', 'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', //
  'ī': 'i', 'í': 'i', 'ì': 'i', 'ï': 'i', //
  'ū': 'u', 'ú': 'u', 'ù': 'u', 'ü': 'u', //
  'ē': 'e', 'é': 'e', 'è': 'e', 'ō': 'o', 'ó': 'o', 'ò': 'o', 'ö': 'o', //
  'ṛ': 'r', 'ṝ': 'r', 'ḷ': 'l', 'ṃ': 'm', 'ṁ': 'm', 'ḥ': 'h', //
  'ṅ': 'n', 'ñ': 'n', 'ṇ': 'n', 'ṭ': 't', 'ḍ': 'd', 'ś': 's', 'ṣ': 's', //
};
