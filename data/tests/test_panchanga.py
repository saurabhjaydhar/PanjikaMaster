"""T-204: tithi, nakshatra, yoga and karana transitions.

Properties over random windows in 2020–2045 (Hypothesis): no gaps or overlaps,
indices cycle, physical span lengths, each transition lies on its boundary to within
a second of motion, and karanas halve tithis. Plus a full-year count and determinism.
"""

from datetime import UTC, datetime
from itertools import pairwise

import numpy as np
from hypothesis import given, settings
from hypothesis import strategies as st

from engine.panchanga import DAY, HOUR, KINDS, search_in_chunks, spans

START = int(datetime(2020, 1, 1, tzinfo=UTC).timestamp())
END = int(datetime(2046, 1, 1, tzinfo=UTC).timestamp())

# Span lengths in hours: spec §6.5.1 for tithi; the others follow from the Moon's
# (and Sun's) speed range, with margin.
LENGTH_H = {"tithi": (19, 27), "karana": (9, 14), "nakshatra": (19, 29), "yoga": (18, 27)}

windows = st.tuples(st.integers(START, END - 12 * DAY), st.integers(2, 10))


def all_kinds(astro, start, end):
    return {k: spans(k, astro, start, end) for k in KINDS}


@settings(max_examples=15, deadline=None)
@given(windows)
def test_contiguous_cyclic_and_physical(astro, window):
    t0, days = window
    t1 = t0 + days * DAY
    for kind, ss in all_kinds(astro, t0, t1).items():
        n = KINDS[kind].count
        assert ss[0].start <= t0 < ss[0].end and ss[-1].start < t1 <= ss[-1].end, kind
        lo, hi = LENGTH_H[kind]
        for a, b in pairwise(ss):
            assert b.start == a.end, f"{kind}: gap or overlap at {a.end}"
            assert b.idx == (a.idx + 1) % n, f"{kind}: {a.idx} → {b.idx}"
        for s in ss[1:-1]:  # the ends may be cut by the margin only if very long
            assert lo * HOUR <= s.end - s.start <= hi * HOUR, (kind, s)


@settings(max_examples=10, deadline=None)
@given(windows)
def test_transitions_lie_on_their_boundary(astro, window):
    t0, days = window
    for kind, ss in all_kinds(astro, t0, t0 + days * DAY).items():
        k = KINDS[kind]
        times = np.array([s.start for s in ss[1:]], dtype=float)
        expected = np.array([s.idx * k.step for s in ss[1:]])
        diff = (k.angle(astro, times) - expected + 180) % 360 - 180
        # Within one second of the fastest motion (the Moon, < 16°/day ≈ 0.0002°/s),
        # on either side (the instant is rounded to the second).
        assert np.abs(diff).max() < 0.0002, kind


@settings(max_examples=10, deadline=None)
@given(windows)
def test_karanas_halve_tithis(astro, window):
    t0, days = window
    t1 = t0 + days * DAY
    tithis = spans("tithi", astro, t0, t1)
    karanas = {s.start: s for s in spans("karana", astro, t0 - DAY, t1 + DAY)}
    for t in tithis:
        first = karanas[t.start]
        assert first.idx == 2 * t.idx
        second = karanas[first.end]
        assert second.idx == 2 * t.idx + 1 and second.end == t.end


def test_a_full_year(astro):
    t0 = int(datetime(2026, 1, 1, tzinfo=UTC).timestamp())
    t1 = int(datetime(2027, 1, 1, tzinfo=UTC).timestamp())
    tithis = search_in_chunks("tithi", astro, t0, t1, chunk=97 * DAY)
    # A synodic month is 29.53 days: about 371 tithis touch a year.
    assert 365 < len(tithis) < 378
    for a, b in pairwise(tithis):
        assert b.start == a.end
    assert tithis == spans("tithi", astro, t0, t1), "chunking changes nothing"


def test_same_inputs_same_output(astro):
    t0 = int(datetime(2031, 5, 17, 6, 13, tzinfo=UTC).timestamp())
    a = spans("nakshatra", astro, t0, t0 + 5 * DAY)
    b = spans("nakshatra", astro, t0 + 7, t0 + 5 * DAY)  # a different query start
    assert a == b
