"""Validation checks: computed pack vs human-entered references (spec §6.7, T-302).

Reference files live in `reference/` (entered by the human only). Comment lines start
with '#'. Formats:

  tithi_times.csv     kind,name_en,ends_ist        tithi,Shukla Saptami,2026-10-12T14:32
  sunrise_kolkata.csv date,lat,lon,sunrise_ist,sunset_ist
                                                    2026-10-12,22.57,88.36,05:31,17:12
  bengali_dates.csv   date,bn_day,bn_month_idx,bn_year

(Example rows show the shape only; they are not values.) `kind` is tithi, nakshatra or
yoga; `name_en` is the English name as in content/names.toml; times are IST to the
minute. The latitude and longitude are the ones the reference itself uses for Kolkata.
"""

import csv
import sqlite3
from dataclasses import dataclass, field
from datetime import UTC, date, datetime, timedelta, timezone
from pathlib import Path

IST = timezone(timedelta(hours=5, minutes=30))


@dataclass
class Row:
    key: str
    ours: str
    reference: str
    diff: str
    ok: bool


@dataclass
class Check:
    name: str
    reference: str
    tolerance: str
    rows: list[Row] = field(default_factory=list)
    missing: bool = False  # reference not entered yet
    note: str = ""

    @property
    def failures(self) -> list[Row]:
        return [r for r in self.rows if not r.ok]

    @property
    def status(self) -> str:
        if self.missing:
            return "waiting for reference"
        return "failed" if self.failures else "passed"


def read_reference(path: Path) -> list[dict] | None:
    if not path.exists():
        return None
    lines = [
        line
        for line in path.read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    ]
    return list(csv.DictReader(lines))


def ist(text: str) -> int:
    return int(datetime.fromisoformat(text).replace(tzinfo=IST).timestamp())


def fmt(unix: int) -> str:
    return datetime.fromtimestamp(unix, IST).strftime("%Y-%m-%d %H:%M:%S IST")


def elements(conn: sqlite3.Connection, ref_dir: Path, tolerance_s: int = 120) -> Check:
    check = Check("Tithi / nakshatra / yoga end times", "tithi_times.csv", "±2 min")
    rows = read_reference(ref_dir / "tithi_times.csv")
    if rows is None:
        check.missing = True
        return check
    names = {
        (k, i): en.lower() for k, i, en in conn.execute("SELECT kind, idx, name_en FROM names")
    }
    for r in rows:
        kind, want = r["kind"].strip(), ist(r["ends_ist"])
        best = conn.execute(
            "SELECT idx, ends_utc FROM transitions WHERE kind = ?"
            " ORDER BY abs(ends_utc - ?) LIMIT 1",
            (kind, want),
        ).fetchone()
        key = f"{kind} {r['name_en']} {r['ends_ist']}"
        if best is None:
            check.rows.append(Row(key, "—", r["ends_ist"], "not in pack", False))
            continue
        idx, ends = best
        name_ok = names.get((kind, idx)) == r["name_en"].strip().lower()
        diff = ends - want
        check.rows.append(
            Row(
                key,
                f"{names.get((kind, idx), idx)} until {fmt(ends)}",
                r["ends_ist"],
                f"{diff:+d} s" + ("" if name_ok else ", different element"),
                name_ok and abs(diff) <= tolerance_s,
            )
        )
    return check


def sunrise_kolkata(astro, ref_dir: Path, tolerance_s: int = 60) -> Check:
    check = Check("Sunrise / sunset, Kolkata", "sunrise_kolkata.csv", "±1 min")
    rows = read_reference(ref_dir / "sunrise_kolkata.csv")
    if rows is None:
        check.missing = True
        return check
    from engine.riseset import city_days

    for r in rows:
        d = date.fromisoformat(r["date"])
        (ours,) = city_days(astro, float(r["lat"]), float(r["lon"]), d, d)
        for label, value in (("sunrise", ours.sunrise), ("sunset", ours.sunset)):
            want = ist(f"{r['date']}T{r[label + '_ist']}")
            diff = value - want
            check.rows.append(
                Row(
                    f"{label} {d}",
                    fmt(value),
                    r[label + "_ist"],
                    f"{diff:+d} s",
                    abs(diff) <= tolerance_s,
                )
            )
    return check


def bengali_dates(conn: sqlite3.Connection, ref_dir: Path) -> Check:
    check = Check("Bengali dates (and month start days)", "bengali_dates.csv", "exact")
    rows = read_reference(ref_dir / "bengali_dates.csv")
    if rows is None:
        check.missing = True
        return check
    ours = {
        d: (day, month, year)
        for d, day, month, year in conn.execute(
            "SELECT date, bn_day, bn_month_idx, bn_year FROM bengali_dates"
        )
    }
    for r in rows:
        want = (int(r["bn_day"]), int(r["bn_month_idx"]), int(r["bn_year"]))
        got = ours.get(r["date"])
        check.rows.append(
            Row(
                r["date"],
                "—" if got is None else "/".join(map(str, got)),
                "/".join(map(str, want)),
                "" if got == want else "differs",
                got == want,
            )
        )
    return check


def run_all(pack: Path, ref_dir: Path, astro) -> list[Check]:
    conn = sqlite3.connect(pack)
    checks = [
        elements(conn, ref_dir),
        sunrise_kolkata(astro, ref_dir),
        bengali_dates(conn, ref_dir),
    ]
    pending = [
        Check(
            "Sunrise, other cities",
            "Astronomy Engine",
            "±1 min",
            missing=True,
            note="Runs on the city pack once the coordinate source is decided (Q13).",
        ),
        Check(
            "Festival dates (tier 1 and 2)",
            "printed panjika + expert",
            "exact",
            missing=True,
            note="Observance rules arrive in Phase 5.",
        ),
        Check(
            "Bengal periods",
            "printed panjika, 30 days",
            "exact window",
            missing=True,
            note="Feature-flagged until the expert's rule tables are entered (§6.5.9).",
        ),
    ]
    return checks + pending


def generated_label() -> str:
    return datetime.now(UTC).strftime("%Y-%m-%d %H:%M UTC")
