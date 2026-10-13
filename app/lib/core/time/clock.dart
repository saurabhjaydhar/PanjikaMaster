import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current instant. Overridden in tests. TODO(T-212): tick each minute and at the
/// next transition so Today updates while open (FR-HOME-08).
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
