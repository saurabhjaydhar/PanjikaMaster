"""Lahiri (Chitrapaksha) ayanamsa (spec §6.5, T-203).

Definition: the mean ayanamsa was 23°15′00.658″ at 1956 March 21, 0h ET (taken here as
TT), as adopted on the Calendar Reform Committee's recommendation (Govt. of India, 1955)
and used by the Indian Astronomical Ephemeris and the Rashtriya Panchang. From that
epoch it grows with the general precession in longitude, p_A, for which we use the IAU
2006 expression (Capitaine, Wallace & Chapront 2003; IERS Conventions 2010, eq. 5.39).
The true ayanamsa adds the nutation in longitude Δψ (IAU 2000B: within 1 mas of 2000A
over 1995–2050 and twenty times faster, so the scans stay cheap).

Sidereal longitude = apparent tropical longitude − true ayanamsa: both refer to the true
equinox of date, so nutation cancels and the result is star-fixed.

Status: implemented from the published definition; validated against the reference
values in `reference/ayanamsa.csv` once the human has entered them (T-203 gate).
"""

import numpy as np
from skyfield.nutationlib import iau2000b_radians

EPOCH_JD_TT = 2435553.5  # 1956-03-21 00:00 TT
EPOCH_VALUE_ARCSEC = 23 * 3600 + 15 * 60 + 0.658
J2000 = 2451545.0
ARCSEC_PER_RAD = 180 * 3600 / np.pi


def general_precession_arcsec(jd_tt) -> np.ndarray:
    """p_A, IAU 2006: accumulated precession in longitude since J2000, arcseconds."""
    t = (np.asarray(jd_tt, dtype=float) - J2000) / 36525
    return t * (
        5028.796195 + t * (1.1054348 + t * (0.00007964 + t * (-0.000023857 + t * -0.0000000383)))
    )


def mean_ayanamsa(jd_tt) -> np.ndarray:
    """Mean Lahiri ayanamsa in degrees."""
    arcsec = (
        EPOCH_VALUE_ARCSEC
        + general_precession_arcsec(jd_tt)
        - general_precession_arcsec(EPOCH_JD_TT)
    )
    return arcsec / 3600


def true_ayanamsa(t) -> np.ndarray:
    """True Lahiri ayanamsa in degrees for a Skyfield Time: mean + Δψ."""
    dpsi, _ = iau2000b_radians(t)
    return mean_ayanamsa(t.tt) + dpsi * ARCSEC_PER_RAD / 3600
