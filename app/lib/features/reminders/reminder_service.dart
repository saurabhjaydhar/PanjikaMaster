import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_language.dart';
import '../../core/l10n/l10n_providers.dart';
import '../../core/l10n/panjika_formatter.dart';
import '../../core/settings/settings.dart';
import '../../core/time/civil_date.dart';
import '../../core/time/clock.dart';
import '../../data/notifications/notification_scheduler.dart';
import '../../data/repositories/panjika_providers.dart';
import '../../domain/entities/name_ref.dart';
import '../../domain/entities/panjika.dart';
import '../../domain/reminders/plan_reminders.dart';
import '../../domain/reminders/reminder_config.dart';
import '../../l10n/gen/app_localizations.dart';
import 'reminder_prefs.dart';

final reminderServiceProvider = Provider<ReminderService>(ReminderService.new);

/// Plans the next 60 days of reminders from the packs and puts them on the device
/// (FR-REM-01..03). Called whenever what they depend on changes (T-508).
class ReminderService {
  ReminderService(this._ref);

  final Ref _ref;
  Future<void>? _running;
  bool _again = false;

  /// One reschedule at a time; calls that arrive meanwhile are folded into one more
  /// run, so the last state always wins.
  Future<void> reschedule() {
    if (_running != null) {
      _again = true;
      return _running!;
    }
    return _running = _loop();
  }

  Future<void> _loop() async {
    try {
      do {
        _again = false;
        await _once();
      } while (_again);
    } finally {
      _running = null;
    }
  }

  Future<void> _once() async {
    try {
      final config = _ref.read(reminderConfigProvider);
      final language = _ref.read(appLanguageProvider);
      final l = lookupAppLocalizations(language.locale);
      final scheduler = _ref.read(notificationSchedulerProvider);
      final channels = {
        ReminderChannel.festival: (
          name: l.channelFestival,
          description: l.channelFestivalDescription,
        ),
        ReminderChannel.tithi: (
          name: l.channelTithi,
          description: l.channelTithiDescription,
        ),
      };
      if (config.isEmpty) {
        await scheduler.replaceAll(const [], channels: channels);
        return;
      }
      final repo = _ref.read(panjikaRepositoryProvider);
      final tradition = _ref.read(traditionProvider);
      final now = _ref.read(clockProvider)();
      final today = CivilDate.ofInstant(now);
      // A day either side: a "day before" reminder can be for tomorrow's festival.
      final (observances, tithis, names) = await (
        repo.observances(tradition, today, today.addDays(61)),
        repo.transitions(
          tradition,
          TransitionKind.tithi,
          now.subtract(const Duration(days: 2)),
          now.add(const Duration(days: 62)),
        ),
        repo.names(),
      ).wait;
      final plan = planReminders(
        config: config,
        observances: observances,
        tithis: tithis,
        now: now,
        copy: AppReminderCopy(
          l,
          _ref.read(formatterProvider),
          language,
          names.tradition(tradition),
        ),
      );
      await scheduler.replaceAll(plan, channels: channels);
    } on Object catch (e) {
      // Never break the screen that asked; the next trigger tries again.
      debugPrint('reminders: reschedule failed: $e');
    }
  }
}

/// Reminder texts in the UI language (FR-REM-04, spec §17), with the provenance
/// every datum carries: tradition and time zone.
class AppReminderCopy implements ReminderCopy {
  AppReminderCopy(this.l, this.f, this.language, this.tradition);

  final AppLocalizations l;
  final PanjikaFormatter f;
  final AppLanguage language;
  final NameRef tradition;

  @override
  String title(ObservanceDate o, ReminderTiming timing) {
    final name = o.observance.name.of(language);
    return switch (timing) {
      ReminderTiming.dayBefore => l.reminderTomorrow(name),
      ReminderTiming.morningOf => l.reminderToday(name),
      ReminderTiming.tithiStart => l.reminderTithiBegun(name),
    };
  }

  @override
  String body(ObservanceDate o, DateTime? tithiStart) => l.reminderBody(
    tithiStart == null
        ? f.gregorianDateShort(o.date)
        : l.reminderTithiBegins(f.time(tithiStart)),
    tradition.of(language),
    l.timeZoneLabel,
  );
}
