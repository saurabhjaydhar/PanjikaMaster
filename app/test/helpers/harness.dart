import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/app/theme/app_theme.dart';
import 'package:panjika/core/l10n/app_language.dart';
import 'package:panjika/core/l10n/l10n_providers.dart';
import 'package:panjika/core/settings/settings.dart';
import 'package:panjika/data/db/app_database.dart';
import 'package:panjika/data/db/database_provider.dart';
import 'package:panjika/l10n/gen/app_localizations.dart';

import 'fakes.dart';

/// Pumps [child] in the app's theme and localisation, on a phone-width screen.
Future<ProviderContainer> pumpComponent(
  WidgetTester tester,
  Widget child, {
  required AppDatabase db,
  AppLanguage language = AppLanguage.bn,
  Brightness brightness = Brightness.light,
  double textScale = 1.0,
  Size size = const Size(360, 640),
  double devicePixelRatio = 1,
  bool settle = true,
}) async {
  tester.view
    ..physicalSize = size * devicePixelRatio
    ..devicePixelRatio = devicePixelRatio;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      deviceLocalesProvider.overrideWithValue([language.locale]),
      settingsSourceProvider.overrideWithValue(MemorySettings()),
      appLocaleChannelProvider.overrideWithValue(FakeAppLocaleChannel()),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (context, ref, _) {
          final current = ref.watch(appLanguageProvider);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: buildPanjikaTheme(brightness, current),
            locale: current.locale,
            supportedLocales: [for (final l in AppLanguage.values) l.locale],
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Scaffold(body: child),
          );
        },
      ),
    ),
  );
  if (settle) await tester.pumpAndSettle();
  return container;
}

/// [pumpComponent] without settling, to watch animations frame by frame.
Future<ProviderContainer> pumpComponentNoSettle(
  WidgetTester tester,
  Widget child, {
  required AppDatabase db,
}) => pumpComponent(tester, child, db: db, settle: false);
