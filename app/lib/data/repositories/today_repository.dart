import 'package:drift/drift.dart';

import '../../core/time/civil_date.dart';
import '../../domain/entities/name_ref.dart';
import '../../domain/engine/karana.dart';
import '../../domain/entities/today_snapshot.dart';
import '../db/app_database.dart';

DateTime _utc(int seconds) =>
    DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);

/// Reads one day's data from the pack tables. Returns null when anything Today needs is
/// missing, so the screen shows the "data not available" state rather than guessing
/// (FR-HOME-09).
class TodayRepository {
  TodayRepository(this._db);

  final AppDatabase _db;

  Future<TodaySnapshot?> load({
    required DateTime now,
    required String tradition,
    required String cityId,
  }) async {
    final date = CivilDate.ofInstant(now);
    final iso = date.toIso();
    final bn = await _db.bengaliDateOn(tradition, iso).getSingleOrNull();
    final day = await _db.cityDay(cityId, iso).getSingleOrNull();
    final city = await (_db.select(
      _db.cities,
    )..where((c) => c.id.equals(cityId))).getSingleOrNull();
    if (bn == null || day == null || city == null) return null;

    final nameRows =
        await (_db.select(_db.names)..orderBy([
              (n) => OrderingTerm.asc(n.kind),
              (n) => OrderingTerm.asc(n.idx),
            ]))
            .get();
    final names = <String, List<NameRef>>{};
    for (final r in nameRows) {
      (names[r.kind] ??= []).add(NameRef(r.nameBn, r.nameEn));
    }
    NameRef nameOf(String kind, int idx) => names[kind]![idx];

    // Every pack that contributes a datum goes into the provenance (CLAUDE.md).
    final packIds = <String>{bn.packId, day.packId, city.packId};
    final at = now.toUtc().millisecondsSinceEpoch ~/ 1000;
    Future<ElementSpan?> element(
      String kind,
      NameRef Function(int idx) name, {
      int? cycle,
    }) async {
      final rows = await _db
          .transitionsOverlapping(tradition, kind, at, at + 1)
          .get();
      if (rows.isEmpty) return null;
      final r = rows.first;
      packIds.add(r.packId);
      return ElementSpan(
        name: name(r.idx),
        start: _utc(r.startsUtc),
        end: _utc(r.endsUtc),
        next: cycle == null ? null : name((r.idx + 1) % cycle),
      );
    }

    final tithi = await element('tithi', (i) => nameOf('tithi', i), cycle: 30);
    final nakshatra = await element('nakshatra', (i) => nameOf('nakshatra', i));
    final yoga = await element('yoga', (i) => nameOf('yoga', i));
    final karana = await element(
      'karana',
      (k) => nameOf('karana', karanaNameIndex(k)),
    );
    if (tithi == null || nakshatra == null || yoga == null || karana == null) {
      return null;
    }

    // names(kind='tradition') rows carry the tradition id in `translit` (names.toml).
    final traditionRow = nameRows.where(
      (r) => r.kind == 'tradition' && r.translit == tradition,
    );
    final traditionName = traditionRow.isEmpty
        ? NameRef(tradition, tradition)
        : NameRef(traditionRow.first.nameBn, traditionRow.first.nameEn);

    final packs = await (_db.select(
      _db.packs,
    )..where((p) => p.id.isIn(packIds))).get();

    return TodaySnapshot(
      date: date,
      bnDay: bn.bnDay,
      bnMonth: nameOf('solar_month', bn.bnMonthIdx),
      bnYear: bn.bnYear,
      tithi: tithi,
      nakshatra: nakshatra,
      yoga: yoga,
      karana: karana,
      sunrise: _utc(day.sunriseUtc),
      sunset: _utc(day.sunsetUtc),
      moonrise: day.moonriseUtc == null ? null : _utc(day.moonriseUtc!),
      moonset: day.moonsetUtc == null ? null : _utc(day.moonsetUtc!),
      provenance: Provenance(
        tradition: traditionName,
        city: NameRef(city.nameBn, city.nameEn),
        packIds: packIds.toList()..sort(),
        isSample: packs.any((p) => p.isSample == 1),
      ),
    );
  }
}
