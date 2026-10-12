# Phase 1 — Foundations

**Goal:** a debug APK opens on a basic Today screen, driven by a watermarked sample pack, in Bengali and English with instant switching. All CI pipelines green.

**Read first:** §14 (architecture), §15.1 (tables), §13.1, §13.3, §13.5 (localisation), §12.2–12.3 (tokens, type), §6.8 (`sample` status), §28.1 (repo layout).

### Backend (pipeline)
| ID | Task | Done when |
|---|---|---|
| T-101 ✅ | Scaffold Python project (3.12, uv, ruff, pytest, hypothesis) | `ruff check`, `pytest` green |
| T-102 ✅ | `data/pack/schema.sql`: the single schema from §15.1 | A test creates an empty DB from it; every non-user table has `pack_id` |
| T-103 ✅ | Sample-pack generator: a few months of fixture rows, all `status = sample`, names in both languages, `packs.kind` marked sample | Test asserts every row is `sample`; generator refuses release mode |

### App core (state, data, platform)
| ID | Task | Done when |
|---|---|---|
| T-104 🟡 | `flutter create` in `app/` with placeholder app ID (`TODO(Q11)`), targetSdk 36, edge-to-edge; minSdk recorded as an ADR in `docs/decisions/` | Debug and release builds start on an emulator — *builds verified (placeholder ID, targetSdk 36, minSdk 24); emulator launch runs in CI with T-115 (no KVM in the agent container)* |
| T-105 ✅ | Add the packages needed now (Riverpod 3, Drift + drift_flutter, go_router, flutter_localizations, intl) | Each in `docs/dependencies.md` |
| T-106 ✅ | Drift database mirroring `schema.sql`, migration framework, DAOs for the tables Today needs | Test: Drift columns == `schema.sql` columns; in-memory DB tests |
| T-107 ✅ | Localisation foundation: `app_bn.arb`/`app_en.arb`, locale controller (in-app setting + Android per-app language `locales_config.xml`), device-locale default, `PanjikaFormatter` (dates, times, ranges, numerals, plurals), independent numeral setting, ARB parity + no-literal checks wired into `ci-app.yml` (FR-L10N-01..04, FR-L10N-06) | Language switch re-renders without restart; formatter tests for both languages × both numeral styles; CI fails on a missing key |
| T-108 ✅ | Settings store on the `settings` table + Riverpod providers (locale, numerals, theme, text scale, time format, tradition, city) | Values survive app restart (test) |
| T-109 ✅ | Theme: colour tokens as `PanjikaColors`, per-script `TextTheme`s, bundled + subset fonts, light/dark/system switching, contrast test | Contrast test green; goldens light/dark × bn/en for a text specimen page |
| T-110 ✅ | Sample-pack loader (debug/test builds only): bundled asset → Drift | Release build has no loader (compile-time flag) |

### Frontend (screens & UI)
| ID | Task | Done when |
|---|---|---|
| T-111 ✅ | App shell: go_router, 4-tab bottom navigation with labels in both languages (placeholder screens for Calendar, Festivals, More), system text scaling respected | Navigation works; tabs labelled; back handled with `PopScope` |
| T-112 | Basic Today: date header, tithi, nakshatra/yoga/karana rows, sunrise/sunset, provenance footer, from the sample pack; `SampleWatermark` | Golden bn/en × light/dark; no hard-coded strings |

### DevOps (CI/CD, builds)
| ID | Task | Done when |
|---|---|---|
| T-113 🟡 | `ci-app.yml`: `flutter analyze`, `flutter test`, build release APK; fail if the release bundle contains a sample marker | Green on PR — *all steps pass locally; green on PR pending* |
| T-114 ✅ | `ci-docs.yml`: run `scripts/check_docs.py` (every FR/US mapped to a task, every § reference resolves) | Green on PR; fails on an unmapped requirement or broken § reference |

### QA
| ID | Task | Done when |
|---|---|---|
| T-115 | Integration smoke test: launch → Today in Bengali, switch to English, back | Passes on an emulator in CI or locally |

### Human gates
None required. Optional: look at the Today skeleton on a phone; protect `main` in GitHub settings (require CI).

### Exit criteria
- [ ] All tasks done, all CIs green
- [ ] Today opens in Bengali and English; switching is instant
- [ ] Release build contains no sample data

### Not in this phase
Real astronomy, signing, hosting, other screens, reminders, ads.
