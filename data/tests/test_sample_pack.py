"""T-103: sample packs are complete, internally consistent and unmistakably sample."""

import itertools
import sqlite3
from datetime import date, timedelta

import pytest

from pack import sample, schema


@pytest.fixture(scope="module")
def packs(tmp_path_factory) -> dict[str, sqlite3.Connection]:
    out = tmp_path_factory.mktemp("sample")
    paths = sample.build(out)
    return {p.stem: sqlite3.connect(p) for p in paths}


def test_three_packs_one_kind_each(packs):
    kinds = {}
    for name, conn in packs.items():
        rows = conn.execute("SELECT kind, is_sample, validation_summary FROM packs").fetchall()
        assert len(rows) == 1, name
        kind, is_sample, summary = rows[0]
        assert is_sample == 1
        assert sample.SAMPLE_MARKER in summary
        kinds[name] = kind
    assert kinds == {
        "sample-global": "global",
        "sample-cities": "cities",
        "sample-observances": "observances",
    }


def test_schema_and_foreign_keys_hold(packs):
    for conn in packs.values():
        assert conn.execute("PRAGMA user_version").fetchone()[0] == schema.SCHEMA_VERSION
        assert conn.execute("PRAGMA foreign_key_check").fetchall() == []


def test_every_observance_row_is_sample(packs):
    statuses = {
        r[0] for r in packs["sample-observances"].execute("SELECT status FROM observance_dates")
    }
    assert statuses == {"sample"}


def transitions(conn, kind):
    return conn.execute(
        "SELECT idx, starts_utc, ends_utc FROM transitions WHERE kind = ? ORDER BY starts_utc",
        (kind,),
    ).fetchall()


@pytest.mark.parametrize(
    ("kind", "cycle"),
    [("tithi", 30), ("nakshatra", 27), ("yoga", 27), ("karana", 60), ("sankranti", 12)],
)
def test_transitions_are_contiguous_and_cycle(packs, kind, cycle):
    rows = transitions(packs["sample-global"], kind)
    assert len(rows) > 3
    for (i1, _, e1), (i2, s2, _) in itertools.pairwise(rows):
        assert s2 == e1, "no gaps or overlaps"
        assert i2 == (i1 + 1) % cycle


def test_transitions_cover_the_range(packs):
    lo = int(
        sample.datetime.combine(
            sample.COVERS_FROM, sample.datetime.min.time(), sample.IST
        ).timestamp()
    )
    hi = int(
        sample.datetime.combine(
            sample.COVERS_TO, sample.datetime.max.time(), sample.IST
        ).timestamp()
    )
    for kind in ("tithi", "nakshatra", "yoga", "karana", "sankranti"):
        rows = transitions(packs["sample-global"], kind)
        assert rows[0][1] <= lo and rows[-1][2] >= hi, kind


def test_tithi_lengths_plausible(packs):
    for _, start, end in transitions(packs["sample-global"], "tithi"):
        assert 19 * 3600 <= end - start <= 27 * 3600


def test_bengali_dates_daily_and_months_plausible(packs):
    rows = (
        packs["sample-global"]
        .execute("SELECT date, bn_day, bn_month_idx FROM bengali_dates ORDER BY date")
        .fetchall()
    )
    expected = (sample.COVERS_TO - sample.COVERS_FROM).days + 1
    assert len(rows) == expected
    assert date.fromisoformat(rows[0][0]) == sample.COVERS_FROM
    lengths, prev = [], None
    for d, day, month in rows:
        if prev and month != prev[2]:
            assert day == 1 and month == (prev[2] + 1) % 12
            lengths.append(prev[1])
        elif prev:
            assert day == prev[1] + 1
            assert date.fromisoformat(d) == date.fromisoformat(prev[0]) + timedelta(days=1)
        prev = (d, day, month)
    assert all(29 <= n <= 32 for n in lengths[1:])  # the first month is cut off by the range


def test_wireframe_anchor(packs):
    """The fixture lines up with the PRD's sample wireframe: 25 Ashwin = 12 Oct."""
    row = (
        packs["sample-global"]
        .execute("SELECT bn_day, bn_month_idx FROM bengali_dates WHERE date = '2026-10-12'")
        .fetchone()
    )
    assert row == (25, 5)


def test_names_complete_in_both_languages(packs):
    conn = packs["sample-global"]
    for kind, entries in sample.load_names().items():
        count = conn.execute("SELECT count(*) FROM names WHERE kind = ?", (kind,)).fetchone()[0]
        assert count == len(entries), kind
    expected = {
        "tithi": 30,
        "nakshatra": 27,
        "yoga": 27,
        "karana": 11,
        "solar_month": 12,
        "weekday": 7,
    }
    for kind, n in expected.items():
        assert conn.execute("SELECT count(*) FROM names WHERE kind = ?", (kind,)).fetchone()[0] == n


def test_cities_have_a_row_per_day(packs):
    conn = packs["sample-cities"]
    days = (sample.COVERS_TO - sample.COVERS_FROM).days + 1
    for (city,) in conn.execute("SELECT id FROM cities"):
        n = conn.execute("SELECT count(*) FROM city_days WHERE city_id = ?", (city,)).fetchone()[0]
        assert n == days


def test_some_days_have_no_moonrise(packs):
    n = (
        packs["sample-cities"]
        .execute("SELECT count(*) FROM city_days WHERE moonrise_utc IS NULL")
        .fetchone()[0]
    )
    assert n > 0


def test_refuses_release_env(tmp_path, monkeypatch):
    monkeypatch.setenv("PANJIKA_BUILD", "release")
    with pytest.raises(sample.ReleaseBuildError):
        sample.build(tmp_path)
    assert not any(tmp_path.iterdir())


def test_refuses_release_flag(tmp_path):
    with pytest.raises(sample.ReleaseBuildError):
        sample.main(["--release", "--out", str(tmp_path)])


def test_output_is_reproducible(tmp_path):
    a = sample.build(tmp_path / "a")
    b = sample.build(tmp_path / "b")
    for pa, pb in zip(a, b, strict=True):
        dump = lambda p: list(sqlite3.connect(p).iterdump())  # noqa: E731
        assert dump(pa) == dump(pb)
