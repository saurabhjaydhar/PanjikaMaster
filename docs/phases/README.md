# Build phases

**Current phase: 1 — Foundations** (T-101 done)

| Phase | Name | What you can see at the end | Human gate before it can finish |
|---|---|---|---|
| 0 | [Decisions & references](phase-0-decisions.md) | Answers and reference books in hand | All of it is human work |
| 1 | [Foundations](phase-1-foundations.md) | App opens on a Today screen (sample data) in Bengali and English | None (app ID can be a placeholder) |
| 2 | [Engine & components](phase-2-engine-components.md) | Pipeline computes 26 years of tithi/nakshatra/yoga/karana/sankranti/sunrise; app has its full widget kit | Ephemeris checksum, ayanamsa reference values, design sign-off |
| 3 | [Real data end to end](phase-3-real-data.md) | App shows real, validated data from a signed pack, offline | Reference data entry, Q2–Q5, Q10, Q12, Q14 |
| 4 | [Core screens](phase-4-core-screens.md) | Onboarding, Today, Calendar, Day, City, Settings complete | Q15, visual sign-off |
| 5 | [Festivals & reminders](phase-5-festivals-reminders.md) | Festival list/detail, reminders, share cards | Expert review of tier-1 festivals, Q1, Q7 |
| 6 | [Trust & polish](phase-6-trust-polish.md) | Sources, report-error, search, glossary; accessibility and performance pass | User tests, copy review, Q6, Q8 |
| 7 | [Release](phase-7-release.md) | Staged rollout on Google Play | Store accounts, final app ID, production keys |

## Why the phases look like this

This is not a typical feature-by-feature app build:

1. **Correctness can't come from code alone.** Calendar data is only right once it matches the printed panjika and an expert signs it off. The agent can't produce that evidence, so phases end at **human gates**, and work that needs a gate never blocks work that doesn't.
2. **Two tracks run side by side.** The Python pipeline (`data/`) and the Flutter app (`app/`) share only the pack file and its schema. Each phase moves both tracks forward.
3. **The app never waits for real data.** It is built on a clearly watermarked sample pack (Phase 1) and switches to the real pack in Phase 3.
4. **Every phase ends with something you can run and look at.** It's a vertical slice, not a layer, so problems in the design or the data model show up early.

## How a phase is worked

- Work only on the current phase. Read its file, then only the spec sections it lists under "Read first".
- One task per branch and commit. A task is done when its "Done when" holds and the checks pass (`flutter analyze && flutter test` for the app, `ruff check . && pytest` for data).
- Tick the task in the phase file and add a line to the log below.
- When something needs the human (a Q-item, reference data, keys, sign-off), say so, park it behind a flag with `TODO(Q#)`, and carry on with the next task that doesn't need it.
- A phase is finished when every exit criterion is ticked. Then update "Current phase" at the top.

## Log

| Date | Change |
|---|---|
| 2026-10-12 | Docs v2.0: PRD slimmed, details moved to `docs/spec/`, build plan reorganised into these phases. |
| 2026-10-12 | T-101 done: `data/` scaffold (Python 3.12 via uv, ruff, pytest, hypothesis), `ci-data.yml`. Checks green. |
