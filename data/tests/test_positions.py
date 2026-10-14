"""T-314: the Sun/Moon table rebuilds Skyfield's positions over 2020–2045, fits the size
budget, and its rows are what the phone expects."""

import gzip
from datetime import date, timedelta

import numpy as np
import pytest

from engine import positions as p

ARCSEC = np.pi / 180 / 3600
FIRST, LAST = date(2020, 1, 1), date(2045, 12, 31)


def skyfield(astro, body, unix):
    t = astro.time(unix)
    ra, dec, dist = astro._earth.at(t).observe(body).apparent(()).radec("date")
    return ra.radians, dec.radians, dist.km, t.gast / 24 * 2 * np.pi


def wrapped(a):
    return (a + np.pi) % (2 * np.pi) - np.pi


@pytest.fixture(scope="module")
def sample_days():
    rng = np.random.default_rng(314)
    span = (LAST - FIRST).days
    return [FIRST + timedelta(days=int(n)) for n in rng.choice(span + 1, 40, replace=False)]


def test_rebuilt_positions_match_skyfield_over_2020_to_2045(astro, sample_days):
    rng = np.random.default_rng(1)
    for d in sample_days:
        (row,) = p.rows(astro, d, d)
        unix = row.start_utc + rng.uniform(0, 86_400, 20)
        c = row.coefficients
        for body, prefix, limit in ((astro._sun, "sun", 1), (astro._moon, "moon", 2)):
            ra, dec, dist, _ = skyfield(astro, body, unix)
            d_ra = wrapped(p.value(c[f"{prefix}_ra"], row.start_utc, unix) - ra)
            d_dec = p.value(c[f"{prefix}_dec"], row.start_utc, unix) - dec
            err = np.hypot(d_ra * np.cos(dec), d_dec) / ARCSEC
            assert err.max() < limit, (d, prefix, err.max())
            assert err.max() < 0.01, (d, prefix, err.max())  # the margin we actually have
            # Distance only sets parallax and the Moon's radius: 1 km is far below 0.01″.
            assert np.abs(p.value(c[f"{prefix}_dist"], row.start_utc, unix) - dist).max() < 1
        *_, gast = skyfield(astro, astro._sun, unix)
        d_gast = wrapped(p.value(c["gast"], row.start_utc, unix) - gast)
        assert np.abs(d_gast).max() / (2 * np.pi) * 86_164 < 0.001, d  # seconds of time


def test_rows_are_ist_days_with_continuous_angles(astro):
    rows = p.rows(astro, date(2026, 3, 19), date(2026, 3, 22))  # Sun crosses RA 0 here
    assert [r.date for r in rows] == [date(2026, 3, 19) + timedelta(days=i) for i in range(4)]
    for r in rows:
        assert r.start_utc == p.ist_midnight(r.date)
        assert r.start_utc % 86_400 == 86_400 - 19_800  # 18:30 UTC
        x = np.linspace(r.start_utc, r.start_utc + 86_400, 200)
        for f in ("sun_ra", "moon_ra", "gast"):
            steps = np.diff(p.value(r.coefficients[f], r.start_utc, x))
            assert np.all(steps > 0), (r.date, f)  # no 2π jump inside a row


def test_blobs_round_trip_and_have_the_documented_degrees(astro):
    (row,) = p.rows(astro, date(2026, 10, 13), date(2026, 10, 13))
    blobs = dict(zip(p.FIELDS, row.blobs(), strict=True))
    for f, blob in blobs.items():
        assert np.array_equal(p.from_blob(blob), row.coefficients[f])
    degree = {f: len(b) // 8 - 1 for f, b in blobs.items()}
    assert degree == {
        "sun_ra": 3, "sun_dec": 3, "sun_dist": 3,
        "moon_ra": 6, "moon_dec": 6, "moon_dist": 6,
        "gast": 3,
    }  # fmt: skip


def test_a_year_fits_the_size_budget(astro):
    rows = p.rows(astro, date(2026, 4, 14), date(2027, 4, 14))
    raw = b"".join(b for r in rows for b in r.blobs())
    assert len(gzip.compress(raw, 9)) <= 200 * 1024  # performance.md
