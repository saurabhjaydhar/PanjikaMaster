"""Sun/Moon table for rise and set on the phone (spec §6.5.5, T-314).

The phone computes sunrise, sunset, moonrise and moonset for any coordinates. It runs no
astronomy library: it reads the positions the pipeline computed, stored here as one
row per IST civil day. Each row holds, for that day [IST midnight, +86,400 s), the
Chebyshev coefficients of:

* the Sun's and the Moon's apparent geocentric right ascension and declination (radians,
  true equator and equinox of date, without light deflection, as `riseset.py`'s Skyfield
  search uses them) and distance (km), and
* Greenwich apparent sidereal time (radians),

with the day mapped to x ∈ [−1, 1]. Right ascension and sidereal time are continuous
within a row (not wrapped to 2π), so the polynomials stay smooth. Coefficients are stored
as little-endian float64 blobs; the degree is `len(blob) / 8 − 1`. The phone adds the
observer's position (WGS84) and the horizon of `riseset.py` itself.

Degrees are chosen for accuracy with a wide margin: over 2020–2045 the rebuilt positions
differ from Skyfield by under 0.0001″ (target: 1″ Sun, 2″ Moon), at about 106 KB a year.
"""

from dataclasses import dataclass
from datetime import date, timedelta

import numpy as np
from numpy.polynomial import chebyshev

from engine.astro import DAY, Astro
from engine.riseset import IST_OFFSET

SUN_DEGREE = 3
MOON_DEGREE = 6
GAST_DEGREE = 3

FIELDS = ("sun_ra", "sun_dec", "sun_dist", "moon_ra", "moon_dec", "moon_dist", "gast")


@dataclass(frozen=True)
class Row:
    date: date
    start_utc: int  # IST midnight of `date`
    coefficients: dict[str, np.ndarray]  # FIELDS → Chebyshev coefficients, lowest first

    def blobs(self) -> tuple[bytes, ...]:
        return tuple(to_blob(self.coefficients[f]) for f in FIELDS)


def to_blob(coefficients: np.ndarray) -> bytes:
    return np.asarray(coefficients, dtype="<f8").tobytes()


def from_blob(blob: bytes) -> np.ndarray:
    return np.frombuffer(blob, dtype="<f8")


def nodes(degree: int) -> np.ndarray:
    """Chebyshev points of the first kind on [−1, 1], ascending (so in time order)."""
    n = degree + 1
    return -np.cos(np.pi * (np.arange(n) + 0.5) / n)


def ist_midnight(d: date) -> int:
    return (d - date(1970, 1, 1)).days * DAY - IST_OFFSET


def value(coefficients: np.ndarray, start_utc: int, unix_seconds) -> np.ndarray:
    """Evaluate one row's polynomial at Unix seconds inside its day."""
    x = 2 * (np.asarray(unix_seconds, dtype=float) - start_utc) / DAY - 1
    return chebyshev.chebval(x, coefficients)


def rows(astro: Astro, first: date, last: date) -> list[Row]:
    """One row per IST day in [first, last]."""
    days = [first + timedelta(days=i) for i in range((last - first).days + 1)]
    starts = np.array([ist_midnight(d) for d in days], dtype=float)
    fits: dict[str, np.ndarray] = {}
    for prefix, body, degree in (
        ("sun", astro._sun, SUN_DEGREE),
        ("moon", astro._moon, MOON_DEGREE),
    ):
        x = nodes(degree)
        t = astro.time((starts[:, None] + (x + 1) / 2 * DAY).ravel())
        ra, dec, dist = astro._earth.at(t).observe(body).apparent(()).radec("date")
        shape = (len(days), degree + 1)
        values = {
            "ra": np.unwrap(ra.radians.reshape(shape), axis=1),
            "dec": dec.radians.reshape(shape),
            "dist": dist.km.reshape(shape),
        }
        for name, v in values.items():
            fits[f"{prefix}_{name}"] = chebyshev.chebfit(x, v.T, degree).T
    x = nodes(GAST_DEGREE)
    t = astro.time((starts[:, None] + (x + 1) / 2 * DAY).ravel())
    gast = np.unwrap((t.gast / 24 * 2 * np.pi).reshape(len(days), GAST_DEGREE + 1), axis=1)
    fits["gast"] = chebyshev.chebfit(x, gast.T, GAST_DEGREE).T
    return [Row(d, int(starts[i]), {f: fits[f][i] for f in FIELDS}) for i, d in enumerate(days)]
