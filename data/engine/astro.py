"""Apparent geocentric Sun and Moon longitudes (spec §6.4, §6.5), via Skyfield and a JPL
ephemeris. Longitudes are tropical, on the true ecliptic and equinox of date; sidereal
values subtract the ayanamsa (ayanamsa.py). Times are Unix seconds UTC, as in the packs.
"""

from functools import cached_property
from pathlib import Path

import numpy as np
from skyfield.api import load, load_file
from skyfield.framelib import ecliptic_frame

DAY = 86_400


class Astro:
    def __init__(self, ephemeris: Path):
        self.ephemeris = ephemeris
        self._eph = load_file(str(ephemeris))
        self._earth = self._eph["earth"]
        self._sun = self._eph["sun"]
        self._moon = self._eph["moon"]

    @cached_property
    def ts(self):
        # Leap seconds and ΔT ship with Skyfield: no download, reproducible builds.
        return load.timescale(builtin=True)

    def time(self, unix_seconds):
        """Skyfield Time for Unix seconds (scalar or array).

        Unix time has 86,400 s in every day (no leap seconds), so it is split into whole
        days plus seconds of that day. Passing the full count as seconds would make
        Skyfield treat it as elapsed SI seconds and land 27 s early since 2017.
        """
        days, rem = np.divmod(np.asarray(unix_seconds, dtype=float), DAY)
        return self.ts.utc(1970, 1, 1 + days.astype(int), 0, 0, rem)

    def _longitude(self, body, unix_seconds) -> np.ndarray:
        t = self.time(unix_seconds)
        apparent = self._earth.at(t).observe(body).apparent()
        _, lon, _ = apparent.frame_latlon(ecliptic_frame)
        return lon.degrees

    def sun_longitude(self, unix_seconds) -> np.ndarray:
        """Apparent tropical ecliptic longitude of the Sun, degrees in [0, 360)."""
        return self._longitude(self._sun, unix_seconds)

    def moon_longitude(self, unix_seconds) -> np.ndarray:
        """Apparent tropical ecliptic longitude of the Moon, degrees in [0, 360)."""
        return self._longitude(self._moon, unix_seconds)

    def elongation(self, unix_seconds) -> np.ndarray:
        """(λ_moon − λ_sun) mod 360°: tithi and karana (spec §6.5.1, §6.5.4). The same in
        tropical and sidereal terms, so it needs no ayanamsa."""
        return (self.moon_longitude(unix_seconds) - self.sun_longitude(unix_seconds)) % 360
