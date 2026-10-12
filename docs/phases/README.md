# Build phases

**Current phase: 2 — Engine & components** (Phase 1 complete; T-208–T-212 done; T-201 partial — ephemeris hosts blocked here)

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
| 2026-10-12 | T-106 done: Drift `AppDatabase` with pack tables generated from `schema.sql` (`scripts/sync_drift_schema.py`, `--check` in `ci-data.yml`), device tables, named queries for Today, migration strategy, foreign keys on. 16 tests incl. per-table parity with `schema.sql` (columns, types, keys, FKs, indexes, STRICT). `libsqlite3.so` confirmed in the release APK for all ABIs. |
| 2026-10-12 | T-113 (pending first CI run): `ci-app.yml` runs generated-code freshness, `dart format`, `flutter analyze`, `flutter test`, release APK build and `scripts/check_release_bundle.sh` (fails if the sample marker is anywhere in the APK; tested both ways). CI jobs renamed `app`/`data`/`docs`. |
| 2026-10-12 | T-107 done: gen-l10n with `app_bn.arb` (source) + `app_en.arb`; `PanjikaFormatter` (IST times with Bengali day parts, ranges, dates, Indian grouping, numerals independent of language, Q5 ordinal flag); language controller with device default (Q15 fallback, primary locale only), instant switching, two-way Android 13+ per-app language sync (Kotlin channel, `locales_config.xml`); only bn/en resources ship. `scripts/check_l10n.py` in `ci-app.yml` (ARB parity, placeholders, descriptions, untranslated copies, hard-coded strings; negative-tested). 28 new tests (46 total). Per-app sync verified with a mocked channel only; on-device check comes with T-115. |
| 2026-10-12 | T-108 done: `SettingsSource` (core) + `DbSettings` (data, `settings` table): loaded before the first frame, written through on change; persisted providers for language, numerals, time format, theme, text scale, tradition, city (default Kolkata), names in both scripts (null = Q15 default), onboarding. Values stored in spec §15.1 formats. 6 tests incl. restart across two DB sessions. 52 app tests green; release APK builds. |
| 2026-10-12 | T-109 done: colour tokens (`PanjikaColors`), per-script type scale (Tiro Bangla display; Noto Sans Bengali / Noto Sans text; fallbacks to the other script; no letter spacing; no synthetic bold), spacing/shape/motion tokens, Material 3 theme, light/dark/system switching, in-app text size on top of system scaling, font licences on the licences page. Fonts: 788 KB, subset by `scripts/build_fonts.sh`, Bengali shaping verified identical to the originals (44 HarfBuzz comparisons). Contrast test over every token pair; 4 golden specimens (bn/en × light/dark). 129 app tests green. |
| 2026-10-12 | T-110 done: sample packs become SQL in `app/lib/data/fixtures/sample_pack.g.dart` (`scripts/gen_sample_fixture.py`, self-verifying, `--check` in ci-data), loaded by `loadSamplePackIfEmpty` behind `kDebugMode`. Verified: release APK contains no sample marker, sample strings or loader; debug APK does. **Fixed a T-113 bug:** `check_release_bundle.sh` used `grep -q` under `pipefail`, so on real-size APKs a match became a false "OK"; it now counts matches (debug APK now correctly fails, release passes). 134 app tests. |
| 2026-10-12 | T-111 done: go_router `StatefulShellRoute` with four tabs (labels from ARB, always visible), one router for the app's lifetime so language/theme changes keep the current tab, `PopScope` back handling (other tab → Today, Today → app closes), placeholder Calendar/Festivals/More screens. 6 shell tests incl. 200 % text on 360 dp in both languages; test font helper now loads the Material icon font for goldens. 140 app tests. |
| 2026-10-12 | T-112 done: basic Today from the pack tables (`TodayRepository` → `TodaySnapshot` with `NameRef` names in both scripts and `Provenance`): weekday + city, Bengali and Gregorian dates, tithi seal with progress ring, end time (incl. "(পরদিন)") and next tithi, nakshatra/yoga/karana, sun/moon times ("নেই" when absent), provenance footer, নমুনা watermark for sample packs, explicit no-data state with retry. Shared widgets: `NameText` (Q15 default off), `TithiRing`, `PanchangRow`, `TimingStrip`, `ProvenanceFooter`, `StateMessage`, `SampleWatermark`. 13 tests incl. US-01 (seal visible at 130 % on 360×640, both languages), 200 % without overflow, no numbers in the no-data state, 4 goldens. 153 app tests. |
| 2026-10-12 | T-115 (pending first CI run): `integration_test/app_smoke_test.dart` — launch on Today in Bengali with sample data, switch to English (asserting the real Kotlin per-app language channel on API 33+), system back from another tab returns to Today. New `integration` job in `ci-app.yml` boots an Android 14 emulator (KVM). Compiles for Android locally; 153 unit/widget tests still green. |
| 2026-10-12 | Phase 1 PR opened (#2, stacked on #1) so CI incl. the emulator job runs. Phase 2 started. T-201 (partial): `ephem/fetch.py` downloads DE440s (NAIF, then SSD mirror) atomically, pins size + SHA-256 in `ephem/ephemeris.lock.json`, fails on mismatch or partial file, `--require-confirmed` for production. 9 tests (no network). Both JPL hosts are blocked by this environment's network policy; ci-data now fetches it (cached) and prints the checksum for the human to confirm. |
| 2026-10-12 | T-208 done: domain entities in `domain/entities/panjika.dart` (Weekday with 0 = Sunday, Transition, VerificationStatus ↔ DB values, BengaliDate, SunMoonTimes, LunarMonth, City, Observance/ObservanceDate, PeriodRule/TimePeriod, Provenance with IST label, sealed DataCoverage) and `PanjikaSource` / `PeriodCalculator` interfaces; T-112's `Element` renamed `ElementSpan` (clashed with Flutter's `Element`). 6 tests; 159 app tests. |
| 2026-10-12 | T-209 done: `DivisionPeriodCalculator` (day or night divided into equal parts, microsecond-exact tiling) and the spec §6.5.8 Rahu Kaal / Yamaganda / Gulika table (flagged to verify against the reference before release). 13 tests: all 7 weekdays × 3 periods, ordering, no coincidences, uneven days, night basis, invalid input. |
| 2026-10-12 | **Phase 1 complete.** PR #2 green on all four CI jobs: docs, data, app (incl. release APK and sample-data check) and integration (app launched on an Android 14 emulator; Bengali → English switch; per-app language channel; system back). T-104, T-113, T-115 confirmed. |
| 2026-10-12 | T-210 done: `StandardDayAssembler` builds a `DayPanjika` (sunrise → next sunrise) from UTC transitions: udaya tithi, kshaya and vriddhi flags, per-kind spans, karana names via `karanaNameIndex` (moved to `domain/engine/karana.dart`), periods in time order, `currentOf` / `nextAfter` / `activePeriod` / `isAfterMidnight` for "(পরদিন)". 21 tests on synthetic inputs; CI also runs domain tests under UTC+14 and UTC−10. 193 app tests. |
| 2026-10-12 | T-211 done: `DriftPanjikaRepository` implements `PanjikaSource` + new `CatalogSource` (names, cities, enabled period rules, sample flag); `PanjikaSource.transitions` now takes the tradition (it was missing). Use cases `GetDayPanjika` (by date, or `containing(instant)` = sunrise-to-sunrise day), `GetMonthGrid` (Bengali or Gregorian month; ●/○/এ markers from the udaya tithi; null unless the whole month is installed) and `GetUpcomingObservances` (limit, tier filter); all carry provenance. `DayPanjika` now has the day's observances. Riverpod providers in `data/repositories/panjika_providers.dart`. 20 tests on the sample pack, incl. every day Sep–Dec: tithis tile, vriddhi pairs agree, every tithi named or kshaya. Today still reads `TodaySnapshot`; it moves to `DayPanjika` with the full Today screen. For design sign-off (T-215): between midnight and sunrise, should Today show the civil date's panjika day or the one in progress? 213 app tests. |
| 2026-10-12 | T-212 done: `nowProvider` ticks on every minute boundary (so IST midnight too) and exactly at instants registered with `wakeAt`; re-reads the clock when the app resumes. Today now runs on `DayPanjika` (`TodaySnapshot`/`TodayRepository` removed): it loads the panjika day in progress once, registers its transitions, period edges, sunset and next sunrise, picks current elements each tick, and reloads at the next sunrise. Goldens unchanged. Tests with fake time: minute ticks, exact transition, refresh, timer cancelled on dispose; Today switches tithi at the transition's millisecond and rolls to the next day at sunrise. New dev dependency `fake_async` (already transitive via `flutter_test`). 214 app tests. |
