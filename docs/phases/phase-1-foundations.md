# Phase 1 — Foundations

**Goal:** a debug APK that opens on a basic Today screen, driven by a watermarked sample pack, in Bengali and English with instant switching. Both CI pipelines green.

**Read first:** §14 (architecture), §15.1 (tables), §13.1, §13.3, §13.5 (localisation), §12.2–12.3 (tokens, type), §6.8 (`sample` status), §28 (repo layout).

## Tasks

| ID | Track | Task | Done when |
|---|---|---|---|
| T-101 ✅ | data | Scaffold Python project (3.12, uv, ruff, pytest, hypothesis), CI | `ruff check`, `pytest` green in CI |
| T-102 | data | `data/pack/schema.sql`: the single schema from §15.1 | A test creates an empty DB from it; every table except user tables has `pack_id` |
| T-103 | data | Sample-pack generator: a few months of fixture rows, all `status = sample`, `packs.kind` marked sample, names in both languages | Pack opens with the schema; a test asserts every row is `sample`; the generator refuses to run in release mode |
| T-104 | app | `flutter create` in `app/` with a placeholder app ID (`TODO(Q11)`), targetSdk 36, edge-to-edge on, minSdk recorded in `docs/decisions/` | Debug and release builds start on an emulator |
| T-105 | app | Add the §14.3 packages needed now (Riverpod 3, Drift, go_router, flutter_localizations) | Each one recorded in `docs/dependencies.md` |
| T-106 | app | Drift tables mirroring `schema.sql` | Test: Drift columns == `schema.sql` columns |
| T-107 | app | Localisation foundation: `app_bn.arb`/`app_en.arb`, locale setting + Android per-app language, `PanjikaFormatter`, ARB parity and no-literal checks | Switching language re-renders without restart; formatter tests for both languages × both numeral styles; CI fails on a missing key |
| T-108 | app | Theme: colour tokens, per-script type scale, bundled fonts, contrast test | Contrast test green; goldens light/dark × bn/en for a sample text page |
| T-109 | app | Basic Today: date header, tithi, nakshatra/yoga/karana rows, sunrise/sunset, provenance footer, read from the sample pack; `SampleWatermark` | Golden bn/en × light/dark; watermark visible; no hard-coded strings |
| T-110 | app | `ci-app.yml`: analyze, test, build release APK, fail if the release bundle contains a sample marker | Green on PR |

## Human gates
None required. Optional: look at the Today skeleton on a phone.

## Exit criteria
- [ ] All tasks done, both CIs green
- [ ] Today opens in Bengali and English; language switch is instant
- [ ] Release build contains no sample data (T-110 check)

## Not in this phase
Real astronomy, signing, other screens, reminders, ads.
