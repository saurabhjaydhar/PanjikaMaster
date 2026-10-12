import '../engine/interfaces.dart';
import '../entities/name_table.dart';
import '../entities/panjika.dart';

/// Provenance for data from [packIds] in [tradition] and [city] (CLAUDE.md: no datum
/// without tradition, city, time zone, pack and status).
Future<Provenance> provenanceFor(
  CatalogSource catalog,
  NameTable names, {
  required String tradition,
  required City city,
  required Set<String> packIds,
}) async => Provenance(
  tradition: names.tradition(tradition),
  city: city.name,
  packIds: List.unmodifiable(packIds.toList()..sort()),
  isSample: await catalog.anySample(packIds),
);
