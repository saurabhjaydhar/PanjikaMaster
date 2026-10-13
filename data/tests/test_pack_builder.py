"""T-303: pack builder — gzip + Ed25519 + manifest, and every refusal."""

import base64
import gzip
import hashlib
import json
import shutil
import sqlite3

import pytest
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

from pack import builder, sample

SEED = bytes(range(32))  # test-only key; never used outside tests


@pytest.fixture
def key(monkeypatch):
    monkeypatch.setenv(builder.KEY_ENV, base64.b64encode(SEED).decode())
    monkeypatch.setenv("SOURCE_DATE_EPOCH", "1800000000")
    return Ed25519PrivateKey.from_private_bytes(SEED)


@pytest.fixture
def sample_packs(tmp_path):
    return sample.build(tmp_path / "src")


def as_computed(src, dst, *, locked=True, confirmed=False):
    """A copy of a sample pack relabelled as computed (test input for the checks)."""
    shutil.copy(src, dst)
    conn = sqlite3.connect(dst)
    meta = {"ephemeris": {"locked": locked, "confirmed_by_human": confirmed}}
    with conn:
        conn.execute("UPDATE packs SET is_sample = 0, validation_summary = ?", (json.dumps(meta),))
    return dst


def test_gzip_signature_and_manifest(key, sample_packs, tmp_path):
    out = tmp_path / "v1"
    manifest = builder.build(sample_packs, out, allow_sample=True, allow_dev=True)
    m = json.loads(manifest.read_text())
    assert m["schema"] == 1 and m["generated_at"] == "2027-01-15T08:00:00Z"
    assert len(m["packs"]) == 3
    for entry in m["packs"]:
        data = (out / entry["url"].removeprefix("/v1/")).read_bytes()
        assert entry["size"] == len(data)
        assert entry["sha256"] == hashlib.sha256(data).hexdigest()
        sig = (out / entry["sig_url"].removeprefix("/v1/")).read_bytes()
        key.public_key().verify(sig, data)  # raises if invalid
        assert gzip.decompress(data)[:16] == b"SQLite format 3\x00"


def test_output_is_deterministic(key, sample_packs, tmp_path):
    a = builder.build(sample_packs, tmp_path / "a", allow_sample=True, allow_dev=True)
    b = builder.build(sample_packs, tmp_path / "b", allow_sample=True, allow_dev=True)
    assert a.read_bytes() == b.read_bytes()
    for f in (tmp_path / "a" / "packs").iterdir():
        assert f.read_bytes() == (tmp_path / "b" / "packs" / f.name).read_bytes()


def test_manifest_id_drops_the_version(tmp_path):
    info = builder.PackInfo("global-drik-2020-2045-v3", "global", "x", 3, "a", "b", False, {})
    assert builder.manifest_id(info) == "global-drik-2020-2045"


def test_refuses_sample_packs(key, sample_packs, tmp_path):
    with pytest.raises(builder.PackRejected, match="sample"):
        builder.build(sample_packs, tmp_path / "v1")


def test_refuses_a_row_missing_a_language(key, sample_packs, tmp_path):
    bad = as_computed(sample_packs[0], tmp_path / "bad.sqlite")
    with sqlite3.connect(bad) as conn:
        conn.execute("UPDATE names SET name_en = ' ' WHERE kind = 'tithi' AND idx = 3")
    with pytest.raises(builder.PackRejected, match="Bengali or English"):
        builder.build([bad], tmp_path / "v1")


def test_refuses_a_dev_ephemeris_global_pack(key, sample_packs, tmp_path):
    src = next(p for p in sample_packs if "global" in p.name)
    dev = as_computed(src, tmp_path / "dev.sqlite", locked=False)
    with pytest.raises(builder.PackRejected, match="dev ephemeris"):
        builder.build([dev], tmp_path / "v1")
    builder.build([dev], tmp_path / "staging", allow_dev=True)  # staging may


def test_release_needs_a_confirmed_checksum_and_never_overwrites(key, sample_packs, tmp_path):
    src = next(p for p in sample_packs if "global" in p.name)
    unconfirmed = as_computed(src, tmp_path / "u.sqlite", confirmed=False)
    with pytest.raises(builder.PackRejected, match="not confirmed"):
        builder.build([unconfirmed], tmp_path / "v1", release=True)
    confirmed = as_computed(src, tmp_path / "c.sqlite", confirmed=True)
    builder.build([confirmed], tmp_path / "v1", release=True)
    with pytest.raises(builder.PackRejected, match="never overwritten"):
        builder.build([confirmed], tmp_path / "v1", release=True)


def test_needs_the_key_from_the_environment(sample_packs, tmp_path, monkeypatch):
    monkeypatch.delenv(builder.KEY_ENV, raising=False)
    with pytest.raises(builder.PackRejected, match="not set"):
        builder.build(sample_packs, tmp_path / "v1", allow_sample=True, allow_dev=True)


@pytest.mark.parametrize("bad", ["x", "not base64!", base64.b64encode(b"short").decode()])
def test_a_malformed_key_is_rejected_clearly(sample_packs, tmp_path, monkeypatch, bad):
    monkeypatch.setenv(builder.KEY_ENV, bad)
    with pytest.raises(builder.PackRejected, match=builder.KEY_ENV):
        builder.build(sample_packs, tmp_path / "v1", allow_sample=True, allow_dev=True)


def test_notices_need_both_languages(key, sample_packs, tmp_path):
    with pytest.raises(builder.PackRejected, match="notice"):
        builder.build(
            sample_packs,
            tmp_path / "v1",
            allow_sample=True,
            allow_dev=True,
            notices=[{"id": "n1", "level": "info", "text_bn": "x", "text_en": ""}],
        )


def test_cli_reports_rejections(key, sample_packs, tmp_path, capsys):
    args = [x for p in sample_packs for x in ("--in", str(p))] + ["--out", str(tmp_path / "v1")]
    assert builder.main(args) == 1
    assert "REJECTED" in capsys.readouterr().err
