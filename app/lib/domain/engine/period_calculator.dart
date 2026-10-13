import '../entities/panjika.dart';
import 'interfaces.dart';

/// Indices of the period names in `names(kind='period')` (data/content/names.toml).
abstract final class PeriodIds {
  static const rahuKaal = 0;
  static const yamaganda = 1;
  static const gulika = 2;
}

/// Rahu Kaal, Yamaganda and Gulika: daytime (sunrise→sunset) divided into 8 equal parts,
/// part number by weekday, exactly as tabled in spec §6.5.8. That table is the commonly
/// published one and must be verified against the reference panjika before release.
/// (Bengal-specific periods come from the pack's `period_rules`, spec §6.5.9.)
final List<PeriodRule> standardDayPeriodRules = List.unmodifiable([
  //                         Sun Mon Tue Wed Thu Fri Sat
  ..._rules(PeriodIds.rahuKaal, [8, 2, 7, 5, 6, 4, 3]),
  ..._rules(PeriodIds.yamaganda, [5, 4, 3, 2, 1, 7, 6]),
  ..._rules(PeriodIds.gulika, [7, 6, 5, 4, 3, 2, 1]),
]);

List<PeriodRule> _rules(int periodId, List<int> partBySundayFirst) => [
  for (final day in Weekday.values)
    PeriodRule(
      periodId: periodId,
      kind: PeriodKind.ashubh,
      weekday: day,
      basis: PeriodBasis.day,
      divisions: 8,
      part: partBySundayFirst[day.index],
    ),
];

/// Divides day (sunrise→sunset) or night (sunset→next sunrise) into equal parts and
/// returns the part each matching rule names. Pure and synchronous (spec §15.4).
class DivisionPeriodCalculator implements PeriodCalculator {
  const DivisionPeriodCalculator();

  @override
  List<TimePeriod> periodsFor({
    required DateTime sunriseUtc,
    required DateTime sunsetUtc,
    required DateTime nextSunriseUtc,
    required Weekday weekday,
    required List<PeriodRule> rules,
  }) {
    if (!sunriseUtc.isBefore(sunsetUtc) ||
        !sunsetUtc.isBefore(nextSunriseUtc)) {
      throw ArgumentError('expected sunrise < sunset < next sunrise');
    }
    final periods = <TimePeriod>[
      for (final rule in rules)
        if (rule.weekday == weekday)
          _period(rule, sunriseUtc, sunsetUtc, nextSunriseUtc),
    ]..sort((a, b) => a.startUtc.compareTo(b.startUtc));
    return periods;
  }

  TimePeriod _period(
    PeriodRule rule,
    DateTime sunrise,
    DateTime sunset,
    DateTime nextSunrise,
  ) {
    final (from, to) = rule.basis == PeriodBasis.day
        ? (sunrise, sunset)
        : (sunset, nextSunrise);
    final span = to.difference(from).inMicroseconds;
    // Integer arithmetic on microseconds, so the parts tile the span exactly.
    DateTime boundary(int i) =>
        from.add(Duration(microseconds: span * i ~/ rule.divisions));
    return TimePeriod(
      periodId: rule.periodId,
      kind: rule.kind,
      startUtc: boundary(rule.part - 1),
      endUtc: boundary(rule.part),
    );
  }
}
