/// The pipeline's Sun and Moon positions for a run of IST days (pack table
/// `body_positions`, spec §6.5.5, T-314), read by the on-device rise/set calculator.
library;

/// One IST day [startUtc, startUtc + 86 400 s): Chebyshev coefficients (lowest order
/// first) over the day mapped to x ∈ [−1, 1]. Apparent geocentric right ascension and
/// declination in radians (true equator and equinox of date; RA continuous within the
/// day), distances in km, Greenwich apparent sidereal time in radians (continuous).
class BodyPositionsDay {
  const BodyPositionsDay({
    required this.startUtc,
    required this.sunRa,
    required this.sunDec,
    required this.sunDist,
    required this.moonRa,
    required this.moonDec,
    required this.moonDist,
    required this.gast,
    required this.packId,
  });

  /// IST midnight of the day, Unix seconds.
  final int startUtc;
  final List<double> sunRa;
  final List<double> sunDec;
  final List<double> sunDist;
  final List<double> moonRa;
  final List<double> moonDec;
  final List<double> moonDist;
  final List<double> gast;
  final String packId;

  static const seconds = 86400;

  int get endUtc => startUtc + seconds;
}

/// Consecutive days, in order. Rise and set for an IST day need that day's row.
class BodyPositions {
  BodyPositions(Iterable<BodyPositionsDay> days)
    : days = List.unmodifiable(days.toList()) {
    for (var i = 1; i < this.days.length; i++) {
      if (this.days[i].startUtc != this.days[i - 1].endUtc) {
        throw ArgumentError('body positions must be consecutive days');
      }
    }
  }

  final List<BodyPositionsDay> days;

  /// The day containing [unix] (the earlier day at a shared boundary), or null.
  BodyPositionsDay? dayAt(double unix) {
    for (final d in days) {
      if (unix >= d.startUtc && unix <= d.endUtc) return d;
    }
    return null;
  }
}
