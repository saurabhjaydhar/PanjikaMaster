// T-606: gated features are off unless a build turns them on.
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/core/config/feature_flags.dart';

void main() {
  test('Bengal periods are off by default (T-602 not passed)', () {
    expect(FeatureFlags.fromEnvironment().bengalPeriods, isFalse);
    expect(const FeatureFlags().bengalPeriods, isFalse);
  });
}
