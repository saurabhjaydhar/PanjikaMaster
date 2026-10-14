import 'dart:math' as math;

import '../../core/time/civil_date.dart';
import '../entities/body_positions.dart';
import 'interfaces.dart';

/// Which point of the Sun counts at sunrise and sunset (Q3), as in the pipeline's
/// `engine/riseset.py`. Both include 34′ of standard refraction.
enum SunriseDefinition {
  /// Upper limb: the Sun's centre 50′ below the horizon (34′ refraction + 16′ radius).
  upperLimb,

  /// Centre of the disc: 34′ below the horizon (refraction only).
  centre,
}

/// TODO(Q3): the reference panjika's definition decides this; upper limb until
/// validated, the same default as the pipeline.
const sunriseDefinition = SunriseDefinition.upperLimb;

/// Rise and set for any coordinates from the pack's Sun/Moon table (spec §6.5.5,
/// T-317). No astronomy library: the positions come from the pipeline, and this does
/// only the geometry the pipeline's Skyfield search does.
///
/// For an instant: the day's Chebyshev series give the body's apparent geocentric
/// RA/Dec and distance and the Greenwich apparent sidereal time; the body is rotated
/// into Earth-fixed axes, the observer's WGS84 position (elevation 0) is subtracted,
/// and the altitude is taken against the geodetic horizon. A body rises when that
/// altitude climbs through its horizon: −50′ for the Sun's upper limb (−34′ for its
/// centre), and −34′ minus the Moon's apparent radius for the Moon. The IST day is
/// scanned in 10-minute steps and each crossing refined by bisection to a millisecond.
///
/// Matches the pipeline within ±5 s (Sun) and ±10 s (Moon), checked against the
/// shared fixture `test/fixtures/riseset.json` (T-315).
class OnDeviceRiseSet implements RiseSetCalculator {
  const OnDeviceRiseSet({this.definition = sunriseDefinition});

  final SunriseDefinition definition;

  static const _step = 600.0;
  static const _arcmin = math.pi / 180 / 60;
  static const _moonRadiusKm = 1737.4;
  // WGS84
  static const _a = 6378.137;
  static const _f = 1 / 298.257223563;
  static const _e2 = _f * (2 - _f);

  @override
  RiseSetTimes timesFor({
    required double lat,
    required double lon,
    required CivilDate date,
    required BodyPositions positions,
  }) {
    if (lat.abs() > 90 || lon.abs() > 180) {
      throw ArgumentError('coordinates out of range: $lat, $lon');
    }
    // The IST day, as in the pipeline (Q16 may change this for places abroad).
    final start =
        DateTime.utc(
          date.year,
          date.month,
          date.day,
        ).subtract(Ist.offset).millisecondsSinceEpoch ~/
        1000;
    final end = start + BodyPositionsDay.seconds;
    if (positions.dayAt(start.toDouble()) == null ||
        positions.dayAt(end.toDouble()) == null) {
      throw ArgumentError('body positions do not cover ${date.toIso()}');
    }
    final place = _Place(lat, lon);
    final sunHorizon = definition == SunriseDefinition.upperLimb
        ? -50 * _arcmin
        : -34 * _arcmin;
    double sun(double t) {
      final (alt, _) = place.altitude(positions, t, _Body.sun);
      return alt - sunHorizon;
    }

    double moon(double t) {
      final (alt, dist) = place.altitude(positions, t, _Body.moon);
      return alt - (-34 * _arcmin - _moonRadiusKm / dist);
    }

    final (sunrise, sunset) = _crossings(sun, start, end);
    final (moonrise, moonset) = _crossings(moon, start, end);
    return RiseSetTimes(
      sunrise: _instant(sunrise),
      sunset: _instant(sunset),
      moonrise: _instant(moonrise),
      moonset: _instant(moonset),
    );
  }

  /// The first upward and the first downward zero of [f] in [start, end).
  static (double?, double?) _crossings(
    double Function(double) f,
    int start,
    int end,
  ) {
    double? up, down;
    var t0 = start.toDouble();
    var f0 = f(t0);
    while (t0 < end && (up == null || down == null)) {
      final t1 = math.min(t0 + _step, end.toDouble());
      final f1 = f(t1);
      if (up == null && f0 < 0 && f1 >= 0) up = _bisect(f, t0, t1);
      if (down == null && f0 >= 0 && f1 < 0) down = _bisect(f, t0, t1);
      t0 = t1;
      f0 = f1;
    }
    return (
      up != null && up < end ? up : null,
      down != null && down < end ? down : null,
    );
  }

  static double _bisect(double Function(double) f, double lo, double hi) {
    final rising = f(lo) < 0;
    while (hi - lo > 1e-3) {
      final mid = (lo + hi) / 2;
      if ((f(mid) < 0) == rising) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return (lo + hi) / 2;
  }

  static DateTime? _instant(double? unix) => unix == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch((unix * 1000).round(), isUtc: true);
}

enum _Body { sun, moon }

class _Place {
  _Place(double latDeg, double lonDeg)
    : _sinLat = math.sin(latDeg * math.pi / 180),
      _cosLat = math.cos(latDeg * math.pi / 180),
      _sinLon = math.sin(lonDeg * math.pi / 180),
      _cosLon = math.cos(lonDeg * math.pi / 180) {
    final n =
        OnDeviceRiseSet._a /
        math.sqrt(1 - OnDeviceRiseSet._e2 * _sinLat * _sinLat);
    _x = n * _cosLat * _cosLon;
    _y = n * _cosLat * _sinLon;
    _z = n * (1 - OnDeviceRiseSet._e2) * _sinLat;
  }

  final double _sinLat, _cosLat, _sinLon, _cosLon;
  late final double _x, _y, _z;

  /// Topocentric altitude (radians) above the geodetic horizon, and distance (km).
  (double, double) altitude(BodyPositions positions, double t, _Body body) {
    final day = positions.dayAt(t)!;
    final x = 2 * (t - day.startUtc) / BodyPositionsDay.seconds - 1;
    final sun = body == _Body.sun;
    final ra = _cheb(sun ? day.sunRa : day.moonRa, x);
    final dec = _cheb(sun ? day.sunDec : day.moonDec, x);
    final r = _cheb(sun ? day.sunDist : day.moonDist, x);
    final theta = _cheb(day.gast, x);
    // Earth-fixed: the body's longitude is RA − GAST.
    final h = ra - theta;
    final bx = r * math.cos(dec) * math.cos(h);
    final by = r * math.cos(dec) * math.sin(h);
    final bz = r * math.sin(dec);
    final vx = bx - _x, vy = by - _y, vz = bz - _z;
    final d = math.sqrt(vx * vx + vy * vy + vz * vz);
    final up = _cosLat * _cosLon * vx + _cosLat * _sinLon * vy + _sinLat * vz;
    return (math.asin(up / d), d);
  }

  /// Clenshaw's recurrence for Σ c_k T_k(x).
  static double _cheb(List<double> c, double x) {
    var b1 = 0.0, b2 = 0.0;
    for (var k = c.length - 1; k >= 1; k--) {
      final b0 = 2 * x * b1 - b2 + c[k];
      b2 = b1;
      b1 = b0;
    }
    return x * b1 - b2 + c[0];
  }
}
