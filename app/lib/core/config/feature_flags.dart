import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Features that stay off until a human gate is passed. Set with `--dart-define`s; a
/// release build passes none until the gate is recorded in the phase log.
class FeatureFlags {
  const FeatureFlags({this.bengalPeriods = false});

  factory FeatureFlags.fromEnvironment() => const FeatureFlags(
    // TODO(T-602): on once the expert's rule tables match 30 printed days (§6.5.9).
    bengalPeriods: bool.fromEnvironment('PANJIKA_BENGAL_PERIODS'),
  );

  /// Bengal-specific periods from the pack's `period_rules` (spec §6.5.9).
  final bool bengalPeriods;
}

final featureFlagsProvider = Provider<FeatureFlags>(
  (ref) => FeatureFlags.fromEnvironment(),
);
