// T-106: the Drift database mirrors data/pack/schema.sql exactly, and its queries work.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

const packTables = [
  'packs',
  'transitions',
  'lunar_months',
  'cities',
  'city_days',
  'bengali_dates',
  'body_positions',
  'names',
  'observances',
  'observance_dates',
  'observance_windows',
  'period_rules',
];
const deviceTables = [
  'reminders',
  'settings',
  'error_reports_queue',
  'observance_corrections',
];

// `flutter test` runs with app/ as the working directory.
final schemaSql = File('../data/pack/schema.sql').readAsStringSync();

/// Everything about a table that matters for parity, from SQLite's own catalog.
typedef Shape = Map<String, List<String>>;

Shape shapeOf(
  List<Map<String, Object?>> Function(String sql) query,
  String table,
) {
  List<String> rows(String sql, List<String> cols) =>
      query(sql)
          .map((r) => cols.map((c) => '$c=${_squash(r[c])}').join(' '))
          .toList()
        ..sort();
  return {
    'columns': rows('PRAGMA table_info($table)', [
      'name',
      'type',
      'notnull',
      'dflt_value',
      'pk',
    ]),
    'foreign_keys': rows('PRAGMA foreign_key_list($table)', [
      'table',
      'from',
      'to',
    ]),
    'indexes': rows(
      "SELECT name, sql FROM sqlite_master WHERE type = 'index' AND tbl_name = '$table' "
      'AND sql IS NOT NULL',
      ['name', 'sql'],
    ),
    'strict': rows(
      "SELECT strict FROM pragma_table_list WHERE name = '$table'",
      ['strict'],
    ),
  };
}

void main() {
  late AppDatabase db;
  late raw.Database reference;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    reference = raw.sqlite3.openInMemory()..execute(schemaSql);
  });

  tearDown(() async {
    await db.close();
    reference.close();
  });

  Future<List<Map<String, Object?>>> driftQuery(String sql) async =>
      (await db.customSelect(sql).get()).map((r) => r.data).toList();

  test('has exactly the pack tables plus the device tables', () async {
    final rows = await driftQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
    );
    expect(rows.map((r) => r['name']).toSet(), {
      ...packTables,
      ...deviceTables,
    });
  });

  for (final table in packTables) {
    test(
      '$table matches schema.sql (columns, types, keys, FKs, indexes, STRICT)',
      () async {
        final expected = shapeOf(
          (sql) => reference.select(sql).toList(),
          table,
        );
        final cache = <String, List<Map<String, Object?>>>{};
        for (final sql in _shapeQueries(table)) {
          cache[sql] = await driftQuery(sql);
        }
        final actual = shapeOf((sql) => cache[sql]!, table);
        expect(actual, expected);
      },
    );
  }

  test('pack schema version matches schema.sql', () {
    final version = reference
        .select('PRAGMA user_version')
        .single
        .values
        .single;
    expect(AppDatabase.packSchemaVersion, version);
  });

  test('foreign keys are enforced', () async {
    expect(
      () => db.customStatement(
        "INSERT INTO bengali_dates VALUES ('drik_bishuddha', '2026-04-15', 1, 0, 1433, 'nope')",
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  group('queries', () {
    setUp(() async {
      await db.customStatement(
        'INSERT INTO packs (id, tradition, kind, is_sample, covers_from, covers_to, version, '
        "generated_at, engine_version) VALUES ('p', 'drik_bishuddha', 'global', 1, "
        "'2026-01-01', '2026-12-31', 1, '2026-10-12T00:00:00Z', 'test')",
      );
      for (final (idx, start, end) in [
        (0, 0, 100),
        (1, 100, 200),
        (2, 200, 300),
      ]) {
        await db.customStatement(
          'INSERT INTO transitions (pack_id, tradition, kind, idx, starts_utc, ends_utc) '
          "VALUES ('p', 'drik_bishuddha', 'tithi', $idx, $start, $end)",
        );
      }
    });

    test('transitionsOverlapping returns transitions touching the window, in order', () async {
      final rows = await db
          .transitionsOverlapping('drik_bishuddha', 'tithi', 150, 250)
          .get();
      expect(rows.map((r) => r.idx), [1, 2]);
    });

    test('a window on a boundary does not include the neighbour', () async {
      final rows = await db
          .transitionsOverlapping('drik_bishuddha', 'tithi', 100, 200)
          .get();
      expect(rows.map((r) => r.idx), [1]);
    });

    test('packById returns the pack with its sample flag', () async {
      final pack = await db.packById('p').getSingle();
      expect(pack.isSample, 1);
    });
  });
}

List<String> _shapeQueries(String table) => [
  'PRAGMA table_info($table)',
  'PRAGMA foreign_key_list($table)',
  "SELECT name, sql FROM sqlite_master WHERE type = 'index' AND tbl_name = '$table' "
      'AND sql IS NOT NULL',
  "SELECT strict FROM pragma_table_list WHERE name = '$table'",
];

/// Collapses runs of whitespace, so formatting differences in stored SQL don't count.
String _squash(Object? value) => '$value'.replaceAll(RegExp(r'\s+'), ' ');
