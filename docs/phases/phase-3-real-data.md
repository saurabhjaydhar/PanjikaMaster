# Phase 3 — Real data end to end

**Goal:** packs are built, validated, signed and served from our own hosting; the app imports them (bundled and downloaded), and, offline, shows real data with the right verification status.

**Read first:** §6.5.6–6.5.7 (Bengali date, kshaya/vriddhi, mala masa), §6.7–6.8 (validation, status), §15.1–15.3 (tables, pack format, manifest API), §11.9 (system states), §16 (edge cases), §18 (offline & sync).

### Backend (pipeline, hosting)
| ID | Task | Done when |
|---|---|---|
| T-301 🟡 | `bengali.py`: Bengal midnight rule as a pure function (Q4 behind config); lunar months incl. মলমাস (Q2) | Edge tests ±1 s around midnight and before sunrise; full-year match vs `reference/bengali_dates.csv` — *rule, dates and lunar months done; the match waits for the reference file (columns `date,bn_day,bn_month_idx,bn_year`)* |
| T-302 ✅ | Validation harness → HTML diff report in `validate/reports/` (§6.7) | Every mismatch listed with tolerance; CI fails beyond tolerance |
| T-303 ✅ | Pack builder: global, cities and observances packs; SQLite + gzip + Ed25519 (key from env) + `manifest.json`; refuses rows missing either language (FR-L10N-09) | App-side test imports the produced pack |
| T-304 | Hosting: HTTPS static site on the VPS behind a CDN serving `/v1/manifest.json` and `/v1/packs/*`; staging and production paths; cache headers (manifest short, packs immutable) | `curl` of staging manifest returns the built manifest; pack SHA-256 matches |
| T-305 | Publish script (pipeline → staging → production), never overwriting a published pack version | Dry run and staging publish work; production needs a manual confirm |

### App core (state, data, platform)
| ID | Task | Done when |
|---|---|---|
| T-306 ✅ | Pack importer: SHA-256 from manifest, Ed25519 signature with embedded public key, attach + copy in one transaction, supersede old pack, fire "reschedule" hook | Tests: bad signature and partial file rejected; v1→v2 upgrade |
| T-307 | Bundled packs in the APK (current + next 2 Bengali years global; WB + metros cities), imported on first launch | Fresh install works in airplane mode (US-05) |
| T-308 ✅ | Manifest client: check at most once per 24 h; download silently if < 2 MB, else ask; resume; `min_app_version`; manifest notices (bn/en) | Tests with a fake server for each branch |
| T-309 ✅ | Coverage and staleness: `Covered` / `NotDownloaded` / `Stale`; device clock outside every pack range | Unit tests for each case |

### Frontend (screens & UI)
| ID | Task | Done when |
|---|---|---|
| T-310 ✅ | System states (§11.9) with actions: not downloaded, offline, stale banner, signature failed, unverified festival; "check your phone's date" | Widget tests for each state in both languages |
| T-311 | Today reads the real pack; verification badges from data; manifest notice banner; download prompt for large packs | Today shows real `computed`/`reference_matched` rows; no watermark in this build |

### DevOps
| ID | Task | Done when |
|---|---|---|
| T-312 | `pack-build.yml` (manual dispatch): build → validate → sign with the dev key from CI secrets → upload artifacts → publish to staging | Run produces a validation report and a staging manifest |

### QA
| ID | Task | Done when |
|---|---|---|
| T-313 | Integration: fresh install offline; outside-range date shows "not downloaded"; import a newer pack from staging | Passes on emulator |

### Human gates
- Enter reference data in `data/reference/*.csv`: tithi/nakshatra/yoga end times for 3 months and Kolkata sunrise for 24 days (Rashtriya Panchang); every Bengali date of 1433 and 1434 (printed panjika)
- Answer Q2, Q3, Q4, Q5, Q10, Q12 (dev key), Q14
- VPS/CDN access, domain and TLS for hosting

### Exit criteria
- [ ] Bengali dates exact for every reference day; tithi/nakshatra/yoga within ±2 min; Kolkata sunrise/sunset within ±1 min
- [ ] Validation report: zero unexplained mismatches
- [ ] App imports bundled and downloaded packs; offline works (US-05)
