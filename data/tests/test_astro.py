"""T-202: apparent geocentric Sun and Moon longitudes.

Checks: (1) Skyfield's own almanac events (equinoxes, solstices, new and full moons)
land on the expected longitudes, (2) an independent theory (Astronomy Engine, analytic,
no JPL data) agrees, (3) motion rates are physical over 2020–2045.
"""

from datetime import UTC, datetime

import astronomy
import numpy as np
import pytest
from hypothesis import given, settings
from hypothesis import strategies as st
from skyfield import almanac

START = int(datetime(2020, 1, 1, tzinfo=UTC).timestamp())
END = int(datetime(2046, 1, 1, tzinfo=UTC).timestamp())


def angle_diff(a, b) -> np.ndarray:
    """Signed difference a − b in degrees, in (−180, 180]."""
    return (np.asarray(a) - np.asarray(b) + 180) % 360 - 180


def test_seasons_put_the_sun_on_the_cardinal_longitudes(astro):
    ts = astro.ts
    t, kind = almanac.find_discrete(
        ts.utc(2024, 1, 1), ts.utc(2026, 1, 1), almanac.seasons(astro._eph)
    )
    secs = [x.utc_datetime().timestamp() for x in t]
    lon = astro.sun_longitude(secs)
    assert np.abs(angle_diff(lon, np.asarray(kind) * 90.0)).max() < 1e-5


def test_moon_phases_put_the_elongation_on_quarters(astro):
    ts = astro.ts
    t, phase = almanac.find_discrete(
        ts.utc(2025, 1, 1), ts.utc(2026, 1, 1), almanac.moon_phases(astro._eph)
    )
    secs = [x.utc_datetime().timestamp() for x in t]
    assert np.abs(angle_diff(astro.elongation(secs), np.asarray(phase) * 90.0)).max() < 1e-5


@pytest.mark.parametrize("year", [2020, 2027, 2033, 2045])
def test_independent_theory_by_year(astro, year):
    secs = np.linspace(
        datetime(year, 1, 1, tzinfo=UTC).timestamp(),
        datetime(year, 12, 31, tzinfo=UTC).timestamp(),
        37,
    )
    sun = astro.sun_longitude(secs)
    moon = astro.moon_longitude(secs)
    for s, sun_lon, moon_lon in zip(secs, sun, moon, strict=True):
        t = astronomy.Time.Make(*datetime.fromtimestamp(s, UTC).timetuple()[:6])
        assert abs(angle_diff(sun_lon, astronomy.SunPosition(t).elon)) < 0.005, s
        assert abs(angle_diff(moon_lon, astronomy.EclipticGeoMoon(t).lon)) < 0.02, s


@settings(max_examples=50, deadline=None)
@given(st.integers(START, END - 86_400))
def test_motion_rates_are_physical(astro, t0):
    hour = np.array([t0, t0 + 3600])
    sun = angle_diff(*astro.sun_longitude(hour)[::-1]) * 24
    moon = angle_diff(*astro.moon_longitude(hour)[::-1]) * 24
    assert 0.94 < sun < 1.03  # °/day
    assert 11.5 < moon < 15.5


def test_vectorised_matches_scalar(astro):
    secs = np.array([START, START + 12_345_678, END - 1])
    vector = astro.moon_longitude(secs)
    scalar = [float(astro.moon_longitude(s)) for s in secs]
    assert np.allclose(vector, scalar, atol=1e-9)


def test_unix_seconds_are_utc_without_leap_seconds(astro):
    # 2024-06-01T00:00:00Z: 27 leap seconds after 1970 must not shift the instant.
    secs = datetime(2024, 6, 1, tzinfo=UTC).timestamp()
    t = astro.time(secs)
    assert t.utc_datetime() == datetime(2024, 6, 1, tzinfo=UTC)
    arr = astro.time(np.array([secs, secs + 0.5]))
    assert abs(arr[1].utc_datetime().timestamp() - secs - 0.5) < 1e-4
