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
}
