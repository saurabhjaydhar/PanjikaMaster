#!/usr/bin/env python3
"""Generate app/lib/data/db/pack_tables.drift from data/pack/schema.sql (T-106).

The pack schema has one source of truth (data/pack/schema.sql). The app's Drift
database imports the generated file, so the two cannot drift apart. Run after
any schema change; `--check` (used by CI) fails if the generated file is stale.
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "data" / "pack" / "schema.sql"
DST = ROOT / "app" / "lib" / "data" / "db" / "pack_tables.drift"
HEADER = (
    "-- GENERATED from data/pack/schema.sql by scripts/sync_drift_schema.py. Do not edit.\n"
    "-- Change the schema there, then run: python scripts/sync_drift_schema.py\n\n"
)


def render() -> str:
    sql = SRC.read_text(encoding="utf-8")
    # Drift files can't contain PRAGMAs; the schema version lives in AppDatabase.
    sql = re.sub(r"^PRAGMA [^;]*;\n", "", sql, flags=re.M)
    # Name row classes <Table>Row (e.g. BengaliDateRow) so they never clash with domain entities.
    sql = re.sub(
        r"^CREATE TABLE (\w+) \((.*?)^\) STRICT;",
        lambda m: f"CREATE TABLE {m[1]} ({m[2]}) STRICT AS {row_class(m[1])};",
        sql,
        flags=re.M | re.S,
    )
    return HEADER + sql


def row_class(table: str) -> str:
    if table.endswith("ies"):
        singular = table[:-3] + "y"
    elif table.endswith("s"):
        singular = table[:-1]
    else:
        singular = table
    return "".join(part.capitalize() for part in singular.split("_")) + "Row"


def main() -> int:
    content = render()
    if "--check" in sys.argv:
        if not DST.exists() or DST.read_text(encoding="utf-8") != content:
            print(
                f"{DST.relative_to(ROOT)} is out of date: run python scripts/sync_drift_schema.py"
            )
            return 1
        print("pack_tables.drift is in sync with schema.sql")
        return 0
    DST.write_text(content, encoding="utf-8")
    print(f"wrote {DST.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
