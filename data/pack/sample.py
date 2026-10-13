"""Sample-pack generator (T-103): fixture packs for app development and tests.

Everything time-based here is SYNTHETIC: fixed mean durations with a small
sine wobble, anchored to the PRD's sample wireframe values. It is NOT astronomy
and NOT a panjika. Every pack is marked three ways so it can never pass for
real data (spec §6.8):

* ``packs.is_sample = 1``
* every ``observance_dates.status`` is ``'sample'``
* ``packs.validation_summary`` carries ``SAMPLE_MARKER``, which the app's release
  check (T-113) greps for

Names come from ``content/names.toml`` (draft, Q5/Q14). The generator refuses
to run for a release build.

Usage::

    uv run python -m pack.sample --out dist/sample
"""

import argparse
import itertools
import math
import os
import sqlite3
import sys
import tomllib
import unicodedata
from collections.abc import Iterator
from datetime import UTC, date, datetime, timedelta, timezone
from pathlib import Path

from pack import schema

SAMPLE_MARKER = "PANJIKA-SAMPLE-FIXTURE-DO-NOT-SHIP"
ENGINE_VERSION = "sample-generator-1"
TRADITION = "drik_bishuddha"
IST = timezone(timedelta(hours=5, minutes=30))
NAMES_PATH = Path(__file__).resolve().parents[1] / "content" / "names.toml"

# Fixture range: "a few months" around the PRD wireframes' sample day (12 Oct 2026).
COVERS_FROM = date(2026, 9, 1)
COVERS_TO = date(2026, 12, 31)
SAMPLE_BN_YEAR = 1433  # constant over this range; fixture only

# Synthetic means (seconds). Real values come from the Phase 2 engine.
DAY = 86_400
TITHI_MEAN = 29.530589 * DAY / 30
NAKSHATRA_MEAN = 27.321662 * DAY / 27
YOGA_MEAN = 0.9415 * DAY
SANKRANTI_MEAN = 30.4369 * DAY

# Anchors chosen so the fixture lines up with the PRD wireframes ("25 Ashwin = 12 Oct").
ASHWIN_SANKRANTI = datetime(2026, 9, 17, 6, 0, tzinfo=UTC)  # sample, not a computed ingress
SERIES_START = datetime(2026, 8, 20, 0, 0, tzinfo=UTC)  # a little before COVERS_FROM

SAMPLE_CITIES = [
    # id, name_bn, name_en, aliases, district_bn, district_en, lat, lon, popular
    # Approximate coordinates for fixtures only; the real source is Q13.
    ("kolkata", "কলকাতা", "Kolkata", "calcutta|kolkata|কলকাতা", "কলকাতা", "Kolkata", 22.57, 88.36, 1),
    ("howrah", "হাওড়া", "Howrah", "howrah|haora|হাওড়া", "হাওড়া", "Howrah", 22.59, 88.26, 1),
    (
        "siliguri",
        "শিলিগুড়ি",
        "Siliguri",
        "siliguri|shiliguri|শিলিগুড়ি",
        "দার্জিলিং",
        "Darjeeling",
        26.73,
        88.40,
        1,
    ),
]

# id, name_bn, name_en, category, tier, date (all sample values from the PRD wireframes)
SAMPLE_OBSERVANCES = [
    ("mahalaya", "মহালয়া", "Mahalaya", "tithi", 1, "2026-10-06"),
    ("durga_shashthi", "দুর্গাষষ্ঠী", "Durga Shashthi", "puja", 1, "2026-10-12"),
    ("maha_saptami", "মহাসপ্তমী", "Maha Saptami", "puja", 1, "2026-10-13"),
    ("maha_ashtami", "মহাষ্টমী", "Maha Ashtami", "puja", 1, "2026-10-14"),
    ("maha_navami", "মহানবমী", "Maha Navami", "puja", 1, "2026-10-15"),
    ("vijaya_dashami", "বিজয়া দশমী", "Vijaya Dashami", "puja", 1, "2026-10-16"),
    ("lakshmi_puja", "লক্ষ্মীপূজা", "Lakshmi Puja", "puja", 1, "2026-10-20"),
    ("kali_puja", "কালীপূজা", "Kali Puja", "puja", 1, "2026-11-08"),
    ("bhai_phonta", "ভাইফোঁটা", "Bhai Phonta", "utsav", 2, "2026-11-10"),
]
# observance_id, window_kind, start, end (UTC). Sample values.
SAMPLE_WINDOWS = [
    ("maha_ashtami", "sandhi_puja", datetime(2026, 10, 14, 5, 26, tzinfo=UTC), 48 * 60),
    ("kali_puja", "nishita", datetime(2026, 11, 8, 18, 1, tzinfo=UTC), 50 * 60),
]
SAMPLE_DESC_BN = "এটি নমুনা বিবরণ, শুধু অ্যাপ তৈরির সময় পরীক্ষার জন্য। (নমুনা বিবরণ)"
SAMPLE_DESC_EN = "This is a sample description, used only while building the app. (Sample)"


class ReleaseBuildError(SystemExit):
    pass


def assert_not_release(argv: list[str] | None = None) -> None:
    """Sample data must never be produced for a release build (CLAUDE.md, spec §6.8)."""
    if os.environ.get("PANJIKA_BUILD", "").lower() == "release" or "--release" in (argv or []):
        raise ReleaseBuildError("refusing to generate sample packs for a release build")


def ts(dt: datetime) -> int:
    return int(dt.timestamp())


def days(start: date, end: date) -> Iterator[date]:
    d = start
    while d <= end:
        yield d
        d += timedelta(days=1)


# ---------------------------------------------------------------- synthetic series


def series(
    mean: float, wobble: float, cycle: int, start_idx: int, start: datetime, end: datetime
) -> list[tuple[int, int, int]]:
    """Contiguous (idx, starts_utc, ends_utc) rows with a deterministic wobble."""
    rows, t, idx, n = [], ts(start), start_idx, 0
    stop = ts(end)
    while t < stop:
        duration = round(mean + wobble * math.sin(n * 0.9))
        rows.append((idx, t, t + duration))
        t += duration
        idx = (idx + 1) % cycle
        n += 1
    return rows


def karanas(tithis: list[tuple[int, int, int]]) -> list[tuple[int, int, int]]:
    """Each tithi splits into two karanas; k = 2 * tithi_idx + half (spec §6.5.4)."""
    rows = []
    for idx, start, end in tithis:
        mid = (start + end) // 2
        rows += [(2 * idx, start, mid), (2 * idx + 1, mid, end)]
    return rows


def sankrantis(end: datetime) -> list[tuple[int, int, int]]:
    start = ASHWIN_SANKRANTI - timedelta(seconds=SANKRANTI_MEAN)  # Bhadra ingress
    return series(SANKRANTI_MEAN, 0.6 * DAY, 12, 4, start, end)


def bengali_dates(sankranti_rows: list[tuple[int, int, int]]) -> list[tuple[date, int, int]]:
    """(date, bn_day, bn_month_idx). Simplified fixture rule: a month starts the IST day
    after its sankranti. TODO(Q4): the real midnight rule lives in engine/bengali.py (T-301)."""
    starts = [
        (datetime.fromtimestamp(s, IST).date() + timedelta(days=1), idx)
        for idx, s, _ in sankranti_rows
    ]
    out = []
    for d in days(COVERS_FROM, COVERS_TO):
        month_start, month_idx = max((s for s in starts if s[0] <= d), key=lambda s: s[0])
        out.append((d, (d - month_start).days + 1, month_idx))
    return out


def lunar_months(tithis: list[tuple[int, int, int]]) -> list[tuple[int, int, int]]:
    """Amanta months bounded by the end of Amavasya (tithi idx 29). TODO(Q2)."""
    ends = [end for idx, _, end in tithis if idx == 29]
    month_idx = 4  # first boundary in the fixture range falls in Bhadra
    rows = []
    for a, b in itertools.pairwise(ends):
        rows.append((month_idx, a, b))
        month_idx = (month_idx + 1) % 12
    return rows


def city_day(lat: float, lon: float, d: date) -> tuple[int, int, int | None, int | None]:
    """Smooth synthetic rise/set times: plausible shape, not astronomy."""
    doy = d.timetuple().tm_yday
    season = math.cos(2 * math.pi * (doy - 172) / 365.25)  # +1 near June, -1 near December
    half_day = (12 + 1.4 * season * (lat / 23.0)) * 3600 / 2
    noon_ist = datetime(d.year, d.month, d.day, 12, 0, tzinfo=IST) - timedelta(
        minutes=(lon - 82.5) * 4
    )
    sunrise = ts(noon_ist) - int(half_day)
    sunset = ts(noon_ist) + int(half_day)
    lunar_age = (d - date(2026, 9, 1)).days % 30
    if lunar_age == 14:
        return sunrise, sunset, None, ts(noon_ist) - 5 * 3600  # one day a month without moonrise
    moonrise = sunrise + lunar_age * 50 * 60
    return sunrise, sunset, moonrise, moonrise + 12 * 3600 + 25 * 60


# ---------------------------------------------------------------- writing


def translit(entry: dict) -> str:
    if "translit" in entry:
        return entry["translit"]
    ascii_form = unicodedata.normalize("NFKD", entry["en"]).encode("ascii", "ignore").decode()
    return ascii_form.lower()


def load_names() -> dict[str, list[dict]]:
    data = tomllib.loads(NAMES_PATH.read_text(encoding="utf-8"))
    return {k: v for k, v in data.items() if isinstance(v, list)}


def new_pack(path: Path, pack_id: str, kind: str) -> sqlite3.Connection:
    path.unlink(missing_ok=True)
    conn = schema.connect(path)
    conn.execute(
        "INSERT INTO packs (id, tradition, kind, is_sample, covers_from, covers_to, version,"
        " generated_at, engine_version, validation_summary) VALUES (?, ?, ?, 1, ?, ?, 1, ?, ?, ?)",
        (
            pack_id,
            TRADITION,
            kind,
            COVERS_FROM.isoformat(),
            COVERS_TO.isoformat(),
            "2026-10-12T00:00:00Z",  # fixed, so output is reproducible
            ENGINE_VERSION,
            f"{SAMPLE_MARKER}: synthetic fixture data, not validated",
        ),
    )
    return conn


def write_global(path: Path) -> None:
    pid = "sample-global-drik"
    end = datetime.combine(COVERS_TO + timedelta(days=2), datetime.min.time(), UTC)
    tithis = series(TITHI_MEAN, 2.5 * 3600, 30, 0, SERIES_START, end)
    with new_pack(path, pid, "global") as conn:
        rows = {
            "tithi": tithis,
            "karana": karanas(tithis),
            "nakshatra": series(NAKSHATRA_MEAN, 2 * 3600, 27, 0, SERIES_START, end),
            "yoga": series(YOGA_MEAN, 1.5 * 3600, 27, 0, SERIES_START, end),
            "sankranti": sankrantis(end),
        }
        conn.executemany(
            "INSERT INTO transitions (pack_id, tradition, kind, idx, starts_utc, ends_utc)"
            " VALUES (?, ?, ?, ?, ?, ?)",
            [(pid, TRADITION, k, *r) for k, rs in rows.items() for r in rs],
        )
        conn.executemany(
            "INSERT INTO lunar_months VALUES (?, ?, 0, ?, ?, ?)",
            [(TRADITION, m, a, b, pid) for m, a, b in lunar_months(tithis)],
        )
        conn.executemany(
            "INSERT INTO bengali_dates VALUES (?, ?, ?, ?, ?, ?)",
            [
                (TRADITION, d.isoformat(), day, month, SAMPLE_BN_YEAR, pid)
                for d, day, month in bengali_dates(rows["sankranti"])
            ],
        )
        conn.executemany(
            "INSERT INTO names (kind, idx, name_bn, name_en, translit, pack_id)"
            " VALUES (?, ?, ?, ?, ?, ?)",
            [
                (kind, i, e["bn"], e["en"], translit(e), pid)
                for kind, entries in load_names().items()
                for i, e in enumerate(entries)
            ],
        )
    conn.close()


def write_cities(path: Path) -> None:
    pid = "sample-cities"
    with new_pack(path, pid, "cities") as conn:
        for cid, nbn, nen, aliases, dbn, den, lat, lon, popular in SAMPLE_CITIES:
            conn.execute(
                "INSERT INTO cities VALUES (?, ?, ?, ?, ?, ?, 'West Bengal', ?, ?, 0,"
                " 'Asia/Kolkata', ?, ?)",
                (cid, nbn, nen, aliases, dbn, den, lat, lon, popular, pid),
            )
            conn.executemany(
                "INSERT INTO city_days VALUES (?, ?, ?, ?, ?, ?, ?)",
                [
                    (cid, d.isoformat(), *city_day(lat, lon, d), pid)
                    for d in days(COVERS_FROM, COVERS_TO)
                ],
            )
    conn.close()


def write_observances(path: Path) -> None:
    pid = "sample-observances-drik"
    with new_pack(path, pid, "observances") as conn:
        for oid, nbn, nen, category, tier, day in SAMPLE_OBSERVANCES:
            conn.execute(
                "INSERT INTO observances VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                (oid, nbn, nen, category, tier, SAMPLE_DESC_BN, SAMPLE_DESC_EN, pid),
            )
            conn.execute(
                "INSERT INTO observance_dates (observance_id, tradition, date, status, pack_id)"
                " VALUES (?, ?, ?, 'sample', ?)",
                (oid, TRADITION, day, pid),
            )
        dates = {oid: day for oid, *_, day in SAMPLE_OBSERVANCES}
        conn.executemany(
            "INSERT INTO observance_windows VALUES (?, ?, ?, ?, ?, ?, ?)",
            [
                (oid, TRADITION, dates[oid], kind, ts(start), ts(start) + length, pid)
                for oid, kind, start, length in SAMPLE_WINDOWS
            ],
        )
    conn.close()


def build(out_dir: Path) -> list[Path]:
    assert_not_release()
    out_dir.mkdir(parents=True, exist_ok=True)
    paths = [
        out_dir / "sample-global.sqlite",
        out_dir / "sample-cities.sqlite",
        out_dir / "sample-observances.sqlite",
    ]
    write_global(paths[0])
    write_cities(paths[1])
    write_observances(paths[2])
    return paths


def main(argv: list[str] | None = None) -> int:
    argv = sys.argv[1:] if argv is None else argv
    assert_not_release(argv)
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--out", type=Path, default=Path("dist/sample"))
    args = parser.parse_args(argv)
    for p in build(args.out):
        print(f"wrote {p} (SAMPLE — not real calendar data)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
