"""Observance rules: the YAML schema and a strict loader (spec §6.6).

One file per observance, named ``<id>.yaml``. Unknown keys, missing keys and bad values
are errors: a rule that silently means something else is worse than no rule. Every
choice a convention could make differently (which day wins when a tithi touches two
sunrises, what counts as "prevailing") is a required parameter, so it is written in
the rule and reviewed with it, never defaulted in code.
"""

from __future__ import annotations

import re
import tomllib
from dataclasses import dataclass
from datetime import date
from pathlib import Path

import yaml

ID = re.compile(r"^[a-z0-9_]{1,64}$")

CATEGORIES = ("puja", "vrata", "tithi", "utsav", "jayanti")  # schema.sql CHECK order

# Solar (Bengali) and lunar months share their names, 0 = বৈশাখ. TODO(Q2): lunar naming.
MONTHS = (
    "boishakh", "jyoishtho", "asharh", "srabon", "bhadro", "ashwin",
    "kartik", "agrahayan", "poush", "magh", "falgun", "chaitra",
)  # fmt: skip
EVERY = "every"

_TITHIS = (
    "pratipada", "dwitiya", "tritiya", "chaturthi", "panchami", "shashthi", "saptami",
    "ashtami", "navami", "dashami", "ekadashi", "dwadashi", "trayodashi", "chaturdashi",
)  # fmt: skip

MOMENTS = ("pratah", "madhyahna", "aparahna", "pradosha", "nishita")
WINDOWS = ("tithi_span", "sandhi_puja", *MOMENTS)
REVIEW = ("draft", "reviewed")


class RuleError(ValueError):
    """A rule file is malformed; the message names the file and the field."""


def tithi_index(paksha: str, name: str) -> int:
    """0-based tithi index (spec §15.1): Shukla Pratipada 0 … Purnima 14, Krishna
    Pratipada 15 … Amavasya 29."""
    if paksha == "shukla":
        if name == "purnima":
            return 14
        return _TITHIS.index(name)
    if paksha == "krishna":
        if name == "amavasya":
            return 29
        return 15 + _TITHIS.index(name)
    raise ValueError(paksha)


# --- decisions -----------------------------------------------------------------------


@dataclass(frozen=True)
class Udaya:
    """The day whose sunrise falls in the tithi. A tithi touching two sunrises takes
    [on_vriddhi]; one touching none (kshaya) belongs to the panjika day it lies in."""

    lunar_month: str  # a MONTHS name, or EVERY
    tithi: int
    on_vriddhi: str  # first | second
    include_mala: bool


@dataclass(frozen=True)
class PrevailsAt:
    """The day on which the tithi covers the named moment ([coverage]: any overlap, or
    the whole moment). Two such days → [tie_breaker]; none → [if_none]."""

    lunar_month: str
    tithi: int
    moment: str
    coverage: str  # any | whole
    tie_breaker: str  # earlier_day | later_day
    if_none: str  # udaya | skip
    include_mala: bool


@dataclass(frozen=True)
class SankrantiDay:
    """The first or last day of a Bengali solar month (the day after / of its
    sankranti, per the Bengal midnight rule)."""

    month: str  # a MONTHS name, or EVERY
    day: str  # first | last


@dataclass(frozen=True)
class FixedBengaliDate:
    month: str
    day: int


@dataclass(frozen=True)
class EkadashiSmarta:
    """Every Ekadashi by sunrise, as an udaya rule with an explicit [on_vriddhi].
    The dashami-vedha refinements belong to `ekadashi_vaishnava` (v1.1)."""

    paksha: str  # shukla | krishna | both
    on_vriddhi: str
    include_mala: bool


@dataclass(frozen=True)
class SpanOf:
    """A multi-day observance whose days are other observances, in order (e.g. Durga
    Puja: Shashthi → Dashami). Day [i] is the next occurrence of [days][i] within
    [within_days] of the first."""

    days: tuple[str, ...]
    within_days: int


@dataclass(frozen=True)
class OverrideDate:
    date: date
    reason_bn: str
    reason_en: str


@dataclass(frozen=True)
class Override:
    """Editorial dates set by a reviewer, each with its reason in both languages."""

    dates: tuple[OverrideDate, ...]


Decision = Udaya | PrevailsAt | SankrantiDay | FixedBengaliDate | EkadashiSmarta | SpanOf | Override


@dataclass(frozen=True)
class Correction:
    """Moves one computed date to another, with the reason in both languages; shown
    to users as the date's note."""

    computed: date
    date: date
    reason_bn: str
    reason_en: str


@dataclass(frozen=True)
class Review:
    status: str  # draft | reviewed
    reviewer: str | None
    reviewed_on: date | None


@dataclass(frozen=True)
class Rule:
    id: str
    name_bn: str
    name_en: str
    category: str
    tier: int
    traditions: tuple[str, ...]
    decision: Decision
    windows: tuple[str, ...]
    corrections: tuple[Correction, ...]
    description_bn: str | None
    description_en: str | None
    review: Review


# --- loading -------------------------------------------------------------------------


class _Fields:
    """Reads a mapping key by key and complains about anything left over."""

    def __init__(self, data: object, where: str):
        if not isinstance(data, dict):
            raise RuleError(f"{where}: expected a mapping")
        self.data = dict(data)
        self.where = where

    def _fail(self, key: str, msg: str) -> RuleError:
        return RuleError(f"{self.where}.{key}: {msg}")

    def get(self, key: str, kind: type | tuple[type, ...], optional: bool = False):
        if key not in self.data:
            if optional:
                return None
            raise self._fail(key, "missing")
        value = self.data.pop(key)
        if value is None and optional:
            return None
        if isinstance(value, bool) and kind is int:
            raise self._fail(key, "expected a number")
        if not isinstance(value, kind):
            raise self._fail(key, f"expected {kind}, got {type(value).__name__}")
        return value

    def text(self, key: str, optional: bool = False) -> str | None:
        value = self.get(key, str, optional)
        if value is not None and not value.strip():
            raise self._fail(key, "empty")
        return value

    def choice(self, key: str, options: tuple[str, ...]) -> str:
        value = self.get(key, str)
        if value not in options:
            raise self._fail(key, f"{value!r} is not one of {options}")
        return value

    def done(self) -> None:
        if self.data:
            raise RuleError(f"{self.where}: unknown keys {sorted(self.data)}")


def _tithi(f: _Fields) -> int:
    paksha = f.choice("paksha", ("shukla", "krishna"))
    names = (*_TITHIS, "purnima" if paksha == "shukla" else "amavasya")
    return tithi_index(paksha, f.choice("tithi", names))


def _decision(data: object, where: str) -> Decision:
    f = _Fields(data, where)
    kind = f.choice(
        "type",
        (
            "udaya", "prevails_at", "sankranti_day", "fixed_bengali_date",
            "ekadashi_smarta", "span", "override",
        ),
    )  # fmt: skip
    months_or_every = (*MONTHS, EVERY)
    decision: Decision
    match kind:
        case "udaya":
            decision = Udaya(
                lunar_month=f.choice("lunar_month", months_or_every),
                tithi=_tithi(f),
                on_vriddhi=f.choice("on_vriddhi", ("first", "second")),
                include_mala=f.get("include_mala", bool),
            )
        case "prevails_at":
            location = f.choice("location", ("reference",))  # TODO(Q1): which place
            del location
            decision = PrevailsAt(
                lunar_month=f.choice("lunar_month", months_or_every),
                tithi=_tithi(f),
                moment=f.choice("moment", MOMENTS),
                coverage=f.choice("coverage", ("any", "whole")),
                tie_breaker=f.choice("tie_breaker", ("earlier_day", "later_day")),
                if_none=f.choice("if_none", ("udaya", "skip")),
                include_mala=f.get("include_mala", bool),
            )
        case "sankranti_day":
            decision = SankrantiDay(
                month=f.choice("month", months_or_every),
                day=f.choice("day", ("first", "last")),
            )
        case "fixed_bengali_date":
            month = f.choice("month", MONTHS)
            day = f.get("day", int)
            if not 1 <= day <= 32:
                raise RuleError(f"{where}.day: {day} is not 1–32")
            decision = FixedBengaliDate(month, day)
        case "ekadashi_smarta":
            decision = EkadashiSmarta(
                paksha=f.choice("paksha", ("shukla", "krishna", "both")),
                on_vriddhi=f.choice("on_vriddhi", ("first", "second")),
                include_mala=f.get("include_mala", bool),
            )
        case "span":
            days = f.get("days", list)
            if len(days) < 2 or not all(isinstance(d, str) and ID.match(d) for d in days):
                raise RuleError(f"{where}.days: two or more observance ids")
            within = f.get("within_days", int)
            if not 1 <= within <= 31:
                raise RuleError(f"{where}.within_days: 1–31")
            decision = SpanOf(tuple(days), within)
        case _:  # override
            raw = f.get("dates", list)
            if not raw:
                raise RuleError(f"{where}.dates: at least one")
            dates = []
            for i, item in enumerate(raw):
                g = _Fields(item, f"{where}.dates[{i}]")
                dates.append(
                    OverrideDate(g.get("date", date), g.text("reason_bn"), g.text("reason_en"))
                )
                g.done()
            decision = Override(tuple(dates))
    f.done()
    return decision


def parse_rule(data: object, where: str, expected_id: str | None = None) -> Rule:
    f = _Fields(data, where)
    rule_id = f.get("id", str)
    if not ID.match(rule_id):
        raise RuleError(f"{where}.id: {rule_id!r} must match {ID.pattern}")
    if expected_id is not None and rule_id != expected_id:
        raise RuleError(f"{where}.id: {rule_id!r} does not match the file name")
    tier = f.get("tier", int)
    if tier not in (1, 2, 3):
        raise RuleError(f"{where}.tier: 1, 2 or 3")
    traditions = f.get("traditions", list)
    if not traditions or not all(isinstance(t, str) and ID.match(t) for t in traditions):
        raise RuleError(f"{where}.traditions: one or more tradition ids")
    decision = _decision(f.get("decision", dict), f"{where}.decision")
    windows = tuple(f.get("windows", list, optional=True) or ())
    for w in windows:
        if w not in WINDOWS:
            raise RuleError(f"{where}.windows: {w!r} is not one of {WINDOWS}")
    if windows and isinstance(decision, SpanOf | Override | SankrantiDay | FixedBengaliDate):
        raise RuleError(f"{where}.windows: only tithi-based decisions have windows")
    corrections = []
    for i, item in enumerate(f.get("corrections", list, optional=True) or ()):
        g = _Fields(item, f"{where}.corrections[{i}]")
        corrections.append(
            Correction(
                g.get("computed", date),
                g.get("date", date),
                g.text("reason_bn"),
                g.text("reason_en"),
            )
        )
        g.done()
    description_bn = f.text("description_bn", optional=True)
    description_en = f.text("description_en", optional=True)
    if (description_bn is None) != (description_en is None):
        raise RuleError(f"{where}: descriptions come in pairs (bn and en)")
    g = _Fields(f.get("review", dict), f"{where}.review")
    review = Review(
        g.choice("status", REVIEW),
        g.text("reviewer", optional=True),
        g.get("reviewed_on", date, optional=True),
    )
    g.done()
    if review.status == "reviewed" and (review.reviewer is None or review.reviewed_on is None):
        raise RuleError(f"{where}.review: a reviewed rule names its reviewer and date")
    rule = Rule(
        id=rule_id,
        name_bn=f.text("name_bn"),
        name_en=f.text("name_en"),
        category=f.choice("category", CATEGORIES),
        tier=tier,
        traditions=tuple(traditions),
        decision=decision,
        windows=windows,
        corrections=tuple(corrections),
        description_bn=description_bn,
        description_en=description_en,
        review=review,
    )
    f.done()
    return rule


def load_rules(directory: Path) -> list[Rule]:
    """Every ``*.yaml`` rule in [directory], sorted by id; span members must exist."""
    rules = []
    for path in sorted(directory.glob("*.yaml")):
        with path.open(encoding="utf-8") as fh:
            data = yaml.safe_load(fh)
        rules.append(parse_rule(data, path.name, expected_id=path.stem))
    ids = {r.id for r in rules}
    for r in rules:
        if isinstance(r.decision, SpanOf):
            missing = [d for d in r.decision.days if d not in ids]
            if missing:
                raise RuleError(f"{r.id}.yaml: span days {missing} have no rule")
    return rules


# --- moments -------------------------------------------------------------------------


@dataclass(frozen=True)
class Moment:
    part: str  # day | night
    start: int  # muhurta, 0–15
    end: int


@dataclass(frozen=True)
class Moments:
    review: str
    by_name: dict[str, Moment]


def load_moments(path: Path) -> Moments:
    data = tomllib.loads(path.read_text(encoding="utf-8"))
    review = data.pop("review", None)
    if review not in REVIEW:
        raise RuleError(f"{path.name}: review must be one of {REVIEW}")
    out = {}
    for name in MOMENTS:
        f = _Fields(data.pop(name, None), f"{path.name}.{name}")
        part = f.choice("part", ("day", "night"))
        start, end = f.get("from", int), f.get("to", int)
        f.done()
        if not 0 <= start < end <= 15:
            raise RuleError(f"{path.name}.{name}: need 0 ≤ from < to ≤ 15")
        out[name] = Moment(part, start, end)
    if data:
        raise RuleError(f"{path.name}: unknown moments {sorted(data)}")
    return Moments(review, out)
