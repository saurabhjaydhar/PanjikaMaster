import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_language.dart';
import '../l10n/panjika_formatter.dart';

/// Keys of the device `settings` table (spec §15.1).
enum SettingKey {
  locale('locale'),
  numerals('numerals'),
  namesBothScripts('names_both_scripts'),
  tradition('tradition'),
  cityId('city_id'),
  theme('theme'),
  textScale('text_scale'),
  timeFormat('time_format'),
  onboardingDone('onboarding_done'),
  lastManifestCheck('last_manifest_check'),
  lastManifest('last_manifest'),
  dismissedNotices('dismissed_notices'),
  recentCities('recent_cities'),
  remindersOptIn('reminders_opt_in'),
  reminders('reminders');

  const SettingKey(this.key);

  final String key;
}

/// Where settings live. Read synchronously (loaded before the first frame), written
/// through on every change. The database-backed version is in `data/`.
abstract interface class SettingsSource {
  String? read(SettingKey key);

  /// null removes the setting so its default applies again.
  Future<void> write(SettingKey key, String? value);
}

/// Values kept only in memory (tests, previews).
class MemorySettings implements SettingsSource {
  MemorySettings([Map<SettingKey, String> initial = const {}])
    : _values = Map.of(initial);

  final Map<SettingKey, String> _values;

  @override
  String? read(SettingKey key) => _values[key];

  @override
  Future<void> write(SettingKey key, String? value) async {
    value == null ? _values.remove(key) : _values[key] = value;
  }
}

/// Must be overridden at startup (main.dart) or in tests.
final settingsSourceProvider = Provider<SettingsSource>(
  (ref) => throw StateError('settingsSourceProvider was not overridden'),
);

/// One persisted setting: decoded from the store on first read, written through on
/// [set]. A missing or unreadable value falls back to [fallback].
class PersistedSetting<T> extends Notifier<T> {
  PersistedSetting(
    this.key, {
    required this.fallback,
    required this.decode,
    required this.encode,
  });

  final SettingKey key;
  final T fallback;
  final T? Function(String raw) decode;
  final String? Function(T value) encode;

  @override
  T build() {
    final raw = ref.read(settingsSourceProvider).read(key);
    return raw == null ? fallback : (decode(raw) ?? fallback);
  }

  Future<void> set(T value) async {
    state = value;
    await ref.read(settingsSourceProvider).write(key, encode(value));
  }
}

T? _byName<T extends Enum>(List<T> values, String raw) {
  for (final v in values) {
    if (v.name == raw) return v;
  }
  return null;
}

/// The user's saved UI language; null until they choose (FR-L10N-02).
final savedLanguageProvider =
    NotifierProvider<PersistedSetting<AppLanguage?>, AppLanguage?>(
      () => PersistedSetting<AppLanguage?>(
        SettingKey.locale,
        fallback: null,
        decode: AppLanguage.fromTag,
        encode: (v) => v?.name,
      ),
    );

/// Explicit numeral choice; null follows the language (FR-L10N-04). Stored as
/// 'beng' | 'latn' (spec §15.1).
final numeralOverrideProvider =
    NotifierProvider<PersistedSetting<NumeralStyle?>, NumeralStyle?>(
      () => PersistedSetting<NumeralStyle?>(
        SettingKey.numerals,
        fallback: null,
        decode: (raw) => switch (raw) {
          'beng' => NumeralStyle.bengali,
          'latn' => NumeralStyle.latin,
          _ => null,
        },
        encode: (v) => switch (v) {
          NumeralStyle.bengali => 'beng',
          NumeralStyle.latin => 'latn',
          null => null,
        },
      ),
    );

/// '12' | '24'.
final timeFormatProvider =
    NotifierProvider<PersistedSetting<TimeFormat>, TimeFormat>(
      () => PersistedSetting<TimeFormat>(
        SettingKey.timeFormat,
        fallback: TimeFormat.h12,
        decode: (raw) => switch (raw) {
          '12' => TimeFormat.h12,
          '24' => TimeFormat.h24,
          _ => null,
        },
        encode: (v) => v == TimeFormat.h24 ? '24' : '12',
      ),
    );

/// 'system' | 'light' | 'dark'.
final themeModeProvider =
    NotifierProvider<PersistedSetting<ThemeMode>, ThemeMode>(
      () => PersistedSetting<ThemeMode>(
        SettingKey.theme,
        fallback: ThemeMode.system,
        decode: (raw) => _byName(ThemeMode.values, raw),
        encode: (v) => v.name,
      ),
    );

/// In-app text size multiplier on top of the system setting; null = system only.
final textScaleProvider = NotifierProvider<PersistedSetting<double?>, double?>(
  () => PersistedSetting<double?>(
    SettingKey.textScale,
    fallback: null,
    decode: double.tryParse,
    encode: (v) => v?.toString(),
  ),
);

/// Panjika tradition (spec §5.3). Only Drik is active in MVP.
final traditionProvider = NotifierProvider<PersistedSetting<String>, String>(
  () => PersistedSetting<String>(
    SettingKey.tradition,
    fallback: 'drik_bishuddha',
    decode: (raw) => raw,
    encode: (v) => v,
  ),
);

/// Selected city; Kolkata is the default (FR-LOC-04).
final cityIdProvider = NotifierProvider<PersistedSetting<String>, String>(
  () => PersistedSetting<String>(
    SettingKey.cityId,
    fallback: 'kolkata',
    decode: (raw) => raw,
    encode: (v) => v,
  ),
);

/// "Names in both scripts"; null = the per-language default, which is Q15.
final namesBothScriptsProvider =
    NotifierProvider<PersistedSetting<bool?>, bool?>(
      () => PersistedSetting<bool?>(
        SettingKey.namesBothScripts,
        fallback: null,
        decode: (raw) => raw == '1' ? true : (raw == '0' ? false : null),
        encode: (v) => v == null ? null : (v ? '1' : '0'),
      ),
    );

final onboardingDoneProvider = NotifierProvider<PersistedSetting<bool>, bool>(
  () => PersistedSetting<bool>(
    SettingKey.onboardingDone,
    fallback: false,
    decode: (raw) => raw == '1',
    encode: (v) => v ? '1' : '0',
  ),
);

/// The onboarding reminders answer: true = "Yes, remind me", false = "Not now",
/// null = not asked. The scheduler (T-506) and permission flow (T-507) read it.
final remindersOptInProvider = NotifierProvider<PersistedSetting<bool?>, bool?>(
  () => PersistedSetting<bool?>(
    SettingKey.remindersOptIn,
    fallback: null,
    decode: (raw) => raw == '1' ? true : (raw == '0' ? false : null),
    encode: (v) => v == null ? null : (v ? '1' : '0'),
  ),
);
