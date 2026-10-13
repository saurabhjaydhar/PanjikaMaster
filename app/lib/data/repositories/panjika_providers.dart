import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/settings.dart';
import '../../core/time/civil_date.dart';
import '../../domain/engine/day_assembler.dart';
import '../../domain/entities/name_table.dart';
import '../../domain/usecases/get_day_panjika.dart';
import '../../domain/usecases/get_month_grid.dart';
import '../../domain/usecases/get_upcoming_observances.dart';
import '../db/database_provider.dart';
import 'panjika_repository.dart';

final panjikaRepositoryProvider = Provider<DriftPanjikaRepository>(
  (ref) => DriftPanjikaRepository(ref.watch(appDatabaseProvider)),
);

final getDayPanjikaProvider = Provider<GetDayPanjika>((ref) {
  final repo = ref.watch(panjikaRepositoryProvider);
  return GetDayPanjika(repo, repo);
});

final getMonthGridProvider = Provider<GetMonthGrid>((ref) {
  final repo = ref.watch(panjikaRepositoryProvider);
  return GetMonthGrid(repo, repo);
});

final getUpcomingObservancesProvider = Provider<GetUpcomingObservances>((ref) {
  final repo = ref.watch(panjikaRepositoryProvider);
  return GetUpcomingObservances(repo, repo);
});

/// The panjika day starting at sunrise on a date, for the chosen tradition and city.
/// Null means "not available" (FR-HOME-09).
final dayPanjikaProvider = FutureProvider.family<DayPanjika?, CivilDate>(
  (ref, date) => ref
      .watch(getDayPanjikaProvider)
      .call(
        date: date,
        tradition: ref.watch(traditionProvider),
        cityId: ref.watch(cityIdProvider),
      ),
);

/// One month of the Calendar grid for the chosen tradition and city.
final monthGridProvider = FutureProvider.family<MonthGrid?, MonthRef>(
  (ref, month) => ref
      .watch(getMonthGridProvider)
      .call(
        month: month,
        tradition: ref.watch(traditionProvider),
        cityId: ref.watch(cityIdProvider),
      ),
);

/// Display names and glossary entries from the installed packs.
final namesProvider = FutureProvider<NameTable>(
  (ref) => ref.watch(panjikaRepositoryProvider).names(),
);
