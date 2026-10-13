"""T-302: the validation harness. References here are synthetic files in a temp folder,
derived from the pack under test and shifted to probe the tolerances (test inputs; the
real references are human-entered in reference/)."""

import sqlite3
from datetime import date, datetime

import pytest

from engine import build as b
from engine.riseset import city_days
from validate import checks as v
from validate.__main__ import main
from validate.report import render

FIRST, LAST = date(2027, 6, 1), date(2027, 6, 3)


@pytest.fixture
def pack(astro, tmp_path, monkeypatch):
    monkeypatch.setenv("SOURCE_DATE_EPOCH", "1800000000")
    return b.build(FIRST, LAST, tmp_path / "dist", dev=True)


def ist_minute(unix: int) -> str:
    return datetime.fromtimestamp(unix, v.IST).strftime("%Y-%m-%dT%H:%M")


def write(path, header, rows):
    path.write_text("# synthetic test reference\n" + header + "\n" + "\n".join(rows) + "\n")


def tithis(pack):
    conn = sqlite3.connect(pack)
    return conn.execute(
        "SELECT t.idx, t.ends_utc, n.name_en FROM transitions t JOIN names n"
        " ON n.kind = t.kind AND n.idx = t.idx WHERE t.kind = 'tithi' ORDER BY t.ends_utc"
    ).fetchall()


def test_missing_references_wait_and_do_not_fail(astro, pack, tmp_path):
    out = v.run_all(pack, tmp_path / "none", astro)
    assert all(c.missing and not c.failures for c in out)
    assert (
        main(
            [
                "--pack",
                str(pack),
                "--reference",
                str(tmp_path / "none"),
                "--out",
                str(tmp_path / "r"),
            ]
        )
        == 0
    )
    assert (
        main(
            [
                "--pack",
                str(pack),
                "--reference",
                str(tmp_path / "none"),
                "--out",
                str(tmp_path / "r"),
                "--release",
            ]
        )
        == 1
    )


def test_element_end_times_within_two_minutes(astro, pack, tmp_path):
    (_, ends, name), (_, ends2, name2), (_, ends3, _) = tithis(pack)[:3]
    write(
        tmp_path / "tithi_times.csv",
        "kind,name_en,ends_ist",
        [
            f"tithi,{name},{ist_minute(ends + 60)}",  # within ±2 min (minute rounding)
            f"tithi,{name2},{ist_minute(ends2 + 240)}",  # 4 min off: fails
            f"tithi,Not A Tithi,{ist_minute(ends3)}",  # wrong element: fails
        ],
    )
    check = v.elements(sqlite3.connect(pack), tmp_path)
    assert [r.ok for r in check.rows] == [True, False, False]
    assert "different element" in check.rows[2].diff
    assert check.status == "failed"


def test_sunrise_within_a_minute(astro, pack, tmp_path):
    lat, lon = 22.5, 88.3  # synthetic test coordinates
    (row,) = city_days(astro, lat, lon, FIRST, FIRST)
    hm = lambda t: datetime.fromtimestamp(t, v.IST).strftime("%H:%M")  # noqa: E731
    late = datetime.fromtimestamp(row.sunset + 300, v.IST).strftime("%H:%M")
    write(
        tmp_path / "sunrise_kolkata.csv",
        "date,lat,lon,sunrise_ist,sunset_ist",
        [f"{FIRST},{lat},{lon},{hm(row.sunrise)},{late}"],
    )
    check = v.sunrise_kolkata(astro, tmp_path)
    assert [r.ok for r in check.rows] == [True, False]


def test_bengali_dates_exact(astro, pack, tmp_path):
    rows = (
        sqlite3.connect(pack)
        .execute("SELECT date, bn_day, bn_month_idx, bn_year FROM bengali_dates ORDER BY date")
        .fetchall()
    )
    lines = [",".join(map(str, r)) for r in rows]
    d, day, month, year = rows[-1]
    lines[-1] = f"{d},{day + 1},{month},{year}"  # one day off
    write(tmp_path / "bengali_dates.csv", "date,bn_day,bn_month_idx,bn_year", lines)
    check = v.bengali_dates(sqlite3.connect(pack), tmp_path)
    assert [r.ok for r in check.rows] == [True, True, False]


def test_report_lists_every_row_mismatches_first(astro, pack, tmp_path):
    (_, ends, name), (_, ends2, name2) = tithis(pack)[:2]
    write(
        tmp_path / "tithi_times.csv",
        "kind,name_en,ends_ist",
        [f"tithi,{name},{ist_minute(ends)}", f"tithi,{name2},{ist_minute(ends2 + 600)}"],
    )
    out = tmp_path / "reports"
    code = main(["--pack", str(pack), "--reference", str(tmp_path), "--out", str(out)])
    assert code == 1
    html = (out / f"{pack.stem}.html").read_text()
    assert html.count("class=bad") == 1 and html.count("class=ok") == 1
    assert html.index("class=bad") < html.index("class=ok")
    assert "waiting for reference" in html and "Q13" in html


def test_report_escapes_text():
    c = v.Check("<script>", "x", "y", rows=[v.Row("<b>", "&", '"', "", False)])
    html = render("p<1>", [c], "now")
    assert "<script>" not in html and "&lt;b&gt;" in html
