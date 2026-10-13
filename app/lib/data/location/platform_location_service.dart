import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator_android/geolocator_android.dart' as geo;

import '../../domain/location/location.dart';

final locationServiceProvider = Provider<LocationService>(
  (ref) => PlatformLocationService(),
);

/// [LocationService] on `geolocator`: low accuracy (coarse) and Android's own
/// LocationManager, so it works without Google Play services.
class PlatformLocationService implements LocationService {
  PlatformLocationService();

  // Android only for now; iOS (T-814) adds geolocator_apple.
  final _platform = geo.GeolocatorAndroid();

  @override
  Future<LocationPermission> permission() async => switch (await _platform
      .checkPermission()) {
    geo.LocationPermission.always ||
    geo.LocationPermission.whileInUse => LocationPermission.granted,
    geo.LocationPermission.deniedForever => LocationPermission.deniedForever,
    geo.LocationPermission.denied => LocationPermission.notAsked,
    geo.LocationPermission.unableToDetermine => LocationPermission.notAsked,
  };

  @override
  Future<LocationResult> locate() async {
    try {
      var permission = await _platform.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await _platform.requestPermission();
      }
      switch (permission) {
        case geo.LocationPermission.deniedForever:
          return const LocationDenied(permanently: true);
        case geo.LocationPermission.denied ||
            geo.LocationPermission.unableToDetermine:
          return const LocationDenied(permanently: false);
        case geo.LocationPermission.whileInUse || geo.LocationPermission.always:
          break;
      }
      if (!await _platform.isLocationServiceEnabled()) {
        return const LocationServiceOff();
      }
      try {
        final p = await _platform.getCurrentPosition(
          locationSettings: geo.AndroidSettings(
            accuracy: geo.LocationAccuracy.low,
            forceLocationManager: true,
            timeLimit: const Duration(seconds: 20),
          ),
        );
        return Located(p.latitude, p.longitude);
      } on TimeoutException {
        final last = await _platform.getLastKnownPosition(
          forceLocationManager: true,
        );
        return last == null
            ? const LocationUnavailable()
            : Located(last.latitude, last.longitude);
      }
    } on geo.LocationServiceDisabledException {
      return const LocationServiceOff();
    } on geo.PermissionDeniedException {
      return const LocationDenied(permanently: false);
    } on Exception {
      return const LocationUnavailable();
    }
  }

  @override
  Future<void> openAppSettings() => _platform.openAppSettings();

  @override
  Future<void> openLocationSettings() => _platform.openLocationSettings();
}
