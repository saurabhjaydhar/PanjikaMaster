import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_providers.dart';
import '../../core/settings/settings.dart';
import '../../data/packs/pack_updater.dart';
import '../../data/packs/update_providers.dart';
import 'reminder_service.dart';

/// Everything that moves reminders reschedules them (spec §17, FR-REM-03, T-508):
/// app start and return, a city change, a language change (texts and channel names
/// are in the UI language), and a pack import. A tradition change reschedules through
/// `changeTradition`; a reminder change through the reminder settings.
///
/// After a reboot or an app update, flutter_local_notifications' boot receiver puts
/// the scheduled reminders back; the next app start replans them. Reminders are
/// planned as absolute instants (IST wall-clock times converted to UTC), so a device
/// time-zone change doesn't move them; the return to the app replans anyway.
final reminderTriggersProvider = Provider<ReminderTriggers>((ref) {
  final triggers = ReminderTriggers(
    ref.read(reminderServiceProvider).reschedule,
  );
  ref
    ..listen(cityIdProvider, (_, _) => triggers.cityChanged())
    ..listen(appLanguageProvider, (_, _) => triggers.languageChanged())
    ..listen(updateControllerProvider, (_, next) => triggers.updated(next));
  return triggers;
});

class ReminderTriggers {
  ReminderTriggers(this._reschedule);

  final Future<void> Function() _reschedule;

  void appStarted() => unawaited(_reschedule());
  void appResumed() => unawaited(_reschedule());
  void cityChanged() => unawaited(_reschedule());
  void languageChanged() => unawaited(_reschedule());

  /// Only an update that imported packs changes dates.
  void updated(UpdateResult? result) {
    if (result is UpdateDone && result.imported.isNotEmpty) {
      unawaited(_reschedule());
    }
  }
}
