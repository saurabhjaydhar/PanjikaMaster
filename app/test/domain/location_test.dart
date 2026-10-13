// T-409: nearest supported city by great-circle distance; the 50 km warning edge.
import 'package:flutter_test/flutter_test.dart';
import 'package:panjika/domain/entities/name_ref.dart';
import 'package:panjika/domain/entities/panjika.dart';
import 'package:panjika/domain/location/location.dart';

City _city(String id, double lat, double lon) => City(
  id: id,
  name: NameRef(id, id),
  district: NameRef(id, id),
  state: 'West Bengal',
  lat: lat,
  lon: lon,
  timeZone: 'Asia/Kolkata',
  popular: true,
  aliases: const [],
);

void main() {
  test('distance: zero to itself, symmetric, one degree of latitude', () {
    expect(distanceKm(22.5, 88.3, 22.5, 88.3), 0);
    expect(
      distanceKm(22.5, 88.3, 26.7, 88.4),
      closeTo(distanceKm(26.7, 88.4, 22.5, 88.3), 1e-9),
    );
    // One degree along a meridian is 2πR/360 on a sphere.
    expect(distanceKm(0, 0, 1, 0), closeTo(111.195, 0.001));
  });

  test('picks the closest city; null with none', () {
    final a = _city('a', 22.0, 88.0);
    final b = _city('b', 23.0, 88.0);
    expect(nearestCity([a, b], 22.4, 88.0)!.city.id, 'a');
    expect(nearestCity([a, b], 22.6, 88.0)!.city.id, 'b');
    expect(nearestCity(const [], 22.6, 88.0), isNull);
  });

  test('far means more than 50 km', () {
    final c = _city('c', 0, 0);
    expect(NearestCity(c, 50).isFar, isFalse);
    expect(NearestCity(c, 50.1).isFar, isTrue);
  });
}
