import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../domain/reminders/plan_reminders.dart';

/// A channel's name and description in the UI language (spec §17).
typedef ChannelText = ({String name, String description});

/// Puts a reminder plan on the device: the previous plan is replaced as a whole.
abstract interface class NotificationScheduler {
  Future<void> replaceAll(
    List<PlannedReminder> plan, {
    required Map<ReminderChannel, ChannelText> channels,
  });
}

final notificationSchedulerProvider = Provider<NotificationScheduler>(
  (ref) => LocalNotificationScheduler(FlutterLocalNotificationsPlugin()),
);

/// Channel ids never change; re-creating a channel under the same id renames it, so
/// Android shows the names in the current language (spec §17).
const channelIds = {
  ReminderChannel.festival: 'festival_reminders',
  ReminderChannel.tithi: 'tithi_reminders',
};

/// [NotificationScheduler] on flutter_local_notifications. Inexact scheduling (spec
/// §17): a few minutes' variance is fine for "day before" reminders. TODO(Q7): exact
/// timing for tithi-start reminders if Play policy allows it.
class LocalNotificationScheduler implements NotificationScheduler {
  LocalNotificationScheduler(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialised = false;

  Future<void> _init() async {
    if (_initialised) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        // TODO(T-216): a monochrome notification icon with the real app icon.
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _initialised = true;
  }

  @override
  Future<void> replaceAll(
    List<PlannedReminder> plan, {
    required Map<ReminderChannel, ChannelText> channels,
  }) async {
    try {
      await _init();
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      for (final MapEntry(key: channel, value: text) in channels.entries) {
        await android?.createNotificationChannel(
          AndroidNotificationChannel(
            channelIds[channel]!,
            text.name,
            description: text.description,
            importance: Importance.high,
          ),
        );
      }
      await _plugin.cancelAll();
      for (final r in plan) {
        final text = channels[r.channel]!;
        await _plugin.zonedSchedule(
          id: r.id,
          title: r.title,
          body: r.body,
          scheduledDate: tz.TZDateTime.from(r.at, tz.UTC),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channelIds[r.channel]!,
              text.name,
              channelDescription: text.description,
              importance: Importance.high,
              styleInformation: BigTextStyleInformation(r.body),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: r.route,
        );
      }
    } on MissingPluginException {
      // No notification support on this platform (tests, desktop builds).
    }
  }
}
