import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/search/search_key.dart';
import '../../core/settings/settings.dart';
import '../../core/time/civil_date.dart';
import '../../core/time/clock.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/entities/panjika.dart';

/// A city with today's sunrise, for the picker rows (spec §11.7).
class CityRowData {
  const CityRowData(this.city, this.sunrise);
  final City city;
  final DateTime? sunrise;

  bool matches(String query) {
    final q = searchKey(query);
    if (q.isEmpty) return true;
    return [
      city.name.bn,
      city.name.en,
      city.district.bn,
      city.district.en,
      ...city.aliases,
    ].any((s) => searchKey(s).contains(q));
  }
}

final cityRowsProvider = FutureProvider<List<CityRowData>>((ref) async {
  final repo = ref.watch(panjikaRepositoryProvider);
  final today = ref.watch(nowProvider.select(CivilDate.ofInstant));
  return [
    for (final c in await repo.cities())
      CityRowData(c, (await repo.sunMoonTimes(c.id, today))?.sunrise),
  ];
});

/// Recently chosen city ids, newest first (at most five).
List<String> recentCities(SettingsSource settings) => [
  for (final id in (settings.read(SettingKey.recentCities) ?? '').split(','))
    if (id.isNotEmpty) id,
];

/// Choose a city: the setting, the recent list, and everything that depends on it
/// reloads (FR-LOC-01).
Future<void> chooseCity(WidgetRef ref, String id) async {
  final settings = ref.read(settingsSourceProvider);
  final recent = [id, ...recentCities(settings).where((r) => r != id)].take(5);
  await settings.write(SettingKey.recentCities, recent.join(','));
  await ref.read(cityIdProvider.notifier).set(id);
}
