/// Engine interfaces (spec §15.4). Implementations: `data/` (Drift) and pure Dart.
library;

import '../../core/time/civil_date.dart';
import '../entities/panjika.dart';

/// Where panchanga data comes from. MVP: pack data in Drift. v1.1 may combine it with
/// on-device astronomy for arbitrary coordinates.
abstract interface class PanjikaSource {
  Future<List<Transition>> transitions(
    TransitionKind kind,
    DateTime fromUtc,
    DateTime toUtc,
  );
  Future<SunMoonTimes?> sunMoonTimes(String cityId, CivilDate date);
  Future<BengaliDate?> bengaliDate(String tradition, CivilDate date);
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
