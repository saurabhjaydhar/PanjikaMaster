// T-108: settings persist in the device database and survive an app restart.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart' show Locale, ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/core/l10n/app_language.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/l10n/panjika_formatter.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/repositories/settings_store.dart';

void main() {
  // select() talks to the (absent) platform channel, which needs the binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late File dbFile;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('panjika_settings_');
    dbFile = File('${dir.path}/panjika.sqlite');
  });

  tearDown(() => dir.deleteSync(recursive: true));

  /// One "app session": open the database file, load settings, build providers.
  Future<(AppDatabase, ProviderContainer)> session() async {
    final db = AppDatabase(NativeDatabase(dbFile));
    final settings = await DbSettings.load(db);
    final container = ProviderContainer(
      overrides: [
        settingsSourceProvider.overrideWithValue(settings),
        deviceLocalesProvider.overrideWithValue(const [Locale('bn')]),
      ],
    );
    return (db, container);
  }

  test('defaults when nothing is saved (FR-LOC-04: Kolkata)', () async {
    final (db, c) = await session();
    expect(c.read(appLanguageProvider), AppLanguage.bn);
    expect(c.read(numeralOverrideProvider), isNull);
    expect(c.read(timeFormatProvider), TimeFormat.h12);
    expect(c.read(themeModeProvider), ThemeMode.system);
    expect(c.read(textScaleProvider), isNull);
    expect(c.read(traditionProvider), 'drik_bishuddha');
    expect(c.read(cityIdProvider), 'kolkata');
    expect(c.read(namesBothScriptsProvider), isNull);
    expect(c.read(onboardingDoneProvider), isFalse);
    c.dispose();
    await db.close();
  });

  test('every setting survives a restart', () async {
    var (db, c) = await session();
    await c.read(appLanguageProvider.notifier).select(AppLanguage.en);
    await c.read(numeralOverrideProvider.notifier).set(NumeralStyle.bengali);
    await c.read(timeFormatProvider.notifier).set(TimeFormat.h24);
    await c.read(themeModeProvider.notifier).set(ThemeMode.dark);
    await c.read(textScaleProvider.notifier).set(1.3);
    await c.read(cityIdProvider.notifier).set('siliguri');
    await c.read(namesBothScriptsProvider.notifier).set(true);
    await c.read(onboardingDoneProvider.notifier).set(true);
    c.dispose();
    await db.close();

    (db, c) = await session(); // restart
    expect(c.read(appLanguageProvider), AppLanguage.en);
    expect(c.read(numeralOverrideProvider), NumeralStyle.bengali);
    expect(c.read(timeFormatProvider), TimeFormat.h24);
    expect(c.read(themeModeProvider), ThemeMode.dark);
    expect(c.read(textScaleProvider), 1.3);
    expect(c.read(cityIdProvider), 'siliguri');
    expect(c.read(namesBothScriptsProvider), isTrue);
    expect(c.read(onboardingDoneProvider), isTrue);
    expect(
      c.read(formatterProvider).digits('12'),
      '১২',
      reason: 'override beats language',
    );
    c.dispose();
    await db.close();
  });

  test('values are stored in the spec §15.1 formats', () async {
    final (db, c) = await session();
    await c.read(numeralOverrideProvider.notifier).set(NumeralStyle.latin);
    await c.read(timeFormatProvider.notifier).set(TimeFormat.h24);
    await c.read(namesBothScriptsProvider.notifier).set(false);
    final rows = {
      for (final r in await db.select(db.settings).get()) r.key: r.value,
    };
    expect(rows, {
      'numerals': 'latn',
      'time_format': '24',
      'names_both_scripts': '0',
    });
    c.dispose();
    await db.close();
  });

  test('setting a nullable value back to null deletes the row', () async {
    var (db, c) = await session();
    await c.read(numeralOverrideProvider.notifier).set(NumeralStyle.latin);
    await c.read(numeralOverrideProvider.notifier).set(null);
    expect(await db.select(db.settings).get(), isEmpty);
    c.dispose();
    await db.close();

    (db, c) = await session();
    expect(c.read(numeralOverrideProvider), isNull);
    c.dispose();
    await db.close();
  });

  test('an unreadable stored value falls back to the default', () async {
    final db = AppDatabase(NativeDatabase(dbFile));
    await db
        .into(db.settings)
        .insert(SettingsCompanion.insert(key: 'time_format', value: 'garbage'));
    await db.close();
    final (db2, c) = await session();
    expect(c.read(timeFormatProvider), TimeFormat.h12);
    c.dispose();
    await db2.close();
  });

  test('without an override the app fails loudly, not silently in memory', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(() => c.read(settingsSourceProvider), throwsA(anything));
  });
}
