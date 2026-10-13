import '../../core/time/civil_date.dart';
import '../engine/interfaces.dart';
import '../entities/name_ref.dart';
import '../entities/panjika.dart';
import 'provenance.dart';

/// Which month the grid shows: the Bengali/Gregorian toggle (spec §11.3).
sealed class MonthRef {
  const MonthRef();
}

final class BengaliMonthRef extends MonthRef {
  const BengaliMonthRef(this.year, this.monthIdx);

  final int year;

  /// 0 = বৈশাখ (spec §15.1).
  final int monthIdx;

  /// চৈত্র rolls over to বৈশাখ of the next year (spec §16).
  BengaliMonthRef get next => monthIdx == 11
      ? BengaliMonthRef(year + 1, 0)
      : BengaliMonthRef(year, monthIdx + 1);
  BengaliMonthRef get previous => monthIdx == 0
      ? BengaliMonthRef(year - 1, 11)
      : BengaliMonthRef(year, monthIdx - 1);

  @override
  bool operator ==(Object other) =>
      other is BengaliMonthRef &&
      other.year == year &&
      other.monthIdx == monthIdx;

  @override
  int get hashCode => Object.hash('bn', year, monthIdx);
}

final class GregorianMonthRef extends MonthRef {
  const GregorianMonthRef(this.year, this.month);

  final int year;

  /// 1–12, as in [DateTime.month].
  final int month;

  GregorianMonthRef get next => month == 12
      ? GregorianMonthRef(year + 1, 1)
      : GregorianMonthRef(year, month + 1);
  GregorianMonthRef get previous => month == 1
      ? GregorianMonthRef(year - 1, 12)
      : GregorianMonthRef(year, month - 1);

  @override
  bool operator ==(Object other) =>
      other is GregorianMonthRef && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash('greg', year, month);
}

/// Grid markers (spec §11.3): ● পূর্ণিমা, ○ অমাবস্যা, এ একাদশী. They follow the udaya
/// tithi; when a vrata is actually kept is an observance rule, and comes from the pack.
enum MoonMarker { purnima, amavasya, ekadashi }

/// Tithi indices (0-based, spec §15.1) behind each marker.
const _markerTithis = {
  14: MoonMarker.purnima,
  29: MoonMarker.amavasya,
  10: MoonMarker.ekadashi,
  25: MoonMarker.ekadashi,
};

class MonthGridDay {
  const MonthGridDay({
    required this.date,
    required this.weekday,
    required this.bengaliDate,
    required this.udayaTithiIdx,
    required this.udayaTithi,
    required this.markers,
    required this.observances,
  });

  final CivilDate date;
  final Weekday weekday;
  final BengaliDate bengaliDate;
  final int udayaTithiIdx;
  final NameRef udayaTithi;
  final Set<MoonMarker> markers;
  final List<ObservanceDate> observances;
}

class MonthGrid {
  const MonthGrid({
    required this.month,
    required this.monthName,
    required this.days,
    required this.provenance,
  });

  final MonthRef month;

  /// Bengali month name (Bengali mode) or Gregorian month name (Gregorian mode).
  final NameRef monthName;
  final List<MonthGridDay> days;
  final Provenance provenance;

  /// Empty cells before the first day; weeks start on Sunday (spec §11.3).
  int get leadingBlanks => days.first.weekday.index;
}

/// One month of the Calendar grid. Returns null unless every day of the month is in
/// the installed packs: a half-filled month would read as real (FR-HOME-09).
class GetMonthGrid {
  const GetMonthGrid(this._source, this._catalog);

  final PanjikaSource _source;
  final CatalogSource _catalog;

  Future<MonthGrid?> call({
    required MonthRef month,
    required String tradition,
    required String cityId,
  }) async {
    final dates = switch (month) {
      BengaliMonthRef(:final year, :final monthIdx) =>
        await _source.bengaliMonthDates(tradition, year, monthIdx),
      GregorianMonthRef(:final year, month: final m) => [
        for (var d = CivilDate(year, m, 1); d.month == m; d = d.addDays(1)) d,
      ],
    };
    if (dates.isEmpty) return null;
    final from = dates.first;
    final to = dates.last;

    final (suns, bengali, observances, city, names) = await (
      _source.sunMoonTimesBetween(cityId, from, to),
      // One day either side, to prove a Bengali month is whole (below).
      _source.bengaliDatesBetween(tradition, from.addDays(-1), to.addDays(1)),
      _source.observances(tradition, from, to),
      _catalog.city(cityId),
      _catalog.names(),
    ).wait;
    if (city == null ||
        dates.any((d) => suns[d] == null || bengali[d] == null)) {
      return null;
    }
    // A Bengali month is only shown whole: its first day is day 1 and the next day
    // starts the following month. A pack edge inside the month would otherwise make a
    // part of it look like all of it.
    if (month is BengaliMonthRef &&
        (bengali[from]!.day != 1 || bengali[to.addDays(1)]?.day != 1)) {
      return null;
    }

    final tithis = await _source.transitions(
      tradition,
      TransitionKind.tithi,
      suns[from]!.sunrise,
      suns[to]!.sunrise.add(const Duration(seconds: 1)),
    );
    final packIds = <String>{};
    final days = <MonthGridDay>[];
    for (final date in dates) {
      final sun = suns[date]!;
      final bn = bengali[date]!;
      final udaya = tithis.where((t) => t.contains(sun.sunrise));
      if (udaya.isEmpty) return null;
      final tithi = udaya.first;
      final onDay = [
        for (final o in observances)
          if (o.date == date) o,
      ];
      packIds.addAll([
        sun.packId,
        bn.packId,
        tithi.packId,
        for (final o in onDay) o.packId,
      ]);
      days.add(
        MonthGridDay(
          date: date,
          weekday: Weekday.of(date),
          bengaliDate: bn,
          udayaTithiIdx: tithi.idx,
          udayaTithi: names.of('tithi', tithi.idx),
          markers: {?_markerTithis[tithi.idx]},
          observances: List.unmodifiable(onDay),
        ),
      );
    }

    return MonthGrid(
      month: month,
      monthName: switch (month) {
        BengaliMonthRef(:final monthIdx) => names.of('solar_month', monthIdx),
        GregorianMonthRef(month: final m) => names.of('gregorian_month', m - 1),
      },
      days: List.unmodifiable(days),
      provenance: await provenanceFor(
        _catalog,
        names,
        tradition: tradition,
        city: city,
        packIds: packIds,
      ),
    );
  }
}
