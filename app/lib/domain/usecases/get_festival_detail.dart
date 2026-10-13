import '../../core/time/civil_date.dart';
import '../engine/interfaces.dart';
import '../entities/name_ref.dart';
import '../entities/panjika.dart';
import 'provenance.dart';

/// One day of a festival: its date row, Bengali date, the tithi at sunrise (where the
/// city's sunrise is installed) and that day's windows.
class FestivalDay {
  const FestivalDay({
    required this.date,
    required this.bengaliDate,
    required this.tithi,
    required this.tithiEnd,
    required this.windows,
  });

  final ObservanceDate date;
  final BengaliDate? bengaliDate;
  final NameRef? tithi;
  final DateTime? tithiEnd;
  final List<ObservanceWindow> windows;
}

class FestivalDetail {
  const FestivalDetail({
    required this.observance,
    required this.days,
    required this.selected,
    required this.provenance,
  });

  final Observance observance;

  /// The days of one occurrence: one day, or Shashthi → Dashami (FR-FEST-04).
  final List<FestivalDay> days;

  /// Index into [days] to show first.
  final int selected;
  final Provenance provenance;
}

/// A festival's detail (spec §11.6, FR-FEST-03..04): the occurrence containing [date]
/// if given, else the next one from [today], else the latest installed. Null if the
/// festival or the city isn't installed.
class GetFestivalDetail {
  const GetFestivalDetail(this._source, this._catalog);

  final PanjikaSource _source;
  final CatalogSource _catalog;

  Future<FestivalDetail?> call({
    required String tradition,
    required String cityId,
    required String id,
    required CivilDate today,
    CivilDate? date,
  }) async {
    final (dates, windows, city, names) = await (
      _source.observanceDatesOf(tradition, id),
      _source.windowsOf(tradition, id),
      _catalog.city(cityId),
      _catalog.names(),
    ).wait;
    if (dates.isEmpty || city == null) return null;

    // Occurrences: a run of days whose day index counts up from 0.
    final cycles = <List<ObservanceDate>>[];
    for (final d in dates) {
      if (d.dayIndex == 0 || cycles.isEmpty) {
        cycles.add([d]);
      } else {
        cycles.last.add(d);
      }
    }
    bool has(List<ObservanceDate> c, CivilDate x) => c.any((d) => d.date == x);
    final cycle = date != null && cycles.any((c) => has(c, date))
        ? cycles.firstWhere((c) => has(c, date))
        : cycles.firstWhere(
            (c) => c.last.date.compareTo(today) >= 0,
            orElse: () => cycles.last,
          );
    final focus = date ?? today;
    final selected = cycle.indexWhere((d) => d.date == focus);

    final days = <FestivalDay>[];
    final packIds = <String>{};
    for (final d in cycle) {
      final (bengali, sun) = await (
        _source.bengaliDate(tradition, d.date),
        _source.sunMoonTimes(cityId, d.date),
      ).wait;
      NameRef? tithi;
      DateTime? tithiEnd;
      if (sun != null) {
        final at = await _source.transitions(
          tradition,
          TransitionKind.tithi,
          sun.sunrise,
          sun.sunrise.add(const Duration(seconds: 1)),
        );
        final t = at.where((t) => t.contains(sun.sunrise)).firstOrNull;
        if (t != null) {
          tithi = names.of('tithi', t.idx);
          tithiEnd = t.endUtc;
          packIds.add(t.packId);
        }
        packIds.add(sun.packId);
      }
      final dayWindows = [
        for (final w in windows)
          if (w.date == d.date) w,
      ];
      packIds
        ..add(d.packId)
        ..addAll(dayWindows.map((w) => w.packId));
      if (bengali != null) packIds.add(bengali.packId);
      days.add(
        FestivalDay(
          date: d,
          bengaliDate: bengali,
          tithi: tithi,
          tithiEnd: tithiEnd,
          windows: List.unmodifiable(dayWindows),
        ),
      );
    }
    return FestivalDetail(
      observance: cycle.first.observance,
      days: List.unmodifiable(days),
      selected: selected < 0 ? 0 : selected,
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
