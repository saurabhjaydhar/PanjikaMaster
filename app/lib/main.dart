import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/panjika_app.dart';
import 'core/settings/settings.dart';
import 'data/db/app_database.dart';
import 'data/db/database_provider.dart';
import 'data/fixtures/sample_loader.dart';
import 'data/repositories/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw behind the status and navigation bars (spec §12.10). Android 15+ enforces this at
  // targetSdk 36; enabling it everywhere keeps older devices consistent.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  _registerFontLicences();

  final db = AppDatabase.open();
  // Debug builds only: kDebugMode is a compile-time constant, so release builds contain
  // neither this call nor the sample data (checked in CI by check_release_bundle.sh).
  if (kDebugMode) {
    await loadSamplePackIfEmpty(db);
  }
  // Settings are read before the first frame, so the first screen is already in the
  // user's language and theme (no flicker).
  final settings = await DbSettings.load(db);

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        settingsSourceProvider.overrideWithValue(settings),
      ],
      child: const PanjikaApp(),
    ),
  );
}

/// Adds the bundled fonts' SIL OFL texts and the data notice to the licences page
/// (spec §19.1 L2, L6, L7).
void _registerFontLicences() {
  const fonts = {
    'Tiro Bangla': 'assets/fonts/OFL-TiroBangla.txt',
    'Noto Sans Bengali': 'assets/fonts/OFL-NotoSansBengali.txt',
    'Noto Sans': 'assets/fonts/OFL-NotoSans.txt',
  };
  LicenseRegistry.addLicense(() async* {
    for (final MapEntry(key: name, value: path) in fonts.entries) {
      yield LicenseEntryWithLineBreaks([
        name,
      ], await rootBundle.loadString(path));
    }
    // Where the computed data comes from, in both languages (§19.1 L2).
    yield LicenseEntryWithLineBreaks([
      'বাংলা পঞ্জিকা: তথ্য · Bangla Panjika data', // both languages
    ], await rootBundle.loadString('assets/legal/DATA-NOTICE.txt'));
  });
}
