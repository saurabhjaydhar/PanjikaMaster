import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/panjika_app.dart';
import 'core/settings/settings.dart';
import 'data/db/app_database.dart';
import 'data/db/database_provider.dart';
import 'data/repositories/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw behind the status and navigation bars (spec §12.10). Android 15+ enforces this at
  // targetSdk 36; enabling it everywhere keeps older devices consistent.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final db = AppDatabase.open();
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
