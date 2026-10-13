"""T-301: the Bengal midnight rule, Bengali dates and lunar months.

Rule edges use synthetic instants and sun times (test inputs). Year-long properties use
the engine's own sankrantis and tithis. The exact match against the printed panjika runs
once `reference/bengali_dates.csv` exists.
"""

import csv
from datetime import UTC, date, datetime, timedelta
from itertools import pairwise
from pathlib import Path

import pytest

from engine import bengali as bn
from engine.panchanga import DAY, search_in_chunks
from engine.solar import sankrantis

REFERENCE = Path(__file__).resolve().parents[1] / "reference" / "bengali_dates.csv"
D = date(2027, 4, 14)
MID = bn.ist_midnight(D + timedelta(days=1))  # 00:00 IST that ends D


def fake_sun(d: date):
    # Synthetic times: sunrise 05:30 IST, sunset 18:00 IST, true midnight 23:45 IST.
    m = bn.ist_midnight(d)
    return m + 5 * 3600 + 1800, m + 18 * 3600, m + DAY + 5 * 3600 + 1800


class TestCivilMidnight:
    @pytest.mark.parametrize("offset", [-1, 0, 1])
    def test_around_civil_midnight(self, offset):
        # 23:59:59 on D → D+1; 00:00:00 and 00:00:01 on D+1 → D+2.
        expected = D + timedelta(days=1 if offset < 0 else 2)
        assert bn.month_start(MID + offset, bn.Midnight.CIVIL_IST) == expected

    @pytest.mark.parametrize("offset", [-1, 0, 1])
    def test_around_sunrise(self, offset):
        rise, _, _ = fake_sun(D)
        # Before or after sunrise on D, the civil rule gives D+1 (sunrise-day D−1 after
        # its midnight → its d+2; or sunrise-day D before its midnight → its d+1).
        assert bn.month_start(rise + offset, bn.Midnight.CIVIL_IST) == D + timedelta(days=1)


class TestTrueMidnight:
    @pytest.mark.parametrize(("offset", "days"), [(-1, 1), (0, 2), (1, 2)])
    def test_around_true_midnight(self, offset, days):
        _, set_, next_rise = fake_sun(D)
        true_mid = (set_ + next_rise) // 2  # 23:45 IST
        got = bn.month_start(true_mid + offset, bn.Midnight.TRUE_LOCAL, fake_sun)
        assert got == D + timedelta(days=days)

    def test_between_true_and_civil_midnight_differs_from_civil(self):
        s = MID - 10 * 60  # 23:50 IST: after true midnight, before civil midnight
        assert bn.month_start(s, bn.Midnight.CIVIL_IST) == D + timedelta(days=1)
        assert bn.month_start(s, bn.Midnight.TRUE_LOCAL, fake_sun) == D + timedelta(days=2)

    @pytest.mark.parametrize("offset", [-1, 0, 1])
    def test_around_sunrise(self, offset):
        rise, _, _ = fake_sun(D)
        # Before sunrise the sankranti belongs to sunrise-day D−1, after its midnight:
        # D+1. From sunrise on, it is in day D before midnight: D+1 as well.
        got = bn.month_start(rise + offset, bn.Midnight.TRUE_LOCAL, fake_sun)
        assert got == D + timedelta(days=1)

    def test_needs_sun_times(self):
        with pytest.raises(ValueError):
            bn.month_start(MID, bn.Midnight.TRUE_LOCAL)


def test_bangabda():
    assert bn.bangabda(date(2026, 4, 15), 0) == 1433  # বৈশাখ
    assert bn.bangabda(date(2026, 12, 16), 8) == 1433  # পৌষ
    assert bn.bangabda(date(2027, 1, 15), 9) == 1433  # মাঘ
    assert bn.bangabda(date(2027, 3, 15), 11) == 1433  # চৈত্র
    assert bn.bangabda(date(2027, 4, 15), 0) == 1434


def ts(d: date) -> int:
    return int(datetime(d.year, d.month, d.day, tzinfo=UTC).timestamp())


def test_a_year_of_bengali_dates(astro):
    first, last = date(2026, 1, 1), date(2027, 12, 31)
    ss = sankrantis(astro, ts(first) - 40 * DAY, ts(last) + 40 * DAY)
    rows = bn.bengali_dates(ss, first, last)
    assert [r.date for r in rows] == [first + timedelta(days=i) for i in range(len(rows))]
    for a, b in pairwise(rows):
        if b.day == 1:
            assert b.month_idx == (a.month_idx + 1) % 12
            assert 29 <= a.day <= 32
            assert b.year == a.year + (1 if b.month_idx == 0 else 0)
        else:
            assert (b.day, b.month_idx, b.year) == (a.day + 1, a.month_idx, a.year)
    boishakh = [r for r in rows if r.day == 1 and r.month_idx == 0]
    assert [(r.date.month, r.year) for r in boishakh] == [(4, 1433), (4, 1434)]


def test_lunar_months_and_mala_masa(astro):
    t0, t1 = ts(date(2020, 1, 1)), ts(date(2031, 1, 1))
    tithis = search_in_chunks("tithi", astro, t0, t1)
    signs = {}

    def sign(t):
        if t not in signs:
            signs[t] = int(float(astro.sun_sidereal(t)) // 30)
        return signs[t]

    months = bn.lunar_months(tithis, sign)
    for a, b in pairwise(months):
        assert b.start == a.end
    for m in months:
        assert 29.2 * DAY < m.end - m.start < 29.9 * DAY
    adhik = [m for m in months if m.is_adhik]
    # A mala masa comes about every 32.5 months: 3–5 of them in 11 years.
    assert 3 <= len(adhik) <= 5
    for m in adhik:
        assert sign(m.start) == sign(m.end), "no sankranti inside a mala masa"


def test_matches_the_printed_panjika(astro):
    if not REFERENCE.exists():
        pytest.skip(f"NOTICE: {REFERENCE.name} not entered yet (Phase 3 human gate)")
    rows = list(
        csv.DictReader(
            line
            for line in REFERENCE.read_text(encoding="utf-8").splitlines()
            if line.strip() and not line.lstrip().startswith("#")
        )
    )
    dates = [date.fromisoformat(r["date"]) for r in rows]
    ss = sankrantis(astro, ts(min(dates)) - 40 * DAY, ts(max(dates)) + 40 * DAY)
    ours = {r.date: r for r in bn.bengali_dates(ss, min(dates), max(dates))}
    for r, d in zip(rows, dates, strict=True):
        o = ours[d]
        assert (o.day, o.month_idx, o.year) == (
            int(r["bn_day"]),
            int(r["bn_month_idx"]),
            int(r["bn_year"]),
        ), d
