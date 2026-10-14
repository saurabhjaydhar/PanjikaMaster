# Phase 3 — Real data end to end

**Goal:** packs are built, validated, signed and served from our own hosting; the app imports them (bundled and downloaded), and, offline, shows real data with the right verification status.

**Read first:** §6.5.6–6.5.7 (Bengali date, kshaya/vriddhi, mala masa), §6.7–6.8 (validation, status), §15.1–15.3 (tables, pack format, manifest API), §11.9 (system states), §16 (edge cases), §18 (offline & sync). For T-314–T-318 (any-place timings, decision 2026-10-13): §6.2, §6.5.5, §8.5, §15.1, §15.4.

### Backend (pipeline, hosting)
| ID | Task | Done when |
|---|---|---|
| T-301 🟡 | `bengali.py`: Bengal midnight rule as a pure function (Q4 behind config); lunar months incl. মলমাস (Q2) | Edge tests ±1 s around midnight and before sunrise; full-year match vs `reference/bengali_dates.csv` — *rule, dates and lunar months done; the match waits for the reference file (columns `date,bn_day,bn_month_idx,bn_year`)* |
| T-302 ✅ | Validation harness → HTML diff report in `validate/reports/` (§6.7) | Every mismatch listed with tolerance; CI fails beyond tolerance |
| T-303 ✅ | Pack builder: global, cities and observances packs; SQLite + gzip + Ed25519 (key from env) + `manifest.json`; refuses rows missing either language (FR-L10N-09) | App-side test imports the produced pack |
| T-304 | Hosting: HTTPS static site on the VPS behind a CDN serving `/v1/manifest.json` and `/v1/packs/*`; staging and production paths; cache headers (manifest short, packs immutable) | `curl` of staging manifest returns the built manifest; pack SHA-256 matches |
| T-305 | Publish script (pipeline → staging → production), never overwriting a published pack version | Dry run and staging publish work; production needs a manual confirm |
| T-314 ✅ | Sun/Moon table `body_positions` in the global pack (§6.5.5): the pipeline's apparent geocentric Sun and Moon positions, plus Moon distance and the sidereal-time correction, in a compact form (e.g. per-day Chebyshev coefficients); `schema.sql`, Drift sync, pack builder and importer updated | Positions rebuilt from the table agree with Skyfield within 1″ (Sun) and 2″ (Moon) at random instants over 2020–2045; ≤ 200 KB per year compressed (test fails above); deterministic bytes |
| T-315 ✅ | Shared rise/set fixture from `engine/riseset.py`: about 40 places worldwide (West Bengal, Nainital, Delhi, Chennai, Dhaka, Dubai, London, New York, Sydney, ±60° latitude, both sides of IST) × 24 days; sunrise, sunset, moonrise, moonset (null when none) | Fixture written by a script with `--check` in `ci-data`; the pipeline itself still matches Astronomy Engine within ±1 min for these places (§6.7) |
| T-316 | Place list (source per Q13): West Bengal by district, every Indian state's major cities, major cities abroad with Bengali communities; names in both languages, aliases, country/state, time zone. `city_days` retired from `schema.sql` and the packs | Search fixtures find "nainital"/"নৈনিতাল", "burdwan"/"বর্ধমান"; builder refuses a place missing either language; old packs with `city_days` still import (rows ignored) |

### App core (state, data, platform)
| ID | Task | Done when |
|---|---|---|
| T-306 ✅ | Pack importer: SHA-256 from manifest, Ed25519 signature with embedded public key, attach + copy in one transaction, supersede old pack, fire "reschedule" hook | Tests: bad signature and partial file rejected; v1→v2 upgrade |
| T-307 | Bundled packs in the APK (current + next 2 Bengali years global, incl. the Sun/Moon table; the whole place list), imported on first launch | Fresh install works in airplane mode (US-05), for a listed city and for an own location |
| T-308 ✅ | Manifest client: check at most once per 24 h; download silently if < 2 MB, else ask; resume; `min_app_version`; manifest notices (bn/en) | Tests with a fake server for each branch |
| T-309 ✅ | Coverage and staleness: `Covered` / `NotDownloaded` / `Stale`; device clock outside every pack range | Unit tests for each case |
| T-317 | `OnDeviceRiseSet` (§15.4 `RiseSetCalculator`): pure Dart rise/set for any coordinates from `body_positions`, same sunrise definition flag as the pipeline (Q3), Moon parallax, "no moonrise" days | Matches the T-315 fixture within ±5 s (Sun) and ±10 s (Moon) for every place and day; benchmark within the `performance.md` budget; no new dependency |
| T-318 | Place model: `Place` (listed or own location, rounded to 0.01°) replaces `CityId` in settings, repositories, use cases, `Provenance` and coverage; settings `city_id` migrated to `place`; reminders reschedule on a place change that alters times; error reports send the nearest listed city, never coordinates | Migration test from a database with `city_id`; Today/Day/Calendar tests for a listed city and an own location agree with the fixture; a test proves no request body or log line contains the coordinates (FR-LOC-06) |

### Frontend (screens & UI)
| ID | Task | Done when |
|---|---|---|
| T-310 ✅ | System states (§11.9) with actions: not downloaded, offline, stale banner, signature failed, unverified festival; "check your phone's date" | Widget tests for each state in both languages |
| T-311 🟡 | Today reads the real pack; verification badges from data; manifest notice banner; download prompt for large packs | Today shows real `computed`/`reference_matched` rows; no watermark in this build — *updater, notices, prompt and actions done; a real pack on Today needs hosting (T-304) or bundled packs (T-307)* |

### DevOps
| ID | Task | Done when |
|---|---|---|
| T-312 🟡 | `pack-build.yml` (manual dispatch): build → validate → sign with the dev key from CI secrets → upload artifacts → publish to staging | Run produces a validation report and a staging manifest — *workflow done up to signed artifacts; needs the `PANJIKA_SIGNING_KEY` secret (Q12) and the staging host (T-304)* |

### QA
| ID | Task | Done when |
|---|---|---|
| T-313 | Integration: fresh install offline; outside-range date shows "not downloaded"; import a newer pack from staging | Passes on emulator |

### Human gates
- Enter reference data in `data/reference/*.csv`: tithi/nakshatra/yoga end times for 3 months and Kolkata sunrise for 24 days (Rashtriya Panchang); every Bengali date of 1433 and 1434 (printed panjika)
- Answer Q2, Q3, Q4, Q5, Q10, Q12 (dev key), Q13 (place list source, for T-316), Q14
- VPS/CDN access, domain and TLS for hosting

### Exit criteria
- [ ] Bengali dates exact for every reference day; tithi/nakshatra/yoga within ±2 min; Kolkata sunrise/sunset within ±1 min
- [ ] Validation report: zero unexplained mismatches
- [ ] App imports bundled and downloaded packs; offline works (US-05)
- [ ] Rise/set on the phone matches the pipeline fixture for every test place (§6.7)
