import 'dart:math' as math;

import '../entities/panjika.dart';

/// What asking for the device's position gave (FR-LOC-02..04).
sealed class LocationResult {
  const LocationResult();
}

final class Located extends LocationResult {
  const Located(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

/// The user said no; [permanently] means Android won't ask again, so only the app's
/// system settings can change it.
final class LocationDenied extends LocationResult {
  const LocationDenied({required this.permanently});
  final bool permanently;
}

/// Location is switched off on the phone.
final class LocationServiceOff extends LocationResult {
  const LocationServiceOff();
}

/// No fix in time, or the platform failed.
final class LocationUnavailable extends LocationResult {
  const LocationUnavailable();
}

enum LocationPermission { granted, notAsked, denied, deniedForever }

/// The device's coarse position, asked for only when the user taps "Use my location"
/// (spec §19: coarse only, on tap, never in background).
abstract interface class LocationService {
  Future<LocationPermission> permission();

  /// Asks for permission if needed, then one coarse fix.
  Future<LocationResult> locate();

  /// The app's page in system settings (after a permanent denial).
  Future<void> openAppSettings();

  /// The phone's location settings (when location is off).
  Future<void> openLocationSettings();
}

/// Beyond this, the nearest city's times may differ by a few minutes (FR-LOC-03).
const farFromCityKm = 50.0;

class NearestCity {
  const NearestCity(this.city, this.distanceKm);
  final City city;
  final double distanceKm;

  bool get isFar => distanceKm > farFromCityKm;
}

/// The supported city closest to a position, by great-circle distance; null when
/// there are no cities.
NearestCity? nearestCity(Iterable<City> cities, double lat, double lon) {
  NearestCity? best;
  for (final city in cities) {
    final d = distanceKm(lat, lon, city.lat, city.lon);
    if (best == null || d < best.distanceKm) best = NearestCity(city, d);
  }
  return best;
}

/// Haversine distance on the IUGG mean Earth radius; ample for "which city is
/// nearest" and a kilometre figure.
double distanceKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0088;
  double rad(double deg) => deg * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLon = rad(lon2 - lon1);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) *
          math.cos(rad(lat2)) *
          math.pow(math.sin(dLon / 2), 2);
  return 2 * earthRadiusKm * math.asin(math.min(1, math.sqrt(a)));
}
