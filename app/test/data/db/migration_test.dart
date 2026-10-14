// Device schema migrations: a database created at an earlier schema version opens at
// the current one with its data kept.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/fixtures/sample_loader.dart';

void main() {
  test(
    'v1 → v2 adds observance_corrections (T-603), keeping the data',
    () async {
      final dir = await Directory.systemTemp.createTemp('migration');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/panjika.sqlite');

      // A v1 database: today's schema without the v2 table, user_version 1.
      final v1 = AppDatabase(NativeDatabase(file));
      await loadSamplePackIfEmpty(v1);
      await v1.customStatement('DROP TABLE observance_corrections');
      await v1.customStatement('PRAGMA user_version = 1');
      await v1.close();

      final db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);
      await db
          .into(db.observanceCorrections)
          .insert(
            ObservanceCorrectionsCompanion.insert(
              tradition: 'drik_bishuddha',
              observanceId: 'kali_puja',
              correctedAt: '2026-10-12T00:00:00.000Z',
            ),
          );
      expect(await db.select(db.observanceCorrections).get(), hasLength(1));
      final packs = await db
          .customSelect('SELECT count(*) AS n FROM packs')
          .getSingle();
      expect(packs.read<int>('n'), 3, reason: 'installed packs survive');
      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.single, db.schemaVersion);
    },
  );

  test('v2 → v3 adds body_positions (T-314), keeping the data', () async {
    final dir = await Directory.systemTemp.createTemp('migration');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/panjika.sqlite');

    final v2 = AppDatabase(NativeDatabase(file));
    await loadSamplePackIfEmpty(v2);
    await v2.customStatement('DROP TABLE body_positions');
    await v2.customStatement('PRAGMA user_version = 2');
    await v2.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    final rows = await db
        .customSelect('SELECT count(*) AS n FROM body_positions')
        .getSingle();
    expect(rows.read<int>('n'), 0);
    final packs = await db
        .customSelect('SELECT count(*) AS n FROM packs')
        .getSingle();
    expect(packs.read<int>('n'), 3, reason: 'installed packs survive');
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 3);
  });
}
