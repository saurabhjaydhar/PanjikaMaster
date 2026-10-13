import 'dart:convert';

/// When a reminder fires, relative to its observance (spec §11.13, FR-REM-01..02).
enum ReminderTiming {
  /// The evening before, at [ReminderTime.minutes] IST.
  dayBefore,

  /// The morning of the (udaya) day, at [ReminderTime.minutes] IST.
  morningOf,

  /// When the tithi begins. Needs exact alarms to be useful. TODO(Q7)
  tithiStart,
}

class ReminderTime {
  const ReminderTime(this.timing, [this.minutes = 0]);

  final ReminderTiming timing;

  /// Minutes after IST midnight; unused for [ReminderTiming.tithiStart].
  final int minutes;

  @override
  bool operator ==(Object other) =>
      other is ReminderTime &&
      other.timing == timing &&
      other.minutes == minutes;

  @override
  int get hashCode => Object.hash(timing, minutes);

  Map<String, Object> toJson() => {'timing': timing.name, 'minutes': minutes};

  static ReminderTime? fromJson(Object? json) {
    if (json is! Map) return null;
    final timing = ReminderTiming.values
        .where((t) => t.name == json['timing'])
        .firstOrNull;
    final minutes = json['minutes'];
    if (timing == null || minutes is! int || minutes < 0 || minutes >= 1440) {
      return null;
    }
    return ReminderTime(timing, minutes);
  }
}

/// Recurring tithi reminders (FR-REM-02); each is the pack observance of that id.
enum RecurringKind {
  ekadashi,
  purnima,
  amavasya;

  /// The observance id in the packs (`data/observances/<id>.yaml`).
  String get observanceId => name;
}

/// What the user wants to be reminded of. Stored as JSON in the settings.
class ReminderConfig {
  const ReminderConfig({this.festivals = const {}, this.recurring = const {}});

  /// Observance id → when. Defaults: the evening before at 20:00 (FR-REM-01).
  final Map<String, List<ReminderTime>> festivals;

  /// Absent = off. Default when turned on: the morning of the day at 06:00 (FR-REM-02).
  final Map<RecurringKind, List<ReminderTime>> recurring;

  static const festivalDefault = [
    ReminderTime(ReminderTiming.dayBefore, 20 * 60),
  ];
  static const recurringDefault = [
    ReminderTime(ReminderTiming.morningOf, 6 * 60),
  ];

  bool get isEmpty => festivals.isEmpty && recurring.isEmpty;

  ReminderConfig withFestival(String id, List<ReminderTime>? times) =>
      ReminderConfig(
        festivals: {
          for (final e in festivals.entries)
            if (e.key != id) e.key: e.value,
          if (times != null && times.isNotEmpty) id: times,
        },
        recurring: recurring,
      );

  ReminderConfig withRecurring(RecurringKind kind, List<ReminderTime>? times) =>
      ReminderConfig(
        festivals: festivals,
        recurring: {
          for (final e in recurring.entries)
            if (e.key != kind) e.key: e.value,
          if (times != null && times.isNotEmpty) kind: times,
        },
      );

  String encode() => jsonEncode({
    'festivals': {
      for (final e in festivals.entries)
        e.key: [for (final t in e.value) t.toJson()],
    },
    'recurring': {
      for (final e in recurring.entries)
        e.key.name: [for (final t in e.value) t.toJson()],
    },
  });

  /// Unreadable or missing parts are dropped rather than failing the app.
  static ReminderConfig decode(String? raw) {
    if (raw == null || raw.isEmpty) return const ReminderConfig();
    Object? json;
    try {
      json = jsonDecode(raw);
    } on FormatException {
      return const ReminderConfig();
    }
    if (json is! Map) return const ReminderConfig();
    List<ReminderTime> times(Object? list) => [
      if (list is List)
        for (final t in list) ?ReminderTime.fromJson(t),
    ];
    final festivals = json['festivals'];
    final recurring = json['recurring'];
    return ReminderConfig(
      festivals: {
        if (festivals is Map)
          for (final e in festivals.entries)
            if (e.key is String && times(e.value).isNotEmpty)
              e.key as String: times(e.value),
      },
      recurring: {
        if (recurring is Map)
          for (final kind in RecurringKind.values)
            if (times(recurring[kind.name]).isNotEmpty)
              kind: times(recurring[kind.name]),
      },
    );
  }
}
