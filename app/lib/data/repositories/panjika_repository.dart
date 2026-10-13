import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/time/civil_date.dart';
import '../../domain/engine/interfaces.dart';
import '../../domain/entities/name_ref.dart';
import '../../domain/entities/name_table.dart';
import '../../domain/entities/pack_detail.dart';
import '../../domain/entities/panjika.dart';
import '../../domain/usecases/assess_coverage.dart';
import '../db/app_database.dart';

DateTime _utc(int seconds) =>
    DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);

int _seconds(DateTime instant) =>
    instant.toUtc().millisecondsSinceEpoch ~/ 1000;

/// Panjika and reference data from the installed packs in Drift (spec §14.4). Every
/// returned datum keeps the id of the pack it came from.
class DriftPanjikaRepository implements PanjikaSource, CatalogSource {
  DriftPanjikaRepository(this._db);

  final AppDatabase _db;

  // ------------------------------------------------------------- PanjikaSource

  @override
  Future<List<Transition>> transitions(
    String tradition,
    TransitionKind kind,
    DateTime fromUtc,
    DateTime toUtc,
  ) async {
    final rows = await _db
        .transitionsOverlapping(
          tradition,
          kind.name,
          _seconds(fromUtc),
          _seconds(toUtc),
        )
        .get();
    return [
      for (final r in rows)
        Transition(
          kind: kind,
          idx: r.idx,
          startUtc: _utc(r.startsUtc),
          endUtc: _utc(r.endsUtc),
          packId: r.packId,
        ),
    ];
  }

  @override
  Future<SunMoonTimes?> sunMoonTimes(String cityId, CivilDate date) async {
    final row = await _db.cityDay(cityId, date.toIso()).getSingleOrNull();
    return row == null ? null : _sunMoon(row);
  }

  @override
  Future<Map<CivilDate, SunMoonTimes>> sunMoonTimesBetween(
    String cityId,
    CivilDate from,
    CivilDate to,
  ) async {
    final rows = await _db
        .cityDaysBetween(cityId, from.toIso(), to.toIso())
        .get();
    return {for (final r in rows) CivilDate.parse(r.date): _sunMoon(r)};
  }

  SunMoonTimes _sunMoon(CityDayRow r) => SunMoonTimes(
    sunrise: _utc(r.sunriseUtc),
    sunset: _utc(r.sunsetUtc),
    moonrise: r.moonriseUtc == null ? null : _utc(r.moonriseUtc!),
    moonset: r.moonsetUtc == null ? null : _utc(r.moonsetUtc!),
    packId: r.packId,
  );

  @override
  Future<BengaliDate?> bengaliDate(String tradition, CivilDate date) async {
    final row = await _db
        .bengaliDateOn(tradition, date.toIso())
        .getSingleOrNull();
    return row == null ? null : _bengali(row);
  }

  @override
  Future<Map<CivilDate, BengaliDate>> bengaliDatesBetween(
    String tradition,
    CivilDate from,
    CivilDate to,
  ) async {
    final rows = await _db
        .bengaliDatesBetween(tradition, from.toIso(), to.toIso())
        .get();
    return {for (final r in rows) CivilDate.parse(r.date): _bengali(r)};
  }

  /// Every installed date with this Bengali day and month, in date order (search).
  Future<Map<CivilDate, BengaliDate>> bengaliDatesOf(
    String tradition,
    int monthIdx,
    int day,
  ) async => {
    for (final r in await _db.bengaliDatesOf(tradition, monthIdx, day).get())
      CivilDate.parse(r.date): _bengali(r),
  };

  /// The first day of every installed observance date, in date order (search index).
  Future<List<ObservanceDate>> observanceStarts(String tradition) async => [
    for (final ObservanceStartsResult(:o, :d)
        in await _db.observanceStarts(tradition).get())
      _observanceDate(o, d),
  ];

  @override
  Future<List<CivilDate>> bengaliMonthDates(
    String tradition,
    int year,
    int monthIdx,
  ) async {
    final rows = await _db.bengaliMonthDates(tradition, year, monthIdx).get();
    return [for (final r in rows) CivilDate.parse(r.date)];
  }

  BengaliDate _bengali(BengaliDateRow r) => BengaliDate(
    day: r.bnDay,
    monthIdx: r.bnMonthIdx,
    year: r.bnYear,
    packId: r.packId,
  );

  @override
  Future<List<LunarMonth>> lunarMonths(
    String tradition,
    DateTime fromUtc,
    DateTime toUtc,
  ) async {
    final rows = await _db
        .lunarMonthsOverlapping(tradition, _seconds(fromUtc), _seconds(toUtc))
        .get();
    return [
      for (final r in rows)
        LunarMonth(
          monthIdx: r.monthIdx,
          isAdhik: r.isAdhik == 1,
          startUtc: _utc(r.startsUtc),
          endUtc: _utc(r.endsUtc),
          packId: r.packId,
        ),
    ];
  }

  @override
  Future<List<ObservanceDate>> observances(
    String tradition,
    CivilDate from,
    CivilDate to,
  ) async {
    final rows = await _db
        .observancesBetween(tradition, from.toIso(), to.toIso())
        .get();
    return [
      for (final ObservancesBetweenResult(:o, :d) in rows)
        _observanceDate(o, d),
    ];
  }

  @override
  Future<List<ObservanceDate>> observanceDatesOf(
    String tradition,
    String id,
  ) async => [
    for (final ObservanceDatesOfResult(:o, :d)
        in await _db.observanceDatesOf(tradition, id).get())
      _observanceDate(o, d),
  ];

  @override
  Future<List<ObservanceWindow>> windowsOf(String tradition, String id) async =>
      [
        for (final w in await _db.windowsOf(tradition, id).get())
          ObservanceWindow(
            observanceId: w.observanceId,
            date: CivilDate.parse(w.date),
            kind: w.windowKind,
            start: _utc(w.startUtc),
            end: _utc(w.endUtc),
            packId: w.packId,
          ),
      ];

  ObservanceDate _observanceDate(ObservanceRow o, ObservanceDateRow d) =>
      ObservanceDate(
        observance: _observance(o),
        date: CivilDate.parse(d.date),
        dayIndex: d.dayIndex,
        status: VerificationStatus.parse(d.status),
        packId: d.packId,
        reviewedBy: d.reviewedBy,
        reviewedOn: d.reviewedOn == null
            ? null
            : CivilDate.parse(d.reviewedOn!),
        note: d.noteBn == null ? null : NameRef(d.noteBn!, d.noteEn!),
      );

  Observance _observance(ObservanceRow o) => Observance(
    id: o.id,
    name: NameRef(o.nameBn, o.nameEn),
    category: ObservanceCategory.values.byName(o.category),
    tier: o.tier,
    description: NameRef(o.descriptionBn, o.descriptionEn),
  );

  /// One observance by id (festival links, T-411); null if no pack has it.
  Future<Observance?> observance(String id) async {
    final o = await _db.observanceById(id).getSingleOrNull();
    return o == null ? null : _observance(o);
  }

  /// The dates both the global pack(s) of [tradition] and [cityId]'s pack cover.
  /// Contiguous global packs (one per year) count as one range. Staleness needs the
  /// manifest and comes with the pack updater (Phase 3).
  @override
  Future<DataCoverage> coverage(String tradition, String cityId) async {
    final city = await _db.cityById(cityId).getSingleOrNull();
    if (city == null) return const NotDownloaded();
    final cityPack = await _db.packById(city.packId).getSingleOrNull();
    final globals = await _db.packsOfTradition(tradition, 'global').get();
    if (cityPack == null || globals.isEmpty) return const NotDownloaded();

    final ranges = [
      for (final p in globals)
        (CivilDate.parse(p.coversFrom), CivilDate.parse(p.coversTo)),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    var (from, to) = ranges.first;
    for (final (f, t) in ranges.skip(1)) {
      if (f.compareTo(to.addDays(1)) > 0) break; // a gap ends the range
      if (t.compareTo(to) > 0) to = t;
    }

    final cityFrom = CivilDate.parse(cityPack.coversFrom);
    final cityTo = CivilDate.parse(cityPack.coversTo);
    if (cityFrom.compareTo(from) > 0) from = cityFrom;
    if (cityTo.compareTo(to) < 0) to = cityTo;
    return from.compareTo(to) > 0 ? const NotDownloaded() : Covered(from, to);
  }

  // ------------------------------------------------------------- CatalogSource

  /// names(kind='tradition') rows carry the tradition id in `translit` (names.toml).
  @override
  Future<NameTable> names() async {
    final rows = await _db.allNames().get();
    final byKind = <String, List<NameRef>>{};
    final traditions = <String, NameRef>{};
    final glosses = <(String, int), NameRef>{};
    for (final r in rows) {
      final name = NameRef(r.nameBn, r.nameEn);
      (byKind[r.kind] ??= []).add(name);
      if (r.kind == 'tradition') traditions[r.translit] = name;
      if (r.glossBn != null) {
        glosses[(r.kind, r.idx)] = NameRef(r.glossBn!, r.glossEn!);
      }
    }
    return NameTable(byKind, traditions, glosses: glosses);
  }

  @override
  Future<City?> city(String id) async {
    final r = await _db.cityById(id).getSingleOrNull();
    return r == null ? null : _city(r);
  }

  /// Every installed city (the city picker).
  Future<List<City>> cities() async => [
    for (final r in await _db.allCities().get()) _city(r),
  ];

  City _city(CityRow r) => City(
    id: r.id,
    name: NameRef(r.nameBn, r.nameEn),
    district: NameRef(r.districtBn, r.districtEn),
    lat: r.lat,
    lon: r.lon,
    timeZone: r.tz,
    popular: r.popular == 1,
    state: r.state,
    aliases: [
      for (final a in r.aliases.split('|'))
        if (a.trim().isNotEmpty) a.trim(),
    ],
  );

  @override
  Future<List<PeriodRule>> enabledPeriodRules(String tradition) async {
    final rows = await _db.enabledPeriodRules(tradition).get();
    return [
      for (final r in rows)
        PeriodRule(
          periodId: r.nameIdx,
          kind: PeriodKind.values.byName(r.kind),
          weekday: Weekday.values[r.weekday],
          basis: PeriodBasis.values.byName(r.basis),
          divisions: r.divisions,
          part: r.part,
        ),
    ];
  }

  @override
  Future<bool> anySample(Iterable<String> packIds) async {
    final ids = packIds.toSet();
    if (ids.isEmpty) return false;
    final query = _db.select(_db.packs)
      ..where((p) => p.id.isIn(ids) & p.isSample.equals(1));
    return (await query.get()).isNotEmpty;
  }

  /// Every installed pack's identity and range, for [assessCoverage].
  Future<List<PackRange>> installedPacks() async {
    final rows = await _db.select(_db.packs).get();
    return [
      for (final p in rows)
        PackRange(
          id: p.id.endsWith('-v${p.version}')
              ? p.id.substring(0, p.id.length - '-v${p.version}'.length)
              : p.id,
          kind: p.kind,
          tradition: p.tradition,
          version: p.version,
          from: CivilDate.parse(p.coversFrom),
          to: CivilDate.parse(p.coversTo),
        ),
    ];
  }

  /// Every installed pack as the Sources & verification screen shows it (FR-SET-02),
  /// global data first, then cities, then festivals.
  Future<List<PackDetail>> packDetails() async {
    const order = ['global', 'cities', 'observances'];
    final rows = await _db.select(_db.packs).get();
    final details = [
      for (final p in rows)
        PackDetail(
          id: p.id.endsWith('-v${p.version}')
              ? p.id.substring(0, p.id.length - '-v${p.version}'.length)
              : p.id,
          kind: p.kind,
          tradition: p.tradition,
          version: p.version,
          from: CivilDate.parse(p.coversFrom),
          to: CivilDate.parse(p.coversTo),
          isSample: p.isSample == 1,
          validatedOn: _validatedOn(p.validationSummary),
        ),
    ];
    return details
      ..sort((a, b) => order.indexOf(a.kind).compareTo(order.indexOf(b.kind)));
  }

  /// `validated_on` (YYYY-MM-DD) from a pack's validation summary; null when the
  /// summary is missing, not JSON, or the pack has not been validated.
  static CivilDate? _validatedOn(String? summary) {
    if (summary == null) return null;
    try {
      final meta = jsonDecode(summary);
      if (meta is! Map) return null;
      final value = meta['validated_on'];
      return value is String ? CivilDate.tryParse(value) : null;
    } on FormatException {
      return null;
    }
  }

  /// The pack that holds [cityId]'s rows, if the city is installed.
  Future<String?> cityPackId(String cityId) async {
    final city = await _db.cityById(cityId).getSingleOrNull();
    if (city == null) return null;
    final pack = await _db.packById(city.packId).getSingleOrNull();
    if (pack == null) return null;
    final suffix = '-v${pack.version}';
    return pack.id.endsWith(suffix)
        ? pack.id.substring(0, pack.id.length - suffix.length)
        : pack.id;
  }
}
