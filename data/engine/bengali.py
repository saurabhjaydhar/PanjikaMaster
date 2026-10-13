"""Bengali civil dates and lunar months (spec §6.5.6–6.5.7, T-301).

Bengal rule: take the sunrise-to-sunrise day d in which a sankranti falls. If it falls
before that day's midnight, the new month begins on d + 1; if after, on d + 2.

TODO(Q4): which midnight. With civil 00:00 IST (the default until the expert answers)
the rule always gives the civil date after the sankranti, so sunrise does not matter.
With the local true midnight (midway between sunset and the next sunrise at the
reference place, TODO(Q1)), a sankranti between true and civil midnight moves a day.

Lunar months (TODO(Q2) naming): amanta, from one new moon (the end of Amavasya) to the
next, named after the Sun's sign at the new moon that starts it, so the month that begins
with the Sun in Meena is চৈত্র (11) and with the Sun in Mesha বৈশাখ (0). A month in which
no sankranti falls is মলমাস (adhik): it takes the next month's name and is flagged.
"""

from collections.abc import Callable
from dataclasses import dataclass
from datetime import date, timedelta
from enum import Enum
from itertools import pairwise

from engine.panchanga import Span

IST_OFFSET = 19_800
DAY = 86_400
EPOCH = date(1970, 1, 1)


class Midnight(Enum):
    CIVIL_IST = "civil_ist"
    TRUE_LOCAL = "true_local"


MIDNIGHT = Midnight.CIVIL_IST  # TODO(Q4)


def ist_date(unix: int) -> date:
    return EPOCH + timedelta(days=(unix + IST_OFFSET) // DAY)


def ist_midnight(d: date) -> int:
    return (d - EPOCH).days * DAY - IST_OFFSET


# (sunrise of d, sunset of d, sunrise of d+1) for a civil date, Unix seconds.
SunTimes = Callable[[date], tuple[int, int, int]]


def month_start(
    sankranti: int,
    midnight: Midnight = MIDNIGHT,
    sun: SunTimes | None = None,
) -> date:
    """The civil date on which the month that this sankranti opens begins."""
    if midnight is Midnight.CIVIL_IST:
        # The sunrise-day's midnight is 00:00 IST, so either branch of the rule lands on
        # the civil day after the sankranti.
        return ist_date(sankranti) + timedelta(days=1)
    if sun is None:
        raise ValueError("true local midnight needs sunrise/sunset at the reference place")
    d = ist_date(sankranti)
    rise, _, _ = sun(d)
    if sankranti < rise:  # before sunrise: still the previous sunrise-day
        d -= timedelta(days=1)
    _, set_, next_rise = sun(d)
    true_midnight = (set_ + next_rise) // 2
    return d + timedelta(days=1 if sankranti < true_midnight else 2)


def bangabda(month_start_date: date, month_idx: int) -> int:
    """Bengali year: Gregorian − 593 from Poila Boishakh, − 594 before it (§6.5.6)."""
    year = month_start_date.year - 593
    # Months after Poush start in the next Gregorian year but belong to the same Bengali
    # year, which began in the April before.
    if month_idx >= 9 and month_start_date.month <= 4:
        year -= 1
    return year


@dataclass(frozen=True)
class BengaliDate:
    date: date
    day: int  # 1–32
    month_idx: int  # 0 = বৈশাখ
    year: int


def bengali_dates(
    sankrantis: list[Span],
    first: date,
    last: date,
    midnight: Midnight = MIDNIGHT,
    sun: SunTimes | None = None,
) -> list[BengaliDate]:
    """One row per civil date in [first, last]. [sankrantis] must cover the range with a
    sankranti before [first] and one after [last]."""
    starts = [(month_start(s.start, midnight, sun), s.idx) for s in sankrantis]
    out: list[BengaliDate] = []
    for (start, idx), (nxt, _) in pairwise(starts):
        length = (nxt - start).days
        if not 29 <= length <= 32:
            raise ValueError(f"Bengali month of {length} days from {start}")
        year = bangabda(start, idx)
        for i in range(length):
            d = start + timedelta(days=i)
            if first <= d <= last:
                out.append(BengaliDate(d, i + 1, idx, year))
    expected = (last - first).days + 1
    if len(out) != expected:
        raise ValueError("sankrantis do not cover the requested dates")
    return out


@dataclass(frozen=True)
class LunarMonth:
    start: int  # new moon, Unix seconds
    end: int
    month_idx: int
    is_adhik: bool


def lunar_months(tithis: list[Span], sun_sign: Callable[[int], int]) -> list[LunarMonth]:
    """Amanta months from tithi spans: each starts where Shukla Pratipada (idx 0) starts.
    [sun_sign] gives the Sun's nirayana sign (0 = Mesha) at an instant."""
    new_moons = [t.start for t in tithis if t.idx == 0]
    signs = [sun_sign(t) for t in new_moons]
    months = []
    for i in range(len(new_moons) - 1):
        a, b = signs[i], signs[i + 1]
        steps = (b - a) % 12
        if steps > 1:
            raise ValueError(f"kshaya masa (two sankrantis in one lunar month) at {new_moons[i]}")
        adhik = steps == 0
        # Named after the sign at its start; an adhik month takes the next month's name,
        # which is the same sign.
        months.append(LunarMonth(new_moons[i], new_moons[i + 1], a, adhik))
    return months
