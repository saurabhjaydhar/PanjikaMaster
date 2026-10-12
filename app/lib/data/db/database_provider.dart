import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// The open device database. Overridden in main.dart (and in tests).
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw StateError('appDatabaseProvider was not overridden'),
);
