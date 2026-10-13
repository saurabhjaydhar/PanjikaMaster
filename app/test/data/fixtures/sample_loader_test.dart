// T-110: the sample packs load into an empty database, unmistakably marked as sample.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';
import 'package:panjika/data/fixtures/sample_pack.g.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> count(String sql) async =>
      (await db.customSelect(sql).getSingle()).data.values.single as int;

  test('loads all three sample packs into an empty database', () async {
    expect(await loadSamplePackIfEmpty(db), isTrue);
    expect(await count('SELECT count(*) FROM packs'), 3);
    for (final table in [
      'transitions',
      'bengali_dates',
      'names',
      'cities',
      'city_days',
      'observances',
    ]) {
      expect(
        await count('SELECT count(*) FROM $table'),
        greaterThan(0),
        reason: table,
      );
    }
  });

  test('every pack is flagged sample and carries the marker', () async {
    await loadSamplePackIfEmpty(db);
    expect(await count('SELECT count(*) FROM packs WHERE is_sample <> 1'), 0);
    expect(
      await count(
        "SELECT count(*) FROM packs WHERE validation_summary NOT LIKE '%$sampleMarker%'",
      ),
      0,
    );
    expect(
      await count(
        "SELECT count(*) FROM observance_dates WHERE status <> 'sample'",
      ),
      0,
    );
  });

  test('foreign keys hold after loading', () async {
    await loadSamplePackIfEmpty(db);
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });

  test('does nothing if a pack is already installed', () async {
    await loadSamplePackIfEmpty(db);
    expect(await loadSamplePackIfEmpty(db), isFalse);
    expect(await count('SELECT count(*) FROM packs'), 3);
  });

  test(
    'the wireframe sample day reads back through the generated queries',
    () async {
      await loadSamplePackIfEmpty(db);
      final bn = await db
          .bengaliDateOn('drik_bishuddha', '2026-10-12')
          .getSingle();
      expect((bn.bnDay, bn.bnMonthIdx, bn.bnYear), (25, 5, 1433));
      final month = await db.namesOfKind('solar_month').get();
      expect((month[5].nameBn, month[5].nameEn), ('আশ্বিন', 'Ashwin'));
      final kolkata = await db.cityDay('kolkata', '2026-10-12').getSingle();
      expect(kolkata.sunriseUtc, lessThan(kolkata.sunsetUtc));
    },
  );
}
