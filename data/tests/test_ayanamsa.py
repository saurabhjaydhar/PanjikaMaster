"""T-203: Lahiri ayanamsa.

Reference values: `reference/ayanamsa.csv`, entered by the human from the Rashtriya
Panchang / Indian Astronomical Ephemeris. Until it exists, the 1″ check is skipped with
a notice. Expected format (comment lines start with '#'):

    date_tt,ayanamsa,kind
    2026-01-01T00:00,24°12′34.56″,true     # DMS or decimal degrees; kind = mean | true
"""

import csv
import re
from datetime import UTC, datetime
from pathlib import Path

import numpy as np
import pytest
from skyfield.api import Star

from engine import ayanamsa as ay

REFERENCE = Path(__file__).resolve().parents[1] / "reference" / "ayanamsa.csv"


def jd(year, month, day):
    return datetime(year, month, day, tzinfo=UTC).timestamp() / 86400 + 2440587.5


def test_epoch_value_is_the_published_definition():
    assert ay.mean_ayanamsa(ay.EPOCH_JD_TT) * 3600 == pytest.approx(83700.658, abs=1e-9)


def test_rate_is_the_general_precession():
    per_year = (ay.mean_ayanamsa(jd(2027, 1, 1)) - ay.mean_ayanamsa(jd(2026, 1, 1))) * 3600
    assert 50.2 < per_year < 50.4  # ″ per year


def test_order_of_magnitude_at_j2000():
    # Lahiri is a little under 23°52′ at J2000; a sanity bound, not a reference value.
    assert 23.80 < ay.mean_ayanamsa(ay.J2000) < 23.90


def test_true_minus_mean_is_nutation(astro):
    secs = np.linspace(
        datetime(2020, 1, 1, tzinfo=UTC).timestamp(),
        datetime(2045, 12, 31, tzinfo=UTC).timestamp(),
        200,
    )
    t = astro.time(secs)
    diff = (ay.true_ayanamsa(t) - ay.mean_ayanamsa(t.tt)) * 3600
    assert np.abs(diff).max() < 20  # |Δψ| < 20″
    assert np.abs(diff).max() > 10  # and nutation really is included


def test_spica_sits_near_180_degrees(astro):
    # Chitrapaksha: the ayanamsa is defined so Chitra (Spica) is at sidereal 180°.
    # Hipparcos (HIP 65474) position and motion, as a test input.
    spica = Star(
        ra_hours=(13, 25, 11.57937),
        dec_degrees=(-11, -9, -40.7501),
        ra_mas_per_year=-42.35,
        dec_mas_per_year=-30.67,
        parallax_mas=13.06,
    )
    from skyfield.framelib import ecliptic_frame

    secs = datetime(2026, 1, 1, tzinfo=UTC).timestamp()
    t = astro.time(secs)
    _, lon, _ = astro._earth.at(t).observe(spica).apparent().frame_latlon(ecliptic_frame)
    sidereal = (lon.degrees - ay.true_ayanamsa(t)) % 360
    # Lahiri was fixed in 1956 from the star data of the time, so it is not a "true
    # Chitra" ayanamsa: here Spica comes out about 1′ short of 180°. This is an order
    # check only; the reference test below is the 1″ gate.
    assert abs(sidereal - 180) < 0.05, sidereal


def parse_angle(text: str) -> float:
    text = text.strip()
    m = re.fullmatch(r"(\d+)°\s*(\d+)′\s*([\d.]+)″", text)
    if m:
        d, mi, s = m.groups()
        return int(d) + int(mi) / 60 + float(s) / 3600
    return float(text)


def test_matches_the_reference_within_one_arcsecond(astro):
    if not REFERENCE.exists():
        pytest.skip(f"NOTICE: {REFERENCE.name} not entered yet (T-203 human gate)")
    rows = [
        r
        for r in csv.DictReader(
            line
            for line in REFERENCE.read_text(encoding="utf-8").splitlines()
            if line.strip() and not line.lstrip().startswith("#")
        )
    ]
    assert rows, "reference file has no rows"
    for r in rows:
        when = datetime.fromisoformat(r["date_tt"]).replace(tzinfo=UTC)
        jd_tt = when.timestamp() / 86400 + 2440587.5
        t = astro.ts.tt_jd(jd_tt)
        ours = ay.true_ayanamsa(t) if r["kind"].strip() == "true" else ay.mean_ayanamsa(jd_tt)
        assert abs(float(ours) - parse_angle(r["ayanamsa"])) * 3600 <= 1.0, r
