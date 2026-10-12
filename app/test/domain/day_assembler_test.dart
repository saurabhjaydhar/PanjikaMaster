// T-210: udaya tithi, kshaya/vriddhi, after-midnight times, time-zone independence
// (spec §6.5.7, §16). All instants below are synthetic test inputs, not calendar data.
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/domain/engine/day_assembler.dart';
import 'package:panjika/domain/engine/karana.dart';
import 'package:panjika/domain/engine/period_calculator.dart';
import 'package:panjika/domain/entities/name_ref.dart';
import 'package:panjika/domain/entities/panjika.dart';

const assembler = StandardDayAssembler();
const pack = 'test-pack';

// A synthetic Monday: sunrise 00:30 UTC (06:00 IST), sunset 12:00 UTC.
const date = CivilDate(2026, 1, 5);
final previousSunrise = DateTime.utc(2026, 1, 4, 0, 30);
final sunrise = DateTime.utc(2026, 1, 5, 0, 30);
final sunset = DateTime.utc(2026, 1, 5, 12);
final nextSunrise = DateTime.utc(2026, 1, 6, 0, 30);

NameRef fakeName(String kind, int idx) =>
    NameRef('$kind-bn-$idx', '$kind-en-$idx');

const provenance = Provenance(
  tradition: NameRef('ঐতিহ্য', 'Tradition'),
  city: NameRef('শহর', 'City'),
  packIds: [pack],
  isSample: true,
);

Transition t(TransitionKind kind, int idx, DateTime start, DateTime end) =>
    Transition(
      kind: kind,
      idx: idx,
      startUtc: start,
      endUtc: end,
      packId: pack,
    );

Transition tithi(int idx, DateTime start, DateTime end) =>
    t(TransitionKind.tithi, idx, start, end);

/// Tithi 4 ends before the day; 5 is udaya; 6 is kshaya (08:00–23:00 UTC, i.e. ends
/// 04:30 IST after midnight); 7 runs past the next sunrise.
final normalTithis = [
  tithi(4, DateTime.utc(2026, 1, 3, 12), DateTime.utc(2026, 1, 4, 10)),
  tithi(5, DateTime.utc(2026, 1, 4, 10), DateTime.utc(2026, 1, 5, 8)),
  tithi(6, DateTime.utc(2026, 1, 5, 8), DateTime.utc(2026, 1, 5, 23)),
  tithi(7, DateTime.utc(2026, 1, 5, 23), DateTime.utc(2026, 1, 6, 20)),
];

final otherKinds = [
  t(
    TransitionKind.nakshatra,
    10,
    DateTime.utc(2026, 1, 4, 6),
    DateTime.utc(2026, 1, 5, 6),
  ),
  t(
    TransitionKind.nakshatra,
    11,
    DateTime.utc(2026, 1, 5, 6),
    DateTime.utc(2026, 1, 6, 7),
  ),
  t(
    TransitionKind.yoga,
    3,
    DateTime.utc(2026, 1, 4, 20),
    DateTime.utc(2026, 1, 6, 1),
  ),
  t(
    TransitionKind.karana,
    8,
    DateTime.utc(2026, 1, 4, 22),
    DateTime.utc(2026, 1, 5, 8),
  ),
  t(
    TransitionKind.karana,
    9,
    DateTime.utc(2026, 1, 5, 8),
    DateTime.utc(2026, 1, 5, 15),
  ),
  t(
    TransitionKind.karana,
    10,
    DateTime.utc(2026, 1, 5, 15),
    DateTime.utc(2026, 1, 5, 23),
  ),
  t(
    TransitionKind.karana,
    11,
    DateTime.utc(2026, 1, 5, 23),
    DateTime.utc(2026, 1, 6, 9),
  ),
];

DayInputs inputs({
  List<Transition>? tithis,
  DateTime? previous,
  DateTime? rise,
  DateTime? set,
  DateTime? next,
}) => DayInputs(
  date: date,
  previousSunrise: previous ?? previousSunrise,
  sun: SunMoonTimes(
    sunrise: rise ?? sunrise,
    sunset: set ?? sunset,
    moonrise: null,
    moonset: null,
    packId: pack,
  ),
  nextSunrise: next ?? nextSunrise,
  bengaliDate: const BengaliDate(
    day: 20,
    monthIdx: 8,
    year: 1432,
    packId: pack,
  ),
  transitions: [...otherKinds, ...(tithis ?? normalTithis)].reversed.toList(),
  periodRules: standardDayPeriodRules,
  names: fakeName,
  provenance: provenance,
);

void main() {
  group('a day with a kshaya tithi', () {
    final day = assembler.assemble(inputs());

    test('the udaya tithi is the one prevailing at sunrise', () {
      expect(day.udayaTithi.idx, 5);
      expect(day.udayaTithi.name, fakeName('tithi', 5));
      expect(day.isVriddhi, isFalse);
    });

    test('lists every tithi touching the day, in order', () {
      expect([for (final x in day.tithis) x.span.idx], [5, 6, 7]);
    });

    test('a tithi that touches no sunrise is kshaya', () {
      expect([for (final x in day.kshayaTithis) x.span.idx], [6]);
    });

    test(
      'other kinds are per kind, in order, and only those touching the day',
      () {
        expect(
          [for (final s in day.spans[TransitionKind.nakshatra]!) s.idx],
          [10, 11],
        );
        expect([for (final s in day.spans[TransitionKind.yoga]!) s.idx], [3]);
        expect(
          [for (final s in day.spans[TransitionKind.karana]!) s.idx],
          [8, 9, 10, 11],
        );
      },
    );

    test('karana names go through the 11-name mapping', () {
      final names = [for (final s in day.spans[TransitionKind.karana]!) s.name];
      expect(names, [
        fakeName('karana', 0), // k = 8 → Bava again
        fakeName('karana', 1),
        fakeName('karana', 2),
        fakeName('karana', 3),
      ]);
    });

    test('weekday, Bengali month name and provenance carry through', () {
      expect(day.weekday, Weekday.monday);
      expect(day.bengaliMonth, fakeName('solar_month', 8));
      expect(day.provenance, same(provenance));
    });

    test('times after IST midnight are flagged for "(পরদিন)"', () {
      final kshaya = day.kshayaTithis.single.span;
      expect(
        day.isAfterMidnight(kshaya.endUtc),
        isTrue,
      ); // 04:30 IST on the 6th
      expect(day.isAfterMidnight(day.udayaTithi.endUtc), isFalse); // 13:30 IST
      expect(
        day.isAfterMidnight(DateTime.utc(2026, 1, 5, 18, 29)),
        isFalse,
      ); // 23:59 IST
      expect(
        day.isAfterMidnight(DateTime.utc(2026, 1, 5, 18, 30)),
        isTrue,
      ); // 00:00 IST
    });

    test('currentOf follows now inside the day and sunrise outside it', () {
      final inDay = DateTime.utc(2026, 1, 5, 10);
      expect(day.currentOf(TransitionKind.tithi, inDay).idx, 6);
      expect(day.currentOf(TransitionKind.karana, inDay).idx, 9);
      final otherDay = DateTime.utc(2026, 3, 1);
      expect(day.currentOf(TransitionKind.tithi, otherDay).idx, 5);
      expect(day.currentOf(TransitionKind.nakshatra, otherDay).idx, 10);
    });

    test('nextAfter gives the following span within the day', () {
      expect(day.nextAfter(day.udayaTithi)?.idx, 6);
      expect(day.nextAfter(day.tithis.last.span), isNull);
    });

    test('progressAt is 0–1 across a span', () {
      final s = day.udayaTithi;
      expect(s.progressAt(s.startUtc), 0);
      expect(s.progressAt(s.endUtc), 1);
      expect(s.progressAt(DateTime.utc(2026, 1, 4, 21)), closeTo(0.5, 1e-9));
      expect(s.progressAt(DateTime.utc(2030)), 1);
    });
  });

  group('vriddhi', () {
    test('udaya tithi that also prevailed at the previous sunrise', () {
      final day = assembler.assemble(
        inputs(
          tithis: [
            tithi(5, DateTime.utc(2026, 1, 3, 23), DateTime.utc(2026, 1, 5, 2)),
            tithi(6, DateTime.utc(2026, 1, 5, 2), DateTime.utc(2026, 1, 6, 3)),
          ],
        ),
      );
      expect(day.udayaTithi.idx, 5);
      expect(day.isVriddhi, isTrue);
      expect(day.kshayaTithis, isEmpty);
    });

    test('udaya tithi that will also prevail at the next sunrise', () {
      final day = assembler.assemble(
        inputs(
          tithis: [
            tithi(5, DateTime.utc(2026, 1, 4, 12), DateTime.utc(2026, 1, 6, 2)),
          ],
        ),
      );
      expect(day.isVriddhi, isTrue);
      expect([for (final x in day.tithis) x.span.idx], [5]);
    });

    test('a tithi starting exactly at sunrise is udaya, not kshaya', () {
      final day = assembler.assemble(
        inputs(
          tithis: [
            tithi(4, DateTime.utc(2026, 1, 4, 3), sunrise),
            tithi(5, sunrise, DateTime.utc(2026, 1, 6, 0)),
            tithi(6, DateTime.utc(2026, 1, 6, 0), DateTime.utc(2026, 1, 6, 22)),
          ],
        ),
      );
      expect(day.udayaTithi.idx, 5);
      expect([for (final x in day.tithis) x.span.idx], [5, 6]);
      expect(day.kshayaTithis, isEmpty);
    });
  });

  group('periods', () {
    final day = assembler.assemble(inputs());

    test('match the calculator for the weekday, in time order', () {
      final expected = [
        ...const DivisionPeriodCalculator().periodsFor(
          sunriseUtc: sunrise,
          sunsetUtc: sunset,
          nextSunriseUtc: nextSunrise,
          weekday: Weekday.monday,
          rules: standardDayPeriodRules,
        ),
      ]..sort((a, b) => a.startUtc.compareTo(b.startUtc));
      String key(TimePeriod p) => '${p.periodId}@${p.startUtc}-${p.endUtc}';
      expect(day.periods.map(key), expected.map(key));
      for (var i = 1; i < day.periods.length; i++) {
        expect(
          day.periods[i - 1].startUtc.isAfter(day.periods[i].startUtc),
          isFalse,
        );
      }
    });

    test('activePeriod highlights Rahu Kaal while it runs', () {
      final rahu = day.periods.singleWhere(
        (p) => p.periodId == PeriodIds.rahuKaal,
      );
      expect(day.activePeriod(rahu.startUtc)?.periodId, PeriodIds.rahuKaal);
      expect(
        day.activePeriod(rahu.endUtc)?.periodId,
        isNot(PeriodIds.rahuKaal),
      );
      expect(day.activePeriod(DateTime.utc(2026, 1, 5, 20)), isNull); // night
    });
  });

  group('device time zone', () {
    test('local DateTime inputs give the same day as UTC inputs', () {
      final utcDay = assembler.assemble(inputs());
      final localDay = assembler.assemble(
        inputs(
          tithis: [
            for (final x in normalTithis)
              tithi(x.idx, x.startUtc.toLocal(), x.endUtc.toLocal()),
          ],
          previous: previousSunrise.toLocal(),
          rise: sunrise.toLocal(),
          set: sunset.toLocal(),
          next: nextSunrise.toLocal(),
        ),
      );
      String summary(DayPanjika d) => [
        d.udayaTithi.idx,
        d.udayaTithi.startUtc.toIso8601String(),
        for (final x in d.tithis) '${x.span.idx}${x.isKshaya ? 'k' : ''}',
        for (final p in d.periods) p.startUtc.toIso8601String(),
        d.isAfterMidnight(d.kshayaTithis.single.span.endUtc),
      ].join('|');
      expect(summary(localDay), summary(utcDay));
      expect(localDay.udayaTithi.startUtc.isUtc, isTrue);
      expect(localDay.nextSunrise.isUtc, isTrue);
    });

    // CI also runs this file under TZ=Pacific/Kiritimati (UTC+14), where the device date
    // differs from the IST date for part of every day.
    test('runs with the device offset ${DateTime.now().timeZoneOffset}', () {
      final day = assembler.assemble(inputs());
      expect(day.date, date);
      expect(day.isAfterMidnight(DateTime.utc(2026, 1, 5, 18, 30)), isTrue);
    });
  });

  group('invalid input', () {
    test('sunrises out of order', () {
      expect(
        () => assembler.assemble(inputs(previous: sunrise)),
        throwsArgumentError,
      );
      expect(
        () => assembler.assemble(inputs(next: sunrise)),
        throwsArgumentError,
      );
    });

    test('no tithi covers sunrise', () {
      expect(
        () => assembler.assemble(
          inputs(
            tithis: [
              tithi(
                6,
                DateTime.utc(2026, 1, 5, 8),
                DateTime.utc(2026, 1, 6, 3),
              ),
            ],
          ),
        ),
        throwsStateError,
      );
    });
  });

  group('karanaNameIndex', () {
    test('fixed and movable karanas', () {
      expect(karanaNameIndex(0), 10); // Kimstughna
      expect(
        [for (var k = 1; k <= 8; k++) karanaNameIndex(k)],
        [0, 1, 2, 3, 4, 5, 6, 0],
      );
      expect(karanaNameIndex(56), 6); // last Vishti
      expect(
        [karanaNameIndex(57), karanaNameIndex(58), karanaNameIndex(59)],
        [7, 8, 9],
      );
    });

    test('rejects indices outside 0–59', () {
      expect(() => karanaNameIndex(-1), throwsRangeError);
      expect(() => karanaNameIndex(60), throwsRangeError);
    });
  });
}
