"""Shared rise/set fixture (spec §6.5.5, T-315).

The phone computes sunrise, sunset, moonrise and moonset itself, from the global pack's
`body_positions` table (T-317). This fixture is how both sides are kept in step: for
about 40 places worldwide and 24 days spread over 2020–2043 it holds

* the pipeline's events (`riseset.day_events`, the reference), and
* the `body_positions` rows for those days and the day after,

so the app's test can recompute every event from the rows and compare (±5 s Sun,
±10 s Moon). Written to `app/test/fixtures/riseset.json` by
`scripts/gen_riseset_fixture.py`; `--check` in ci-data compares it with a fresh build.

The places are test inputs only: approximate public coordinates, not the app's place
list (that source is Q13). They cover West Bengal, the rest of India, Bengali
communities abroad, both hemispheres, the date line, and ±60° (the app's limit).
"""

from datetime import date, timedelta

from engine import positions, riseset
from engine.astro import Astro

FORMAT = 1

PLACES = {
    # West Bengal
    "kolkata": (22.5726, 88.3639),
    "howrah": (22.5958, 88.2636),
    "bardhaman": (23.2324, 87.8615),
    "siliguri": (26.7271, 88.3953),
    "darjeeling": (27.0410, 88.2663),
    "digha": (21.6266, 87.5074),
    # Rest of India
    "nainital": (29.3803, 79.4636),
    "delhi": (28.6139, 77.2090),
    "mumbai": (19.0760, 72.8777),
    "ahmedabad": (23.0225, 72.5714),
    "chennai": (13.0827, 80.2707),
    "bengaluru": (12.9716, 77.5946),
    "kanyakumari": (8.0883, 77.5385),
    "guwahati": (26.1445, 91.7362),
    "agartala": (23.8315, 91.2868),
    "port_blair": (11.6234, 92.7265),
    "leh": (34.1526, 77.5771),
    # Abroad
    "dhaka": (23.8103, 90.4125),
    "kathmandu": (27.7172, 85.3240),
    "dubai": (25.2048, 55.2708),
    "singapore": (1.3521, 103.8198),
    "tokyo": (35.6762, 139.6503),
    "sydney": (-33.8688, 151.2093),
    "auckland": (-36.8485, 174.7633),
    "london": (51.5074, -0.1278),
    "stockholm": (59.3293, 18.0686),
    "oslo": (59.9139, 10.7522),
    "moscow": (55.7558, 37.6173),
    "nairobi": (-1.2921, 36.8219),
    "johannesburg": (-26.2041, 28.0473),
    "toronto": (43.6532, -79.3832),
    "new_york": (40.7128, -74.0060),
    "san_francisco": (37.7749, -122.4194),
    "honolulu": (21.3069, -157.8583),
    "apia": (-13.8333, -171.7500),
    "sao_paulo": (-23.5505, -46.6333),
    "buenos_aires": (-34.6037, -58.3816),
    # Synthetic edges: the equator, and the ±60° limit (FR-LOC-07)
    "equator_0e": (0.0, 0.0),
    "edge_60n": (60.0, 25.0),
    "edge_60s": (-60.0, -65.0),
}

# 24 days, one per year 2020–2043, cycling through the months and days of the month.
DAYS = [date(2020 + k, k % 12 + 1, 1 + (7 * k) % 28) for k in range(24)]

EVENTS = ("sunrise", "sunset", "moonrise", "moonset")


def build(astro: Astro, ephemeris_sha256: str) -> dict:
    rows = {}
    for d in DAYS:
        for r in positions.rows(astro, d, d + timedelta(days=1)):
            rows[r.date.isoformat()] = {
                "start_utc": r.start_utc,
                **{f: [float(c) for c in r.coefficients[f]] for f in positions.FIELDS},
            }
    expected = {}
    for name, (lat, lon) in PLACES.items():
        expected[name] = {}
        for d in DAYS:
            (e,) = riseset.day_events(astro, lat, lon, d, d)
            expected[name][d.isoformat()] = [getattr(e, k) for k in EVENTS]
    return {
        "format": FORMAT,
        "note": "TEST FIXTURE (T-315): approximate coordinates; IST days; times in Unix s",
        "sunrise_definition": riseset.SUNRISE_DEFINITION.name,  # TODO(Q3)
        "ephemeris_sha256": ephemeris_sha256,
        "events": list(EVENTS),
        "places": {n: {"lat": lat, "lon": lon} for n, (lat, lon) in PLACES.items()},
        "days": [d.isoformat() for d in DAYS],
        "body_positions": rows,
        "expected": expected,
    }


def differences(committed: dict, fresh: dict) -> list[str]:
    """What differs beyond rounding: events by more than 1 s, coefficients by more than
    1e-9 relative (so a build on another platform still passes)."""
    out = []
    for key in ("format", "sunrise_definition", "ephemeris_sha256", "events", "places", "days"):
        if committed.get(key) != fresh[key]:
            out.append(f"{key} differs")
    if set(committed.get("body_positions", {})) != set(fresh["body_positions"]):
        out.append("body_positions dates differ")
    else:
        for day, row in fresh["body_positions"].items():
            old = committed["body_positions"][day]
            for field, values in row.items():
                if field == "start_utc":
                    ok = old[field] == values
                else:
                    ok = len(old[field]) == len(values) and all(
                        abs(a - b) <= 1e-9 * max(1.0, abs(b))
                        for a, b in zip(old[field], values, strict=True)
                    )
                if not ok:
                    out.append(f"body_positions {day} {field} differs")
    for place, days in fresh["expected"].items():
        for day, events in days.items():
            old = committed.get("expected", {}).get(place, {}).get(day)
            if old is None or any(
                (a is None) != (b is None) or (a is not None and abs(a - b) > 1)
                for a, b in zip(old, events, strict=True)
            ):
                out.append(f"expected {place} {day} differs")
    return out
