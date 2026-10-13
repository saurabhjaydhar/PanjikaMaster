"""Correction packs (spec §18, T-603).

`python -m pack.correction --base <published v N>.sqlite --new <rebuilt v N+1>.sqlite
    --observance <id> [--observance <id> …] --reason "<why, for the audit trail>"`

A correction is the next version of an observances pack, rebuilt after a rule, config
or override fix (never by editing output rows, spec §6.7). This tool proves that the
rebuild changes only the observances it is meant to correct: every other row, in every
table, must be identical to the published version (apart from `pack_id`), and every
declared observance must really have changed dates or windows. It then records the
correction in the new pack's `validation_summary`:

    "correction": {"of_version": N, "observances": [...], "reason": "..."}

The app's importer replaces only the rows that differ and flags the changed
observances as corrected for 7 days. The pack then goes through `pack.builder` as usual.
"""

import argparse
import json
import sqlite3
import sys
from collections import defaultdict
from pathlib import Path

from pack import builder, schema

# Observance tables and the column holding the observance id.
OBSERVANCE_TABLES = {
    "observances": "id",
    "observance_dates": "observance_id",
    "observance_windows": "observance_id",
}
# Changes here count as a date correction (a description fix does not).
DATE_TABLES = ("observance_dates", "observance_windows")


class CorrectionRejected(ValueError):
    pass


def _rows(conn: sqlite3.Connection, table: str) -> tuple[list[str], set[tuple]]:
    cols = [c for c in schema.columns(conn, table) if c != "pack_id"]
    rows = set(conn.execute(f"SELECT {', '.join(cols)} FROM {table}"))
    return cols, rows


def changed_observances(base: Path, new: Path) -> dict[str, set[str]]:
    """Per observance table, the observance ids whose rows differ; raises if any other
    table differs at all."""
    a, b = sqlite3.connect(base), sqlite3.connect(new)
    changed: dict[str, set[str]] = defaultdict(set)
    for table in schema.PACK_TABLES:
        if table == "packs":
            continue
        cols, old = _rows(a, table)
        _, cur = _rows(b, table)
        diff = old ^ cur
        if not diff:
            continue
        if table not in OBSERVANCE_TABLES:
            raise CorrectionRejected(
                f"{table}: {len(diff)} rows differ; a correction may only change observances"
            )
        key = cols.index(OBSERVANCE_TABLES[table])
        changed[table] |= {row[key] for row in diff}
    return changed


def correct(base: Path, new: Path, observances: list[str], reason: str) -> dict:
    if not reason.strip():
        raise CorrectionRejected("a correction needs a reason")
    old_info, new_info = builder.inspect(base), builder.inspect(new)
    if new_info.kind != "observances":
        raise CorrectionRejected(f"{new_info.id}: only observances packs take corrections")
    same = (
        builder.manifest_id(old_info) == builder.manifest_id(new_info)
        and (old_info.kind, old_info.tradition) == (new_info.kind, new_info.tradition)
        and (old_info.covers_from, old_info.covers_to) == (new_info.covers_from, new_info.covers_to)
    )
    if not same:
        raise CorrectionRejected(f"{new_info.id} is not a later build of {old_info.id}")
    if new_info.version != old_info.version + 1:
        raise CorrectionRejected(f"version {new_info.version} must follow {old_info.version}")

    changed = changed_observances(base, new)
    dates = set().union(*(changed.get(t, set()) for t in DATE_TABLES))
    touched = set().union(*changed.values()) if changed else set()
    declared = set(observances)
    if undeclared := touched - declared:
        raise CorrectionRejected(f"changed but not declared: {', '.join(sorted(undeclared))}")
    if unchanged := declared - dates:
        names = ", ".join(sorted(unchanged))
        raise CorrectionRejected(f"declared but their dates did not change: {names}")

    record = {
        "of_version": old_info.version,
        "observances": sorted(declared),
        "reason": reason.strip(),
    }
    summary = dict(new_info.summary, correction=record)
    conn = sqlite3.connect(new)
    with conn:
        conn.execute(
            "UPDATE packs SET validation_summary = ?",
            (json.dumps(summary, ensure_ascii=False, sort_keys=True),),
        )
    conn.close()
    return record


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(prog="python -m pack.correction")
    p.add_argument("--base", type=Path, required=True, help="the published version")
    p.add_argument("--new", type=Path, required=True, help="the rebuilt next version")
    p.add_argument("--observance", action="append", required=True, dest="observances")
    p.add_argument("--reason", required=True)
    args = p.parse_args(argv)
    try:
        record = correct(args.base, args.new, args.observances, args.reason)
    except (CorrectionRejected, builder.PackRejected) as e:
        print(f"REJECTED: {e}", file=sys.stderr)
        return 1
    print(f"correction of v{record['of_version']}: {', '.join(record['observances'])}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
