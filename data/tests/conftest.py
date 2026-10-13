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
