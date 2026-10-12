import 'package:panjika/core/l10n/app_locale_channel.dart';

/// Stands in for the Android per-app language channel in widget tests: a real platform
/// call never completes inside the test's fake clock.
class FakeAppLocaleChannel extends AppLocaleChannel {
  FakeAppLocaleChannel([this.tag]);

  String? tag;

  @override
  Future<String?> current() async => tag;

  @override
  Future<void> set(String tag) async => this.tag = tag;
}
