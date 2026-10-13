import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'manifest.dart';

/// Pack tables, parents before children (mirrors `data/pack/schema.py`).
const packTablesInOrder = [
  'packs',
  'transitions',
  'lunar_months',
  'cities',
  'city_days',
  'bengali_dates',
  'names',
  'observances',
  'observance_dates',
  'observance_windows',
  'period_rules',
];

sealed class PackImportError implements Exception {
  const PackImportError(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Wrong size or SHA-256: a partial or altered download.
final class PackCorrupt extends PackImportError {
  const PackCorrupt(super.message);
}

/// The Ed25519 signature does not verify with the embedded public key.
final class PackBadSignature extends PackImportError {
  const PackBadSignature(super.message);
}

/// Signed and intact, but not what the manifest promised (or a sample pack in a build
/// that must not import one).
final class PackInvalid extends PackImportError {
  const PackInvalid(super.message);
}

/// Imports a downloaded or bundled pack (spec §15.2): verify SHA-256 and size against
/// the manifest, verify the Ed25519 signature over the gzip bytes, then attach the
/// SQLite file and copy its rows in one transaction, replacing the pack it supersedes.
/// Nothing changes unless every step succeeds.
///
/// A new version of an installed observances pack — a correction (spec §18, T-603) —
/// replaces only the rows that differ, and the observances whose dates or windows
/// changed are recorded in `observance_corrections` so the app can label them
/// "সংশোধিত / Corrected" for 7 days.
class PackImporter {
  PackImporter(
    this._db, {
    required this.publicKey,
    this.allowSample = false,
    this.onImported,
    this.now = DateTime.now,
    Directory? tempDir,
  }) : _tempDir = tempDir ?? Directory.systemTemp;

  /// Corrections older than this are pruned on import; the label shows for 7 days.
  static const keepCorrections = Duration(days: 30);

  final AppDatabase _db;

  /// Raw 32-byte Ed25519 public key. TODO(Q12): the key pair and who holds it.
  final List<int> publicKey;

  /// Sample packs exist only for debug builds and tests (spec §6.8).
  final bool allowSample;

  /// "Reschedule" hook: reminders depend on the data (spec §17).
  final Future<void> Function(ManifestEntry entry)? onImported;
  final DateTime Function() now;
  final Directory _tempDir;

  Future<void> import(
    ManifestEntry entry,
    List<int> gzipBytes,
    List<int> signature,
  ) async {
    await _verify(entry, gzipBytes, signature);
    final List<int> sqlite;
    try {
      sqlite = gzip.decode(gzipBytes);
    } on FormatException catch (e) {
      throw PackInvalid('not a gzip file: $e');
    }
    final file = File(
      '${_tempDir.path}/import-${entry.id}-v${entry.version}-'
      '${DateTime.now().microsecondsSinceEpoch}.sqlite',
    );
    await file.writeAsBytes(sqlite, flush: true);
    try {
      await _db.customStatement('ATTACH DATABASE ? AS incoming', [file.path]);
      try {
        await _copy(entry);
      } finally {
        await _db.customStatement('DETACH DATABASE incoming');
      }
    } finally {
      if (file.existsSync()) file.deleteSync();
    }
    await onImported?.call(entry);
  }

  Future<void> _verify(
    ManifestEntry entry,
    List<int> data,
    List<int> signature,
  ) async {
    if (data.length != entry.size) {
      throw PackCorrupt('size ${data.length} ≠ manifest ${entry.size}');
    }
    final hash = await Sha256().hash(data);
    final hex = hash.bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    if (hex != entry.sha256) {
      throw const PackCorrupt('SHA-256 differs from the manifest');
    }
    if (publicKey.length != 32) {
      throw const PackBadSignature('no valid public key is configured');
    }
    final ok = await Ed25519().verify(
      data,
      signature: Signature(
        signature,
        publicKey: SimplePublicKey(publicKey, type: KeyPairType.ed25519),
      ),
    );
    if (!ok) throw const PackBadSignature('signature does not verify');
  }

  Future<void> _copy(ManifestEntry entry) async {
    final rows = await _db
        .customSelect(
          'SELECT id, kind, tradition, version, is_sample FROM incoming.packs',
        )
        .get();
    if (rows.length != 1) {
      throw PackInvalid('expected one packs row, found ${rows.length}');
    }
    final p = rows.single;
    final id = p.read<String>('id');
    final matches =
        (id == entry.id || id == '${entry.id}-v${entry.version}') &&
        p.read<String>('kind') == entry.kind &&
        p.read<String>('tradition') == entry.tradition &&
        p.read<int>('version') == entry.version;
    if (!matches) {
      throw PackInvalid('pack $id is not the one the manifest lists');
    }
    if (p.read<int>('is_sample') == 1 && !allowSample) {
      throw const PackInvalid('sample packs are not imported in this build');
    }

    await _db.transaction(() async {
      // Superseded: earlier packs of the same kind and tradition, and this one if it
      // is already installed (re-import).
      final old = await _db
          .customSelect(
            'SELECT id FROM main.packs WHERE kind = ? AND tradition = ?',
            variables: [Variable(entry.kind), Variable(entry.tradition)],
          )
          .map((r) => r.read<String>('id'))
          .get();
      final installedAt = now().toUtc();
      if (entry.kind == 'observances' && old.isNotEmpty && !old.contains(id)) {
        await _applyCorrection(old, id, entry.tradition, installedAt);
      } else {
        await _replace(old);
      }
      await _db.customStatement(
        'UPDATE main.packs SET installed_at = ?, sha256 = ? WHERE id = ?',
        [installedAt.toIso8601String(), entry.sha256, id],
      );
    });
  }

  Future<void> _replace(List<String> old) async {
    for (final table in packTablesInOrder.reversed) {
      for (final oldId in old) {
        await _db.customStatement(
          'DELETE FROM main.$table WHERE ${table == 'packs' ? 'id' : 'pack_id'} = ?',
          [oldId],
        );
      }
    }
    for (final table in packTablesInOrder) {
      await _db.customStatement(
        'INSERT INTO main.$table SELECT * FROM incoming.$table',
      );
    }
  }

  /// Replaces only the rows that differ between the installed packs [old] and the
  /// incoming pack [newId], retags the rest, and records the observances whose dates
  /// or windows changed.
  Future<void> _applyCorrection(
    List<String> old,
    String newId,
    String tradition,
    DateTime at,
  ) async {
    // Rows are compared on every column but pack_id; a parent row may be replaced
    // while its children stay, so foreign keys are checked at commit.
    await _db.customStatement('PRAGMA defer_foreign_keys = ON');
    final oldIds = List.filled(old.length, '?').join(', ');
    Future<List<String>> columns(String table) async => [
      for (final r
          in await _db.customSelect('PRAGMA main.table_info($table)').get())
        if (r.read<String>('name') != 'pack_id') r.read<String>('name'),
    ];
    String same(List<String> cols, String a, String b) =>
        cols.map((c) => '$a."$c" IS $b."$c"').join(' AND ');

    final changed = <String>{};
    for (final table in const ['observance_dates', 'observance_windows']) {
      final cols = (await columns(table)).map((c) => '"$c"').join(', ');
      final diff = await _db
          .customSelect(
            'SELECT observance_id FROM ('
            'SELECT $cols FROM main.$table WHERE pack_id IN ($oldIds) '
            'EXCEPT SELECT $cols FROM incoming.$table) '
            'UNION SELECT observance_id FROM ('
            'SELECT $cols FROM incoming.$table EXCEPT '
            'SELECT $cols FROM main.$table WHERE pack_id IN ($oldIds))',
            variables: [
              for (final o in [...old, ...old]) Variable(o),
            ],
          )
          .map((r) => r.read<String>('observance_id'))
          .get();
      changed.addAll(diff);
    }
    // A brand-new observance is not a correction.
    final existing = await _db
        .customSelect(
          'SELECT id FROM main.observances WHERE pack_id IN ($oldIds)',
          variables: [for (final o in old) Variable(o)],
        )
        .map((r) => r.read<String>('id'))
        .get();
    changed.retainAll(existing);

    await _db.customStatement(
      'INSERT INTO main.packs SELECT * FROM incoming.packs',
    );
    for (final table in packTablesInOrder.skip(1).toList().reversed) {
      final cols = await columns(table);
      await _db.customStatement(
        'DELETE FROM main.$table WHERE pack_id IN ($oldIds) AND NOT EXISTS '
        '(SELECT 1 FROM incoming.$table i WHERE ${same(cols, 'i', table)})',
        old,
      );
    }
    for (final table in packTablesInOrder.skip(1)) {
      final cols = await columns(table);
      await _db.customStatement(
        'UPDATE main.$table SET pack_id = ? WHERE pack_id IN ($oldIds)',
        [newId, ...old],
      );
      await _db.customStatement(
        'INSERT INTO main.$table SELECT * FROM incoming.$table i WHERE NOT EXISTS '
        '(SELECT 1 FROM main.$table m WHERE ${same(cols, 'm', 'i')})',
      );
    }
    await _db.customStatement(
      'DELETE FROM main.packs WHERE id IN ($oldIds)',
      old,
    );

    for (final observanceId in changed) {
      await _db
          .into(_db.observanceCorrections)
          .insertOnConflictUpdate(
            ObservanceCorrectionsCompanion.insert(
              tradition: tradition,
              observanceId: observanceId,
              correctedAt: at.toIso8601String(),
            ),
          );
    }
    await (_db.delete(_db.observanceCorrections)..where(
          (c) => c.correctedAt.isSmallerThanValue(
            at.subtract(keepCorrections).toIso8601String(),
          ),
        ))
        .go();
  }
}
