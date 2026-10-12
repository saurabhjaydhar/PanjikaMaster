# Phase 3 — Real data end to end

**Goal:** the app, offline, shows real computed data from a signed pack, validated against the human-entered references, with the right verification status on each row.

**Read first:** §6.5.6–6.5.7 (Bengali date, kshaya/vriddhi, mala masa), §6.7–6.8 (validation, status), §15.1–15.3 (tables, pack format, manifest), §11.9 (system states), §18 (offline).

## Tasks

| ID | Track | Task | Done when |
|---|---|---|---|
| T-301 | data | `bengali.py`: Bengal midnight rule as a pure function (Q4 behind config); lunar months incl. মলমাস (Q2) | Edge tests at ±1 s around midnight and before sunrise; full-year match vs `reference/bengali_dates.csv` |
| T-302 | data | Validation harness → HTML diff report (§6.7) | Every mismatch listed with its tolerance; CI fails beyond tolerance |
| T-303 | data | Pack builder: SQLite + gzip + Ed25519 (dev key) + manifest; refuses rows missing either language | App-side test imports the produced pack |
| T-304 | app | Pack importer: SHA-256, signature, transactional import, supersede old pack | Tests: bad signature and partial file rejected; v1→v2 upgrade |
| T-305 | app | Coverage and system states (§11.9): not downloaded, stale, signature failed | Widget tests for each state in both languages |
| T-306 | app | Bundle the real (debug-signed) pack; Today reads it; status badges from data | Today shows `computed`/`reference_matched` rows; no sample watermark |

## Human gates
- Enter reference data into `data/reference/*.csv`: tithi and nakshatra end times for 3 months, Kolkata sunrise for 24 days (Rashtriya Panchang), every Bengali date of 1433 and 1434 (printed panjika)
- Answer Q2, Q3, Q4, Q5, Q10, Q12 (dev key), Q14

## Exit criteria
- [ ] Bengali dates: exact for every day of the reference years
- [ ] Tithi/nakshatra/yoga end times within ±2 min; Kolkata sunrise/sunset within ±1 min
- [ ] Validation report has zero unexplained mismatches
- [ ] App works in airplane mode on a fresh install with the bundled pack (US-05)
