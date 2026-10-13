#!/usr/bin/env python3
"""Docs consistency check (run by ci-docs.yml; T-114).

1. Every requirement ID (FR-…, US-…) in docs/PRD.md is assigned to a task in docs/phases/.
   Ranges like "FR-HOME-01..09" count for every ID inside them.
2. Every "§x.y" reference in the docs resolves to a heading somewhere in the docs.
3. Every task ID appears in exactly one phase file.
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
# Sections intentionally retired in docs v2.0 (see docs/README.md).
RETIRED = {"24", "28.2", "28.3", "28.4", "28.5"}


def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")


def requirement_ids(prd: str) -> set[str]:
    return set(re.findall(r"\b(FR-[A-Z0-9]+-\d+|US-\d+)\b", prd))


def covered_ids(phases: str) -> set[str]:
    ids = set(re.findall(r"\b(FR-[A-Z0-9]+-\d+|US-\d+)\b", phases))
    for prefix, lo, hi in re.findall(r"\b(FR-[A-Z0-9]+-)(\d+)\.\.(\d+)", phases):
        width = len(lo)
        ids.update(f"{prefix}{n:0{width}d}" for n in range(int(lo), int(hi) + 1))
    return ids


def heading_ids(text: str) -> set[str]:
    return set(re.findall(r"^#{2,4} (\d+(?:\.\d+)*)[. ]", text, flags=re.M))


def main() -> int:
    errors: list[str] = []
    md_files = [*DOCS.rglob("*.md"), ROOT / "CLAUDE.md", *(ROOT / "data").rglob("*.md")]
    md_files = [p for p in md_files if ".venv" not in p.parts]
    phase_files = sorted((DOCS / "phases").glob("phase-*.md"))
    phases = "".join(read(p) for p in phase_files)

    missing = sorted(requirement_ids(read(DOCS / "PRD.md")) - covered_ids(phases))
    errors += [f"requirement not assigned to any phase task: {i}" for i in missing]

    headings = set().union(*(heading_ids(read(p)) for p in md_files))
    for p in md_files:
        for ref in re.findall(r"§(\d+(?:\.\d+)*)", read(p)):
            if ref not in headings and ref not in RETIRED:
                errors.append(f"{p.relative_to(ROOT)}: §{ref} does not resolve")

    seen: dict[str, str] = {}
    for p in phase_files:
        for tid in set(re.findall(r"^\| (T-\d{3})\b", read(p), flags=re.M)):
            if tid in seen:
                errors.append(f"{tid} defined in both {seen[tid]} and {p.name}")
            seen[tid] = p.name

    for e in errors:
        print(f"ERROR: {e}")
    print(f"checked {len(md_files)} files, {len(seen)} tasks: {len(errors)} error(s)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
