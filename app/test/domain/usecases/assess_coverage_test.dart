// T-309: Covered / Stale / NotDownloaded / ClockSuspect. Pack ranges are test inputs.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/core/time/civil_date.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/data/repositories/panjika_repository.dart';
import 'package:panjika/domain/entities/panjika.dart';
import 'package:panjika/domain/usecases/assess_coverage.dart';

const drik = 'drik_bishuddha';

PackRange pack(String id, String kind, int version, String from, String to) =>
    PackRange(
      id: id,
      kind: kind,
      tradition: drik,
      version: version,
      from: CivilDate.parse(from),
      to: CivilDate.parse(to),
    );

final global = pack('global-drik', 'global', 1, '2026-04-14', '2029-04-13');
final cities = pack('cities-wb', 'cities', 1, '2026-04-14', '2029-04-13');
final nextGlobal = pack(
  'global-drik-2029',
  'global',
  1,
  '2029-04-14',
  '2032-04-13',
);

DataCoverage assess(
  String date, {
  List<PackRange>? installed,
  List<PackRange> available = const [],
  String? city = 'cities-wb',
}) => assessCoverage(
  date: CivilDate.parse(date),
  tradition: drik,
  cityPackId: city,
  installed: installed ?? [global, cities],
  available: available,
);

void main() {
  test('covered: the overlap of the global and city packs', () {
    final c = assess('2026-10-12') as Covered;
    expect((c.from, c.to), (global.from, global.to));
  });

  test('stale: covered, but the manifest has a newer version', () {
    final c = assess(
      '2026-10-12',
      available: [pack('global-drik', 'global', 2, '2026-04-14', '2029-04-13')],
    );
    expect(c, isA<Stale>());
    c as Stale;
    expect(c.packIds, ['global-drik']);
    expect(c.covered.includes(const CivilDate(2026, 10, 12)), isTrue);
  });

  test('an older or equal manifest version is not stale', () {
    expect(assess('2026-10-12', available: [global, cities]), isA<Covered>());
  });

  test('not downloaded: outside the installed range but offered', () {
    expect(assess('2030-01-01', available: [nextGlobal]), isA<NotDownloaded>());
  });

  test('not downloaded: the city is not installed', () {
    expect(assess('2026-10-12', city: null), isA<NotDownloaded>());
    expect(assess('2026-10-12', city: 'cities-metros'), isA<NotDownloaded>());
  });

  test('clock suspect: no known pack covers the date', () {
    expect(assess('1999-01-01'), isA<ClockSuspect>());
    expect(assess('2040-06-01', available: [nextGlobal]), isA<ClockSuspect>());
  });

  test(
    'fresh install, never online, nothing installed: cannot judge the clock',
    () {
      expect(assess('2026-10-12', installed: const []), isA<NotDownloaded>());
    },
  );

  test('a pack of another tradition does not count', () {
    final other = PackRange(
      id: 'global-ss',
      kind: 'global',
      tradition: 'surya_siddhanta',
      version: 1,
      from: global.from,
      to: global.to,
    );
    expect(
      assess('2026-10-12', installed: [other, cities]),
      isA<NotDownloaded>(),
    );
  });

  test('installed ranges and the city pack come from the database', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await loadSamplePackIfEmpty(db);
    final repo = DriftPanjikaRepository(db);
    final installed = await repo.installedPacks();
    expect(
      installed.map((p) => p.kind),
      containsAll(['global', 'cities', 'observances']),
    );
    expect(await repo.cityPackId('kolkata'), 'sample-cities');
    expect(await repo.cityPackId('nowhere'), isNull);
    final c = assessCoverage(
      date: const CivilDate(2026, 10, 12),
      tradition: drik,
      cityPackId: await repo.cityPackId('kolkata'),
      installed: installed,
      available: const [],
    );
    expect(c, isA<Covered>());
    expect(
      assessCoverage(
        date: const CivilDate(2031, 1, 1),
        tradition: drik,
        cityPackId: 'sample-cities',
        installed: installed,
        available: const [],
      ),
      isA<ClockSuspect>(),
    );
  });
}
