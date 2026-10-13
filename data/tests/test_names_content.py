"""T-217: names content: both languages everywhere, glosses for every term and period."""

import re
import tomllib

from pack import sample

NAMES = tomllib.loads(sample.NAMES_PATH.read_text(encoding="utf-8"))
KINDS = sample.load_names()
BENGALI = re.compile(r"[ঀ-৿]")
DIGITS = re.compile(r"[0-9০-৯]")


def test_still_marked_draft_until_reviewed():
    # Q5 (Bengali spelling) and Q14 (romanisation) decide the final text.
    assert NAMES["status"] == "draft"


def test_every_entry_has_both_languages():
    for kind, entries in KINDS.items():
        for i, e in enumerate(entries):
            assert e["bn"].strip() and BENGALI.search(e["bn"]), (kind, i)
            assert e["en"].strip() and not BENGALI.search(e["en"]), (kind, i)


def test_glosses_come_in_pairs_in_the_right_script():
    for kind, entries in KINDS.items():
        for i, e in enumerate(entries):
            assert ("gloss_bn" in e) == ("gloss_en" in e), (kind, i)
            if "gloss_bn" in e:
                assert BENGALI.search(e["gloss_bn"]), (kind, i)
                assert not BENGALI.search(e["gloss_en"]), (kind, i)


def test_every_term_and_period_has_a_gloss():
    for kind in ("term", "period"):
        for i, e in enumerate(KINDS[kind]):
            assert e.get("gloss_bn") and e.get("gloss_en"), (kind, i)


def test_glosses_spell_numbers_out():
    # Digits would ignore the user's numeral setting (FR-L10N-04).
    for kind, entries in KINDS.items():
        for i, e in enumerate(entries):
            for key in ("gloss_bn", "gloss_en"):
                assert not DIGITS.search(e.get(key, "")), (kind, i, key)


def test_glosses_are_one_or_two_sentences():
    for kind, entries in KINDS.items():
        for i, e in enumerate(entries):
            if "gloss_en" in e:
                assert 1 <= len(re.findall(r"[.!?](\s|$)", e["gloss_en"])) <= 2, (kind, i)
                assert 1 <= e["gloss_bn"].count("।") <= 2, (kind, i)


def test_term_ids_are_unique_snake_case():
    ids = [e["translit"] for e in KINDS["term"]]
    assert len(ids) == len(set(ids))
    assert all(re.fullmatch(r"[a-z]+(_[a-z]+)*", i) for i in ids)


def test_sample_pack_carries_the_glosses(packs):
    conn = packs["sample-global"]
    n = conn.execute(
        "SELECT count(*) FROM names WHERE kind IN ('term', 'period') AND gloss_en IS NOT NULL"
    ).fetchone()[0]
    assert n == len(KINDS["term"]) + len(KINDS["period"])
