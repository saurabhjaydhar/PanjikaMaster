"""T-501: observance rule engine — one test per decision type, windows, corrections,
mala masa, and the loader's strictness.

Everything here runs on a synthetic almanac: abstract days (sunrise 06:00, sunset
18:00 in a made-up time base) and tithi spans placed by hand to exercise each branch.
None of it is calendar data.
"""

from datetime import date, timedelta
from pathlib import Path

import pytest
import yaml

from engine.bengali import BengaliDate, LunarMonth
from engine.observances import (
    Almanac,
    Day,
    EngineError,
    ObservanceRow,
    RuleError,
    evaluate,
    load_moments,
    load_rules,
    parse_rule,
)
from engine.observances.engine import DANDA
from engine.observances.rules import tithi_index
from engine.panchanga import Span

H = 3600
D = 24 * H
START = date(2001, 1, 1)  # synthetic
MOMENTS = load_moments(Path(__file__).parents[1] / "content" / "moments.toml")


def t(day: int, hour: float) -> int:
    """Synthetic instant: [hour] o'clock on day [day]."""
    return int(day * D + hour * H)


def almanac(
    tithis: list[tuple[int, int, int]],
    months: list[tuple[int, int, int, bool]] | None = None,
    bengali: dict[int, tuple[int, int]] | None = None,
    days: int = 12,
) -> Almanac:
    """[tithis] as (idx, start, end); [months] as (start, end, month_idx, adhik);
    [bengali] as day → (day of month, month_idx)."""
    ds = tuple(Day(START + timedelta(days=i), t(i, 6), t(i, 18), t(i + 1, 6)) for i in range(days))
    months = months or [(t(0, 0), t(days + 1, 0), 6, False)]
    return Almanac(
        tradition="drik_bishuddha",
        days=ds,
        tithis=tuple(Span(a, b, i, "tithi") for i, a, b in tithis),
        lunar_months=tuple(LunarMonth(a, b, m, adhik) for a, b, m, adhik in months),
        bengali={
            START + timedelta(days=k): BengaliDate(START + timedelta(days=k), dd, m, 1408)
            for k, (dd, m) in (bengali or {}).items()
        },
        first=START,
        last=START + timedelta(days=days - 1),
    )


def rule(decision: dict, **extra) -> dict:
    return {
        "id": extra.pop("id", "test_rule"),
        "name_bn": "পরীক্ষা",
        "name_en": "Test",
        "category": "puja",
        "tier": 1,
        "traditions": ["drik_bishuddha"],
        "decision": decision,
        "review": {"status": "draft"},
        **extra,
    }


def run(a: Almanac, *rules: dict) -> list[ObservanceRow]:
    return evaluate([parse_rule(r, r["id"]) for r in rules], a, MOMENTS)


def day(n: int) -> date:
    return START + timedelta(days=n)


AMAVASYA = tithi_index("krishna", "amavasya")
PURNIMA = tithi_index("shukla", "purnima")
UDAYA = {"type": "udaya", "lunar_month": "kartik", "paksha": "krishna", "tithi": "amavasya",
         "on_vriddhi": "first", "include_mala": False}  # fmt: skip


# --- udaya ---------------------------------------------------------------------------


def test_udaya_takes_the_day_whose_sunrise_is_in_the_tithi():
    a = almanac([(AMAVASYA, t(3, 2), t(4, 3))])
    rows = run(a, rule(UDAYA))
    assert [r.date for r in rows] == [day(3)]
    assert rows[0].tradition == "drik_bishuddha" and rows[0].status == "computed"
    assert rows[0].review == "draft"


@pytest.mark.parametrize(("which", "expected"), [("first", 3), ("second", 4)])
def test_udaya_vriddhi_follows_the_rule(which, expected):
    a = almanac([(AMAVASYA, t(3, 2), t(4, 9))])  # touches sunrise on day 3 and day 4
    assert [r.date for r in run(a, rule({**UDAYA, "on_vriddhi": which}))] == [day(expected)]


def test_udaya_kshaya_belongs_to_the_day_it_lies_in():
    a = almanac([(AMAVASYA, t(3, 8), t(3, 23))])  # no sunrise inside
    assert [r.date for r in run(a, rule(UDAYA))] == [day(3)]


def test_udaya_filters_by_lunar_month_and_skips_mala_masa():
    months = [(t(0, 0), t(5, 0), 6, True), (t(5, 0), t(13, 0), 6, False)]  # adhik, then nija
    tithis = [(AMAVASYA, t(2, 2), t(3, 1)), (AMAVASYA, t(8, 2), t(9, 1))]
    a = almanac(tithis, months)
    assert [r.date for r in run(a, rule(UDAYA))] == [day(8)]
    assert [r.date for r in run(a, rule({**UDAYA, "include_mala": True}))] == [day(2), day(8)]
    assert run(a, rule({**UDAYA, "lunar_month": "ashwin"})) == []
    every = run(a, rule({**UDAYA, "lunar_month": "every"}))
    assert [r.date for r in every] == [day(8)]


# --- prevails_at ---------------------------------------------------------------------

PREVAILS = {"type": "prevails_at", "lunar_month": "kartik", "paksha": "krishna",
            "tithi": "amavasya", "moment": "nishita", "location": "reference",
            "coverage": "any", "tie_breaker": "earlier_day", "if_none": "udaya",
            "include_mala": False}  # fmt: skip


def test_nishita_is_the_eighth_muhurta_of_the_night():
    # Night 18:00 → 06:00 = 12 h; muhurta 48 min; the 8th is 23:36–00:24.
    a = almanac([(AMAVASYA, t(3, 23), t(4, 23))])
    rows = run(a, rule(PREVAILS, windows=["nishita"]))
    assert [r.date for r in rows] == [day(3)]
    w = rows[0].windows[0]
    assert (w.kind, w.start, w.end) == ("nishita", t(3, 23.6), t(4, 0.4))


def test_prevails_at_picks_the_day_whose_moment_the_tithi_covers():
    # Starts after day 3's nishita, covers day 4's: day 4 even though sunrise of day 4
    # also falls in it.
    a = almanac([(AMAVASYA, t(4, 1), t(5, 2))])
    assert [r.date for r in run(a, rule(PREVAILS))] == [day(4)]


@pytest.mark.parametrize(("tie", "expected"), [("earlier_day", 3), ("later_day", 4)])
def test_prevails_at_on_two_days_uses_the_tie_breaker(tie, expected):
    a = almanac([(AMAVASYA, t(3, 23), t(5, 0))])  # covers both nights' nishita
    got = run(a, rule({**PREVAILS, "tie_breaker": tie}))
    assert [r.date for r in got] == [day(expected)]


def test_prevails_at_on_no_day_falls_back_or_skips():
    a = almanac([(AMAVASYA, t(4, 2), t(4, 20))])  # a daytime-only tithi
    assert [r.date for r in run(a, rule(PREVAILS))] == [day(4)]  # udaya (kshaya day)
    assert run(a, rule({**PREVAILS, "if_none": "skip"})) == []


def test_whole_coverage_needs_the_whole_moment():
    a = almanac([(AMAVASYA, t(3, 23.9), t(4, 3))])  # starts inside nishita
    assert [r.date for r in run(a, rule(PREVAILS))] == [day(3)]
    assert run(a, rule({**PREVAILS, "coverage": "whole", "if_none": "skip"})) == []


# --- sankranti / fixed Bengali date --------------------------------------------------

BENGALI = {0: (30, 4), 1: (31, 4), 2: (1, 5), 3: (2, 5), 9: (31, 5), 10: (1, 6)}


def test_sankranti_day_first_and_last_of_a_bengali_month():
    a = almanac([], bengali=BENGALI)
    last = run(a, rule({"type": "sankranti_day", "month": "bhadro", "day": "last"}))
    assert [r.date for r in last] == [day(1)]
    first = run(a, rule({"type": "sankranti_day", "month": "ashwin", "day": "first"}))
    assert [r.date for r in first] == [day(2)]
    every = run(a, rule({"type": "sankranti_day", "month": "every", "day": "first"}))
    assert [r.date for r in every] == [day(2), day(10)]


def test_fixed_bengali_date():
    a = almanac([], bengali=BENGALI)
    got = run(a, rule({"type": "fixed_bengali_date", "month": "ashwin", "day": 2}))
    assert [r.date for r in got] == [day(3)]
    assert run(a, rule({"type": "fixed_bengali_date", "month": "ashwin", "day": 32})) == []


# --- ekadashi ------------------------------------------------------------------------


def test_ekadashi_smarta_every_ekadashi_by_sunrise():
    shukla, krishna = tithi_index("shukla", "ekadashi"), tithi_index("krishna", "ekadashi")
    a = almanac([(shukla, t(1, 2), t(2, 9)), (krishna, t(7, 4), t(8, 3))])
    ek = {"type": "ekadashi_smarta", "paksha": "both", "on_vriddhi": "first", "include_mala": False}
    assert [r.date for r in run(a, rule(ek))] == [day(1), day(7)]
    second = run(a, rule({**ek, "on_vriddhi": "second", "paksha": "shukla"}))
    assert [r.date for r in second] == [day(2)]


# --- span ----------------------------------------------------------------------------


def _tithi_rule(rid: str, name: str) -> dict:
    return rule(
        {"type": "udaya", "lunar_month": "ashwin", "paksha": "shukla", "tithi": name,
         "on_vriddhi": "first", "include_mala": False},
        id=rid,
    )  # fmt: skip


def test_span_numbers_its_days_from_its_members():
    months = [(t(0, 0), t(13, 0), 5, False)]  # ashwin
    names = ("saptami", "ashtami", "navami")
    tithis = [(tithi_index("shukla", n), t(2 + i, 4), t(3 + i, 4)) for i, n in enumerate(names)]
    a = almanac(tithis, months)
    members = [_tithi_rule(f"m_{n}", n) for n in names]
    span = rule({"type": "span", "days": [f"m_{n}" for n in names], "within_days": 5}, id="puja")
    rows = [r for r in run(a, *members, span) if r.observance_id == "puja"]
    assert [(r.date, r.day_index) for r in rows] == [(day(2), 0), (day(3), 1), (day(4), 2)]


def test_span_with_a_missing_day_is_an_error():
    months = [(t(0, 0), t(13, 0), 5, False)]
    a = almanac([(tithi_index("shukla", "saptami"), t(2, 4), t(3, 4))], months)
    members = [_tithi_rule("m_saptami", "saptami"), _tithi_rule("m_ashtami", "ashtami")]
    span = rule({"type": "span", "days": ["m_saptami", "m_ashtami"], "within_days": 3}, id="puja")
    with pytest.raises(EngineError, match="no m_ashtami"):
        run(a, *members, span)


# --- windows -------------------------------------------------------------------------


def test_sandhi_puja_is_a_danda_either_side_of_ashtami_ending():
    ashtami, navami = tithi_index("shukla", "ashtami"), tithi_index("shukla", "navami")
    months = [(t(0, 0), t(13, 0), 5, False)]
    a = almanac([(ashtami, t(2, 4), t(3, 10)), (navami, t(3, 10), t(4, 11))], months)
    r = _tithi_rule("ashtami", "ashtami")
    rows = run(a, {**r, "windows": ["sandhi_puja", "tithi_span"]})
    sandhi, span = rows[0].windows
    assert (sandhi.start, sandhi.end) == (t(3, 10) - DANDA, t(3, 10) + DANDA)
    assert DANDA == 24 * 60
    assert (span.start, span.end) == (t(2, 4), t(3, 10))


def test_sandhi_puja_needs_ashtami():
    a = almanac([(PURNIMA, t(2, 4), t(3, 10))], [(t(0, 0), t(13, 0), 5, False)])
    with pytest.raises(EngineError, match="Ashtami"):
        run(a, {**_tithi_rule("x", "purnima"), "windows": ["sandhi_puja"]})


# --- override and corrections --------------------------------------------------------


def test_override_dates_carry_their_reason_in_both_languages():
    o = {"type": "override", "dates": [{"date": day(5), "reason_bn": "কারণ", "reason_en": "Reason"}]}
    (row,) = run(almanac([]), rule(o))
    assert (row.date, row.note_bn, row.note_en) == (day(5), "কারণ", "Reason")


def test_a_correction_moves_a_computed_date_with_a_note():
    a = almanac([(AMAVASYA, t(3, 2), t(4, 3))])
    fix = {"computed": day(3), "date": day(4), "reason_bn": "কারণ", "reason_en": "Reason"}
    (row,) = run(a, rule(UDAYA, corrections=[fix]))
    assert (row.date, row.note_en) == (day(4), "Reason")
    stale = {**fix, "computed": day(6)}
    with pytest.raises(EngineError, match="match no computed date"):
        run(a, rule(UDAYA, corrections=[stale]))


def test_only_rules_of_the_almanacs_tradition_run():
    a = almanac([(AMAVASYA, t(3, 2), t(4, 3))])
    assert run(a, rule(UDAYA, traditions=["surya_siddhanta"])) == []


def test_rows_never_lack_tradition_or_status():
    with pytest.raises(ValueError, match="no tradition"):
        ObservanceRow("x", "", day(1), 0, "computed", "draft")
    with pytest.raises(ValueError, match="status"):
        ObservanceRow("x", "drik_bishuddha", day(1), 0, "guessed", "draft")
    with pytest.raises(ValueError, match="pairs"):
        ObservanceRow("x", "drik_bishuddha", day(1), 0, "computed", "draft", note_bn="নোট")


# --- loader --------------------------------------------------------------------------


@pytest.mark.parametrize(
    ("change", "message"),
    [
        ({"colour": "red"}, "unknown keys"),
        ({"tier": 4}, "tier"),
        ({"category": "festival"}, "category"),
        (
            {"decision": {k: v for k, v in UDAYA.items() if k != "on_vriddhi"}},
            "on_vriddhi: missing",
        ),
        ({"decision": {**UDAYA, "tithi": "purnima"}}, "tithi"),
        ({"review": {"status": "reviewed"}}, "names its reviewer"),
        ({"description_bn": "শুধু বাংলা"}, "pairs"),
        ({"description_bn": "ক", "description_en": "a"}, "description_review: missing"),
        ({"windows": ["sunset"]}, "windows"),
        ({"decision": {**PREVAILS, "location": "delhi"}}, "location"),
        (
            {"decision": {"type": "override", "dates": [{"date": day(5), "reason_bn": "ক"}]}},
            "reason_en",
        ),
    ],
)
def test_the_loader_rejects_bad_rules(change, message):
    with pytest.raises(RuleError, match=message):
        parse_rule({**rule(UDAYA), **change}, "x.yaml")


def test_load_rules_reads_yaml_and_checks_names_and_span_members(tmp_path: Path):
    good = rule(UDAYA, id="kali_test")
    (tmp_path / "kali_test.yaml").write_text(yaml.safe_dump(good, allow_unicode=True), "utf-8")
    assert [r.id for r in load_rules(tmp_path)] == ["kali_test"]

    (tmp_path / "other_name.yaml").write_text(yaml.safe_dump(good, allow_unicode=True), "utf-8")
    with pytest.raises(RuleError, match="file name"):
        load_rules(tmp_path)
    (tmp_path / "other_name.yaml").unlink()

    span = rule({"type": "span", "days": ["kali_test", "missing"], "within_days": 2}, id="sp")
    (tmp_path / "sp.yaml").write_text(yaml.safe_dump(span, allow_unicode=True), "utf-8")
    with pytest.raises(RuleError, match="have no rule"):
        load_rules(tmp_path)


def test_moments_are_drafts_until_reviewed():
    assert MOMENTS.review == "draft"
    assert set(MOMENTS.by_name) == {"pratah", "madhyahna", "aparahna", "pradosha", "nishita"}
