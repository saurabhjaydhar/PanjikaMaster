"""Which ephemeris file the engine reads.

Production and CI read `ephem/de440s.bsp`, verified against `ephem/ephemeris.lock.json`
(T-201). For local work where JPL is unreachable, `PANJIKA_EPHEMERIS` may point at
another JPL kernel (e.g. DE421) so algorithm tests can run; the pack builder refuses
such a file (`require_locked=True`), so it can never reach a pack.
"""

import os
from pathlib import Path

from ephem import fetch

ENV = "PANJIKA_EPHEMERIS"


class EphemerisUnavailable(RuntimeError):
    pass


def resolve(*, require_locked: bool = False) -> Path:
    """The ephemeris path. Raises EphemerisUnavailable if there is none to use."""
    override = os.environ.get(ENV)
    if override and not require_locked:
        path = Path(override)
        if not path.exists():
            raise EphemerisUnavailable(f"{ENV}={override} does not exist")
        return path
    try:
        return fetch.fetch(check_only=True)
    except fetch.EphemerisError as e:
        raise EphemerisUnavailable(str(e)) from e


def is_locked(path: Path) -> bool:
    """True if [path] is the lock-verified DE440s."""
    lock = fetch.load_lock()
    return path.resolve() == fetch.ephemeris_path(lock).resolve()
