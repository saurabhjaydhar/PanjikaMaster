"""T-207: `python -m engine build` — reproducible bytes, complete rows, run metadata."""

import hashlib
import json
import sqlite3
from datetime import date
from itertools import pairwise

import pytest

from engine import build as b
from engine import ephemeris
from engine.panchanga import KINDS
from pack import names, schema

FIRST, LAST = date(2027, 3, 10), date(2027, 3, 12)


@pytest.fixture
def reproducible(monkeypatch):
    monkeypatch.setenv("SOURCE_DATE_EPOCH", "1800000000")


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def test_same_inputs_same_bytes(astro, reproducible, tmp_path):
    a = b.build(FIRST, LAST, tmp_path / "a", dev=True)
    c = b.build(FIRST, LAST, tmp_path / "c", dev=True)
    assert a.name == c.name
    assert sha(a) == sha(c)


def test_rows_cover_the_range_and_match_the_schema(astro, reproducible, tmp_path):
    path = b.build(FIRST, LAST, tmp_path, dev=True)
    conn = sqlite3.connect(path)
    for table in schema.PACK_TABLES:
        assert schema.columns(conn, table), table  # every table exists
    (pack,) = conn.execute("SELECT id, kind, is_sample, covers_from, covers_to FROM packs")
    assert pack[1:] == ("global", 0, "2027-03-10", "2027-03-12")
    start, end = b.ist_midnight(FIRST), b.ist_midnight(date(2027, 3, 13))
    for kind in KINDS:
        rows = conn.execute(
            "SELECT idx, starts_utc, ends_utc FROM transitions WHERE kind = ? ORDER BY starts_utc",
            (kind,),
        ).fetchall()
        assert rows[0][1] <= start and rows[-1][2] >= end, kind
        assert all(x[2] == y[1] for x, y in pairwise(rows)), kind
    days = conn.execute("SELECT date FROM bengali_dates ORDER BY date").fetchall()
    assert [d for (d,) in days] == ["2027-03-10", "2027-03-11", "2027-03-12"]
    months = conn.execute("SELECT starts_utc, ends_utc FROM lunar_months").fetchall()
    assert months and months[0][0] <= start and months[-1][1] >= end
    n = conn.execute("SELECT count(*) FROM names").fetchone()[0]
    assert n == len(names.rows(pack[0]))
    assert conn.execute("PRAGMA foreign_key_check").fetchall() == []


def test_run_metadata(astro, reproducible, tmp_path):
    path = b.build(FIRST, LAST, tmp_path, dev=True)
    conn = sqlite3.connect(path)
    summary, engine_version = conn.execute(
        "SELECT validation_summary, engine_version FROM packs"
    ).fetchone()
    meta = json.loads(summary)
    assert meta["status"] == "computed, not validated"
    assert set(meta["libraries"]) == {"skyfield", "jplephem", "numpy"}
    assert len(meta["ephemeris"]["sha256"]) == 64
    assert meta["names_status"] == "draft"
    assert set(meta["rows"]) == set(KINDS) | {"bengali_dates", "lunar_months"}
    assert meta["rows"]["bengali_dates"] == 3
    locked = meta["ephemeris"]["locked"]
    assert engine_version.endswith("+dev-ephemeris") != locked
    run = json.loads(path.with_suffix(".run.json").read_text())
    assert run["seconds"] >= 0 and run["rows"] == meta["rows"]


def test_without_dev_the_override_is_never_used(astro, monkeypatch, tmp_path):
    monkeypatch.setenv(ephemeris.ENV, "/nonexistent/other.bsp")
    try:
        path = b.build(FIRST, FIRST, tmp_path)
    except ephemeris.EphemerisUnavailable:
        return  # no locked DE440s here: refusing is the point
    meta = json.loads(
        sqlite3.connect(path).execute("SELECT validation_summary FROM packs").fetchone()[0]
    )
    assert meta["ephemeris"]["file"] == "de440s.bsp" and meta["ephemeris"]["locked"]


def test_cli(astro, reproducible, tmp_path, capsys):
    assert (
        b.main(
            ["build", "--from", "2027-03-10", "--to", "2027-03-10", "--out", str(tmp_path), "--dev"]
        )
        == 0
    )
    assert "wrote" in capsys.readouterr().out
    assert (
        b.main(
            ["build", "--from", "2027-03-10", "--to", "2027-03-01", "--out", str(tmp_path), "--dev"]
        )
        == 1
    )
