import os
import sys
from pathlib import Path

# Make `engine`, `validate` and `pack` importable without installing the project.
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import sqlite3

import pytest

from pack import sample


@pytest.fixture(scope="session")
def packs(tmp_path_factory) -> dict[str, sqlite3.Connection]:
    """The three sample packs, built once per test run."""
    out = tmp_path_factory.mktemp("sample")
    paths = sample.build(out)
    return {p.stem: sqlite3.connect(p) for p in paths}


# Hypothesis profiles (T-218): quick locally; more examples and a fixed seed in CI, so
# a CI failure reproduces exactly and a pass never depends on luck.
from hypothesis import HealthCheck, settings  # noqa: E402

settings.register_profile("dev", max_examples=50)
settings.register_profile(
    "ci",
    max_examples=500,
    derandomize=True,
    deadline=None,
    print_blob=True,
    suppress_health_check=[HealthCheck.too_slow],
)
settings.load_profile(os.environ.get("HYPOTHESIS_PROFILE", "dev"))
