// T-211: GetDayPanjika, GetMonthGrid and GetUpcomingObservances on the sample pack.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/data/repositories/panjika_repository.dart';
import 'package:panjika/domain/engine/day_assembler.dart';
import 'package:panjika/domain/entities/panjika.dart';
import 'package:panjika/domain/usecases/get_day_panjika.dart';
import 'package:panjika/domain/usecases/get_month_grid.dart';
import 'package:panjika/domain/usecases/get_upcoming_observances.dart';

const drik = 'drik_bishuddha';
const sampleDay = CivilDate(2026, 10, 12);

void main() {
  late AppDatabase db;
  late GetDayPanjika getDay;
  late GetMonthGrid getMonth;
  late GetUpcomingObservances getUpcoming;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await loadSamplePackIfEmpty(db);
    final repo = DriftPanjikaRepository(db);
    getDay = GetDayPanjika(repo, repo);
    getMonth = GetMonthGrid(repo, repo);
    getUpcoming = GetUpcomingObservances(repo, repo);
  });
  tearDown(() => db.close());

  Future<DayPanjika?> day(CivilDate date, {String city = 'kolkata'}) =>
      getDay(date: date, tradition: drik, cityId: city);

  group('GetDayPanjika', () {
    test('assembles the sample day with provenance and observances', () async {
      final d = (await day(sampleDay))!;
      expect(d.date, sampleDay);
      expect(d.weekday, Weekday.monday);
      expect(
        (d.bengaliDate.day, d.bengaliMonth.en, d.bengaliDate.year),
        (25, 'Ashwin', 1433),
      );
      expect(d.udayaTithi.contains(d.sun.sunrise), isTrue);
      expect(d.periods.length, 3);
      expect(d.observances.single.observance.id, 'durga_shashthi');
      expect(d.provenance.isSample, isTrue);
      expect(d.provenance.city.en, 'Kolkata');
      expect(d.provenance.tradition.bn, 'বিশুদ্ধ সিদ্ধান্ত (দৃক)');
      expect(d.provenance.packIds, [
        'sample-cities',
        'sample-global-drik',
        'sample-observances-drik',
      ]);
    });

    test('containing(): before sunrise belongs to the previous date', () async {
      final d = (await day(sampleDay))!;
      final beforeNextSunrise = d.nextSunrise.subtract(
        const Duration(minutes: 1),
      );
      final afterSunrise = d.sun.sunrise.add(const Duration(minutes: 1));
      for (final instant in [beforeNextSunrise, afterSunrise]) {
        final c = await getDay.containing(
          instant,
          tradition: drik,
          cityId: 'kolkata',
        );
        expect(c!.date, sampleDay, reason: '$instant');
      }
      final c = await getDay.containing(
        d.nextSunrise,
        tradition: drik,
        cityId: 'kolkata',
      );
      expect(c!.date, sampleDay.addDays(1));
    });

    test(
      'null outside the packs, at their edges and for unknown cities',
      () async {
        expect(await day(const CivilDate(2027, 2, 1)), isNull);
        expect(
          await day(const CivilDate(2026, 9, 1)),
          isNull,
          reason: 'no previous sunrise',
        );
        expect(
          await day(const CivilDate(2026, 12, 31)),
          isNull,
          reason: 'no next sunrise',
        );
        expect(await day(sampleDay, city: 'nowhere'), isNull);
      },
    );

    test(
      'every day in the packs: tithis tile the day; vriddhi and kshaya agree',
      () async {
        final days = <DayPanjika>[];
        for (
          var d = const CivilDate(2026, 9, 2);
          d.compareTo(const CivilDate(2026, 12, 30)) <= 0;
          d = d.addDays(1)
        ) {
          days.add((await day(d))!);
        }
        final seen = <int>{};
        for (final d in days) {
          for (var i = 1; i < d.tithis.length; i++) {
            expect(d.tithis[i].span.startUtc, d.tithis[i - 1].span.endUtc);
          }
          for (final t in d.tithis) {
            if (t.isKshaya || identical(t.span, d.udayaTithi)) {
              seen.add(t.span.idx);
            }
          }
        }
        for (var i = 1; i < days.length; i++) {
          if (days[i].udayaTithi.idx == days[i - 1].udayaTithi.idx) {
            expect(
              days[i].isVriddhi && days[i - 1].isVriddhi,
              isTrue,
              reason: '${days[i].date}',
            );
          }
        }
        expect(
          seen.length,
          30,
          reason: 'every tithi is named by a day or listed as kshaya',
        );
      },
    );
  });

  group('GetMonthGrid', () {
    Future<MonthGrid?> month(MonthRef m) =>
        getMonth(month: m, tradition: drik, cityId: 'kolkata');

    test('a Gregorian month', () async {
      final g = (await month(const GregorianMonthRef(2026, 10)))!;
      expect(g.days.length, 31);
      expect(g.monthName.en, 'October');
      expect(g.leadingBlanks, 4, reason: '1 Oct 2026 is a Thursday');
      final sample = g.days.singleWhere((x) => x.date == sampleDay);
      expect(sample.bengaliDate.day, 25);
      expect(sample.observances.single.observance.id, 'durga_shashthi');
      expect(g.provenance.isSample, isTrue);
    });

    test('a Bengali month starts on day 1 and runs consecutively', () async {
      final bn = (await getDay(
        date: sampleDay,
        tradition: drik,
        cityId: 'kolkata',
      ))!.bengaliDate;
      final g = (await month(BengaliMonthRef(1433, bn.monthIdx)))!;
      expect(g.monthName.en, 'Ashwin');
      expect(
        [for (final x in g.days) x.bengaliDate.day],
        [for (var i = 1; i <= g.days.length; i++) i],
      );
      expect(g.days.length, inInclusiveRange(29, 32));
    });

    test('markers follow the udaya tithi', () async {
      final g = (await month(const GregorianMonthRef(2026, 10)))!;
      for (final x in g.days) {
        expect(x.markers.contains(MoonMarker.purnima), x.udayaTithiIdx == 14);
        expect(x.markers.contains(MoonMarker.amavasya), x.udayaTithiIdx == 29);
        expect(
          x.markers.contains(MoonMarker.ekadashi),
          x.udayaTithiIdx == 10 || x.udayaTithiIdx == 25,
        );
      }
    });

    test('null when the month is not fully in the packs', () async {
      expect(await month(const GregorianMonthRef(2027, 2)), isNull);
      expect(await month(const GregorianMonthRef(2026, 8)), isNull);
      expect(await month(const BengaliMonthRef(1433, 0)), isNull);
      // ভাদ্র 1433 starts before the pack and কার্তিক… the last month runs past it.
      expect(await month(const BengaliMonthRef(1433, 4)), isNull);
      expect(await month(const BengaliMonthRef(1433, 8)), isNull);
    });

    test('next and previous roll over the year', () {
      expect(
        const BengaliMonthRef(1432, 11).next,
        const BengaliMonthRef(1433, 0),
      );
      expect(
        const BengaliMonthRef(1433, 0).previous,
        const BengaliMonthRef(1432, 11),
      );
      expect(
        const GregorianMonthRef(2026, 12).next,
        const GregorianMonthRef(2027, 1),
      );
      expect(
        const GregorianMonthRef(2027, 1).previous,
        const GregorianMonthRef(2026, 12),
      );
    });
  });

  group('GetUpcomingObservances', () {
    Future<ObservanceList?> upcoming({
      int? limit,
      int? maxTier,
      String city = 'kolkata',
      CivilDate? to,
    }) => getUpcoming(
      tradition: drik,
      cityId: city,
      from: sampleDay,
      to: to ?? const CivilDate(2026, 12, 31),
      limit: limit,
      maxTier: maxTier,
    );

    test('in date order, limited, with provenance', () async {
      final list = (await upcoming(limit: 3))!;
      expect(
        [for (final o in list.items) o.observance.id],
        ['durga_shashthi', 'maha_saptami', 'maha_ashtami'],
      );
      expect(list.provenance.isSample, isTrue);
      expect(list.provenance.packIds, ['sample-observances-drik']);
    });

    test('tier filter', () async {
      final all = (await upcoming())!.items.map((o) => o.observance.id);
      final major = (await upcoming(maxTier: 1))!.items
          .map((o) => o.observance.id);
      expect(all, contains('bhai_phonta'));
      expect(major, isNot(contains('bhai_phonta')));
    });

    test(
      'each observance once, at the first day of a multi-day festival',
      () async {
        // Real packs have spans (Durga Puja Shashthi → Dashami) and recurring
        // observances; add both shapes as sample rows.
        await db.customStatement(
          "INSERT INTO observances VALUES ('durga_puja', 'দুর্গাপূজা', 'Durga Puja',"
          " 'puja', 1, 'নমুনা বিবরণ। (নমুনা বিবরণ)', 'Sample. (Sample)',"
          " 'sample-observances-drik')",
        );
        for (var i = 0; i < 5; i++) {
          await db.customStatement(
            'INSERT INTO observance_dates (observance_id, tradition, date, day_index,'
            " status, pack_id) VALUES ('durga_puja', 'drik_bishuddha',"
            " '2026-10-${13 + i}', $i, 'sample', 'sample-observances-drik')",
          );
        }
        await db.customStatement(
          'INSERT INTO observance_dates (observance_id, tradition, date, status, pack_id)'
          " VALUES ('maha_saptami', 'drik_bishuddha', '2026-12-01', 'sample',"
          " 'sample-observances-drik')",
        );
        final ids = [
          for (final o in (await upcoming())!.items) o.observance.id,
        ];
        expect(ids.where((id) => id == 'durga_puja'), hasLength(1));
        expect(ids.where((id) => id == 'maha_saptami'), hasLength(1));
        final durga = (await upcoming())!.items.firstWhere(
          (o) => o.observance.id == 'durga_puja',
        );
        expect(durga.date, const CivilDate(2026, 10, 13));
      },
    );

    test('empty range and unknown city', () async {
      final none = (await upcoming(to: sampleDay.addDays(-1)))!;
      expect(none.items, isEmpty);
      expect(none.provenance.isSample, isFalse);
      expect(await upcoming(city: 'nowhere'), isNull);
    });
  });
}
