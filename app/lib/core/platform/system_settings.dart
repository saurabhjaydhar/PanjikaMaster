import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// System settings pages the Help screen can open (T-613).
enum SystemSettingsPage { tts, notifications, battery }

/// Opens Android settings pages; falls back to the app's own settings page. Returns
/// false when nothing could be opened (and on platforms without the channel).
class SystemSettings {
  const SystemSettings();

  static const _channel = MethodChannel('panjika/system_settings');

  Future<bool> open(SystemSettingsPage page) async {
    try {
      return await _channel.invokeMethod<bool>('open', {'page': page.name}) ??
          false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}

final systemSettingsProvider = Provider<SystemSettings>(
  (ref) => const SystemSettings(),
);
