import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/settings.dart';
import '../../domain/reminders/reminder_config.dart';
import 'reminder_service.dart';

/// What the user asked to be reminded of (spec §11.13). Every change reschedules.
final reminderConfigProvider =
    NotifierProvider<ReminderConfigController, ReminderConfig>(
      ReminderConfigController.new,
    );

/// Observances with a festival reminder (festival detail's "মনে করিয়ে দিন").
final festivalRemindersProvider = Provider<Set<String>>(
  (ref) => ref.watch(reminderConfigProvider).festivals.keys.toSet(),
);

class ReminderConfigController extends Notifier<ReminderConfig> {
  @override
  ReminderConfig build() => ReminderConfig.decode(
    ref.watch(settingsSourceProvider).read(SettingKey.reminders),
  );

  Future<void> _save(ReminderConfig next) async {
    state = next;
    await ref
        .read(settingsSourceProvider)
        .write(SettingKey.reminders, next.isEmpty ? null : next.encode());
    unawaited(ref.read(reminderServiceProvider).reschedule());
  }

  /// Turns a festival reminder on (with the default timing) or off.
  Future<void> toggleFestival(String id) => _save(
    state.withFestival(
      id,
      state.festivals.containsKey(id) ? null : ReminderConfig.festivalDefault,
    ),
  );

  Future<void> setFestival(String id, List<ReminderTime>? times) =>
      _save(state.withFestival(id, times));

  Future<void> setRecurring(RecurringKind kind, List<ReminderTime>? times) =>
      _save(state.withRecurring(kind, times));
}
