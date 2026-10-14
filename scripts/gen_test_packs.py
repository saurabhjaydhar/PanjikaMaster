#!/usr/bin/env python3
"""Generate app/test/fixtures/packs/ — signed SAMPLE packs for the app's importer tests
(T-303/T-306).

The sample packs go through the real pack builder, signed with a fixed TEST key (its
seed is public; it never signs anything outside tests). Also writes a v2 of the global
pack, identical rows under a new id and version, for the upgrade test, and a correction
v2 of the observances pack (T-603) in which one sample observance moves by a day, for
the correction test. Test-only: app assets never include this folder.

`--check` (CI) verifies the committed files instead of comparing bytes, since SQLite file
bytes can differ between SQLite versions: every signature valid, every SHA-256 as in its
manifest, and every table's rows equal to a fresh build of the sample packs.
"""

import base64
import gzip
import hashlib
import json
import os
import shutil
import sqlite3
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "data"))

from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey  # noqa: E402

from pack import builder, correction, sample, schema  # noqa: E402

DST = ROOT / "app" / "test" / "fixtures" / "packs"
TEST_SEED = bytes(range(32))  # TEST ONLY


def make_v2(src: Path, dst: Path) -> Path:
    shutil.copy(src, dst)
    conn = sqlite3.connect(dst)
    old = conn.execute("SELECT id FROM packs").fetchone()[0]
    new = f"{old}-v2"
    with conn:
        conn.execute("PRAGMA foreign_keys = OFF")
        conn.execute("UPDATE packs SET id = ?, version = 2", (new,))
        for table in schema.PACK_TABLES[1:]:
            if "pack_id" in schema.columns(conn, table):
                conn.execute(f"UPDATE {table} SET pack_id = ? WHERE pack_id = ?", (new, old))
    conn.execute("VACUUM")
    conn.close()
    return dst


def make_correction(src: Path, dst: Path) -> Path:
    """Observances v2 with the synthetic sample's Kali Puja one day later."""
    make_v2(src, dst)
    conn = sqlite3.connect(dst)
    with conn:
        conn.execute("PRAGMA foreign_keys = OFF")
        for table in ("observance_dates", "observance_windows"):
            conn.execute(
                f"UPDATE {table} SET date = date(date, '+1 day') WHERE observance_id = 'kali_puja'"
            )
    conn.close()
    correction.correct(src, dst, ["kali_puja"], "test fixture: a moved sample observance")
    return dst


def rows(db: Path) -> dict[str, list[tuple]]:
    conn = sqlite3.connect(db)
    return {t: sorted(conn.execute(f"SELECT * FROM {t}").fetchall()) for t in schema.PACK_TABLES}


def generate(out: Path) -> None:
    os.environ[builder.KEY_ENV] = base64.b64encode(TEST_SEED).decode()
    os.environ.setdefault("SOURCE_DATE_EPOCH", "1791763200")  # fixed, reproducible manifest
    with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as tmp:  # Windows
        tmp = Path(tmp)
        packs = sample.build(tmp / "src")
        builder.build(packs, out, allow_sample=True, allow_dev=True)
        glob = next(p for p in packs if "global" in p.name)
        v2 = make_v2(glob, tmp / "global-v2.sqlite")
        builder.build([v2], tmp / "v2", allow_sample=True, allow_dev=True)
        shutil.copy(tmp / "v2" / "manifest.json", out / "manifest_v2.json")
        for f in (tmp / "v2" / "packs").iterdir():
            shutil.copy(f, out / "packs" / f.name)
        obs = next(p for p in packs if "observances" in p.name)
        fix = make_correction(obs, tmp / "observances-v2.sqlite")
        builder.build([fix], tmp / "fix", allow_sample=True, allow_dev=True)
        shutil.copy(tmp / "fix" / "manifest.json", out / "manifest_correction.json")
        for f in (tmp / "fix" / "packs").iterdir():
            shutil.copy(f, out / "packs" / f.name)
    key = Ed25519PrivateKey.from_private_bytes(TEST_SEED)
    (out / "test_public_key.txt").write_text(builder.public_key_b64(key) + "\n")


def check() -> list[str]:
    errors = []
    key = Ed25519PrivateKey.from_private_bytes(TEST_SEED).public_key()
    with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as tmp:  # Windows
        expected = Path(tmp) / "expected"
        generate(expected)
        for manifest in ("manifest.json", "manifest_v2.json", "manifest_correction.json"):
            committed = json.loads((DST / manifest).read_text())
            fresh = json.loads((expected / manifest).read_text())
            if [e["id"] for e in committed["packs"]] != [e["id"] for e in fresh["packs"]]:
                errors.append(f"{manifest}: pack list differs")
            for e in committed["packs"]:
                name = e["url"].rsplit("/", 1)[1]
                data = (DST / "packs" / name).read_bytes()
                if hashlib.sha256(data).hexdigest() != e["sha256"] or len(data) != e["size"]:
                    errors.append(f"{name}: SHA-256 or size differs from {manifest}")
                try:
                    key.verify((DST / "packs" / f"{name}.sig").read_bytes(), data)
                except Exception:
                    errors.append(f"{name}: bad signature")
                ours, theirs = Path(tmp) / "c.sqlite", Path(tmp) / "f.sqlite"
                ours.write_bytes(gzip.decompress(data))
                theirs.write_bytes(gzip.decompress((expected / "packs" / name).read_bytes()))
                if rows(ours) != rows(theirs):
                    errors.append(f"{name}: rows differ from the sample packs")
    return errors


def main() -> int:
    if "--check" in sys.argv:
        errors = check()
        for e in errors:
            print(e)
        if errors:
            print("run: python scripts/gen_test_packs.py")
            return 1
        print("test packs are up to date")
        return 0
    if DST.exists():
        shutil.rmtree(DST)
    generate(DST)
    print(f"wrote {DST.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
