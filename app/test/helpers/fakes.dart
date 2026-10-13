import 'package:panjika/core/l10n/app_locale_channel.dart';
import 'package:panjika/domain/location/location.dart';

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

/// A scripted [LocationService]: the permission it reports, what [locate] returns,
/// and what was called.
class FakeLocationService implements LocationService {
  FakeLocationService({
    this.permissionState = LocationPermission.granted,
    this.result = const LocationUnavailable(),
  });

  LocationPermission permissionState;
  LocationResult result;
  int locateCalls = 0;
  int appSettingsOpened = 0;
  int locationSettingsOpened = 0;

  @override
  Future<LocationPermission> permission() async => permissionState;

  @override
  Future<LocationResult> locate() async {
    locateCalls++;
    return result;
  }

  @override
  Future<void> openAppSettings() async => appSettingsOpened++;

  @override
  Future<void> openLocationSettings() async => locationSettingsOpened++;
}
