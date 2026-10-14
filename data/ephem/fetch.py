"""Fetch and verify the JPL DE440s ephemeris (T-201, spec §6.4).

The ephemeris is the root of every computed date, so its bytes are pinned by SHA-256
in ``ephem/ephemeris.lock.json`` (committed). The ``.bsp`` file itself is not committed
and is never shipped in the app.

* First run (lock has no checksum): download, record size and SHA-256 as UNCONFIRMED.
  A human then confirms it (records ``confirmed_by`` / ``confirmed_on``) — Phase 2 gate.
* Later runs: an existing or downloaded file must match the lock, or the run fails.
* ``--require-confirmed`` (production pack builds): fail unless a human confirmed it.

Usage::

    uv run python -m ephem.fetch            # download if missing, then verify
    uv run python -m ephem.fetch --check    # verify the existing file only
"""

import argparse
import hashlib
import json
import sys
import tempfile
import urllib.request
from datetime import UTC, datetime
from pathlib import Path

EPHEM_DIR = Path(__file__).resolve().parent
LOCK_PATH = EPHEM_DIR / "ephemeris.lock.json"


class EphemerisError(RuntimeError):
    pass


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def load_lock(lock_path: Path = LOCK_PATH) -> dict:
    return json.loads(lock_path.read_text(encoding="utf-8"))


def save_lock(lock: dict, lock_path: Path = LOCK_PATH) -> None:
    lock_path.write_text(json.dumps(lock, indent=2) + "\n", encoding="utf-8")


def ephemeris_path(lock: dict, ephem_dir: Path = EPHEM_DIR) -> Path:
    return ephem_dir / lock["file"]


def download(url: str, dest: Path) -> None:
    """Download to a temporary file next to ``dest``, then move it into place, so a
    partial download never looks like a complete one."""
    with tempfile.NamedTemporaryFile(dir=dest.parent, delete=False) as tmp:
        tmp_path = Path(tmp.name)
    # Unlink only after the file is closed: Windows refuses to delete an open file, and
    # that error would hide the download error.
    try:
        with tmp_path.open("wb") as out, urllib.request.urlopen(url, timeout=120) as response:
            for block in iter(lambda: response.read(1 << 20), b""):
                out.write(block)
    except BaseException:
        tmp_path.unlink(missing_ok=True)
        raise
    tmp_path.replace(dest)


def verify(path: Path, lock: dict) -> None:
    """Raise unless ``path`` matches the locked size and SHA-256."""
    if lock.get("sha256") is None:
        raise EphemerisError("lock has no checksum yet; run without --check to record it")
    if lock.get("size") is not None and path.stat().st_size != lock["size"]:
        raise EphemerisError(
            f"{path.name}: size {path.stat().st_size} != locked {lock['size']} (partial download?)"
        )
    actual = sha256_file(path)
    if actual != lock["sha256"]:
        raise EphemerisError(f"{path.name}: SHA-256 {actual} != locked {lock['sha256']}")


def fetch(
    *,
    check_only: bool = False,
    require_confirmed: bool = False,
    lock_path: Path = LOCK_PATH,
    ephem_dir: Path = EPHEM_DIR,
) -> Path:
    lock = load_lock(lock_path)
    path = ephemeris_path(lock, ephem_dir)

    if not path.exists():
        if check_only:
            raise EphemerisError(f"{path} is missing; run `python -m ephem.fetch` to download it")
        errors = []
        for url in lock["sources"]:
            try:
                download(url, path)
                break
            except OSError as e:  # URLError, HTTPError and network errors
                errors.append(f"{url}: {e}")
        else:
            raise EphemerisError("could not download the ephemeris:\n  " + "\n  ".join(errors))

    if lock.get("sha256") is None:
        lock.update(
            size=path.stat().st_size,
            sha256=sha256_file(path),
            recorded_at=datetime.now(UTC).strftime("%Y-%m-%dT%H:%M:%SZ"),
            confirmed_by=None,
            confirmed_on=None,
        )
        save_lock(lock, lock_path)
        print(
            f"Recorded {lock['file']} SHA-256 {lock['sha256']} ({lock['size']} bytes) as "
            "UNCONFIRMED. A human must confirm it in ephemeris.lock.json (Phase 2 gate)."
        )
    else:
        verify(path, lock)

    if require_confirmed and not lock.get("confirmed_by"):
        raise EphemerisError("ephemeris checksum is not confirmed by a human (confirmed_by)")
    return path


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Fetch and verify the JPL DE440s ephemeris.")
    parser.add_argument("--check", action="store_true", help="verify the existing file only")
    parser.add_argument(
        "--require-confirmed", action="store_true", help="fail unless a human confirmed it"
    )
    args = parser.parse_args(argv)
    try:
        path = fetch(check_only=args.check, require_confirmed=args.require_confirmed)
    except EphemerisError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1
    print(f"OK: {path.name} matches the lock")
    return 0


if __name__ == "__main__":
    sys.exit(main())
