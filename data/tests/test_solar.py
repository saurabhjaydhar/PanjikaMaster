"""T-205: sankrantis — 12 a year, in order, 29–32 days apart."""

from datetime import UTC, datetime
from itertools import pairwise

import pytest

from engine.panchanga import DAY
from engine.solar import sankrantis


def ts(y, m=1, d=1):
    return int(datetime(y, m, d, tzinfo=UTC).timestamp())


@pytest.mark.parametrize("year", [2020, 2026, 2033, 2045])
def test_twelve_a_year_in_order_29_to_32_days(astro, year):
    ss = sankrantis(astro, ts(year), ts(year + 1))
    starts = [s for s in ss if ts(year) <= s.start < ts(year + 1)]
    assert len(starts) == 12
    assert sorted(s.idx for s in starts) == list(range(12))
    for a, b in pairwise(ss):
        assert b.start == a.end and b.idx == (a.idx + 1) % 12
        assert 29 * DAY <= b.start - a.start <= 32 * DAY


def test_mesha_sankranti_falls_in_mid_april(astro):
    # Sanity bound only (Poila Boishakh is in mid-April); exact days are validated
    # against the reference panjika in Phase 3.
    for year in range(2020, 2046):
        mesha = [s for s in sankrantis(astro, ts(year, 3, 1), ts(year, 6, 1)) if s.idx == 0]
        when = datetime.fromtimestamp(mesha[0].start, UTC)
        assert when.month == 4 and 12 <= when.day <= 16, when


def test_sun_is_on_the_boundary(astro):
    ss = sankrantis(astro, ts(2030), ts(2031))
    for s in ss[1:]:
        lon = float(astro.sun_sidereal(s.start))
        diff = (lon - s.idx * 30 + 180) % 360 - 180
        assert abs(diff) < 2e-5  # the Sun moves ~1.2e-5° per second
