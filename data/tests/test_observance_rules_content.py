"""T-502: the drafted tier 1–3 rules load, are all drafts, cover the spec's tier list,
and drafts never reach a production pack."""

import pytest

from engine.observances import load_rules
from engine.observances.build import RULES_DIR
from pack import builder

RULES = {r.id: r for r in load_rules(RULES_DIR)}

# Spec §6.6 tier list, as rule ids.
TIER_1 = {
    "poila_boishakh", "mahalaya", "durga_shashthi", "durga_saptami", "durga_ashtami",
    "durga_navami", "vijaya_dashami", "durga_puja", "kojagari_lakshmi_puja", "kali_puja",
    "saraswati_puja", "janmashtami", "rath_yatra", "shivaratri", "dol_purnima",
}  # fmt: skip
TIER_2 = {
    "ekadashi", "purnima", "amavasya", "sankranti", "jamai_shashthi", "bhai_phonta",
    "vishwakarma_puja", "annapurna_puja", "manasa_puja", "jagaddhatri_puja", "ram_navami",
}  # fmt: skip
TIER_3 = {"rabindra_jayanti", "netaji_jayanti"}


def test_the_spec_tier_list_is_drafted_with_its_tiers():
    for tier, ids in ((1, TIER_1), (2, TIER_2), (3, TIER_3)):
        for rid in ids:
            assert rid in RULES, rid
            assert RULES[rid].tier == tier, rid


def test_every_rule_is_a_draft_with_names_in_both_languages():
    for r in RULES.values():
        assert r.review.status == "draft", r.id
        assert r.name_bn.strip() and r.name_en.strip(), r.id
        assert r.traditions == ("drik_bishuddha",), r.id


def test_sandhi_puja_rides_on_maha_ashtami():
    assert "sandhi_puja" in RULES["durga_ashtami"].windows


def test_draft_files_say_so_and_name_the_open_questions():
    for path in RULES_DIR.glob("*.yaml"):
        head = path.read_text(encoding="utf-8").splitlines()[:3]
        assert head[0].startswith("# DRAFT"), path.name
        assert "TODO(Q2)" in head[1], path.name
        assert head[2].startswith("# Expert to confirm:"), path.name


def test_every_rule_has_native_descriptions_awaiting_review():
    # T-504: 80–150 words in each language (spec §13.8), not reviewed yet.
    for r in RULES.values():
        assert r.description_bn and r.description_en, r.id
        for text in (r.description_bn, r.description_en):
            assert 80 <= len(text.split()) <= 150, (r.id, len(text.split()))
        assert r.description_review == "pending", r.id


def _info(summary: dict) -> builder.PackInfo:
    return builder.PackInfo(
        "observances-drik_bishuddha-2026-04-14-2027-04-13-v1",
        "observances",
        "drik_bishuddha",
        1,
        "2026-04-14",
        "2027-04-13",
        False,
        summary,
    )


def test_release_refuses_draft_rules_and_draft_moments():
    drafts = {"draft_rules": ["kali_puja"], "moments_review": "reviewed"}
    with pytest.raises(builder.PackRejected, match="draft observance rules"):
        builder.check_releasable(_info(drafts), release=True, allow_sample=False, allow_dev=False)
    moments = {"draft_rules": [], "moments_review": "draft"}
    with pytest.raises(builder.PackRejected, match="moment definitions"):
        builder.check_releasable(_info(moments), release=True, allow_sample=False, allow_dev=False)
    unknown = {"moments_review": "reviewed"}  # a pack that doesn't say: treated as drafts
    with pytest.raises(builder.PackRejected, match="draft observance rules"):
        builder.check_releasable(_info(unknown), release=True, allow_sample=False, allow_dev=False)


def test_release_accepts_reviewed_rules_and_staging_accepts_drafts():
    ok = {"draft_rules": [], "moments_review": "reviewed", "pending_descriptions": []}
    builder.check_releasable(_info(ok), release=True, allow_sample=False, allow_dev=False)
    drafts = {"draft_rules": ["kali_puja"], "moments_review": "draft"}
    builder.check_releasable(_info(drafts), release=False, allow_sample=False, allow_dev=False)


def test_release_refuses_unreviewed_descriptions():
    pending = {
        "draft_rules": [],
        "moments_review": "reviewed",
        "pending_descriptions": ["kali_puja"],
    }
    with pytest.raises(builder.PackRejected, match="descriptions not reviewed"):
        builder.check_releasable(_info(pending), release=True, allow_sample=False, allow_dev=False)


def test_observance_packs_on_a_dev_ephemeris_are_refused():
    dev = {"draft_rules": [], "moments_review": "reviewed", "dev_ephemeris": True}
    with pytest.raises(builder.PackRejected, match="dev ephemeris"):
        builder.check_releasable(_info(dev), release=False, allow_sample=False, allow_dev=False)
