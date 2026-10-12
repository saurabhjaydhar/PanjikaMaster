# Build phases

**Current phase: 1 — Foundations** (T-101–T-103, T-105, T-114 done; T-104 built, launch check pending)

| Phase | Name | What you can see at the end | Human gate before it can finish |
|---|---|---|---|
| 0 | [Decisions & references](phase-0-decisions.md) | Answers and reference books in hand | All of it is human work |
| 1 | [Foundations](phase-1-foundations.md) | App opens on a Today screen (sample data) in Bengali and English; CI green | None (app ID can be a placeholder) |
| 2 | [Engine & components](phase-2-engine-components.md) | Pipeline computes 2020–2045; app has domain logic and its full widget kit; icon and designs approved | Ephemeris checksum, ayanamsa values, design sign-off |
| 3 | [Real data end to end](phase-3-real-data.md) | Signed packs served from our hosting; app shows real, validated data offline | Reference data entry, Q2–Q5, Q10, Q12, Q14, hosting access |
| 4 | [Core screens](phase-4-core-screens.md) | Onboarding, Today, Calendar, Day, City, Settings, More complete | Q15, visual sign-off |
| 5 | [Festivals & reminders](phase-5-festivals-reminders.md) | Festival list/detail, reminders on real phones, share cards | Expert review of tier-1 festivals, Q1, Q7 |
| 6 | [Trust & polish](phase-6-trust-polish.md) | Sources, report-error, search, glossary, Bengal periods; accessibility and performance pass | User tests, copy review, Q6, Q8 |
| 7 | [Release](phase-7-release.md) | Ads, purchase, store listing; staged rollout on Google Play | Store accounts, final app ID, production keys |
| 8 | [Operations & v1.1](phase-8-operations-v1-1.md) | Yearly data cycle, 72 h corrections, v1.1 features, iOS later | Yearly panjika + expert review |

## Tracks

Each phase file groups its tasks by track, so nothing is left implicit:

| Track | Covers |
|---|---|
| **Frontend** | Screens, widgets, navigation, states, motion, share cards, ad slots (Flutter UI in `app/lib/features`, `app/lib/app`) |
| **App core** | State (Riverpod), local database (Drift), domain logic, use cases, pack import and download, notifications, location, permissions, purchases, crash reporting (`app/lib/core`, `domain`, `data`) |
| **Backend** | The Python pipeline (`data/`), static hosting of the manifest and packs on the VPS + CDN, signing, the optional error-report endpoint, privacy-policy pages |
| **DevOps** | CI workflows, builds, golden-test setup, pack publishing, release pipeline |
| **Design & content** | Approved designs, icon and splash, `names` content, festival descriptions, store assets, copy |
| **QA** | Integration tests, device tests, accessibility, validation against the printed panjika |
| **Human gates** | Decisions (Q-items), reference data, keys and accounts, reviews and sign-offs |

**What "backend" means here.** There is no app server, user account system or server database, by design (§6.1, §14.3): the phone works offline from signed data packs. The backend is (1) the data pipeline that computes and validates the packs, (2) static files (`manifest.json` + packs) on your VPS behind a CDN, (3) one tiny optional endpoint for error reports (Q6), and (4) the privacy-policy pages.

## Why the phases look like this

This is not a typical feature-by-feature app build:

1. **Correctness can't come from code alone.** Calendar data is only right once it matches the printed panjika and an expert signs it off. The agent can't produce that evidence, so phases end at **human gates**, and work that needs a gate never blocks work that doesn't.
2. **The tracks move together.** The pipeline and the app share only the pack file and its schema, so each phase advances both and ends with them joined.
3. **The app never waits for real data.** It is built on a watermarked sample pack (Phase 1) and switches to the real pack in Phase 3.
4. **Every phase ends with something you can run and look at.** It's a vertical slice, not a layer, so design or data-model problems show up early.

## How a phase is worked

- Work only on the current phase. Read its file, then only the spec sections under "Read first".
- One task per branch and commit. Done = "Done when" holds and checks pass (`flutter analyze && flutter test`; `ruff check . && pytest`; `python scripts/check_docs.py`).
- Tick the task (✅) in the phase file and add a line to the log below.
- When something needs the human, say so, park it behind a flag with `TODO(Q#)`, and continue with the next task that doesn't need it.
- A phase is finished when every exit criterion is ticked. Then update "Current phase" at the top.
- `scripts/check_docs.py` (CI) fails if any FR/US requirement has no task, a § reference is broken, or a task ID appears twice.

## Log

| Date | Change |
|---|---|
| 2026-10-12 | Docs v2.0: PRD slimmed, details moved to `docs/spec/`, build plan reorganised into phases. |
| 2026-10-12 | T-101 done: `data/` scaffold (Python 3.12 via uv, ruff, pytest, hypothesis), `ci-data.yml`. Checks green. |
| 2026-10-12 | Phases expanded to every track (frontend, app core, backend, DevOps, design & content, QA, human gates) and Phase 8 added: 117 tasks. T-114 done: `scripts/check_docs.py` + `ci-docs.yml`; all FR/US requirements mapped. |
| 2026-10-12 | T-102 done: `data/pack/schema.sql` (STRICT tables, FKs, CHECKs for index ranges, statuses, both languages; `packs.is_sample`; PK on `period_rules`) + `pack/schema.py`; 25 schema tests. |
| 2026-10-12 | T-103 done: `pack/sample.py` writes three sample packs (global, cities, observances) from synthetic series, marked `is_sample`, `status = sample` and a marker string; refuses release builds. Draft names in both languages in `data/content/names.toml` (Q5, Q14 pending). 18 tests. |
| 2026-10-12 | T-104 (partial): Flutter 3.47.7 app in `app/`: placeholder app ID `dev.panjika.placeholder` overridable with `-P panjikaAppId=` (Q11), compile/target 36, minSdk 24 (ADR-001), edge-to-edge, predictive back, launcher name in bn + en, strict analyzer. Debug and release APKs build; `flutter analyze` and `flutter test` green. Emulator launch pending (CI, T-115). |
| 2026-10-12 | T-105 done: flutter_riverpod 3.4.3, drift 2.35.2 + drift_flutter 0.3.1, go_router 18.0.2, flutter_localizations, intl; dev: drift_dev, build_runner. `sqlite3_flutter_libs` is end-of-life, replaced by `sqlite3` 3.x via drift_flutter. 98 transitive packages licence-checked, no GPL/AGPL. |
