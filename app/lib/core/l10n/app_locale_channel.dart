import 'package:flutter/services.dart';

/// Two-way sync with Android 13+'s per-app language setting (FR-L10N-03).
/// On older Android versions (and in tests) both calls are no-ops.
class AppLocaleChannel {
  const AppLocaleChannel();

  static const _channel = MethodChannel('panjika/app_locale');

  /// The language tag set in system settings for this app, or null if none.
  Future<String?> current() async {
    try {
      final tag = await _channel.invokeMethod<String>('get');
      return (tag == null || tag.isEmpty) ? null : tag;
    } on MissingPluginException {
      return null;
    }
  }

  /// Mirrors an in-app language choice into the system setting.
  Future<void> set(String tag) async {
    try {
      await _channel.invokeMethod<void>('set', {'tag': tag});
    } on MissingPluginException {
      // Not on Android 13+ (or running in a test): nothing to sync.
    }
  }
}
