// T-317: rise and set on the phone match the pipeline for every place and day of the
// shared fixture (test/fixtures/riseset.json, T-315): ±5 s Sun, ±10 s Moon (§6.5.5).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/domain/engine/rise_set.dart';
import 'package:panjika/domain/entities/body_positions.dart';

// `flutter test` runs with app/ as the working directory.
final fixture = jsonDecode(
  File('test/fixtures/riseset.json').readAsStringSync(),
) as Map<String, Object?>;

List<double> _doubles(Object? v) => [
  for (final x in v! as List) (x as num).toDouble(),
];

BodyPositionsDay _day(Map<String, Object?> row) => BodyPositionsDay(
  startUtc: row['start_utc']! as int,
  sunRa: _doubles(row['sun_ra']),
  sunDec: _doubles(row['sun_dec']),
  sunDist: _doubles(row['sun_dist']),
  moonRa: _doubles(row['moon_ra']),
  moonDec: _doubles(row['moon_dec']),
  moonDist: _doubles(row['moon_dist']),
  gast: _doubles(row['gast']),
  packId: 'fixture',
);

BodyPositions positionsFor(CivilDate date) {
  final rows = fixture['body_positions']! as Map<String, Object?>;
  return BodyPositions([
    for (final d in [date, date.addDays(1)])
      _day(rows[d.toIso()]! as Map<String, Object?>),
  ]);
}

int istMidnight(CivilDate d) =>
    DateTime.utc(
      d.year,
      d.month,
      d.day,
    ).subtract(Ist.offset).millisecondsSinceEpoch ~/
    1000;

void main() {
  const calc = OnDeviceRiseSet();
  final places = fixture['places']! as Map<String, Object?>;
  final expected = fixture['expected']! as Map<String, Object?>;
  final days = [
    for (final d in fixture['days']! as List) CivilDate.parse(d as String),
  ];

  test('the fixture is the pipeline\'s upper-limb sunrise (Q3)', () {
    expect(fixture['sunrise_definition'], 'UPPER_LIMB');
    expect(calc.definition, SunriseDefinition.upperLimb);
    expect(places.length, greaterThanOrEqualTo(40));
    expect(days, hasLength(24));
  });

  for (final MapEntry(key: name, value: coords) in places.entries) {
    test('$name: every day within ±5 s (Sun) and ±10 s (Moon)', () {
      final c = coords! as Map<String, Object?>;
      final lat = (c['lat']! as num).toDouble();
      final lon = (c['lon']! as num).toDouble();
      final byDay = expected[name]! as Map<String, Object?>;
      var worstSun = 0, worstMoon = 0;
      for (final date in days) {
        final t = calc.timesFor(
          lat: lat,
          lon: lon,
          date: date,
          positions: positionsFor(date),
        );
        final want = byDay[date.toIso()]! as List;
        final got = [t.sunrise, t.sunset, t.moonrise, t.moonset];
        final start = istMidnight(date);
        for (var i = 0; i < 4; i++) {
          final w = want[i] as int?;
          final g = got[i] == null
              ? null
              : got[i]!.millisecondsSinceEpoch / 1000;
          final what = '$name ${date.toIso()} ${fixture['events']}[$i]';
          if (w == null || g == null) {
            // Both "none", unless the event sits within 30 s of the day's edge.
            final edge = w ?? g;
            expect(
              edge == null ||
                  (edge - start) < 30 ||
                  (start + 86400 - edge) < 30,
              isTrue,
              reason: '$what: pipeline $w, phone $g',
            );
            continue;
          }
          final diff = (g - w).abs().round();
          if (i < 2) {
            expect(diff, lessThanOrEqualTo(5), reason: what);
            if (diff > worstSun) worstSun = diff;
          } else {
            expect(diff, lessThanOrEqualTo(10), reason: what);
            if (diff > worstMoon) worstMoon = diff;
          }
        }
      }
      // Within a second in practice: the margin to the limits is real.
      expect(worstSun, lessThanOrEqualTo(2), reason: '$name Sun');
      expect(worstMoon, lessThanOrEqualTo(2), reason: '$name Moon');
    });
  }

  test('the centre-of-disc flag (Q3) rises later and sets earlier', () {
    const centre = OnDeviceRiseSet(definition: SunriseDefinition.centre);
    final date = days.first;
    final upper = calc.timesFor(
      lat: 22.5726,
      lon: 88.3639,
      date: date,
      positions: positionsFor(date),
    );
    final mid = centre.timesFor(
      lat: 22.5726,
      lon: 88.3639,
      date: date,
      positions: positionsFor(date),
    );
    final later = mid.sunrise!.difference(upper.sunrise!).inSeconds;
    final earlier = upper.sunset!.difference(mid.sunset!).inSeconds;
    expect(later, inInclusiveRange(40, 150));
    expect(earlier, inInclusiveRange(40, 150));
  });

  test('positions that do not cover the day are refused', () {
    final date = days.first;
    final only = BodyPositions([positionsFor(date).days.first]);
    expect(
      () =>
          calc.timesFor(lat: 0, lon: 0, date: date.addDays(1), positions: only),
      throwsArgumentError,
    );
    expect(
      () => calc.timesFor(lat: 91, lon: 0, date: date, positions: only),
      throwsArgumentError,
    );
  });

  test('performance: well under 2 ms per place and day (performance.md)', () {
    final date = days[5];
    final positions = positionsFor(date);
    final watch = Stopwatch()..start();
    var n = 0;
    for (var i = 0; i < 20; i++) {
      for (final c in places.values) {
        final m = c! as Map<String, Object?>;
        calc.timesFor(
          lat: (m['lat']! as num).toDouble(),
          lon: (m['lon']! as num).toDouble(),
          date: date,
          positions: positions,
        );
        n++;
      }
    }
    final perCallMs = watch.elapsedMicroseconds / n / 1000;
    expect(perCallMs, lessThan(2), reason: '$perCallMs ms per call');
  });
}
