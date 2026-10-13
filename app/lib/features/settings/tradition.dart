import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/settings.dart';
import '../reminders/reminder_service.dart';

/// Traditions the engine computes. Surya Siddhanta needs its own engine, so the
/// setting shows it as "coming soon" and keeps Drik (T-410).
final availableTraditionsProvider = Provider<Set<String>>(
  (ref) => const {'drik_bishuddha'},
);

/// Reminders depend on dates that a tradition or city change can move (spec §17).
final rescheduleRemindersProvider = Provider<Future<void> Function()>(
  (ref) => ref.read(reminderServiceProvider).reschedule,
);

/// Switches the tradition if the engine supports it. Everything that reads the
/// tradition reloads by itself; reminders are rescheduled. Returns false (and changes
/// nothing) for a tradition that is not available yet.
Future<bool> changeTradition(Ref ref, String id) async {
  if (!ref.read(availableTraditionsProvider).contains(id)) return false;
  if (ref.read(traditionProvider) == id) return true;
  await ref.read(traditionProvider.notifier).set(id);
  await ref.read(rescheduleRemindersProvider)();
  return true;
}

/// [changeTradition] from widgets.
final traditionChangerProvider = Provider<Future<bool> Function(String id)>(
  (ref) =>
      (id) => changeTradition(ref, id),
);
