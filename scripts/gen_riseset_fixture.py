#!/usr/bin/env python3
"""Generate app/test/fixtures/riseset.json, the shared rise/set fixture (T-315).

The app's on-device rise/set (T-317) must match the pipeline within ±5 s (Sun) and
±10 s (Moon) for every place and day in it (spec §6.5.5). Needs the locked DE440s.
`--check` (used by CI) fails if the committed file differs from a fresh build beyond
rounding (events by more than 1 s, coefficients by more than 1e-9 relative).
"""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "data"))

from engine import ephemeris  # noqa: E402
from engine.astro import Astro  # noqa: E402
from ephem import fetch  # noqa: E402
from validate import riseset_fixture  # noqa: E402

DST = ROOT / "app" / "test" / "fixtures" / "riseset.json"


def main() -> int:
    eph = ephemeris.resolve(require_locked=True)
    fresh = riseset_fixture.build(Astro(eph), fetch.sha256_file(eph))
    if "--check" in sys.argv:
        if not DST.exists():
            print(f"{DST.relative_to(ROOT)} is missing: run python scripts/gen_riseset_fixture.py")
            return 1
        errors = riseset_fixture.differences(json.loads(DST.read_text(encoding="utf-8")), fresh)
        for e in errors[:20]:
            print(e)
        if errors:
            print(f"{DST.relative_to(ROOT)} is stale: run python scripts/gen_riseset_fixture.py")
            return 1
        print("riseset.json is up to date")
        return 0
    DST.write_text(json.dumps(fresh, indent=1) + "\n", encoding="utf-8", newline="\n")
    print(f"wrote {DST.relative_to(ROOT)}: {DST.stat().st_size // 1024} KB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
