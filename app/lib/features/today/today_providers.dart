import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/settings.dart';
import '../../core/time/clock.dart';
import '../../data/db/database_provider.dart';
import '../../data/repositories/today_repository.dart';
import '../../domain/entities/today_snapshot.dart';

final todayRepositoryProvider = Provider<TodayRepository>(
  (ref) => TodayRepository(ref.watch(appDatabaseProvider)),
);

/// Today's data for the chosen tradition and city; null means "not available" and the
/// screen says so (FR-HOME-09). Changing city or tradition reloads it.
final todayProvider = FutureProvider<TodaySnapshot?>((ref) {
  return ref
      .watch(todayRepositoryProvider)
      .load(
        now: ref.watch(clockProvider)(),
        tradition: ref.watch(traditionProvider),
        cityId: ref.watch(cityIdProvider),
      );
});
