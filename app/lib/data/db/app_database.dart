import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// The device database: pack tables (generated from `data/pack/schema.sql`) plus
/// device-only tables. Spec §15.1.
@DriftDatabase(
  include: {'pack_tables.drift', 'app_tables.drift', 'queries.drift'},
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Opens the on-device database file.
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'panjika'));

  /// Must equal `PRAGMA user_version` in `data/pack/schema.sql`; a test checks it.
  static const packSchemaVersion = 2;

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // One step per schema version, each covered by test/data/db/migration_test.dart.
      if (from < 2) await m.createTable(observanceCorrections); // T-603
      if (from < 3) await m.createTable(bodyPositions); // T-314
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
