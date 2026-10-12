import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_language.dart';
import 'app_locale_channel.dart';
import 'panjika_formatter.dart';

final appLocaleChannelProvider = Provider<AppLocaleChannel>(
  (ref) => const AppLocaleChannel(),
);

/// The device's locales; overridden in tests.
final deviceLocalesProvider = Provider<List<Locale>>(
  (ref) => PlatformDispatcher.instance.locales,
);

/// Holds one user setting. TODO(T-108): back these with the settings table.
class SettingNotifier<T> extends Notifier<T> {
  SettingNotifier(this._initial);

  final T _initial;

  @override
  T build() => _initial;

  void set(T value) => state = value;
}

/// The saved language, if the user has chosen one.
final savedLanguageProvider =
    NotifierProvider<SettingNotifier<AppLanguage?>, AppLanguage?>(
      () => SettingNotifier<AppLanguage?>(null),
    );

/// The current UI language. Changing it re-renders the app immediately, without a
/// restart, and keeps navigation state (FR-SET-05).
final appLanguageProvider =
    NotifierProvider<AppLanguageController, AppLanguage>(
      AppLanguageController.new,
    );

class AppLanguageController extends Notifier<AppLanguage> {
  @override
  AppLanguage build() => resolveLanguage(
    saved: ref.watch(savedLanguageProvider),
    deviceLocales: ref.watch(deviceLocalesProvider),
  );

  /// The user picked a language in the app: apply it, remember it, and mirror it to
  /// Android's per-app language setting.
  Future<void> select(AppLanguage language) async {
    ref.read(savedLanguageProvider.notifier).set(language);
    await ref.read(appLocaleChannelProvider).set(language.name);
  }

  /// Picks up a change made in Android's per-app language setting (FR-L10N-03).
  Future<void> syncFromSystem() async {
    final language = AppLanguage.fromTag(
      await ref.read(appLocaleChannelProvider).current(),
    );
    if (language != null && language != state) {
      ref.read(savedLanguageProvider.notifier).set(language);
    }
  }
}

/// Explicit numeral choice; null means "follow the language" (FR-L10N-04).
final numeralOverrideProvider =
    NotifierProvider<SettingNotifier<NumeralStyle?>, NumeralStyle?>(
      () => SettingNotifier<NumeralStyle?>(null),
    );

final timeFormatProvider =
    NotifierProvider<SettingNotifier<TimeFormat>, TimeFormat>(
      () => SettingNotifier<TimeFormat>(TimeFormat.h12),
    );

/// The formatter for the current settings. Widgets read this; nothing else formats.
final formatterProvider = Provider<PanjikaFormatter>((ref) {
  final language = ref.watch(appLanguageProvider);
  return PanjikaFormatter(
    language: language,
    numerals: ref.watch(numeralOverrideProvider) ?? language.defaultNumerals,
    timeFormat: ref.watch(timeFormatProvider),
  );
});
