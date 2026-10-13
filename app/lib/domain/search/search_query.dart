import '../../core/search/search_key.dart';
import '../../core/time/civil_date.dart';
import '../entities/name_table.dart';

/// What a search box entry could mean (spec §13.6, FR-SRCH-01). A query can be a date
/// and a name at the same time; every reading is searched.
sealed class DateQuery {
  const DateQuery();
}

/// A Gregorian date with its year ("12/10/2026", "2026-10-12", "১২ অক্টোবর ২০২৬").
final class GregorianDate extends DateQuery {
  const GregorianDate(this.date);
  final CivilDate date;

  @override
  bool operator ==(Object other) =>
      other is GregorianDate && other.date == date;
  @override
  int get hashCode => date.hashCode;
}

/// A Gregorian day and month without a year ("12 October"): the next one from today.
final class GregorianDayMonth extends DateQuery {
  const GregorianDayMonth(this.day, this.month);
  final int day;

  /// 1–12.
  final int month;

  @override
  bool operator ==(Object other) =>
      other is GregorianDayMonth && other.day == day && other.month == month;
  @override
  int get hashCode => Object.hash(day, month);
}

/// A Bengali date, with or without its year ("২৫ আশ্বিন ১৪৩৩", "২৫শে আশ্বিন",
/// "25 Ashwin"). Only the installed packs can turn it into a civil date.
final class BengaliDay extends DateQuery {
  const BengaliDay(this.day, this.monthIdx, [this.year]);
  final int day;

  /// 0 = বৈশাখ.
  final int monthIdx;
  final int? year;

  @override
  bool operator ==(Object other) =>
      other is BengaliDay &&
      other.day == day &&
      other.monthIdx == monthIdx &&
      other.year == year;
  @override
  int get hashCode => Object.hash(day, monthIdx, year);
}

/// Romanisations people type for the Bengali months, besides the pack's own names
/// (spec §13.6: Boishakh / Baishakh / Vaisakh / বৈশাখ). Spelling data, not dates.
const bengaliMonthVariants = <List<String>>[
  ['baishakh', 'baisakh', 'vaisakh', 'vaishakh', 'boisakh'],
  ['jaishtha', 'jyeshtha', 'jyaistha', 'joishtho', 'jyoishtha', 'jeth'],
  ['ashar', 'asar', 'ashadh', 'asadh', 'ashadha', 'asharh'],
  ['shrabon', 'sraban', 'shraban', 'shravan', 'shravana', 'sravan'],
  ['bhadra', 'bhadrapad', 'bhadrapada', 'bhadro'],
  ['aswin', 'ashvin', 'ashwina', 'ashshin', 'ashin'],
  ['kartika', 'karttik', 'kartic'],
  ['aghrayan', 'agrahayana', 'ogrohayon', 'agrayan', 'margashirsha'],
  ['paush', 'pous', 'pausha', 'poush'],
  ['magha', 'mag'],
  ['phalgun', 'phalguna', 'falgoon', 'phagun', 'fagun'],
  ['choitro', 'chaitro', 'chait', 'chaitr'],
];

/// Reads a search entry as dates (FR-SRCH-01, FR-L10N-07): both scripts and both
/// numeral systems, dd/mm/yyyy (also with - or .), ISO dates, "day month [year]" in
/// Gregorian or Bengali, with or without Bengali ordinal suffixes.
List<DateQuery> parseDateQueries(String input, NameTable names) {
  final text = _digits(input.trim().toLowerCase());
  if (text.isEmpty) return const [];
  final out = <DateQuery>[];

  final dmy = RegExp(r'^(\d{1,2})\s*[/.\-]\s*(\d{1,2})\s*[/.\-]\s*(\d{4})$');
  final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$');
  if (dmy.firstMatch(text) case final m?) {
    final d = _date(int.parse(m[3]!), int.parse(m[2]!), int.parse(m[1]!));
    if (d != null) out.add(GregorianDate(d));
  } else if (iso.firstMatch(text) case final m?) {
    final d = _date(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
    if (d != null) out.add(GregorianDate(d));
  }

  // "25 ashwin 1433", "২৫শে আশ্বিন", "12 october 2026", "october 12, 2026".
  final words = text
      .replaceAll(',', ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  int? dayOf(String w) {
    final m = RegExp(r'^(\d{1,2})(শে|ই|লা|রা|ঠা|st|nd|rd|th)?$').firstMatch(w);
    if (m == null) return null;
    final d = int.parse(m[1]!);
    return d >= 1 && d <= 32 ? d : null;
  }

  int? yearOf(String w) => RegExp(r'^\d{4}$').hasMatch(w) ? int.parse(w) : null;

  for (var i = 0; i < words.length; i++) {
    final bengali = _monthIndex(words[i], names, 'solar_month');
    final gregorian = _monthIndex(words[i], names, 'gregorian_month');
    if (bengali == null && gregorian == null) continue;
    final before = i > 0 ? dayOf(words[i - 1]) : null;
    final after = i + 1 < words.length ? dayOf(words[i + 1]) : null;
    final day = before ?? after;
    if (day == null) continue;
    final yearIndex = before != null ? i + 1 : i + 2;
    final year = yearIndex < words.length ? yearOf(words[yearIndex]) : null;
    if (bengali != null) out.add(BengaliDay(day, bengali, year));
    if (gregorian != null) {
      if (year != null) {
        final d = _date(year, gregorian + 1, day);
        if (d != null) out.add(GregorianDate(d));
      } else if (day <= 31) {
        out.add(GregorianDayMonth(day, gregorian + 1));
      }
    }
  }
  return out.toSet().toList();
}

/// The month index whose names (both scripts, the pack's transliteration, the
/// variants above, or a 3+ letter prefix of the English name) match [word].
int? _monthIndex(String word, NameTable names, String kind) {
  final key = searchKey(word);
  if (key.isEmpty) return null;
  final prefixed = <int>[];
  for (var i = 0; i < names.countOf(kind); i++) {
    final name = names.of(kind, i);
    final keys = {
      searchKey(name.bn),
      searchKey(name.en),
      if (kind == 'solar_month')
        for (final v in bengaliMonthVariants[i]) searchKey(v),
    };
    if (keys.contains(key)) return i;
    if (key.length >= 3 &&
        RegExp(r'^[a-z]+$').hasMatch(key) &&
        searchKey(name.en).startsWith(key)) {
      prefixed.add(i);
    }
  }
  // A prefix counts only when it names one month ("oct", not "ash").
  return prefixed.length == 1 ? prefixed.single : null;
}

CivilDate? _date(int y, int m, int d) => CivilDate.tryParse(
  '${y.toString().padLeft(4, '0')}-${m.toString().padLeft(2, '0')}-'
  '${d.toString().padLeft(2, '0')}',
);

const _bnDigits = '০১২৩৪৫৬৭৮৯';

String _digits(String s) => String.fromCharCodes(
  s.runes.map((r) {
    final i = _bnDigits.indexOf(String.fromCharCode(r));
    return i < 0 ? r : 0x30 + i;
  }),
);
