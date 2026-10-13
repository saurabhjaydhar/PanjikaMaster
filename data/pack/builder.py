"""Pack builder (spec §6.4 step 5, §15.2–15.3, T-303).

`python -m pack.builder --in dist/<a>.sqlite [--in …] --out dist/v1 [--release]`

For each input database: check it, gzip it (deterministic bytes), sign the gzip bytes
with Ed25519 (`<pack>.sqlite.gz.sig`, raw 64 bytes), then write `manifest.json` listing
every pack with its size and SHA-256. The private key comes only from the environment
(`PANJIKA_SIGNING_KEY`: base64 of the 32-byte seed); who holds which key is Q12.

Refuses: a row missing its Bengali or English text (FR-L10N-09); sample packs; packs
computed on a dev ephemeris; and with --release, an ephemeris checksum that a human has
not confirmed.
"""

import argparse
import base64
import gzip
import hashlib
import json
import os
import sqlite3
import sys
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path

from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

KEY_ENV = "PANJIKA_SIGNING_KEY"
MANIFEST_SCHEMA = 1

# (table, columns that must both be non-empty)
BILINGUAL = {
    "names": ("name_bn", "name_en"),
    "cities": ("name_bn", "name_en"),
    "observances": ("name_bn", "name_en", "description_bn", "description_en"),
}


class PackRejected(ValueError):
    pass


@dataclass(frozen=True)
class PackInfo:
    id: str
    kind: str
    tradition: str
    version: int
    covers_from: str
    covers_to: str
    is_sample: bool
    summary: dict


def load_key() -> Ed25519PrivateKey:
    raw = os.environ.get(KEY_ENV)
    if not raw:
        raise PackRejected(f"{KEY_ENV} is not set (signing keys come from env/CI only)")
    try:
        seed = base64.b64decode(raw, validate=True)
    except ValueError as e:  # binascii.Error is a ValueError
        raise PackRejected(f"{KEY_ENV} is not valid base64") from e
    if len(seed) != 32:
        raise PackRejected(f"{KEY_ENV} must be base64 of a 32-byte Ed25519 seed")
    return Ed25519PrivateKey.from_private_bytes(seed)


def public_key_b64(key: Ed25519PrivateKey) -> str:
    raw = key.public_key().public_bytes(serialization.Encoding.Raw, serialization.PublicFormat.Raw)
    return base64.b64encode(raw).decode()


def inspect(path: Path) -> PackInfo:
    conn = sqlite3.connect(path)
    rows = conn.execute(
        "SELECT id, kind, tradition, version, covers_from, covers_to, is_sample,"
        " validation_summary FROM packs"
    ).fetchall()
    if len(rows) != 1:
        raise PackRejected(f"{path.name}: expected exactly one packs row, found {len(rows)}")
    pid, kind, tradition, version, f, t, sample, summary = rows[0]
    try:
        meta = json.loads(summary or "{}")
    except json.JSONDecodeError:
        meta = {}
    for table, cols in BILINGUAL.items():
        cond = " OR ".join(f"trim(coalesce({c}, '')) = ''" for c in cols)
        bad = conn.execute(f"SELECT count(*) FROM {table} WHERE {cond}").fetchone()[0]
        if bad:
            raise PackRejected(f"{path.name}: {bad} {table} rows lack Bengali or English text")
    return PackInfo(pid, kind, tradition, version, f, t, bool(sample), meta)


def check_releasable(info: PackInfo, *, release: bool, allow_sample: bool, allow_dev: bool):
    if info.is_sample and not allow_sample:
        raise PackRejected(f"{info.id}: sample packs are never published")
    eph = info.summary.get("ephemeris", {})
    if info.kind == "global" and not eph.get("locked", False) and not allow_dev:
        raise PackRejected(f"{info.id}: computed on a dev ephemeris")
    if release and info.kind == "global" and not eph.get("confirmed_by_human"):
        raise PackRejected(f"{info.id}: ephemeris checksum not confirmed by a human")
    if info.kind == "observances":
        if info.summary.get("dev_ephemeris") and not allow_dev:
            raise PackRejected(f"{info.id}: computed on a dev ephemeris")
        # Draft rules and draft moment definitions never reach production (T-502).
        drafts = info.summary.get("draft_rules")
        if release and (drafts is None or drafts):
            raise PackRejected(f"{info.id}: draft observance rules {drafts or '(unknown)'}")
        if release and info.summary.get("moments_review") != "reviewed":
            raise PackRejected(f"{info.id}: moment definitions are not reviewed")
        # Descriptions go out only after a human review (spec §13.8, T-504).
        pending = info.summary.get("pending_descriptions")
        if release and (pending is None or pending):
            raise PackRejected(f"{info.id}: descriptions not reviewed {pending or '(unknown)'}")


def manifest_id(info: PackInfo) -> str:
    """The pack's id without its version suffix (manifest `id`, spec §15.3)."""
    suffix = f"-v{info.version}"
    return info.id[: -len(suffix)] if info.id.endswith(suffix) else info.id


def generated_at() -> str:
    epoch = os.environ.get("SOURCE_DATE_EPOCH")
    when = datetime.fromtimestamp(int(epoch), UTC) if epoch else datetime.now(UTC)
    return when.strftime("%Y-%m-%dT%H:%M:%SZ")


def build(
    inputs: list[Path],
    out: Path,
    *,
    min_app_version: str = "1.0.0",
    notices: list[dict] | None = None,
    release: bool = False,
    allow_sample: bool = False,
    allow_dev: bool = False,
) -> Path:
    key = load_key()
    packs_dir = out / "packs"
    packs_dir.mkdir(parents=True, exist_ok=True)
    entries = []
    for path in sorted(inputs):
        info = inspect(path)
        check_releasable(info, release=release, allow_sample=allow_sample, allow_dev=allow_dev)
        name = f"{info.id}.sqlite.gz"
        target = packs_dir / name
        if release and target.exists():
            raise PackRejected(f"{name} already exists: published versions are never overwritten")
        data = gzip.compress(path.read_bytes(), compresslevel=9, mtime=0)
        target.write_bytes(data)
        (packs_dir / f"{name}.sig").write_bytes(key.sign(data))
        entries.append(
            {
                "id": manifest_id(info),
                "kind": info.kind,
                "tradition": info.tradition,
                "version": info.version,
                "covers": [info.covers_from, info.covers_to],
                "url": f"/v1/packs/{name}",
                "size": len(data),
                "sha256": hashlib.sha256(data).hexdigest(),
                "sig_url": f"/v1/packs/{name}.sig",
            }
        )
    manifest = {
        "schema": MANIFEST_SCHEMA,
        "generated_at": generated_at(),
        "min_app_version": min_app_version,
        "packs": entries,
        "notices": notices or [],
    }
    for n in manifest["notices"]:
        if not (n.get("text_bn", "").strip() and n.get("text_en", "").strip()):
            raise PackRejected(f"notice {n.get('id')!r} lacks Bengali or English text")
    path = out / "manifest.json"
    path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return path


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(prog="python -m pack.builder")
    p.add_argument("--in", dest="inputs", type=Path, action="append", required=True)
    p.add_argument("--out", type=Path, default=Path("dist/v1"))
    p.add_argument("--min-app-version", default="1.0.0")
    p.add_argument("--notices", type=Path, help="JSON list of {id, level, text_bn, text_en, until}")
    p.add_argument("--release", action="store_true")
    p.add_argument("--allow-dev-ephemeris", action="store_true", help="staging/tests only")
    args = p.parse_args(argv)
    notices = json.loads(args.notices.read_text(encoding="utf-8")) if args.notices else []
    try:
        path = build(
            args.inputs,
            args.out,
            min_app_version=args.min_app_version,
            notices=notices,
            release=args.release,
            allow_dev=args.allow_dev_ephemeris,
        )
    except PackRejected as e:
        print(f"REJECTED: {e}", file=sys.stderr)
        return 1
    print(f"wrote {path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
