# Dependencies

Record every package before adding it (CLAUDE.md, §19.1 L8). No AGPL/GPL, no Swiss Ephemeris.

| Package | Side (app/data) | Version | Licence | Last release | Platforms | Why | Checked on |
|---|---|---|---|---|---|---|---|
| pytest | data (dev) | 9.1.1 | MIT | 2026-06-19 | Linux/macOS/Windows, Python ≥ 3.10 | Test runner (T-101) | 2026-10-12 |
| hypothesis | data (dev) | 6.169.0 | MPL-2.0 (file-level copyleft; dev-only, not shipped) | 2026-10-11 | Python ≥ 3.11 | Property tests for transitions (PRD §22.1) | 2026-10-12 |
| ruff | data (dev) | 0.17.0 | MIT | 2026-10-09 | Prebuilt wheels for all major platforms | Lint + format | 2026-10-12 |

| flutter_riverpod | app | 3.4.3 | MIT | 2026-09-03 | Android, iOS, desktop | State management (spec §14.3) | 2026-10-12 |
| drift | app | 2.35.2 | MIT | 2026-10-07 | All | Typed SQLite DB mirroring `schema.sql` | 2026-10-12 |
| drift_flutter | app | 0.3.1 | MIT | 2026-07-11 | All | Opens the Drift DB on device; pulls `sqlite3` 3.x, which bundles SQLite natively | 2026-10-12 |
| go_router | app | 18.0.2 | BSD-3-Clause | 2026-09-28 | All | Routing + deep links | 2026-10-12 |
| flutter_localizations | app | SDK | BSD-3-Clause | with Flutter 3.47.7 | All | Material/Cupertino strings for bn + en, gen-l10n | 2026-10-12 |
| intl | app | 0.20.3 (pinned by SDK) | BSD-3-Clause | 2026-06-25 | All | ICU plural/select for ARB messages; formatting goes through `PanjikaFormatter` | 2026-10-12 |
| drift_dev | app (dev) | 2.35.1 | MIT | 2026-09-30 | Build host | Drift code generation | 2026-10-12 |
| build_runner | app (dev) | 2.16.2 | BSD-3-Clause | 2026-10-07 | Build host | Runs code generation | 2026-10-12 |
| flutter_lints | app (dev) | 6.0.0 | BSD-3-Clause | 2025-05-27 | All Flutter platforms | Lint rules (T-104) | 2026-10-12 |

Transitive dev dependencies (pinned in `data/uv.lock`): iniconfig, packaging, pluggy, pygments, colorama (pytest), sortedcontainers (hypothesis). All permissive (MIT/BSD/Apache-2.0).

**App transitive dependencies** (checked 2026-10-12, `flutter pub deps`): 98 packages, all MIT, BSD-2/3-Clause or Apache-2.0, except `sqlcipher_flutter_libs` 0.7.0+eol (Pixar/MIT/BSD-style, permissive), an empty end-of-life shim still listed by `drift_flutter`. No GPL/AGPL.

**Note:** `sqlite3_flutter_libs` (named in spec §14.3) is end-of-life; `sqlite3` 3.x bundles SQLite itself via build hooks. Verify `libsqlite3.so` is in the release APK once Drift is used (T-106; spec §14.3 watch-out).
