// T-209: Rahu Kaal, Yamaganda and Gulika for every weekday (spec §6.5.8).
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/domain/engine/period_calculator.dart';
import 'package:panjika/domain/entities/panjika.dart';

const calc = DivisionPeriodCalculator();

/// A synthetic 12-hour day (06:00–18:00 UTC) so each eighth is exactly 90 minutes and the
/// expected times are easy to read. Not calendar data.
final sunrise = DateTime.utc(2026, 1, 1, 6);
final sunset = DateTime.utc(2026, 1, 1, 18);
final nextSunrise = DateTime.utc(2026, 1, 2, 6);

String hm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

Map<int, String> periodsOn(Weekday day) => {
  for (final p in calc.periodsFor(
    sunriseUtc: sunrise,
    sunsetUtc: sunset,
    nextSunriseUtc: nextSunrise,
    weekday: day,
    rules: standardDayPeriodRules,
  ))
    p.periodId: '${hm(p.startUtc)}–${hm(p.endUtc)}',
};

void main() {
  // Part n of 8 on a 06:00–18:00 day starts at 06:00 + (n − 1) × 1h30.
  const expected = {
    //                 Rahu Kaal        Yamaganda        Gulika
    Weekday.sunday: [
      '16:30–18:00',
      '12:00–13:30',
      '15:00–16:30',
    ], // parts 8, 5, 7
    Weekday.monday: ['07:30–09:00', '10:30–12:00', '13:30–15:00'], // 2, 4, 6
    Weekday.tuesday: ['15:00–16:30', '09:00–10:30', '12:00–13:30'], // 7, 3, 5
    Weekday.wednesday: ['12:00–13:30', '07:30–09:00', '10:30–12:00'], // 5, 2, 4
    Weekday.thursday: ['13:30–15:00', '06:00–07:30', '09:00–10:30'], // 6, 1, 3
    Weekday.friday: ['10:30–12:00', '15:00–16:30', '07:30–09:00'], // 4, 7, 2
    Weekday.saturday: ['09:00–10:30', '13:30–15:00', '06:00–07:30'], // 3, 6, 1
  };

  expected.forEach((day, times) {
    test('${day.name}: Rahu Kaal, Yamaganda, Gulika', () {
      final got = periodsOn(day);
      expect(got[PeriodIds.rahuKaal], times[0]);
      expect(got[PeriodIds.yamaganda], times[1]);
      expect(got[PeriodIds.gulika], times[2]);
    });
  });

  test('each weekday gets exactly the three periods, in time order', () {
    for (final day in Weekday.values) {
      final ps = calc.periodsFor(
        sunriseUtc: sunrise,
        sunsetUtc: sunset,
        nextSunriseUtc: nextSunrise,
        weekday: day,
        rules: standardDayPeriodRules,
      );
      expect(ps, hasLength(3));
      for (var i = 1; i < ps.length; i++) {
        expect(ps[i].startUtc.isBefore(ps[i - 1].startUtc), isFalse);
      }
    }
  });

  test('the three periods never coincide on any weekday', () {
    for (final day in Weekday.values) {
      expect(periodsOn(day).values.toSet(), hasLength(3), reason: day.name);
    }
  });

  test(
    'uneven day lengths: parts tile sunrise→sunset exactly, to the microsecond',
    () {
      final rise = DateTime.utc(
        2026,
        6,
        21,
        23,
        51,
        7,
      ); // arbitrary, not calendar data
      final set = rise.add(const Duration(hours: 13, minutes: 21, seconds: 13));
      final rules = [
        for (var part = 1; part <= 8; part++)
          PeriodRule(
            periodId: part,
            kind: PeriodKind.ashubh,
            weekday: Weekday.monday,
            basis: PeriodBasis.day,
            divisions: 8,
            part: part,
          ),
      ];
      final ps = calc.periodsFor(
        sunriseUtc: rise,
        sunsetUtc: set,
        nextSunriseUtc: set.add(const Duration(hours: 11)),
        weekday: Weekday.monday,
        rules: rules,
      );
      expect(ps.first.startUtc, rise);
      expect(ps.last.endUtc, set);
      for (var i = 1; i < ps.length; i++) {
        expect(ps[i].startUtc, ps[i - 1].endUtc, reason: 'no gaps or overlaps');
      }
    },
  );

  test('night-basis rules divide sunset → next sunrise', () {
    final ps = calc.periodsFor(
      sunriseUtc: sunrise,
      sunsetUtc: sunset,
      nextSunriseUtc: nextSunrise,
      weekday: Weekday.friday,
      rules: const [
        PeriodRule(
          periodId: 5,
          kind: PeriodKind.ashubh,
          weekday: Weekday.friday,
          basis: PeriodBasis.night,
          divisions: 8,
          part: 1,
        ),
      ],
    );
    expect(
      (ps.single.startUtc, ps.single.endUtc),
      (sunset, sunset.add(const Duration(minutes: 90))),
    );
  });

  test(
    'rules for other weekdays are ignored; impossible sun times are rejected',
    () {
      expect(
        calc.periodsFor(
          sunriseUtc: sunrise,
          sunsetUtc: sunset,
          nextSunriseUtc: nextSunrise,
          weekday: Weekday.monday,
          rules: standardDayPeriodRules
              .where((r) => r.weekday == Weekday.sunday)
              .toList(),
        ),
        isEmpty,
      );
      expect(
        () => calc.periodsFor(
          sunriseUtc: sunset,
          sunsetUtc: sunrise,
          nextSunriseUtc: nextSunrise,
          weekday: Weekday.monday,
          rules: standardDayPeriodRules,
        ),
        throwsArgumentError,
      );
    },
  );

  test('isActiveAt includes the start and excludes the end', () {
    final rahu = calc
        .periodsFor(
          sunriseUtc: sunrise,
          sunsetUtc: sunset,
          nextSunriseUtc: nextSunrise,
          weekday: Weekday.monday,
          rules: standardDayPeriodRules,
        )
        .firstWhere((p) => p.periodId == PeriodIds.rahuKaal);
    expect(rahu.isActiveAt(DateTime.utc(2026, 1, 1, 7, 30)), isTrue);
    expect(rahu.isActiveAt(DateTime.utc(2026, 1, 1, 9)), isFalse);
  });
}
