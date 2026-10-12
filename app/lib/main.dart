import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/panjika_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw behind the status and navigation bars (spec §12.10). Android 15+ enforces this at
  // targetSdk 36; enabling it everywhere keeps older devices consistent.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const PanjikaApp());
}
