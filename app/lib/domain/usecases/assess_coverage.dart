import '../../core/time/civil_date.dart';
import '../entities/panjika.dart';

/// A pack's identity and range, installed or offered by the manifest.
class PackRange {
  const PackRange({
    required this.id,
    required this.kind,
    required this.tradition,
    required this.version,
    required this.from,
    required this.to,
  });

  /// Without the version suffix (the manifest's `id`).
  final String id;
  final String kind;
  final String tradition;
  final int version;
  final CivilDate from;
  final CivilDate to;

  bool covers(CivilDate date) =>
      date.compareTo(from) >= 0 && date.compareTo(to) <= 0;
}

/// Whether [date] can be shown for [tradition] in the city whose rows come from the
/// pack [cityPackId] (spec §11.9, §16, T-309). [available] is what the last manifest
/// offered; it is empty when the app has never been online.
DataCoverage assessCoverage({
  required CivilDate date,
  required String tradition,
  required String? cityPackId,
  required List<PackRange> installed,
  required List<PackRange> available,
}) {
  bool isGlobal(PackRange p) => p.kind == 'global' && p.tradition == tradition;
  bool isCity(PackRange p) => p.kind == 'cities' && p.id == cityPackId;

  final global = installed.where((p) => isGlobal(p) && p.covers(date));
  final city = installed.where((p) => isCity(p) && p.covers(date));
  if (global.isNotEmpty && city.isNotEmpty) {
    final g = global.first, c = city.first;
    final covered = Covered(
      g.from.compareTo(c.from) > 0 ? g.from : c.from,
      g.to.compareTo(c.to) < 0 ? g.to : c.to,
    );
    final newer = [
      for (final p in [g, c])
        if (available.any((a) => a.id == p.id && a.version > p.version)) p.id,
    ];
    return newer.isEmpty ? covered : Stale(covered, newer);
  }

  final offered = available.any((a) => isGlobal(a) && a.covers(date));
  if (offered) return const NotDownloaded();
  final known = [...installed, ...available];
  // Nothing known at all (fresh install, never online): we cannot judge the clock.
  if (known.isEmpty) return const NotDownloaded();
  final anyCovers = known.any((p) => p.kind == 'global' && p.covers(date));
  return anyCovers ? const NotDownloaded() : const ClockSuspect();
}
