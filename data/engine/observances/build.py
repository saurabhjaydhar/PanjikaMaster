"""Builds an observances pack: the rules evaluated for one tradition over a date range
at the reference place (spec §6.6, §15).

`python -m engine observances --from 2026-04-14 --to 2027-04-14 --ref-lat … --ref-lon …`

The reference place is an explicit argument until Q1 says which place Bishuddha
Siddhanta decides festivals for; it is recorded in the pack. Each rule's review status
and the moments' review status go into `validation_summary`, and the pack builder
refuses a release while any of them is a draft (T-502).
"""

from __future__ import annotations

import json
from datetime import date, timedelta
from itertools import pairwise
from pathlib import Path

from pack import schema

from .. import __version__, bengali, ephemeris, riseset
from ..astro import Astro
from ..panchanga import search_in_chunks
from ..solar import sankrantis
from .engine import Almanac, Day, evaluate
from .rules import load_moments, load_rules

DATA = Path(__file__).resolve().parents[2]
RULES_DIR = DATA / "observances"
MOMENTS = DATA / "content" / "moments.toml"

DAY = 86_400
MARGIN_DAYS = 40  # whole lunar months and Bengali months either side of the range


class MissingContent(ValueError):
    """A rule lacks something the pack schema requires (e.g. its descriptions, T-504)."""


def almanac(
    astro: Astro, tradition: str, first: date, last: date, lat: float, lon: float
) -> Almanac:
    """Everything the rules read, computed with margins around [first, last]."""
    lo, hi = first - timedelta(days=MARGIN_DAYS), last + timedelta(days=MARGIN_DAYS)
    start, end = bengali.ist_midnight(lo), bengali.ist_midnight(hi + timedelta(days=1))
    tithis = search_in_chunks("tithi", astro, start - 31 * DAY, end + 31 * DAY)
    months = bengali.lunar_months(tithis, lambda t: int(float(astro.sun_sidereal(t)) // 30))
    found = sankrantis(astro, start - 40 * DAY, end + 40 * DAY)
    dates = bengali.bengali_dates(found, lo, hi)
    city = riseset.city_days(astro, lat, lon, lo, hi + timedelta(days=1))
    days = tuple(Day(a.date, a.sunrise, a.sunset, b.sunrise) for a, b in pairwise(city))
    return Almanac(
        tradition=tradition,
        days=days,
        tithis=tuple(tithis),
        lunar_months=tuple(months),
        bengali={d.date: d for d in dates},
        first=first,
        last=last,
    )


def build(
    first: date,
    last: date,
    out_dir: Path,
    *,
    ref_lat: float,
    ref_lon: float,
    tradition: str = "drik_bishuddha",
    version: int = 1,
    dev: bool = False,
    rules_dir: Path = RULES_DIR,
    moments_path: Path = MOMENTS,
    generated_at: str,
) -> Path:
    rules = [r for r in load_rules(rules_dir) if tradition in r.traditions]
    lacking = [r.id for r in rules if r.description_bn is None]
    if lacking:
        raise MissingContent(f"no descriptions yet (T-504): {', '.join(lacking)}")
    moments = load_moments(moments_path)
    eph = ephemeris.resolve(require_locked=not dev)
    if dev and ephemeris.is_locked(eph):
        dev = False
    astro = Astro(eph)
    rows = evaluate(rules, almanac(astro, tradition, first, last, ref_lat, ref_lon), moments)

    pack_id = f"observances-{tradition}-{first.isoformat()}-{last.isoformat()}-v{version}"
    summary = {
        "status": "computed, not validated",
        "engine_version": __version__,
        "reference_place": {"lat": ref_lat, "lon": ref_lon, "note": "TODO(Q1)"},
        "moments_review": moments.review,
        "rules": {r.id: r.review.status for r in rules},
        "draft_rules": sorted(r.id for r in rules if r.review.status == "draft"),
        "dev_ephemeris": dev,
    }

    out_dir.mkdir(parents=True, exist_ok=True)
    path = out_dir / f"{pack_id}.sqlite"
    path.unlink(missing_ok=True)
    conn = schema.connect(path)
    with conn:
        conn.execute(
            "INSERT INTO packs (id, tradition, kind, is_sample, covers_from, covers_to,"
            " version, generated_at, engine_version, ephemeris_sha256, validation_summary)"
            " VALUES (?, ?, 'observances', 0, ?, ?, ?, ?, ?, NULL, ?)",
            (
                pack_id,
                tradition,
                first.isoformat(),
                last.isoformat(),
                version,
                generated_at,
                __version__ + ("+dev-ephemeris" if dev else ""),
                json.dumps(summary, ensure_ascii=False, sort_keys=True),
            ),
        )
        conn.executemany(
            "INSERT INTO observances VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
            [
                (r.id, r.name_bn, r.name_en, r.category, r.tier, r.description_bn,
                 r.description_en, pack_id)
                for r in rules
            ],
        )  # fmt: skip
        conn.executemany(
            "INSERT INTO observance_dates (observance_id, tradition, date, day_index, status,"
            " note_bn, note_en, pack_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
            [
                (r.observance_id, r.tradition, r.date.isoformat(), r.day_index, r.status,
                 r.note_bn, r.note_en, pack_id)
                for r in rows
            ],
        )  # fmt: skip
        conn.executemany(
            "INSERT INTO observance_windows VALUES (?, ?, ?, ?, ?, ?, ?)",
            [
                (r.observance_id, r.tradition, r.date.isoformat(), w.kind, w.start, w.end, pack_id)
                for r in rows
                for w in r.windows
            ],
        )
    conn.execute("VACUUM")
    conn.close()
    return path
