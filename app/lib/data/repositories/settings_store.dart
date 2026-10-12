import '../../core/settings/settings.dart';
import '../db/app_database.dart';

/// [SettingsSource] backed by the device `settings` table (spec §15.1).
class DbSettings implements SettingsSource {
  DbSettings._(this._db, this._values);

  /// Loads every setting once, before the first frame.
  static Future<DbSettings> load(AppDatabase db) async {
    final rows = await db.select(db.settings).get();
    return DbSettings._(db, {for (final r in rows) r.key: r.value});
  }

  final AppDatabase _db;
  final Map<String, String> _values;

  @override
  String? read(SettingKey key) => _values[key.key];

  @override
  Future<void> write(SettingKey key, String? value) async {
    if (value == null) {
      _values.remove(key.key);
      await (_db.delete(
        _db.settings,
      )..where((t) => t.key.equals(key.key))).go();
    } else {
      _values[key.key] = value;
      await _db
          .into(_db.settings)
          .insertOnConflictUpdate(
            SettingsCompanion.insert(key: key.key, value: value),
          );
    }
  }
}
