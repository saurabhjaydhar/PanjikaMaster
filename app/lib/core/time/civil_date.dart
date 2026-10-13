/// A calendar date with no time or zone (the civil date in IST). Stored as
/// 'YYYY-MM-DD' in the database (spec §15.1).
class CivilDate implements Comparable<CivilDate> {
  const CivilDate(this.year, this.month, this.day);

  factory CivilDate.parse(String iso) {
    final parts = iso.split('-').map(int.parse).toList();
    return CivilDate(parts[0], parts[1], parts[2]);
  }

  /// The IST civil date of a UTC instant.
  factory CivilDate.ofInstant(DateTime instant) {
    final ist = Ist.wallClock(instant);
    return CivilDate(ist.year, ist.month, ist.day);
  }

  final int year;
  final int month;
  final int day;

  /// 1 = Monday … 7 = Sunday, as in [DateTime.weekday].
  int get weekday => DateTime.utc(year, month, day).weekday;

  CivilDate addDays(int days) {
    final d = DateTime.utc(year, month, day).add(Duration(days: days));
    return CivilDate(d.year, d.month, d.day);
  }

  String toIso() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(CivilDate other) => toIso().compareTo(other.toIso());

  @override
  bool operator ==(Object other) =>
      other is CivilDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}

/// Indian Standard Time: UTC+05:30 all year (no DST). Every panjika time is shown
/// in IST whatever the device's own time zone (spec §5.3, §16).
abstract final class Ist {
  static const offset = Duration(hours: 5, minutes: 30);

  /// The IST wall-clock reading of [instant], as a UTC-flagged [DateTime] whose
  /// fields are the IST fields. Never compare it with real instants.
  static DateTime wallClock(DateTime instant) => instant.toUtc().add(offset);
}
