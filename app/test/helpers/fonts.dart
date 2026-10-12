import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the bundled fonts so golden tests render real Bengali and Latin glyphs
/// (flutter_test otherwise uses the blocky Ahem font).
Future<void> loadAppFonts() async {
  const families = {
    'TiroBangla': ['TiroBangla-Regular.ttf'],
    'NotoSansBengali': [
      'NotoSansBengali-Regular.ttf',
      'NotoSansBengali-Medium.ttf',
      'NotoSansBengali-SemiBold.ttf',
    ],
    'NotoSans': [
      'NotoSans-Regular.ttf',
      'NotoSans-Medium.ttf',
      'NotoSans-SemiBold.ttf',
    ],
  };
  for (final MapEntry(key: family, value: files) in families.entries) {
    final loader = FontLoader(family);
    for (final file in files) {
      final bytes = File('assets/fonts/$file').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
  await _loadMaterialIcons();
}

/// The Material icon font ships with the Flutter SDK (the app bundles it via
/// `uses-material-design`), but tests don't load it, so icons would render as boxes.
/// flutter_tester lives in `<sdk>/bin/cache/artifacts/engine/<platform>/`.
Future<void> _loadMaterialIcons() async {
  final cache = File(Platform.resolvedExecutable).parent.parent.parent;
  final font = File('${cache.path}/material_fonts/MaterialIcons-Regular.otf');
  // Without it goldens would show boxes; behaviour tests are unaffected.
  if (!font.existsSync()) return;
  final loader = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(font.readAsBytesSync())));
  await loader.load();
}
