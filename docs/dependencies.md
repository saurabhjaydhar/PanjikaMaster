# Dependencies

Record every package before adding it (CLAUDE.md, §19.1 L8). No AGPL/GPL, no Swiss Ephemeris.

| Package | Side (app/data) | Version | Licence | Last release | Platforms | Why | Checked on |
|---|---|---|---|---|---|---|---|
| pytest | data (dev) | 9.1.1 | MIT | 2026-06-19 | Linux/macOS/Windows, Python ≥ 3.10 | Test runner (T-101) | 2026-10-12 |
| hypothesis | data (dev) | 6.169.0 | MPL-2.0 (file-level copyleft; dev-only, not shipped) | 2026-10-11 | Python ≥ 3.11 | Property tests for transitions (PRD §22.1) | 2026-10-12 |
| ruff | data (dev) | 0.17.0 | MIT | 2026-10-09 | Prebuilt wheels for all major platforms | Lint + format | 2026-10-12 |
| skyfield | data | 1.55 | MIT | 2026-08-07 | Pure Python | Sun/Moon apparent positions from the JPL kernel; leap seconds and ΔT built in, so builds need no download (T-202) | 2026-10-13 |
| jplephem | data (via skyfield) | 2.24 | MIT | 2026-01-23 | Pure Python | Reads JPL `.bsp` kernels | 2026-10-13 |
| sgp4 | data (via skyfield) | 2.27 | MIT | 2026-07-03 | Wheels for all major platforms | Skyfield dependency (satellites; unused) | 2026-10-13 |
| numpy | data (via skyfield) | 2.5.4 | BSD-3-Clause and permissive (bundled runtime libraries under their own permissive or runtime-exception licences) | 2026-10-10 | Wheels for all major platforms | Vectorised time grids for the transition search | 2026-10-13 |
| certifi | data (via skyfield) | 2026.7.22 | MPL-2.0 (file-level; pipeline only, not shipped) | 2026-07-22 | Pure Python | CA bundle | 2026-10-13 |
| astronomy-engine | data (dev) | 2.1.19 | MIT | 2023-12-14 | Pure Python | Independent analytic cross-check of Sun/Moon positions and rise/set (T-202, T-206); no JPL data | 2026-10-13 |
| PyYAML | data | 6.0.3 | MIT | 2025-09-25 | Wheels for all major platforms, pure-Python fallback | Observance rule files, one YAML file per observance (spec §6.6, T-501); read with `safe_load` only | 2026-10-13 |
| cryptography (Python) | data | 50.0.2 | Apache-2.0 OR BSD-3-Clause | 2026-09-30 | Wheels for all major platforms | Ed25519 signing of packs (T-303) | 2026-10-13 |
| cffi | data (via cryptography) | 2.1.1 | MIT-0 | 2026-08-03 | Wheels for all major platforms | cryptography dependency | 2026-10-13 |
| pycparser | data (via cryptography) | 3.11 | BSD-3-Clause | 2026-10-09 | Pure Python | cffi dependency | 2026-10-13 |

| flutter_riverpod | app | 3.4.3 | MIT | 2026-09-03 | Android, iOS, desktop | State management (spec §14.3) | 2026-10-12 |
| drift | app | 2.35.2 | MIT | 2026-10-07 | All | Typed SQLite DB mirroring `schema.sql` | 2026-10-12 |
| drift_flutter | app | 0.3.1 | MIT | 2026-07-11 | All | Opens the Drift DB on device; pulls `sqlite3` 3.x, which bundles SQLite natively | 2026-10-12 |
| cryptography (Dart) | app | 2.9.0 | Apache-2.0 | 2025-11-21 | All (pure Dart Ed25519 and SHA-256) | Verify pack signatures and hashes on import (spec §14.3, T-306) | 2026-10-13 |
| http | app | 1.6.0 | BSD-3-Clause | 2025-11-10 | All | Manifest and pack downloads with Range resume; `MockClient` for tests (T-308) | 2026-10-13 |
| go_router | app | 18.0.2 | BSD-3-Clause | 2026-09-28 | All | Routing + deep links | 2026-10-12 |
| flutter_localizations | app | SDK | BSD-3-Clause | with Flutter 3.47.7 | All | Material/Cupertino strings for bn + en, gen-l10n | 2026-10-12 |
| intl | app | 0.20.3 (pinned by SDK) | BSD-3-Clause | 2026-06-25 | All | ICU plural/select for ARB messages; formatting goes through `PanjikaFormatter` | 2026-10-12 |
| drift_dev | app (dev) | 2.35.1 | MIT | 2026-09-30 | Build host | Drift code generation | 2026-10-12 |
| build_runner | app (dev) | 2.16.2 | BSD-3-Clause | 2026-10-07 | Build host | Runs code generation | 2026-10-12 |
| sqlite3 | app (dev) | 3.5.2 | MIT | 2026-09 (3.x line) | All | Raw SQLite in tests to compare the Drift DB against `schema.sql` (already a runtime transitive dependency) | 2026-10-12 |
| geolocator_android | app | 5.1.1+1 | MIT | 2026-10-02 | Android | One coarse location fix for "Use my location" (T-409). Used directly instead of the `geolocator` umbrella, whose Linux plugin pulls in D-Bus/GeoClue packages; iOS adds `geolocator_apple` with T-814. Its background location service is removed in the manifest; `forceLocationManager` avoids needing Play services at run time | 2026-10-13 |
| geolocator_platform_interface | app (via geolocator_android) | 4.4.0 | MIT | 2026-09-26 | All | Types and exceptions | 2026-10-13 |
| com.google.android.gms:play-services-location (Android library) | app (via geolocator_android) | 21.2.0 | Android Software Development Kit License | — | Android | Compiled in by geolocator_android; not called (LocationManager is forced) | 2026-10-13 |
| package_info_plus | app | 10.2.2 | BSD-3-Clause | 2026-10-01 | Android, iOS, desktop, web | App version on the About screen (T-407) | 2026-10-13 |
| package_info_plus_platform_interface | app (via package_info_plus) | 4.1.0 | BSD-3-Clause | 2026 | All | Platform interface | 2026-10-13 |
| win32 | app (via package_info_plus) | 6.4.0 | BSD-3-Clause | 2026-08-05 | Windows only (unused on phones) | Windows version lookup | 2026-10-13 |
| ffi_leak_tracker | app (via win32) | 0.1.2 | BSD-3-Clause | 2026-04-11 | Windows only (unused on phones) | win32 dependency | 2026-10-13 |
| integration_test | app (dev) | SDK | BSD-3-Clause | with Flutter 3.47.7 | Android | On-device smoke test (T-115) | 2026-10-12 |
| flutter_lints | app (dev) | 6.0.0 | BSD-3-Clause | 2025-05-27 | All Flutter platforms | Lint rules (T-104) | 2026-10-12 |
| fake_async | app (dev) | 1.3.3 | Apache-2.0 | 2025-01-28 | All (tests only) | Fake time for the ticking clock tests (T-212); already pinned transitively by `flutter_test` | 2026-10-12 |

Transitive dev dependencies (pinned in `data/uv.lock`): iniconfig, packaging, pluggy, pygments, colorama (pytest), sortedcontainers (hypothesis). All permissive (MIT/BSD/Apache-2.0).

**App transitive dependencies** (checked 2026-10-12, `flutter pub deps`): 98 packages, all MIT, BSD-2/3-Clause or Apache-2.0, except `sqlcipher_flutter_libs` 0.7.0+eol (Pixar/MIT/BSD-style, permissive), an empty end-of-life shim still listed by `drift_flutter`. No GPL/AGPL.

**Note:** `sqlite3_flutter_libs` (named in spec §14.3) is end-of-life; `sqlite3` 3.x bundles SQLite itself via build hooks. Verify `libsqlite3.so` is in the release APK once Drift is used (T-106; spec §14.3 watch-out).

## Datasets (pipeline only, never shipped in the app)

| Dataset | Source | Terms | Used for | Pinned by | Status |
|---|---|---|---|---|---|
| JPL DE440s planetary ephemeris (`de440s.bsp`, ~32 MB) | NASA JPL: naif.jpl.nasa.gov (`generic_kernels/spk/planets`), mirror ssd.jpl.nasa.gov (`ftp/eph/planets/bsp`) | JPL ephemerides are generally treated as public domain; **confirm JPL's terms before release** (spec §19.1 L2) | Sun/Moon positions for every computed value (spec §6.4) | SHA-256 in `data/ephem/ephemeris.lock.json`; human-confirmed (T-201) | Checksum not yet recorded: both hosts are blocked by the agent environment's network policy; recorded by the first CI run |
