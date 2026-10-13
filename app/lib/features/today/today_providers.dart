import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/settings.dart';
import '../../core/time/civil_date.dart';
import '../../core/time/clock.dart';

import 'dart:convert';

import '../../data/packs/manifest.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/engine/day_assembler.dart';
import '../../domain/entities/panjika.dart';
import '../../domain/usecases/assess_coverage.dart';
import '../../domain/usecases/get_day_panjika.dart';

/// The panjika day in progress (sunrise to sunrise) for the chosen tradition and city.
/// It holds every span of the day, so it reloads only when the next sunrise passes;
/// widgets pick the current elements with [nowProvider]. It asks the clock to tick at
/// each transition, period boundary, sunset and the next sunrise (FR-HOME-08).
/// Null means "not available" and the screen says so (FR-HOME-09).
///
/// Between midnight and sunrise this is the previous date's panjika day: to confirm at
/// design sign-off (T-215).
final todayProvider = FutureProvider<DayPanjika?>((ref) async {
  final tradition = ref.watch(traditionProvider);
  final cityId = ref.watch(cityIdProvider);
  final getDay = ref.watch(getDayPanjikaProvider);
  // Read, not watch: a tick must not reload the day. The listeners below decide.
  final now = ref.read(nowProvider);
  final day = await getDay.containing(
    now,
    tradition: tradition,
    cityId: cityId,
  );
  if (!ref.mounted) return day;

  if (day == null) {
    // Try again on the next date (the device clock may have been wrong).
    final date = CivilDate.ofInstant(now);
    ref.listen(nowProvider, (_, n) {
      if (CivilDate.ofInstant(n) != date) ref.invalidateSelf();
    });
    return null;
  }

  ref.read(nowProvider.notifier).wakeAt([
    for (final kind in panchangaKinds)
      for (final s in day.spansOf(kind)) s.endUtc,
    for (final p in day.periods) ...[p.startUtc, p.endUtc],
    day.sun.sunset,
    day.nextSunrise,
  ]);
  ref.listen(nowProvider, (_, n) {
    if (n.isBefore(day.sun.sunrise) || !n.isBefore(day.nextSunrise)) {
      ref.invalidateSelf();
    }
  });
  return day;
});

/// The panjika day whose tithi ring has already filled: it fills once per day, on first
/// view (spec §12.8).
final ringFilledForProvider = NotifierProvider<RingFilledFor, CivilDate?>(
  RingFilledFor.new,
);

class RingFilledFor extends Notifier<CivilDate?> {
  @override
  CivilDate? build() => null;

  void mark(CivilDate date) => state = date;
}

/// What the last manifest offered (cached in settings, so it works offline); empty if
/// the app has never fetched one.
final availablePacksProvider = Provider<List<PackRange>>((ref) {
  final raw = ref.watch(settingsSourceProvider).read(SettingKey.lastManifest);
  if (raw == null) return const [];
  try {
    final m = Manifest.fromJson(jsonDecode(raw) as Map<String, Object?>);
    return [
      for (final e in m.packs)
        PackRange(
          id: e.id,
          kind: e.kind,
          tradition: e.tradition,
          version: e.version,
          from: e.coversFrom,
          to: e.coversTo,
        ),
    ];
  } on Object {
    return const [];
  }
});

/// Whether today's data can be shown, needs an update or a download, or points at a
/// wrong phone clock (T-309, T-310). Re-evaluated when the date changes.
final todayCoverageProvider = FutureProvider<DataCoverage>((ref) async {
  final repo = ref.watch(panjikaRepositoryProvider);
  final date = ref.watch(nowProvider.select(CivilDate.ofInstant));
  final cityPack = await repo.cityPackId(ref.watch(cityIdProvider));
  return assessCoverage(
    date: date,
    tradition: ref.watch(traditionProvider),
    cityPackId: cityPack,
    installed: await repo.installedPacks(),
    available: ref.watch(availablePacksProvider),
  );
});
