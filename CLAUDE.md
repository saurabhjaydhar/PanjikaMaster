# CLAUDE.md — Bangla Panjika (বাংলা পঞ্জিকা)

Full spec: `docs/PRD.md` (v1.2). Build order and tasks: PRD §28. Requirement IDs (FR-…, US-…) are in PRD §8–9. Progress: `docs/progress.md`.

## Non-negotiables
- **Never invent calendar data.** No hand-written tithi times, Bengali dates, festival dates or reference values. Fixtures use `status = sample` and show the "নমুনা · SAMPLE" watermark. Release builds must contain no sample data.
- **No Swiss Ephemeris and no AGPL/GPL dependencies.** Pipeline uses Skyfield + JPL DE440s.
- **Open questions Q1–Q15 (PRD §26) are decided by the human.** Put the behaviour behind config/flags and leave `TODO(Q#)`.
- Every displayed datum must carry provenance (tradition, city, time zone, pack id, status).
- Ads must follow PRD §20.2 (no interstitials, nothing above the fold on Today). Nothing religious behind a paywall.
- **Two complete languages.** Bengali (`bn`, source) and English (`en`, Indian English) are both first-class (PRD §8.9, §13). Nothing ships in only one language.

## Workflow
1. Inspect the repo before editing; don't overwrite existing work.
2. One task from PRD §28.3 per branch/commit; update `docs/progress.md`.
3. After each task run:
   - app: `flutter analyze && flutter test`
   - data: `ruff check . && pytest`
   A task with failing checks is not done.
4. Before adding a package, check licence, last release and platform support; record it in `docs/dependencies.md`. Record every icon, font, image in `docs/assets.md`.
5. Ask the human only for Q-items, reference data entry, keys/accounts, copy review and visual sign-off.

## Conventions
- Layout: `app/` (Flutter: app, core, domain, data, features), `data/` (Python pipeline), `docs/`.
- State: Riverpod 3. DB: Drift (schema mirrors `data/pack/schema.sql`). Routing: go_router. Localisation: `gen-l10n`.
- All panjika times are stored as UTC seconds and shown in IST with an "IST" label. Indices are 0-based (PRD §15.1).
- Android: targetSdk 36; test edge-to-edge and predictive back (`PopScope`). AdMob test IDs in debug. Secrets only from env/CI.

## Bilingual rules (PRD §13)
- UI strings: add every key to `app/lib/l10n/app_bn.arb` **and** `app_en.arb` in the same commit, with an `@key` description and typed placeholders. Use ICU plural/select; never concatenate translated fragments.
- Panchanga names live in the pack's `names` table (`name_bn`, `name_en`, `translit`), festival text in `observances`; never in ARB, never hard-coded.
- English uses romanised panjika terms ("Shukla Saptami", "Barabela"), not invented translations. Romanisation standard is Q14.
- All dates, times, numerals and countdowns go through `PanjikaFormatter` (`core/l10n`); never `toString()`/`DateFormat` in widgets. Numeral style is independent of language.
- Names render only via `NameText` (handles "Names in both scripts").
- Language switch is instant (no restart), preserves navigation, and reschedules notifications.

## UI quality bar (PRD §12)
- Tokens only: colours from `PanjikaColors`, type from the per-locale `TextTheme`, spacing from §12.7. No hex literals, raw font sizes or string literals in `features/`.
- Bengali text: no `letterSpacing`, no fixed-height text containers, wrap instead of ellipsis (PRD §12.11).
- Light `haldi` is decorative only; use `haldi-strong` for the tithi ring, today marker and focus ring.
- Every component/screen: golden tests for bn/en × light/dark × 100%/200% text, plus empty/loading/stale/error states. Touch targets ≥ 48 dp; never colour-only meaning.
