# CLAUDE.md — Bangla Panjika (বাংলা পঞ্জিকা)

A Bengali calendar app (Flutter, `app/`) fed by an offline astronomy pipeline (Python, `data/`). Bengali and English UI.

## Start here
1. `docs/phases/README.md` names the current phase. Open that phase file.
2. Read only the spec sections it lists under "Read first" (`docs/README.md` maps § numbers to files).
3. Do the next unticked task that doesn't wait on the human.

## Never
- **Invent calendar data.** No hand-typed tithi times, Bengali dates, festival dates or reference values. Fixtures are `status = sample` and show the "নমুনা · SAMPLE" watermark; release builds contain none. Never write in `data/reference/`.
- Use Swiss Ephemeris or any AGPL/GPL dependency.
- Decide an open question (Q1–Q15, PRD §26). Put it behind a flag, leave `TODO(Q#)`, tell the human.
- Ship a string, name or description in only one language.
- Show a datum without its provenance (tradition, city, time zone, pack, status).

## Every task
- One task per branch and commit. Checks must pass: app `flutter analyze && flutter test`; data `ruff check . && pytest`.
- New package → `docs/dependencies.md` (licence, last release, platforms). New font/icon/image → `docs/assets.md`.
- Tick the task in its phase file and add a line to the log in `docs/phases/README.md`. Run `python scripts/check_docs.py` after changing docs.
- Secrets come from env/CI only; AdMob test IDs in debug.

## Code conventions
- App: Riverpod 3, Drift (mirrors `data/pack/schema.sql`), go_router, gen-l10n. Android targetSdk 36, edge-to-edge, `PopScope`.
- Times stored as UTC seconds, shown in IST with an "IST" label. Indices are 0-based.
- UI strings go in `app_bn.arb` and `app_en.arb` together; ICU messages, no concatenation. Panchanga names come from the pack's `names` table.
- Format dates/times/numbers only via `PanjikaFormatter`; render names only via `NameText`.
- Widgets use theme tokens only (no hex colours, raw font sizes or string literals). Bengali text: no `letterSpacing`, no fixed-height text boxes.
- Every screen/component: golden tests bn/en × light/dark × 100 %/200 % text.
