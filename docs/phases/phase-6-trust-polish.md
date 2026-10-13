# Phase 6 — Trust & polish

**Goal:** every MVP feature meets the definition of done (§22.3), the trust features are in, and real users complete the key tasks in both languages.

**Read first:** §8.7–8.8 (search, settings & trust), §11.14–11.17 (screens), §6.5.9 (Bengal periods), §12.6, §13.6–13.8, §18 (corrections), §21 (analytics), §22 (testing).

### Backend (pipeline, hosting, endpoints)
| ID | Task | Done when |
|---|---|---|
| T-601 | Error-report endpoint per Q6 (`POST /v1/reports`, only the §15.3 fields, rate-limited) or form-service integration | Accepts a report from the app; stores nothing else |
| T-602 | Bengal period rules from the expert into `period_rules` | 30 sample days match the printed panjika |
| T-603 | Correction packs: replace only affected rows; changed observances flagged for 7 days | Pipeline + importer tests |

### App core (state, data, platform)
| ID | Task | Done when |
|---|---|---|
| T-604 ✅ | Error-report queue: works offline, sends when online | US-07 |
| T-605 ✅ | Search: normaliser (both scripts, both numeral systems, transliteration, spelling variants, dd/mm/yyyy) and index | FR-SRCH-01, FR-L10N-07, §13.6 cases |
| T-606 | Bengal periods computed from `period_rules`, behind a flag until validated | Flag off in release until T-602 passes |
| T-607 | Crash reporting (Sentry or Crashlytics, chosen and disclosed) and analytics per Q8 | Events per §21 in debug; nothing with identifiers unless decided |
| T-608 | Performance: cold start < 1.5 s, app size < 30 MB, font subsetting, R8 rules incl. Drift | §3.3 measured on the low-end phone |

### Frontend (screens & UI)
| ID | Task | Done when |
|---|---|---|
| T-609 ✅ | Sources & verification screen + "why do the two schools differ?" explainer | FR-SET-02 |
| T-610 | Report-an-error form, pre-filled, no personal data | FR-SET-03 |
| T-611 ✅ | Search screen with examples, results, empty state | §11.14 |
| T-612 ✅ | Glossary screen and long-press term sheets | FR-SET-07, FR-L10N-05 |
| T-613 | Help: install Bengali TTS voice; OEM notification settings guides (Xiaomi, Samsung) | Both languages |
| T-614 | "সংশোধিত / Corrected" label on changed observances; Bengal periods UI | Goldens |

### QA
| ID | Task | Done when |
|---|---|---|
| T-615 | Accessibility pass: TalkBack bn + en (incl. a phone without Bengali TTS), 200 % text, focus order | US-08, §12.6 |
| T-616 | Device matrix (§22.2) | All devices pass |
| T-617 | 60 random days on device vs printed panjika, two testers | No unexplained differences |

### Human gates
- Older-user test (5 users 55+) and English-user test (3 users)
- Copy review of every screen on a device, Bengali and English
- Expert rule tables for Bengal periods; Q6, Q8

### Exit criteria
- [ ] §22.3 definition of done holds for every MVP feature
- [ ] User tests: key tasks completed without help
