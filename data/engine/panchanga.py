"""Tithi, nakshatra, yoga and karana transitions (spec §6.5.1–6.5.4, T-204).

Each kind is an angle that grows steadily and is cut into equal steps. The search
samples the angle every hour, finds where the step index changes, and bisects each
bracket to well under a second (vectorised over all brackets at once). Times are
integer Unix seconds, so the same inputs always give the same output.
"""

from collections.abc import Callable
from dataclasses import dataclass

import numpy as np

from engine.astro import Astro

HOUR = 3600
DAY = 86_400
SCAN = HOUR
# Bracket width after bisection: 3600 / 2**13 ≈ 0.44 s, then rounded to the second.
BISECT_STEPS = 13
# Longest span of any kind is under 28 h; two days of margin catch spans overlapping
# the requested range on both sides.
PAD = 2 * DAY


@dataclass(frozen=True)
class Kind:
    name: str
    count: int
    angle: Callable[[Astro, np.ndarray], np.ndarray]

    @property
    def step(self) -> float:
        return 360 / self.count


KINDS = {
    "tithi": Kind("tithi", 30, lambda a, t: a.elongation(t)),
    "karana": Kind("karana", 60, lambda a, t: a.elongation(t)),
    "nakshatra": Kind("nakshatra", 27, lambda a, t: a.moon_sidereal(t)),
    "yoga": Kind("yoga", 27, lambda a, t: a.yoga_angle(t)),
}


@dataclass(frozen=True, order=True)
class Span:
    start: int  # Unix seconds UTC, inclusive
    end: int  # exclusive
    idx: int  # 0-based (spec §15.1)
    kind: str


class SearchError(RuntimeError):
    pass


def _index(kind: Kind, astro: Astro, t: np.ndarray) -> np.ndarray:
    return np.floor(kind.angle(astro, t) / kind.step).astype(int) % kind.count


def crossings(kind: Kind, astro: Astro, start: int, end: int) -> tuple[np.ndarray, np.ndarray]:
    """Instants in [start, end] where the index changes, and the index that begins.

    The grid sits on whole hours (Unix time), so a given crossing is always bracketed
    and bisected the same way, whatever range was asked for: results are identical
    across overlapping queries and chunks.
    """
    first = (start // SCAN) * SCAN
    grid = np.arange(first, end + SCAN, SCAN, dtype=float)
    idx = _index(kind, astro, grid)
    at = np.nonzero(idx[1:] != idx[:-1])[0]
    if not len(at):
        return np.array([], dtype=np.int64), np.array([], dtype=int)
    new = idx[at + 1]
    jumps = (new - idx[at]) % kind.count
    if np.any(jumps != 1):
        raise SearchError(f"{kind.name}: index skipped within one scan step")
    lo, hi = grid[at], grid[at + 1]
    before = idx[at]
    for _ in range(BISECT_STEPS):
        mid = (lo + hi) / 2
        still = _index(kind, astro, mid) == before
        lo = np.where(still, mid, lo)
        hi = np.where(still, hi, mid)
    return np.round((lo + hi) / 2).astype(np.int64), new


def spans(kind_name: str, astro: Astro, start: int, end: int) -> list[Span]:
    """Every span of [kind_name] overlapping [start, end), in order."""
    kind = KINDS[kind_name]
    times, idx = crossings(kind, astro, start - PAD, end + PAD)
    out = [
        Span(int(a), int(b), int(i), kind_name)
        for a, b, i in zip(times[:-1], times[1:], idx[:-1], strict=True)
        if b > start and a < end
    ]
    if not out or out[0].start > start or out[-1].end < end:
        raise SearchError(f"{kind_name}: spans do not cover the requested range")
    return out


def search_in_chunks(kind_name: str, astro: Astro, start: int, end: int, chunk: int = 366 * DAY):
    """[spans] for long ranges, one chunk at a time to bound memory; spans cut by a
    chunk edge appear once."""
    out: list[Span] = []
    t = start
    while t < end:
        part = spans(kind_name, astro, t, min(t + chunk, end))
        out.extend(s for s in part if not out or s.start >= out[-1].end)
        t += chunk
    return out
