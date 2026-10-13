import '../../core/time/civil_date.dart';
import '../../domain/entities/name_ref.dart';

/// `GET /v1/manifest.json` (spec §15.3).
class Manifest {
  const Manifest({
    required this.schema,
    required this.generatedAt,
    required this.minAppVersion,
    required this.packs,
    required this.notices,
  });

  factory Manifest.fromJson(Map<String, Object?> json) => Manifest(
    schema: json['schema']! as int,
    generatedAt: DateTime.parse(json['generated_at']! as String),
    minAppVersion: json['min_app_version']! as String,
    packs: [
      for (final p in json['packs']! as List)
        ManifestEntry.fromJson(p as Map<String, Object?>),
    ],
    notices: [
      for (final n in (json['notices'] as List?) ?? const [])
        ManifestNotice.fromJson(n as Map<String, Object?>),
    ],
  );

  /// The manifest format this app understands.
  static const supportedSchema = 1;

  final int schema;
  final DateTime generatedAt;
  final String minAppVersion;
  final List<ManifestEntry> packs;
  final List<ManifestNotice> notices;
}

class ManifestEntry {
  const ManifestEntry({
    required this.id,
    required this.kind,
    required this.tradition,
    required this.version,
    required this.coversFrom,
    required this.coversTo,
    required this.url,
    required this.size,
    required this.sha256,
    required this.sigUrl,
  });

  factory ManifestEntry.fromJson(Map<String, Object?> json) {
    final covers = json['covers']! as List;
    return ManifestEntry(
      id: json['id']! as String,
      kind: json['kind']! as String,
      tradition: json['tradition']! as String,
      version: json['version']! as int,
      coversFrom: CivilDate.parse(covers[0] as String),
      coversTo: CivilDate.parse(covers[1] as String),
      url: json['url']! as String,
      size: json['size']! as int,
      sha256: json['sha256']! as String,
      sigUrl: json['sig_url']! as String,
    );
  }

  /// Without the version suffix, e.g. `global-drik-2020-2045`.
  final String id;
  final String kind;
  final String tradition;
  final int version;
  final CivilDate coversFrom;
  final CivilDate coversTo;
  final String url;
  final int size;

  /// Hex SHA-256 of the gzip bytes.
  final String sha256;
  final String sigUrl;
}

/// An in-app notice, always in both languages (spec §15.3).
class ManifestNotice {
  const ManifestNotice({
    required this.id,
    required this.level,
    required this.text,
    this.until,
  });

  factory ManifestNotice.fromJson(Map<String, Object?> json) => ManifestNotice(
    id: json['id']! as String,
    level: json['level']! as String,
    text: NameRef(json['text_bn']! as String, json['text_en']! as String),
    until: json['until'] == null
        ? null
        : CivilDate.parse(json['until']! as String),
  );

  final String id;
  final String level;
  final NameRef text;
  final CivilDate? until;
}
