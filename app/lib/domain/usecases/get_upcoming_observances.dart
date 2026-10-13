import '../../core/time/civil_date.dart';
import '../engine/interfaces.dart';
import '../entities/panjika.dart';
import 'provenance.dart';

class ObservanceList {
  const ObservanceList(this.items, this.provenance);

  /// By date, then tier, then id.
  final List<ObservanceDate> items;
  final Provenance provenance;
}

/// The next observances from [from] (inclusive): Today's "upcoming" card (spec §11.2,
/// FR-HOME-06). Null if the city is not installed.
class GetUpcomingObservances {
  const GetUpcomingObservances(this._source, this._catalog);

  final PanjikaSource _source;
  final CatalogSource _catalog;

  Future<ObservanceList?> call({
    required String tradition,
    required String cityId,
    required CivilDate from,
    required CivilDate to,
    int? limit,
    int? maxTier,
  }) async {
    final (rows, city, names) = await (
      _source.observances(tradition, from, to),
      _catalog.city(cityId),
      _catalog.names(),
    ).wait;
    if (city == null) return null;
    // Each observance once, at the first day of its next occurrence: a multi-day
    // festival shows its start, not every day, and a recurring one (Ekadashi) doesn't
    // fill the list (T-514).
    final seen = <String>{};
    final filtered = [
      for (final o in rows)
        if ((maxTier == null || o.observance.tier <= maxTier) &&
            o.dayIndex == 0 &&
            seen.add(o.observance.id))
          o,
    ];
    final items = limit == null ? filtered : filtered.take(limit).toList();
    return ObservanceList(
      List.unmodifiable(items),
      await provenanceFor(
        _catalog,
        names,
        tradition: tradition,
        city: city,
        packIds: {for (final o in items) o.packId},
      ),
    );
  }
}
