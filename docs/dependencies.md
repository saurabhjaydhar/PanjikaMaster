# Dependencies

Record every package before adding it (PRD §28.2 rule 4, §19.1 L8). No AGPL/GPL, no Swiss Ephemeris.

| Package | Side (app/data) | Version | Licence | Last release | Platforms | Why | Checked on |
|---|---|---|---|---|---|---|---|
| pytest | data (dev) | 9.1.1 | MIT | 2026-06-19 | Linux/macOS/Windows, Python ≥ 3.10 | Test runner (T-101) | 2026-10-12 |
| hypothesis | data (dev) | 6.169.0 | MPL-2.0 (file-level copyleft; dev-only, not shipped) | 2026-10-11 | Python ≥ 3.11 | Property tests for transitions (PRD §22.1) | 2026-10-12 |
| ruff | data (dev) | 0.17.0 | MIT | 2026-10-09 | Prebuilt wheels for all major platforms | Lint + format | 2026-10-12 |

Transitive dev dependencies (pinned in `data/uv.lock`): iniconfig, packaging, pluggy, pygments, colorama (pytest), sortedcontainers (hypothesis). All permissive (MIT/BSD/Apache-2.0).
