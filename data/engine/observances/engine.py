"""Evaluates observance rules against an almanac of one tradition at the reference
place (spec §6.6). Output rows always carry their tradition and a status."""

from __future__ import annotations

from collections.abc import Iterable
from dataclasses import dataclass, field
from datetime import date, timedelta

from ..bengali import BengaliDate, LunarMonth
from ..panchanga import Span
from .rules import (
    EVERY,
    MONTHS,
    EkadashiSmarta,
    FixedBengaliDate,
    Moments,
    Override,
    PrevailsAt,
    Rule,
    SankrantiDay,
    SpanOf,
    Udaya,
    tithi_index,
)

# Sandhi Puja: the last 24 minutes (one danda) of Ashtami and the first 24 of Navami
# (spec §6.5.10).
DANDA = 24 * 60
ASHTAMI, NAVAMI = tithi_index("shukla", "ashtami"), tithi_index("shukla", "navami")

STATUSES = ("computed", "reference_matched", "expert_reviewed", "sample")


@dataclass(frozen=True)
class Day:
    """A civil date at the reference place: its sunrise, sunset and the next sunrise
    (Unix seconds). The panjika day runs sunrise → next sunrise."""

    date: date
    sunrise: int
    sunset: int
    next_sunrise: int


@dataclass(frozen=True)
class Almanac:
    """What the rules read: consecutive days, the tithis and lunar months covering
    them, and their Bengali dates. Build it with margins (a month either side) so a
    tithi near the edge is whole; only dates in [first, last] are output."""

    tradition: str
    days: tuple[Day, ...]
    tithis: tuple[Span, ...]
    lunar_months: tuple[LunarMonth, ...]
    bengali: dict[date, BengaliDate]
    first: date
    last: date

    def __post_init__(self):
        if not self.tradition:
            raise ValueError("an almanac belongs to a tradition")
        for a, b in zip(self.days, self.days[1:], strict=False):
            if b.date != a.date + timedelta(days=1) or b.sunrise != a.next_sunrise:
                raise ValueError(f"days are not consecutive at {a.date}")


@dataclass(frozen=True)
class Window:
    kind: str
    start: int
    end: int

    def __post_init__(self):
        if not self.start < self.end:
            raise ValueError(f"empty window {self.kind}")


@dataclass(frozen=True)
class ObservanceRow:
    """One date of one observance in one tradition (observance_dates + windows)."""

    observance_id: str
    tradition: str
    date: date
    day_index: int
    status: str
    review: str  # the rule's review status; production builds refuse "draft" (T-502)
    note_bn: str | None = None
    note_en: str | None = None
    windows: tuple[Window, ...] = field(default=())

    def __post_init__(self):
        if not self.tradition:
            raise ValueError(f"{self.observance_id}: no tradition")
        if self.status not in STATUSES:
            raise ValueError(f"{self.observance_id}: status {self.status!r}")
        if (self.note_bn is None) != (self.note_en is None):
            raise ValueError(f"{self.observance_id}: notes come in pairs")


class EngineError(RuntimeError):
    pass


@dataclass(frozen=True)
class _Hit:
    date: date
    tithi: Span | None = None  # the deciding tithi, for windows
    day: Day | None = None


class _Calc:
    def __init__(self, almanac: Almanac, moments: Moments):
        self.a = almanac
        self.moments = moments
        self.day_by_date = {d.date: d for d in almanac.days}

    # -- lookups --

    def panjika_day(self, t: int) -> Day | None:
        for d in self.a.days:
            if d.sunrise <= t < d.next_sunrise:
                return d
        return None

    def month_of(self, t: int) -> LunarMonth | None:
        for m in self.a.lunar_months:
            if m.start <= t < m.end:
                return m
        return None

    def tithis_in(self, month: str, idx: int, include_mala: bool) -> list[tuple[Span, LunarMonth]]:
        """Tithi [idx] in each matching lunar month (adhik months skipped unless asked)."""
        out = []
        for t in self.a.tithis:
            if t.idx != idx:
                continue
            m = self.month_of(t.start)
            if m is None or (m.is_adhik and not include_mala):
                continue
            if month != EVERY and m.month_idx != MONTHS.index(month):
                continue
            out.append((t, m))
        return out

    def moment(self, day: Day, name: str) -> tuple[int, int]:
        m = self.moments.by_name[name]
        a, b = (day.sunrise, day.sunset) if m.part == "day" else (day.sunset, day.next_sunrise)
        unit = (b - a) / 15
        return round(a + m.start * unit), round(a + m.end * unit)

    def covered(self, day: Day) -> bool:
        return self.a.first <= day.date <= self.a.last

    # -- decisions --

    def udaya_day(self, t: Span, on_vriddhi: str) -> Day | None:
        days = [d for d in self.a.days if t.start <= d.sunrise < t.end]
        if len(days) == 1:
            return days[0]
        if len(days) == 2:
            return days[0] if on_vriddhi == "first" else days[1]
        if not days:  # kshaya: wholly inside one panjika day
            return self.panjika_day(t.start)
        raise EngineError(f"tithi {t.idx} spans {len(days)} sunrises")

    def udaya(self, d: Udaya) -> list[_Hit]:
        hits = []
        for t, _ in self.tithis_in(d.lunar_month, d.tithi, d.include_mala):
            day = self.udaya_day(t, d.on_vriddhi)
            if day is not None:
                hits.append(_Hit(day.date, t, day))
        return hits

    def prevails_at(self, d: PrevailsAt) -> list[_Hit]:
        hits = []
        for t, _ in self.tithis_in(d.lunar_month, d.tithi, d.include_mala):
            candidates = [x for x in self.a.days if x.sunrise < t.end and t.start < x.next_sunrise]
            good = []
            for day in candidates:
                a, b = self.moment(day, d.moment)
                if d.coverage == "whole":
                    ok = t.start <= a and b <= t.end
                else:
                    ok = max(a, t.start) < min(b, t.end)
                if ok:
                    good.append(day)
            if len(good) > 2:
                raise EngineError(f"tithi {t.idx} prevails at {d.moment} on {len(good)} days")
            if good:
                day = good[0] if d.tie_breaker == "earlier_day" or len(good) == 1 else good[1]
            elif d.if_none == "udaya":
                day = self.udaya_day(t, "first" if d.tie_breaker == "earlier_day" else "second")
            else:
                continue
            if day is not None:
                hits.append(_Hit(day.date, t, day))
        return hits

    def sankranti_day(self, d: SankrantiDay) -> list[_Hit]:
        hits = []
        for day, bn in sorted(self.a.bengali.items()):
            if d.month != EVERY and bn.month_idx != MONTHS.index(d.month):
                continue
            if d.day == "first" and bn.day == 1:
                hits.append(_Hit(day))
            nxt = self.a.bengali.get(day + timedelta(days=1))
            if d.day == "last" and nxt is not None and nxt.day == 1:
                hits.append(_Hit(day))
        return hits

    def fixed(self, d: FixedBengaliDate) -> list[_Hit]:
        month = MONTHS.index(d.month)
        return [
            _Hit(day)
            for day, bn in sorted(self.a.bengali.items())
            if bn.month_idx == month and bn.day == d.day
        ]

    def ekadashi(self, d: EkadashiSmarta) -> list[_Hit]:
        pakshas = ("shukla", "krishna") if d.paksha == "both" else (d.paksha,)
        hits = []
        for p in pakshas:
            rule = Udaya(EVERY, tithi_index(p, "ekadashi"), d.on_vriddhi, d.include_mala)
            hits += self.udaya(rule)
        return sorted(hits, key=lambda h: h.date)

    # -- windows --

    def windows(self, rule: Rule, hit: _Hit) -> tuple[Window, ...]:
        out = []
        for kind in rule.windows:
            if hit.tithi is None or hit.day is None:
                raise EngineError(f"{rule.id}: window {kind} needs a tithi decision")
            if kind == "tithi_span":
                out.append(Window(kind, hit.tithi.start, hit.tithi.end))
            elif kind == "sandhi_puja":
                if hit.tithi.idx != ASHTAMI:
                    raise EngineError(f"{rule.id}: sandhi_puja belongs to Shukla Ashtami")
                nxt = next((t for t in self.a.tithis if t.start == hit.tithi.end), None)
                if nxt is None or nxt.idx != NAVAMI:
                    raise EngineError(f"{rule.id}: no Navami after Ashtami at {hit.date}")
                out.append(Window(kind, hit.tithi.end - DANDA, hit.tithi.end + DANDA))
            else:
                a, b = self.moment(hit.day, kind)
                out.append(Window(kind, a, b))
        return tuple(out)


def evaluate(rules: Iterable[Rule], almanac: Almanac, moments: Moments) -> list[ObservanceRow]:
    """Every date of every rule that applies to the almanac's tradition, within
    [almanac.first, almanac.last], sorted by date then id."""
    calc = _Calc(almanac, moments)
    rules = [r for r in rules if almanac.tradition in r.traditions]
    by_id = {r.id: r for r in rules}
    single: dict[str, list[_Hit]] = {}

    def hits_of(rule: Rule) -> list[_Hit]:
        if rule.id in single:
            return single[rule.id]
        d = rule.decision
        match d:
            case Udaya():
                hits = calc.udaya(d)
            case PrevailsAt():
                hits = calc.prevails_at(d)
            case SankrantiDay():
                hits = calc.sankranti_day(d)
            case FixedBengaliDate():
                hits = calc.fixed(d)
            case EkadashiSmarta():
                hits = calc.ekadashi(d)
            case Override():
                hits = [_Hit(o.date) for o in d.dates]
            case SpanOf():
                raise EngineError(f"{rule.id}: a span is not a single-day rule")
        single[rule.id] = hits
        return hits

    rows: list[ObservanceRow] = []
    for rule in rules:
        notes: dict[date, tuple[str, str]] = {}
        if isinstance(rule.decision, Override):
            notes = {o.date: (o.reason_bn, o.reason_en) for o in rule.decision.dates}
        if isinstance(rule.decision, SpanOf):
            members = []
            for member in rule.decision.days:
                if member not in by_id:
                    raise EngineError(
                        f"{rule.id}: span day {member} has no rule for {almanac.tradition}"
                    )
                members.append(hits_of(by_id[member]))
            dated: list[tuple[date, int, _Hit]] = []
            for first in members[0]:
                limit = first.date + timedelta(days=rule.decision.within_days)
                days = [first]
                for later in members[1:]:
                    nxt = next((h for h in later if days[-1].date <= h.date <= limit), None)
                    if nxt is None:
                        raise EngineError(
                            f"{rule.id}: no {rule.decision.days[len(days)]} after {first.date}"
                        )
                    days.append(nxt)
                seen: set[date] = set()
                for i, h in enumerate(days):
                    if h.date not in seen:  # two days on one date: keep the first
                        seen.add(h.date)
                        dated.append((h.date, i, h))
        else:
            dated = [(h.date, 0, h) for h in hits_of(rule)]

        corrections = {c.computed: c for c in rule.corrections}
        for when, index, hit in dated:
            note = notes.get(when)
            windows = () if isinstance(rule.decision, SpanOf) else calc.windows(rule, hit)
            if when in corrections:
                c = corrections.pop(when)
                when, note, windows = c.date, (c.reason_bn, c.reason_en), ()
            if not almanac.first <= when <= almanac.last:
                continue
            rows.append(
                ObservanceRow(
                    observance_id=rule.id,
                    tradition=almanac.tradition,
                    date=when,
                    day_index=index,
                    status="computed",
                    review=rule.review.status,
                    note_bn=note[0] if note else None,
                    note_en=note[1] if note else None,
                    windows=windows,
                )
            )
        unused = [
            c.computed for c in corrections.values() if almanac.first <= c.computed <= almanac.last
        ]
        if unused:
            raise EngineError(f"{rule.id}: corrections for {unused} match no computed date")
    rows.sort(key=lambda r: (r.date, r.observance_id))
    return rows
