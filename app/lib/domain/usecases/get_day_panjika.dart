import '../../core/time/civil_date.dart';
import '../engine/day_assembler.dart';
import '../engine/interfaces.dart';
import '../engine/period_calculator.dart';
import '../entities/panjika.dart';
import 'provenance.dart';

/// The kinds a panjika day shows; each must cover sunrise or the day is unavailable.
const panchangaKinds = [
  TransitionKind.tithi,
  TransitionKind.nakshatra,
  TransitionKind.yoga,
  TransitionKind.karana,
];

/// One panjika day for a tradition and city (spec §14.4). Returns null when any part
/// is missing from the installed packs, so screens show "not available" rather than
/// guessing (FR-HOME-09).
class GetDayPanjika {
  const GetDayPanjika(
    this._source,
    this._catalog, {
    this.assembler = const StandardDayAssembler(),
  });

  final PanjikaSource _source;
  final CatalogSource _catalog;
  final DayAssembler assembler;

  /// The panjika day that starts at sunrise on [date].
  Future<DayPanjika?> call({
    required CivilDate date,
    required String tradition,
    required String cityId,
  }) async {
    final (previous, sun, next, bengali, city) = await (
      _source.sunMoonTimes(cityId, date.addDays(-1)),
      _source.sunMoonTimes(cityId, date),
      _source.sunMoonTimes(cityId, date.addDays(1)),
      _source.bengaliDate(tradition, date),
      _catalog.city(cityId),
    ).wait;
    if (previous == null ||
        sun == null ||
        next == null ||
        bengali == null ||
        city == null) {
      return null;
    }

    final transitions = [
      for (final kind in panchangaKinds)
        ...await _source.transitions(
          tradition,
          kind,
          previous.sunrise,
          next.sunrise,
        ),
    ];
    final covered = panchangaKinds.every(
      (k) => transitions.any((t) => t.kind == k && t.contains(sun.sunrise)),
    );
    if (!covered) return null;

    final (names, rules, observances) = await (
      _catalog.names(),
      _catalog.enabledPeriodRules(tradition),
      _source.observances(tradition, date, date),
    ).wait;
    final packIds = {
      previous.packId,
      sun.packId,
      next.packId,
      bengali.packId,
      for (final t in transitions) t.packId,
      for (final o in observances) o.packId,
    };

    return assembler.assemble(
      DayInputs(
        date: date,
        previousSunrise: previous.sunrise,
        sun: sun,
        nextSunrise: next.sunrise,
        bengaliDate: bengali,
        transitions: transitions,
        periodRules: [...standardDayPeriodRules, ...rules],
        names: names.of,
        observances: observances,
        provenance: await provenanceFor(
          _catalog,
          names,
          tradition: tradition,
          city: city,
          packIds: packIds,
        ),
      ),
    );
  }

  /// The panjika day containing [instant]: between midnight and sunrise that is the
  /// day that began at the previous date's sunrise (spec §5.3: sunrise to sunrise).
  Future<DayPanjika?> containing(
    DateTime instant, {
    required String tradition,
    required String cityId,
  }) async {
    final date = CivilDate.ofInstant(instant);
    final sun = await _source.sunMoonTimes(cityId, date);
    if (sun == null) return null;
    return call(
      date: instant.isBefore(sun.sunrise) ? date.addDays(-1) : date,
      tradition: tradition,
      cityId: cityId,
    );
  }
}
