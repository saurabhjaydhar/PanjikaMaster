import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/settings/settings.dart';
import '../../core/time/civil_date.dart';
import '../../core/time/clock.dart';
import '../db/database_provider.dart';
import '../repositories/panjika_providers.dart';
import 'manifest.dart';
import 'manifest_client.dart';
import 'pack_importer.dart';
import 'pack_updater.dart';

/// The app version checked against `min_app_version`. Keep in step with pubspec.yaml.
const appVersion = '1.0.0';

final packSourceConfigProvider = Provider<PackSourceConfig>(
  (ref) => PackSourceConfig.fromEnvironment(),
);

/// Null when updates are off (no server URL or public key configured).
final packUpdaterProvider = Provider<PackUpdater?>((ref) {
  final config = ref.watch(packSourceConfigProvider);
  if (!config.enabled) return null;
  final client = http.Client();
  ref.onDispose(client.close);
  final db = ref.watch(appDatabaseProvider);
  return PackUpdater(
    manifests: ManifestClient(
      client: client,
      baseUrl: config.baseUrl!,
      settings: ref.watch(settingsSourceProvider),
      now: ref.watch(clockProvider),
      appVersion: appVersion,
    ),
    downloader: PackDownloader(
      client,
      config.baseUrl!,
      dir: Directory.systemTemp,
    ),
    importer: PackImporter(
      db,
      publicKey: config.publicKey!,
      allowSample: kDebugMode,
      // TODO(T-506): reschedule reminders once they exist.
      onImported: (_) async {},
    ),
    repository: ref.watch(panjikaRepositoryProvider),
  );
});

/// The latest update run, for banners and prompts.
final updateControllerProvider =
    NotifierProvider<UpdateController, UpdateResult?>(UpdateController.new);

class UpdateController extends Notifier<UpdateResult?> {
  @override
  UpdateResult? build() => null;

  bool get available => ref.read(packUpdaterProvider) != null;

  /// Background check on app open: silent downloads only (spec §18).
  Future<void> checkInBackground() => _run(force: false, confirmed: false);

  /// The user tapped Download or Update: fetch now, large packs included.
  Future<void> downloadNow() => _run(force: true, confirmed: true);

  Future<void> _run({required bool force, required bool confirmed}) async {
    final updater = ref.read(packUpdaterProvider);
    if (updater == null) return;
    final result = await updater.run(
      tradition: ref.read(traditionProvider),
      cityId: ref.read(cityIdProvider),
      force: force,
      confirmed: confirmed,
    );
    if (!ref.mounted) return;
    state = result;
    if (result is UpdateDone && result.imported.isNotEmpty) {
      // New rows in the database: everything that reads packs reloads.
      ref.invalidate(panjikaRepositoryProvider);
    }
  }

  /// Hide the download prompt until the next check.
  void later() {
    final s = state;
    if (s is UpdateDone) {
      state = UpdateDone(
        imported: s.imported,
        waitingForUser: const [],
        notices: s.notices,
      );
    }
  }
}

/// Current notices from the cached manifest that the user has not dismissed.
final noticesProvider =
    NotifierProvider<NoticesController, List<ManifestNotice>>(
      NoticesController.new,
    );

class NoticesController extends Notifier<List<ManifestNotice>> {
  @override
  List<ManifestNotice> build() {
    ref.watch(updateControllerProvider); // re-read after each check
    final settings = ref.watch(settingsSourceProvider);
    final raw = settings.read(SettingKey.lastManifest);
    if (raw == null) return const [];
    final dismissed = (settings.read(SettingKey.dismissedNotices) ?? '').split(
      ',',
    );
    final today = ref.watch(nowProvider.select(CivilDate.ofInstant));
    try {
      final m = Manifest.fromJson(jsonDecode(raw) as Map<String, Object?>);
      return [
        for (final n in m.notices)
          if (!dismissed.contains(n.id) &&
              (n.until == null || n.until!.compareTo(today) >= 0))
            n,
      ];
    } on Object {
      return const [];
    }
  }

  Future<void> dismiss(String id) async {
    final settings = ref.read(settingsSourceProvider);
    final ids = {
      ...(settings.read(SettingKey.dismissedNotices) ?? '').split(','),
      id,
    }..remove('');
    await settings.write(SettingKey.dismissedNotices, ids.join(','));
    state = [
      for (final n in state)
        if (n.id != id) n,
    ];
  }
}
