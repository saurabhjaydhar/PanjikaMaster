"""`python -m validate --pack dist/<pack>.sqlite [--release]` (T-302).

Writes `validate/reports/<pack>.html` and exits 1 if any check is beyond tolerance, or,
with --release, if any reference is still missing.
"""

import argparse
import sys
from pathlib import Path

from engine.astro import Astro
from engine.ephemeris import resolve
from validate.checks import generated_label, run_all
from validate.report import render

HERE = Path(__file__).resolve().parent


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(prog="python -m validate")
    p.add_argument("--pack", type=Path, required=True)
    p.add_argument("--reference", type=Path, default=HERE.parent / "reference")
    p.add_argument("--out", type=Path, default=HERE / "reports")
    p.add_argument("--release", action="store_true", help="missing references also fail")
    args = p.parse_args(argv)

    checks = run_all(args.pack, args.reference, Astro(resolve()))
    args.out.mkdir(parents=True, exist_ok=True)
    report = args.out / f"{args.pack.stem}.html"
    report.write_text(render(args.pack.name, checks, generated_label()), encoding="utf-8")

    failed = [c for c in checks if c.failures]
    missing = [c for c in checks if c.missing]
    for c in checks:
        print(f"{c.status:>22}  {c.name} ({len(c.failures)}/{len(c.rows)} mismatches)")
    print(f"report: {report}")
    return 1 if failed or (args.release and missing) else 0


if __name__ == "__main__":
    sys.exit(main())
