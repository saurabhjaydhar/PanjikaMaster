"""`python -m engine build --from YYYY-MM-DD --to YYYY-MM-DD` (spec §6.4 step 1, T-207).

Computes L0–L1 for a date range (tithi, nakshatra, yoga, karana and sankranti
transitions) and writes a schema-conformant SQLite file with the names and one `packs`
row. Run metadata (library versions, ephemeris checksum, models, row counts) goes in
`packs.validation_summary`; the wall-clock time goes in a separate `.run.json`, so the
database itself is byte-for-byte reproducible.

Rows start unvalidated: the validation harness and pack builder (Phase 3) decide what
ships. Bengali dates (Q4) and lunar months (Q2) are added in T-301.
"""

import argparse
import importlib.metadata
import json
import os
import platform
import sqlite3
import sys
import time
from datetime import UTC, date, datetime, timedelta
from pathlib import Path

import engine
from engine import ephemeris
from engine.astro import Astro
from engine.panchanga import KINDS, search_in_chunks
from engine.riseset import IST_OFFSET, SUNRISE_DEFINITION
from ephem import fetch
from pack import names, schema

TRADITIONS = ("drik_bishuddha",)  # Surya Siddhanta needs its own engine (out of scope)
LIBRARIES = ("skyfield", "jplephem", "numpy")


def ist_midnight(d: date) -> int:
    return (d - date(1970, 1, 1)).days * 86_400 - IST_OFFSET


def generated_at() -> str:
    """SOURCE_DATE_EPOCH if set (reproducible builds), else now."""
    epoch = os.environ.get("SOURCE_DATE_EPOCH")
    when = datetime.fromtimestamp(int(epoch), UTC) if epoch else datetime.now(UTC)
    return when.strftime("%Y-%m-%dT%H:%M:%SZ")


def metadata(path: Path, *, dev: bool, counts: dict[str, int]) -> dict:
    lock = fetch.load_lock()
    return {
        "status": "computed, not validated",
        "engine_version": engine.__version__,
        "python": platform.python_version(),
        "libraries": {lib: importlib.metadata.version(lib) for lib in LIBRARIES},
        "ephemeris": {
            "file": path.name,
            "sha256": fetch.sha256_file(path),
            "locked": not dev,
            "confirmed_by_human": bool(lock.get("confirmed_by")) and not dev,
        },
        "models": {
            "positions": "apparent geocentric, true ecliptic and equinox of date",
            "ayanamsa": "Lahiri: 23°15′00.658″ at 1956-03-21 0h TT + IAU 2006 p_A; true = + Δψ",
            "nutation": "IAU 2000B (ayanamsa); IAU 2000A (Skyfield frames)",
            "sunrise": SUNRISE_DEFINITION.name,  # TODO(Q3)
        },
        "names_status": names.status(),
        "rows": counts,
    }


def build(
    first: date,
    last: date,
    out_dir: Path,
    *,
    tradition: str = "drik_bishuddha",
    version: int = 1,
    dev: bool = False,
) -> Path:
    """Writes `<out_dir>/<pack id>.sqlite` and its `.run.json`; returns the database path."""
    if tradition not in TRADITIONS:
        raise ValueError(f"unsupported tradition {tradition!r}")
    if last < first:
        raise ValueError("--to is before --from")
    began = time.perf_counter()
    eph = ephemeris.resolve(require_locked=not dev)
    if dev and ephemeris.is_locked(eph):
        dev = False  # the real kernel, even when asked for dev mode
    astro = Astro(eph)
    start, end = ist_midnight(first), ist_midnight(last + timedelta(days=1))

    pack_id = f"global-{tradition}-{first.isoformat()}-{last.isoformat()}-v{version}"
    rows = []
    for kind in KINDS:
        rows += [
            (pack_id, tradition, kind, s.idx, s.start, s.end)
            for s in search_in_chunks(kind, astro, start, end)
        ]
    counts = {kind: sum(1 for r in rows if r[2] == kind) for kind in KINDS}

    out_dir.mkdir(parents=True, exist_ok=True)
    path = out_dir / f"{pack_id}.sqlite"
    path.unlink(missing_ok=True)
    conn = schema.connect(path)
    with conn:
        conn.execute(
            "INSERT INTO packs (id, tradition, kind, is_sample, covers_from, covers_to,"
            " version, generated_at, engine_version, ephemeris_sha256, validation_summary)"
            " VALUES (?, ?, 'global', 0, ?, ?, ?, ?, ?, ?, ?)",
            (
                pack_id,
                tradition,
                first.isoformat(),
                last.isoformat(),
                version,
                generated_at(),
                engine.__version__ + ("+dev-ephemeris" if dev else ""),
                None if dev else fetch.sha256_file(eph),
                json.dumps(
                    metadata(eph, dev=dev, counts=counts), ensure_ascii=False, sort_keys=True
                ),
            ),
        )
        conn.executemany(
            "INSERT INTO transitions (pack_id, tradition, kind, idx, starts_utc, ends_utc)"
            " VALUES (?, ?, ?, ?, ?, ?)",
            sorted(rows, key=lambda r: (r[2], r[4])),
        )
        conn.executemany("INSERT INTO names VALUES (?, ?, ?, ?, ?, ?, ?, ?)", names.rows(pack_id))
    conn.execute("VACUUM")  # canonical page layout
    conn.close()

    run = {"pack": path.name, "seconds": round(time.perf_counter() - began, 1), "rows": counts}
    path.with_suffix(".run.json").write_text(json.dumps(run, indent=2) + "\n", encoding="utf-8")
    return path


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="python -m engine")
    sub = parser.add_subparsers(dest="command", required=True)
    b = sub.add_parser("build", help="compute transitions for a date range")
    b.add_argument("--from", dest="first", type=date.fromisoformat, required=True)
    b.add_argument("--to", dest="last", type=date.fromisoformat, required=True)
    b.add_argument("--out", type=Path, default=Path("dist"))
    b.add_argument("--tradition", default="drik_bishuddha", choices=TRADITIONS)
    b.add_argument("--version", type=int, default=1)
    b.add_argument(
        "--dev",
        action="store_true",
        help=f"allow ${ephemeris.ENV} (local testing; marked and never packable)",
    )
    args = parser.parse_args(argv)
    try:
        path = build(
            args.first,
            args.last,
            args.out,
            tradition=args.tradition,
            version=args.version,
            dev=args.dev,
        )
    except (ephemeris.EphemerisUnavailable, ValueError, sqlite3.Error) as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1
    run = json.loads(path.with_suffix(".run.json").read_text(encoding="utf-8"))
    print(f"wrote {path} in {run['seconds']} s: {run['rows']}")
    return 0
