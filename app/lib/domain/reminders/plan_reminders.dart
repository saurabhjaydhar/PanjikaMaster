import '../../core/time/civil_date.dart';
import '../entities/panjika.dart';
import 'reminder_config.dart';

enum ReminderChannel { festival, tithi }

/// One notification to schedule. Texts are final: written in the UI language when
/// planned (spec §17), so a language change means a new plan.
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
    required this.channel,
    required this.route,
  });

  /// Stable for the same observance, date and timing, so a reschedule replaces it.
  final int id;
  final DateTime at;
  final String title;
  final String body;
  final ReminderChannel channel;

  /// Where tapping it goes (`/festival/<id>?date=…`).
  final String route;
}

/// Writes the notification texts; implemented with the app's localisations.
abstract interface class ReminderCopy {
  String title(ObservanceDate o, ReminderTiming timing);

  /// [tithiStart] is when the observance's tithi begins, if known.
  String body(ObservanceDate o, DateTime? tithiStart);
}

/// Tithi indices of each recurring kind (spec §15.1).
const recurringTithis = {
  RecurringKind.ekadashi: {10, 25},
  RecurringKind.purnima: {14},
  RecurringKind.amavasya: {29},
};

const horizon = Duration(days: 60); // FR-REM-03
const cap = 64; // spec §17

/// The instant [minutes] after IST midnight on [date].
DateTime istInstant(CivilDate date, int minutes) => DateTime.utc(
  date.year,
  date.month,
  date.day,
).add(Duration(minutes: minutes)).subtract(Ist.offset);

/// Notifications for [config] from [now] to [now] + 60 days, earliest first, at most
/// 64 (FR-REM-01..03). [observances] should cover that range; [tithis] are tithi
/// transitions over it (for "tithi begins" and tithi-start reminders). Multi-day
/// festivals are reminded of on their first day.
List<PlannedReminder> planReminders({
  required ReminderConfig config,
  required List<ObservanceDate> observances,
  required List<Transition> tithis,
  required DateTime now,
  required ReminderCopy copy,
}) {
  final end = now.add(horizon);
  final recurringById = {
    for (final k in config.recurring.keys) k.observanceId: k,
  };
  final out = <PlannedReminder>[];

  DateTime? tithiStartOf(ObservanceDate o, Set<int>? indices) {
    if (indices == null) return null;
    final dayStart = istInstant(o.date, 0);
    final dayEnd = istInstant(o.date.addDays(1), 0);
    Duration overlap(Transition t) {
      final a = t.startUtc.isAfter(dayStart) ? t.startUtc : dayStart;
      final b = t.endUtc.isBefore(dayEnd) ? t.endUtc : dayEnd;
      return b.isAfter(a) ? b.difference(a) : Duration.zero;
    }

    final candidates = [
      for (final t in tithis)
        if (indices.contains(t.idx) && overlap(t) > Duration.zero) t,
    ]..sort((a, b) => overlap(b).compareTo(overlap(a)));
    return candidates.firstOrNull?.startUtc;
  }

  for (final o in observances) {
    if (o.dayIndex != 0) continue;
    final id = o.observance.id;
    final kind = recurringById[id];
    final times = config.festivals[id] ?? config.recurring[kind];
    if (times == null) continue;
    final indices = kind == null ? null : recurringTithis[kind];
    final tithiStart = tithiStartOf(o, indices);
    for (final t in times) {
      final at = switch (t.timing) {
        ReminderTiming.dayBefore => istInstant(o.date.addDays(-1), t.minutes),
        ReminderTiming.morningOf => istInstant(o.date, t.minutes),
        ReminderTiming.tithiStart => tithiStart,
      };
      if (at == null || !at.isAfter(now) || at.isAfter(end)) continue;
      out.add(
        PlannedReminder(
          id: reminderId('$id|${o.date.toIso()}|${t.timing.name}|${t.minutes}'),
          at: at,
          title: copy.title(o, t.timing),
          body: copy.body(o, tithiStart),
          channel: kind == null
              ? ReminderChannel.festival
              : ReminderChannel.tithi,
          route: '/festival/$id?date=${o.date.toIso()}',
        ),
      );
    }
  }
  out.sort((a, b) {
    final byTime = a.at.compareTo(b.at);
    return byTime != 0 ? byTime : a.id.compareTo(b.id);
  });
  return out.length > cap ? out.sublist(0, cap) : out;
}

/// A positive 31-bit id from a key (FNV-1a), stable across runs and devices.
int reminderId(String key) {
  var hash = 0x811c9dc5;
  for (final unit in key.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}
