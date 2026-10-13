import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/settings.dart';
import '../../core/time/civil_date.dart';
import '../../core/time/clock.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/entities/panjika.dart';
import '../../domain/usecases/get_festival_year.dart';

final getFestivalYearProvider = Provider<GetFestivalYear>((ref) {
  final repo = ref.watch(panjikaRepositoryProvider);
  return GetFestivalYear(repo, repo);
});

/// Today's Bengali date, for the year to open on and the month to scroll to.
final todayBengaliProvider = FutureProvider<BengaliDate?>((ref) async {
  final today = ref.watch(nowProvider.select(CivilDate.ofInstant));
  return ref
      .watch(panjikaRepositoryProvider)
      .bengaliDate(ref.watch(traditionProvider), today);
});

final festivalYearProvider = FutureProvider.family<FestivalYear?, int>(
  (ref, year) => ref
      .watch(getFestivalYearProvider)
      .call(
        tradition: ref.watch(traditionProvider),
        cityId: ref.watch(cityIdProvider),
        year: year,
      ),
);

/// What the Festivals list shows (FR-FEST-02). A null [year] means the current one.
class FestivalFilter {
  const FestivalFilter({
    this.year,
    this.category,
    this.month,
    this.tiers = const {},
  });

  final int? year;
  final ObservanceCategory? category;

  /// 0 = বৈশাখ; null = every month.
  final int? month;

  /// Empty = every tier.
  final Set<int> tiers;

  bool get narrowed => month != null || tiers.isNotEmpty;

  bool shows(ObservanceDate o) =>
      (category == null || o.observance.category == category) &&
      (tiers.isEmpty || tiers.contains(o.observance.tier));

  FestivalFilter copyWith({
    int? year,
    ObservanceCategory? category,
    bool clearCategory = false,
    int? month,
    bool clearMonth = false,
    Set<int>? tiers,
  }) => FestivalFilter(
    year: year ?? this.year,
    category: clearCategory ? null : (category ?? this.category),
    month: clearMonth ? null : (month ?? this.month),
    tiers: tiers ?? this.tiers,
  );
}

final festivalFilterProvider =
    NotifierProvider<FestivalFilterController, FestivalFilter>(
      FestivalFilterController.new,
    );

class FestivalFilterController extends Notifier<FestivalFilter> {
  @override
  FestivalFilter build() => const FestivalFilter();

  void year(int year) => state = state.copyWith(year: year);

  void category(ObservanceCategory? c) => state = c == null
      ? state.copyWith(clearCategory: true)
      : state.copyWith(category: c);

  void month(int? m) => state = m == null
      ? state.copyWith(clearMonth: true)
      : state.copyWith(month: m);

  void toggleTier(int tier) => state = state.copyWith(
    tiers: state.tiers.contains(tier)
        ? ({...state.tiers}..remove(tier))
        : {...state.tiers, tier},
  );

  void clear() =>
      state = FestivalFilter(year: state.year, category: state.category);
}
