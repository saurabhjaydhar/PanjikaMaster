import '../time/civil_date.dart';
import 'app_language.dart';

/// 12- or 24-hour clock (FR-SET-01).
enum TimeFormat { h12, h24 }

/// The only place dates, times, ranges and numbers are formatted (spec §13.3).
/// Widgets never call `toString()`, `DateFormat` or `NumberFormat` directly.
///
/// Instants are UTC and always shown in IST ([Ist]), whatever the device time zone.
/// Pure and synchronous: no I/O, no `BuildContext`.
class PanjikaFormatter {
  const PanjikaFormatter({
    required this.language,
    required this.numerals,
    this.timeFormat = TimeFormat.h12,
    this.bnOrdinalDates = false,
  });

  final AppLanguage language;
  final NumeralStyle numerals;
  final TimeFormat timeFormat;

  /// Traditional Bengali ordinal dates (১লা, ২রা, ৪ঠা, ৫ই, ১৯শে). TODO(Q5): default
  /// and scope (Bengali and/or Gregorian dates) are the reviewer's decision.
  final bool bnOrdinalDates;

  bool get _bn => language == AppLanguage.bn;

  // ------------------------------------------------------------------ numbers

  static const _bengaliDigits = '০১২৩৪৫৬৭৮৯';

  /// Converts ASCII digits in [text] to the chosen numeral style.
  String digits(String text) {
    if (numerals == NumeralStyle.latin) return text;
    return text.replaceAllMapped(
      RegExp('[0-9]'),
      (m) => _bengaliDigits[int.parse(m[0]!)],
    );
  }

  /// An integer with Indian digit grouping (1,08,000), in the chosen numerals.
  String number(int value) {
    final negative = value < 0;
    final raw = value.abs().toString();
    String grouped;
    if (raw.length <= 3) {
      grouped = raw;
    } else {
      final head = raw.substring(0, raw.length - 3);
      final tail = raw.substring(raw.length - 3);
      final pairs = <String>[];
      for (var end = head.length; end > 0; end -= 2) {
        pairs.insert(0, head.substring(end - 2 < 0 ? 0 : end - 2, end));
      }
      grouped = '${pairs.join(',')},$tail';
    }
    return digits(negative ? '-$grouped' : grouped);
  }

  // ------------------------------------------------------------------ times

  /// Bengali day-part words for the 12-hour clock (spec §12.4). Boundaries are in
  /// minutes after midnight IST. TODO: confirm boundaries with 5 target users (§12.4).
  static const _bnDayParts = <(int, String)>[
    (4 * 60, 'রাত'), // 00:00–04:00
    (6 * 60, 'ভোর'), // 04:00–06:00
    (12 * 60, 'সকাল'), // 06:00–12:00
    (15 * 60, 'দুপুর'), // 12:00–15:00
    (17 * 60 + 30, 'বিকেল'), // 15:00–17:30
    (19 * 60 + 30, 'সন্ধ্যা'), // 17:30–19:30
    (24 * 60, 'রাত'), // 19:30–24:00
  ];

  static String _bnDayPart(int minuteOfDay) =>
      _bnDayParts.firstWhere((p) => minuteOfDay < p.$1).$2;

  /// The IST clock time of [instant], e.g. "দুপুর ২:৩২", "2:32 PM", "14:32".
  String time(DateTime instant) {
    final t = Ist.wallClock(instant);
    final mm = t.minute.toString().padLeft(2, '0');
    if (timeFormat == TimeFormat.h24) {
      return digits('${t.hour.toString().padLeft(2, '0')}:$mm');
    }
    final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final clock = digits('$h12:$mm');
    if (_bn) return '${_bnDayPart(t.hour * 60 + t.minute)} $clock';
    return '$clock ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  /// A time range, sharing the day part / AM-PM when both ends have the same one:
  /// "সকাল ৭:৩২–৯:০০", "7:32–9:00 AM", "11:30 AM–12:15 PM", "07:32–09:00".
  String timeRange(DateTime start, DateTime end) {
    if (timeFormat == TimeFormat.h24) return '${time(start)}–${time(end)}';
    final (a, b) = (time(start), time(end));
    final (aHead, aClock) = _splitClock(a);
    final (bHead, bClock) = _splitClock(b);
    if (aHead == bHead) {
      return _bn ? '$aHead $aClock–$bClock' : '$aClock–$bClock $bHead';
    }
    return '$a–$b';
  }

  /// Splits "দুপুর ২:৩২" into ("দুপুর", "২:৩২") and "2:32 PM" into ("PM", "2:32").
  (String, String) _splitClock(String formatted) {
    final i = formatted.indexOf(' ');
    final first = formatted.substring(0, i);
    final second = formatted.substring(i + 1);
    return _bn ? (first, second) : (second, first);
  }

  /// True if [instant] falls on a later IST civil date than [panjikaDay]: the UI then
  /// adds "(পরদিন)" / "(next day)" via the `nextDayTime` message (spec §12.4, §16).
  bool isNextDay(DateTime instant, CivilDate panjikaDay) =>
      CivilDate.ofInstant(instant).compareTo(panjikaDay) > 0;

  // ------------------------------------------------------------------ dates

  // TODO(Q5): Bengali spellings of Gregorian months (also in data/content/names.toml).
  static const _bnMonths = [
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', //
    'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
  ];
  static const _bnMonthsShort = [
    'জানু', 'ফেব্রু', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', //
    'জুলাই', 'আগ', 'সেপ্টে', 'অক্টো', 'নভে', 'ডিসে',
  ];
  static const _enMonths = [
    'January', 'February', 'March', 'April', 'May', 'June', //
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  // Indexed by DateTime.weekday - 1 (Monday first).
  static const _bnWeekdays = [
    'সোমবার',
    'মঙ্গলবার',
    'বুধবার',
    'বৃহস্পতিবার',
    'শুক্রবার',
    'শনিবার',
    'রবিবার',
  ];
  static const _bnWeekdaysShort = [
    'সোম',
    'মঙ্গল',
    'বুধ',
    'বৃহ',
    'শুক্র',
    'শনি',
    'রবি',
  ];
  static const _enWeekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// Day of month, with the traditional Bengali ordinal suffix if enabled.
  String _day(int day) => _bn && bnOrdinalDates
      ? '${digits('$day')}${bengaliOrdinalSuffix(day)}'
      : digits('$day');

  /// "১২ অক্টোবর ২০২৬" / "12 October 2026" (day-month-year, en-IN).
  String gregorianDate(CivilDate date) {
    final month = (_bn ? _bnMonths : _enMonths)[date.month - 1];
    return '${_day(date.day)} $month ${digits('${date.year}')}';
  }

  /// "সোম, ১২ অক্টো" / "Mon, 12 Oct".
  String gregorianDateShort(CivilDate date) {
    final i = date.weekday - 1;
    if (_bn) {
      return '${_bnWeekdaysShort[i]}, ${_day(date.day)} ${_bnMonthsShort[date.month - 1]}';
    }
    return '${_enWeekdays[i].substring(0, 3)}, ${digits('${date.day}')} '
        '${_enMonths[date.month - 1].substring(0, 3)}';
  }

  /// "১২/১০/২০২৬" / "12/10/2026": always dd/mm/yyyy, never US order.
  String gregorianDateNumeric(CivilDate date) => digits(
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/'
    '${date.year}',
  );

  /// "সোমবার" / "Monday".
  String weekday(CivilDate date) =>
      (_bn ? _bnWeekdays : _enWeekdays)[date.weekday - 1];

  /// "২৫ আশ্বিন ১৪৩৩" / "25 Ashwin 1433". [monthName] comes from the pack's `names`
  /// table in the UI language; the year is never digit-grouped.
  String bengaliDate(int day, String monthName, int year) =>
      '${_day(day)} $monthName ${digits('$year')}';

  /// Count as shown inside the `countdownDays` message.
  String countText(int count) => number(count);

  /// Megabytes with one decimal, for the `sizeMegabytes` message: "৩.১" / "3.1".
  String megabytes(int bytes) =>
      digits((bytes / (1024 * 1024)).toStringAsFixed(1));
}

/// The traditional suffix for a Bengali day of month: ১লা, ২রা, ৩রা, ৪ঠা, ৫ই–১৮ই, ১৯শে–৩২শে.
String bengaliOrdinalSuffix(int day) {
  if (day < 1 || day > 32) throw RangeError.range(day, 1, 32, 'day');
  if (day == 1) return 'লা';
  if (day <= 3) return 'রা';
  if (day == 4) return 'ঠা';
  if (day <= 18) return 'ই';
  return 'শে';
}
