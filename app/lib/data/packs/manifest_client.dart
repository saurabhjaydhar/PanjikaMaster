import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/settings/settings.dart';
import '../../core/time/civil_date.dart';
import '../../domain/usecases/assess_coverage.dart';
import 'manifest.dart';

/// At most one manifest check per day (spec §18).
const manifestCheckInterval = Duration(hours: 24);

/// Packs below this size download without asking (spec §18).
const silentDownloadLimit = 2 * 1024 * 1024;

sealed class ManifestCheck {
  const ManifestCheck();
}

/// Checked less than a day ago; nothing fetched.
final class CheckSkipped extends ManifestCheck {
  const CheckSkipped(this.lastChecked);
  final DateTime lastChecked;
}

/// Offline, server error or a manifest this app cannot read. Retried next time.
final class CheckFailed extends ManifestCheck {
  const CheckFailed(this.reason);
  final String reason;
}

/// The packs need a newer app (`min_app_version`).
final class AppTooOld extends ManifestCheck {
  const AppTooOld(this.minAppVersion);
  final String minAppVersion;
}

final class ManifestChecked extends ManifestCheck {
  const ManifestChecked(this.manifest, this.offers, this.notices);
  final Manifest manifest;
  final List<PackOffer> offers;

  /// Current notices (not past their `until` date).
  final List<ManifestNotice> notices;
}

enum OfferAction { downloadSilently, ask }

class PackOffer {
  const PackOffer(this.entry, this.action, {required this.isUpdate});
  final ManifestEntry entry;
  final OfferAction action;

  /// A newer version of an installed pack (otherwise a pack not installed yet).
  final bool isUpdate;
}

/// Fetches `/v1/manifest.json` and decides what to download (spec §15.3, §18, T-308).
class ManifestClient {
  ManifestClient({
    required this.client,
    required this.baseUrl,
    required this.settings,
    required this.now,
    required this.appVersion,
    this.silentLimit = silentDownloadLimit,
  });

  final http.Client client;
  final Uri baseUrl;
  final SettingsSource settings;
  final DateTime Function() now;
  final String appVersion;

  /// Packs below this many bytes download without asking.
  final int silentLimit;

  /// The last manifest fetched, kept for offline use (offers, notices, coverage).
  Manifest? cached() {
    final raw = settings.read(SettingKey.lastManifest);
    if (raw == null) return null;
    try {
      return Manifest.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } on Object {
      return null;
    }
  }

  Future<ManifestCheck> check({
    required List<PackRange> installed,
    required String tradition,
    required String? cityPackId,
    bool force = false,
  }) async {
    final t = now().toUtc();
    final last = DateTime.tryParse(
      settings.read(SettingKey.lastManifestCheck) ?? '',
    );
    if (!force && last != null && t.difference(last) < manifestCheckInterval) {
      return CheckSkipped(last);
    }

    final String body;
    try {
      final res = await client.get(baseUrl.resolve('/v1/manifest.json'));
      if (res.statusCode != 200) return CheckFailed('HTTP ${res.statusCode}');
      body = utf8.decode(res.bodyBytes);
    } on Object catch (e) {
      return CheckFailed('$e');
    }
    final Manifest manifest;
    try {
      manifest = Manifest.fromJson(jsonDecode(body) as Map<String, Object?>);
    } on Object catch (e) {
      return CheckFailed('unreadable manifest: $e');
    }
    if (manifest.schema != Manifest.supportedSchema) {
      return CheckFailed('manifest schema ${manifest.schema}');
    }
    await settings.write(SettingKey.lastManifestCheck, t.toIso8601String());
    await settings.write(SettingKey.lastManifest, body);
    if (compareVersions(manifest.minAppVersion, appVersion) > 0) {
      return AppTooOld(manifest.minAppVersion);
    }

    final today = CivilDate.ofInstant(t);
    return ManifestChecked(
      manifest,
      offersFor(
        manifest,
        installed,
        tradition,
        cityPackId,
        today,
        silentLimit: silentLimit,
      ),
      [
        for (final n in manifest.notices)
          if (n.until == null || n.until!.compareTo(today) >= 0) n,
      ],
    );
  }
}

/// Which manifest packs to fetch: newer versions of installed packs, and packs not yet
/// installed that are still current, for this tradition and the chosen city's pack.
List<PackOffer> offersFor(
  Manifest manifest,
  List<PackRange> installed,
  String tradition,
  String? cityPackId,
  CivilDate today, {
  int silentLimit = silentDownloadLimit,
}) {
  final out = <PackOffer>[];
  for (final e in manifest.packs) {
    final relevant = e.kind == 'cities'
        ? e.id == cityPackId
        : e.tradition == tradition;
    if (!relevant) continue;
    final mine = installed.where((p) => p.id == e.id);
    final action = e.size < silentLimit
        ? OfferAction.downloadSilently
        : OfferAction.ask;
    if (mine.isNotEmpty) {
      if (e.version >
          mine.map((p) => p.version).reduce((a, b) => a > b ? a : b)) {
        out.add(PackOffer(e, action, isUpdate: true));
      }
    } else if (e.coversTo.compareTo(today) >= 0) {
      out.add(PackOffer(e, action, isUpdate: false));
    }
  }
  return out;
}

/// Compares dotted versions numerically ("1.10.0" > "1.9.2"); build suffixes ignored.
int compareVersions(String a, String b) {
  List<int> parts(String v) => [
    for (final p in v.split('+').first.split('.')) int.tryParse(p) ?? 0,
  ];
  final x = parts(a), y = parts(b);
  for (var i = 0; i < 3; i++) {
    final d = (i < x.length ? x[i] : 0) - (i < y.length ? y[i] : 0);
    if (d != 0) return d.sign;
  }
  return 0;
}

class DownloadFailed implements Exception {
  const DownloadFailed(this.message);
  final String message;

  @override
  String toString() => 'DownloadFailed: $message';
}

/// Downloads pack files, resuming an interrupted download with an HTTP Range request
/// (spec §18). The importer then checks size, SHA-256 and signature.
class PackDownloader {
  PackDownloader(this._client, this.baseUrl, {required this.dir});

  final http.Client _client;
  final Uri baseUrl;
  final Directory dir;

  File _partFile(String path) => File(
    '${dir.path}/${path.replaceAll(RegExp('[^A-Za-z0-9._-]'), '_')}.part',
  );

  Future<List<int>> fetch(String path, {int? expectedSize}) async {
    final part = _partFile(path);
    final have = part.existsSync() ? part.lengthSync() : 0;
    final req = http.Request('GET', baseUrl.resolve(path));
    if (have > 0) req.headers['range'] = 'bytes=$have-';
    final res = await _client.send(req);
    final IOSink sink;
    if (res.statusCode == 206 && have > 0) {
      sink = part.openWrite(mode: FileMode.append);
    } else if (res.statusCode == 200) {
      sink = part.openWrite(); // the server ignored the range: start again
    } else {
      throw DownloadFailed('HTTP ${res.statusCode} for $path');
    }
    try {
      await res.stream.pipe(sink);
    } on Object catch (e) {
      throw DownloadFailed(
        'interrupted: $e',
      ); // the .part file stays for resuming
    }
    final bytes = await part.readAsBytes();
    if (expectedSize != null && bytes.length != expectedSize) {
      if (bytes.length > expectedSize) part.deleteSync();
      throw DownloadFailed('$path: ${bytes.length} of $expectedSize bytes');
    }
    part.deleteSync();
    return bytes;
  }
}
