/// Engine interfaces (spec §15.4). Implementations: `data/` (Drift) and pure Dart.
library;

import '../../core/time/civil_date.dart';
import '../entities/body_positions.dart';
import '../entities/name_table.dart';
import '../entities/panjika.dart';

/// Where panchanga data comes from: pack data in Drift. Rise and set for any place come
/// from [RiseSetCalculator] on the pack's Sun/Moon table; per-city rows go with T-318.
abstract interface class PanjikaSource {
  /// Transitions of [kind] overlapping [fromUtc, toUtc), in start order.
  Future<List<Transition>> transitions(
    String tradition,
    TransitionKind kind,
    DateTime fromUtc,
    DateTime toUtc,
  );
  Future<SunMoonTimes?> sunMoonTimes(String cityId, CivilDate date);

  /// Every day in [from, to] that has rows, keyed by date (the month grid).
  Future<Map<CivilDate, SunMoonTimes>> sunMoonTimesBetween(
    String cityId,
    CivilDate from,
    CivilDate to,
  );
  Future<BengaliDate?> bengaliDate(String tradition, CivilDate date);
  Future<Map<CivilDate, BengaliDate>> bengaliDatesBetween(
    String tradition,
    CivilDate from,
    CivilDate to,
  );

  /// The civil dates of one Bengali month, in order; empty if not in any pack.
  Future<List<CivilDate>> bengaliMonthDates(
    String tradition,
    int year,
    int monthIdx,
  );
  Future<List<LunarMonth>> lunarMonths(
    String tradition,
    DateTime fromUtc,
    DateTime toUtc,
  );
  Future<List<ObservanceDate>> observances(
    String tradition,
    CivilDate from,
    CivilDate to,
  );
  Future<DataCoverage> coverage(String tradition, String cityId);

  /// Every installed date of one observance, in date order.
  Future<List<ObservanceDate>> observanceDatesOf(String tradition, String id);

  /// Every installed window of one observance (Sandhi Puja, nishita, …).
  Future<List<ObservanceWindow>> windowsOf(String tradition, String id);
}

/// Computes timed periods (Rahu Kaal, Yamaganda, Gulika, Bengal periods) from sunrise,
/// sunset and rules. Pure, synchronous, no I/O (spec §15.4).
abstract interface class PeriodCalculator {
  List<TimePeriod> periodsFor({
    required DateTime sunriseUtc,
    required DateTime sunsetUtc,
    required DateTime nextSunriseUtc,
    required Weekday weekday,
    required List<PeriodRule> rules,
  });
}

/// The first sunrise, sunset, moonrise and moonset inside one IST day; null when there
/// is none (a moonless day, or abroad an event outside the IST day: Q16).
class RiseSetTimes {
  const RiseSetTimes({
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
  });

  final DateTime? sunrise;
  final DateTime? sunset;
  final DateTime? moonrise;
  final DateTime? moonset;
}

/// Rise and set for any coordinates from the pack's Sun/Moon table (spec §6.5.5).
/// Pure, synchronous, no I/O (spec §15.4).
abstract interface class RiseSetCalculator {
  /// Throws [ArgumentError] if [positions] do not cover [date] and the day after.
  RiseSetTimes timesFor({
    required double lat,
    required double lon,
    required CivilDate date,
    required BodyPositions positions,
  });
}

/// Reference data around the panjika: names, cities, rules and pack metadata.
abstract interface class CatalogSource {
  Future<NameTable> names();
  Future<City?> city(String id);

  /// Bengal-specific period rules enabled in the packs (spec §6.5.9). The standard
  /// §6.5.8 table lives in code and is not included.
  Future<List<PeriodRule>> enabledPeriodRules(String tradition);

  /// True if any of [packIds] is a sample pack, so the UI must show the watermark.
  Future<bool> anySample(Iterable<String> packIds);
}
