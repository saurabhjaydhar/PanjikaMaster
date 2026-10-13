import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator_android/geolocator_android.dart';

/// Android 13+ asks before an app may post notifications (spec §17, US-03). The app
/// asks only when the user turns a reminder on (T-507).
abstract interface class NotificationPermission {
  Future<bool> granted();

  /// Shows the system prompt where Android still allows it; true if granted.
  Future<bool> request();

  /// The app's page in system settings, for after a refusal.
  Future<void> openSettings();
}

final notificationPermissionProvider = Provider<NotificationPermission>(
  (ref) => PlatformNotificationPermission(),
);

class PlatformNotificationPermission implements NotificationPermission {
  AndroidFlutterLocalNotificationsPlugin? get _android =>
      FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  @override
  Future<bool> granted() async {
    try {
      return await _android?.areNotificationsEnabled() ?? true;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> request() async {
    try {
      return await _android?.requestNotificationsPermission() ?? true;
    } on MissingPluginException {
      return false;
    }
  }

  // The plugin has no settings shortcut; geolocator's opens the app's settings page.
  @override
  Future<void> openSettings() async {
    try {
      await GeolocatorAndroid().openAppSettings();
    } on MissingPluginException {
      // Nothing to open on this platform.
    }
  }
}

/// True when reminders can be shown: already allowed, or allowed at the prompt.
Future<bool> ensureNotificationPermission(NotificationPermission p) async =>
    await p.granted() || await p.request();
