"""T-218: the CI Hypothesis profile is active in CI, and property tests run under it."""

import os
import unicodedata

from hypothesis import given, settings
from hypothesis import strategies as st

from pack import sample


def test_profile_follows_the_environment():
    expected = os.environ.get("HYPOTHESIS_PROFILE", "dev")
    assert settings.get_current_profile_name() == expected
    if expected == "ci":
        assert settings().derandomize and settings().max_examples >= 500


@given(st.text())
def test_translit_is_lower_case_ascii(en):
    # Search keys for names (spec §13.6) must be plain ASCII, whatever the input.
    out = sample.translit({"en": en})
    assert out.isascii()
    assert out == out.lower()


@given(st.text(alphabet=st.characters(categories=["Lu", "Ll"])))
def test_translit_keeps_unaccented_latin_letters(en):
    expected = unicodedata.normalize("NFKD", en).encode("ascii", "ignore").decode().lower()
    assert sample.translit({"en": en}) == expected
