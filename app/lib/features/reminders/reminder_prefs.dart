import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/settings.dart';

/// Observances the user asked to be reminded of (festival detail's "মনে করিয়ে দিন").
/// The scheduler turns these into notifications. TODO(T-506)
final festivalRemindersProvider =
    NotifierProvider<FestivalReminders, Set<String>>(FestivalReminders.new);

class FestivalReminders extends Notifier<Set<String>> {
  @override
  Set<String> build() => {
    for (final id
        in (ref
                    .watch(settingsSourceProvider)
                    .read(SettingKey.festivalReminders) ??
                '')
            .split(','))
      if (id.isNotEmpty) id,
  };

  Future<void> toggle(String id) async {
    final next = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
    await ref
        .read(settingsSourceProvider)
        .write(SettingKey.festivalReminders, (next.toList()..sort()).join(','));
    state = next;
  }
}
