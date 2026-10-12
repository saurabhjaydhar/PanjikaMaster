import '../db/app_database.dart';
import 'sample_pack.g.dart';

/// Loads the SAMPLE packs (নমুনা; synthetic, not a panjika) into an empty database.
///
/// Call only behind `kDebugMode` (a compile-time constant): release and profile builds
/// then tree-shake this function and the fixture strings away, and ci-app's bundle
/// check fails if the sample marker ever reaches a release APK (spec §6.8, T-110).
/// Returns false and changes nothing if any pack is already installed.
Future<bool> loadSamplePackIfEmpty(AppDatabase db) async {
  final row = await db
      .customSelect('SELECT count(*) AS n FROM packs')
      .getSingle();
  if (row.read<int>('n') > 0) return false;
  await db.transaction(() async {
    for (final statement in samplePackStatements) {
      await db.customStatement(statement);
    }
  });
  return true;
}
