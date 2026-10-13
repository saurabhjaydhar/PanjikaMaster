import '../../core/time/civil_date.dart';
import '../engine/interfaces.dart';
import '../entities/name_ref.dart';
import '../entities/panjika.dart';
import 'provenance.dart';

/// One observance date with its Bengali date, for the year list.
class FestivalYearItem {
  const FestivalYearItem(this.observance, this.bengaliDate);

  final ObservanceDate observance;
  final BengaliDate bengaliDate;
}

class FestivalYearMonth {
  const FestivalYearMonth({
    required this.monthIdx,
    required this.monthName,
    required this.items,
  });

  /// 0 = বৈশাখ.
  final int monthIdx;
  final NameRef monthName;

  /// By date, then tier, then id.
  final List<FestivalYearItem> items;
}

class FestivalYear {
  const FestivalYear({
    required this.year,
    required this.months,
    required this.complete,
    required this.provenance,
  });

  final int year;

  /// The year's months that are wholly in the installed packs, in order; months with
  /// no observances are included (empty), so the list shows every whole month.
  final List<FestivalYearMonth> months;

  /// All twelve months are installed.
  final bool complete;
  final Provenance provenance;
}

/// A Bengali year of observances grouped by month (spec §11.5, FR-FEST-01). Only whole
/// months are included: a month cut by a pack edge would look like all of it.
/// Null if no month of the year is installed, or the city isn't.
class GetFestivalYear {
  const GetFestivalYear(this._source, this._catalog);

  final PanjikaSource _source;
  final CatalogSource _catalog;

  Future<FestivalYear?> call({
    required String tradition,
    required String cityId,
    required int year,
  }) async {
    final (monthDates, city, names) = await (
      Future.wait([
        for (var m = 0; m < 12; m++)
          _source.bengaliMonthDates(tradition, year, m),
      ]),
      _catalog.city(cityId),
      _catalog.names(),
    ).wait;
    if (city == null) return null;
    final present = [
      for (var m = 0; m < 12; m++)
        if (monthDates[m].isNotEmpty) m,
    ];
    if (present.isEmpty) return null;
    final from = monthDates[present.first].first;
    final to = monthDates[present.last].last;
    final (bengali, observances) = await (
      // One day either side, to prove the edge months are whole.
      _source.bengaliDatesBetween(tradition, from.addDays(-1), to.addDays(1)),
      _source.observances(tradition, from, to),
    ).wait;

    bool whole(List<CivilDate> dates) =>
        dates.isNotEmpty &&
        bengali[dates.first]?.day == 1 &&
        bengali[dates.last.addDays(1)]?.day == 1;

    final packIds = <String>{};
    final months = <FestivalYearMonth>[];
    for (final m in present) {
      final dates = monthDates[m];
      if (!whole(dates)) continue;
      final items = [
        for (final o in observances)
          if (o.date.compareTo(dates.first) >= 0 &&
              o.date.compareTo(dates.last) <= 0)
            FestivalYearItem(o, bengali[o.date]!),
      ];
      packIds
        ..addAll(items.map((i) => i.observance.packId))
        ..add(bengali[dates.first]!.packId);
      months.add(
        FestivalYearMonth(
          monthIdx: m,
          monthName: names.of('solar_month', m),
          items: List.unmodifiable(items),
        ),
      );
    }
    if (months.isEmpty) return null;
    return FestivalYear(
      year: year,
      months: List.unmodifiable(months),
      complete: months.length == 12,
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
