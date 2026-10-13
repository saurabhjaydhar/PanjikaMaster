import 'dart:convert';

import '../repositories/panjika_repository.dart';
import 'manifest.dart';
import 'manifest_client.dart';
import 'pack_importer.dart';

/// Where packs come from. Both values are build-time defines, so no URL or key is
/// hard-coded and secrets stay in CI (CLAUDE.md). Without them updates are off.
class PackSourceConfig {
  const PackSourceConfig({this.baseUrl, this.publicKey});

  /// From `--dart-define`s. TODO(T-304): the hosting URL. TODO(Q12): the key pair.
  factory PackSourceConfig.fromEnvironment() {
    const url = String.fromEnvironment('PANJIKA_PACK_BASE_URL');
    const key = String.fromEnvironment('PANJIKA_PACK_PUBLIC_KEY');
    return PackSourceConfig(
      baseUrl: url.isEmpty ? null : Uri.parse(url),
      publicKey: key.isEmpty ? null : base64Decode(key),
    );
  }

  final Uri? baseUrl;

  /// Raw 32-byte Ed25519 public key.
  final List<int>? publicKey;

  bool get enabled => baseUrl != null && publicKey?.length == 32;
}

sealed class UpdateResult {
  const UpdateResult();
}

final class UpdateSkipped extends UpdateResult {
  const UpdateSkipped();
}

final class UpdateFailed extends UpdateResult {
  const UpdateFailed(this.reason);
  final String reason;
}

final class UpdateNeedsNewerApp extends UpdateResult {
  const UpdateNeedsNewerApp(this.minAppVersion);
  final String minAppVersion;
}

final class UpdateDone extends UpdateResult {
  const UpdateDone({
    required this.imported,
    required this.waitingForUser,
    required this.notices,
  });

  /// Ids of the packs imported in this run.
  final List<String> imported;

  /// Large packs (≥ 2 MB) that need the user's yes (spec §18).
  final List<PackOffer> waitingForUser;
  final List<ManifestNotice> notices;
}

/// Manifest check → download → verify and import (spec §15.2, §18).
class PackUpdater {
  PackUpdater({
    required this.manifests,
    required this.downloader,
    required this.importer,
    required this.repository,
  });

  final ManifestClient manifests;
  final PackDownloader downloader;
  final PackImporter importer;
  final DriftPanjikaRepository repository;

  /// Silent packs download at once; with [confirmed], the large ones too.
  Future<UpdateResult> run({
    required String tradition,
    required String cityId,
    bool force = false,
    bool confirmed = false,
  }) async {
    final check = await manifests.check(
      installed: await repository.installedPacks(),
      tradition: tradition,
      cityPackId: await repository.cityPackId(cityId),
      force: force,
    );
    switch (check) {
      case CheckSkipped():
        return const UpdateSkipped();
      case CheckFailed(:final reason):
        return UpdateFailed(reason);
      case AppTooOld(:final minAppVersion):
        return UpdateNeedsNewerApp(minAppVersion);
      case ManifestChecked(:final offers, :final notices):
        final imported = <String>[];
        final waiting = <PackOffer>[];
        for (final offer in offers) {
          if (offer.action == OfferAction.ask && !confirmed) {
            waiting.add(offer);
            continue;
          }
          final e = offer.entry;
          try {
            final gz = await downloader.fetch(e.url, expectedSize: e.size);
            final sig = await downloader.fetch(e.sigUrl, expectedSize: 64);
            await importer.import(e, gz, sig);
            imported.add(e.id);
          } on DownloadFailed catch (err) {
            return UpdateFailed(err.message);
          } on PackImportError catch (err) {
            return UpdateFailed(err.message);
          }
        }
        return UpdateDone(
          imported: imported,
          waitingForUser: waiting,
          notices: notices,
        );
    }
  }
}
