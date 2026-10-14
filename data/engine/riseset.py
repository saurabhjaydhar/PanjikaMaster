"""Sunrise, sunset, moonrise and moonset for a place (spec §6.5.5, T-206).

Days are IST civil dates (00:00–24:00 IST), as in `city_days`. Elevation is ignored
(spec §6.5.5). Times are integer Unix seconds UTC; a missing moonrise/moonset that day
is None ("চন্দ্রোদয় নেই", spec §16).
"""

from dataclasses import dataclass
from datetime import date, timedelta
from enum import Enum

import numpy as np
from skyfield import almanac
from skyfield.api import wgs84

from engine.astro import DAY, Astro

IST_OFFSET = 19_800  # +05:30


class SunriseDefinition(Enum):
    """Which point of the Sun counts (Q3). Both include 34′ of standard refraction."""

    UPPER_LIMB = None  # Skyfield's default: refraction + the Sun's apparent radius (−0.833°)
    CENTRE = -34 / 60


# TODO(Q3): the reference panjika's definition decides this; upper limb until validated.
SUNRISE_DEFINITION = SunriseDefinition.UPPER_LIMB


@dataclass(frozen=True)
class CityDay:
    date: date
    sunrise: int
    sunset: int
    moonrise: int | None
    moonset: int | None


def _ist_midnight(d: date) -> int:
    return (d - date(1970, 1, 1)).days * DAY - IST_OFFSET


def _unix(times) -> np.ndarray:
    return np.array([round(t.utc_datetime().timestamp()) for t in times], dtype=np.int64)


def _events(astro, place, body, start, end, rising, horizon):
    find = almanac.find_risings if rising else almanac.find_settings
    t, real = find(place, body, astro.time(start), astro.time(end), horizon_degrees=horizon)
    return _unix(t[real]) if len(t) else np.array([], dtype=np.int64)


@dataclass(frozen=True)
class DayEvents:
    """The first of each event inside one IST day; None when there is none. Far from
    IST (e.g. west of about 8° E) a sunset can fall outside the IST day (Q16)."""

    date: date
    sunrise: int | None
    sunset: int | None
    moonrise: int | None
    moonset: int | None


def day_events(
    astro: Astro,
    lat: float,
    lon: float,
    first: date,
    last: date,
    definition: SunriseDefinition = SUNRISE_DEFINITION,
) -> list[DayEvents]:
    """One row per IST date in [first, last], every event optional. The reference for
    the phone's own rise/set computation (§6.5.5, T-315)."""
    place = astro._earth + wgs84.latlon(lat, lon)
    start = _ist_midnight(first)
    end = _ist_midnight(last + timedelta(days=1))
    sun, moon = astro._sun, astro._moon
    events = {
        "sunrise": _events(astro, place, sun, start, end, True, definition.value),
        "sunset": _events(astro, place, sun, start, end, False, definition.value),
        "moonrise": _events(astro, place, moon, start, end, True, None),
        "moonset": _events(astro, place, moon, start, end, False, None),
    }

    def on(name, day_start):
        e = events[name]
        hit = e[(e >= day_start) & (e < day_start + DAY)]
        return int(hit[0]) if len(hit) else None

    out = []
    d = first
    while d <= last:
        s = _ist_midnight(d)
        out.append(DayEvents(d, *(on(n, s) for n in events)))
        d += timedelta(days=1)
    return out


def city_days(
    astro: Astro,
    lat: float,
    lon: float,
    first: date,
    last: date,
    definition: SunriseDefinition = SUNRISE_DEFINITION,
) -> list[CityDay]:
    """One row per IST date in [first, last]; sunrise and sunset are required."""
    out = []
    for e in day_events(astro, lat, lon, first, last, definition):
        if e.sunrise is None or e.sunset is None:
            raise ValueError(f"no sunrise or sunset at ({lat}, {lon}) on {e.date}")
        out.append(CityDay(e.date, e.sunrise, e.sunset, e.moonrise, e.moonset))
    return out
