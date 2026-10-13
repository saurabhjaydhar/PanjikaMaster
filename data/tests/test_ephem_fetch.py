"""T-201: the ephemeris is pinned by checksum; mismatches and partial files fail.

These tests exercise the verification logic with small local files; no network.
"""

import hashlib
import json
from pathlib import Path

import pytest

from ephem import fetch as f

CONTENT = b"not a real ephemeris, just bytes for the lock logic"


def write_lock(tmp: Path, **overrides) -> Path:
    lock = {
        "file": "de440s.bsp",
        "sources": ["https://example.invalid/de440s.bsp"],
        "size": None,
        "sha256": None,
        "recorded_at": None,
        "confirmed_by": None,
        "confirmed_on": None,
    }
    lock.update(overrides)
    path = tmp / "ephemeris.lock.json"
    path.write_text(json.dumps(lock), encoding="utf-8")
    return path


@pytest.fixture
def fake_download(monkeypatch):
    calls = []

    def download(url, dest):
        calls.append(url)
        dest.write_bytes(CONTENT)

    monkeypatch.setattr(f, "download", download)
    return calls


def test_first_run_records_checksum_as_unconfirmed(tmp_path, fake_download):
    lock_path = write_lock(tmp_path)
    f.fetch(lock_path=lock_path, ephem_dir=tmp_path)
    lock = json.loads(lock_path.read_text())
    assert lock["sha256"] == hashlib.sha256(CONTENT).hexdigest()
    assert lock["size"] == len(CONTENT)
    assert lock["confirmed_by"] is None
    assert fake_download == ["https://example.invalid/de440s.bsp"]


def test_rerun_verifies_and_does_not_download_again(tmp_path, fake_download):
    lock_path = write_lock(tmp_path)
    f.fetch(lock_path=lock_path, ephem_dir=tmp_path)
    f.fetch(lock_path=lock_path, ephem_dir=tmp_path)
    assert len(fake_download) == 1


def test_checksum_mismatch_fails(tmp_path):
    (tmp_path / "de440s.bsp").write_bytes(CONTENT)
    lock_path = write_lock(tmp_path, size=len(CONTENT), sha256="0" * 64)
    with pytest.raises(f.EphemerisError, match="SHA-256"):
        f.fetch(lock_path=lock_path, ephem_dir=tmp_path)


def test_size_mismatch_reports_partial_download(tmp_path):
    (tmp_path / "de440s.bsp").write_bytes(CONTENT[:10])
    lock_path = write_lock(tmp_path, size=len(CONTENT), sha256=hashlib.sha256(CONTENT).hexdigest())
    with pytest.raises(f.EphemerisError, match="partial download"):
        f.fetch(lock_path=lock_path, ephem_dir=tmp_path)


def test_check_only_never_downloads(tmp_path, fake_download):
    lock_path = write_lock(tmp_path)
    with pytest.raises(f.EphemerisError, match="missing"):
        f.fetch(check_only=True, lock_path=lock_path, ephem_dir=tmp_path)
    assert fake_download == []


def test_require_confirmed(tmp_path):
    (tmp_path / "de440s.bsp").write_bytes(CONTENT)
    digest = hashlib.sha256(CONTENT).hexdigest()
    lock_path = write_lock(tmp_path, size=len(CONTENT), sha256=digest)
    with pytest.raises(f.EphemerisError, match="not confirmed"):
        f.fetch(require_confirmed=True, lock_path=lock_path, ephem_dir=tmp_path)
    lock_path = write_lock(
        tmp_path, size=len(CONTENT), sha256=digest, confirmed_by="SJ", confirmed_on="2026-10-12"
    )
    f.fetch(require_confirmed=True, lock_path=lock_path, ephem_dir=tmp_path)


def test_falls_back_to_next_source(tmp_path, monkeypatch):
    calls = []

    def download(url, dest):
        calls.append(url)
        if "first" in url:
            raise OSError("blocked")
        dest.write_bytes(CONTENT)

    monkeypatch.setattr(f, "download", download)
    lock_path = write_lock(
        tmp_path, sources=["https://first.invalid/x", "https://second.invalid/x"]
    )
    f.fetch(lock_path=lock_path, ephem_dir=tmp_path)
    assert calls == ["https://first.invalid/x", "https://second.invalid/x"]


def test_all_sources_failing_is_an_error(tmp_path, monkeypatch):
    def download(url, dest):
        raise OSError("blocked")

    monkeypatch.setattr(f, "download", download)
    lock_path = write_lock(tmp_path)
    with pytest.raises(f.EphemerisError, match="could not download"):
        f.fetch(lock_path=lock_path, ephem_dir=tmp_path)
    assert not (tmp_path / "de440s.bsp").exists()


def test_committed_lock_names_de440s_and_is_not_confirmed_by_the_agent():
    lock = f.load_lock()
    assert lock["file"] == "de440s.bsp"
    assert all(u.startswith("https://") for u in lock["sources"])
    assert lock["confirmed_by"] is None, "only a human may confirm the checksum"
