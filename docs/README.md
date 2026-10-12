# Docs map

| You want to… | Read |
|---|---|
| Know what we're building and why | `PRD.md` |
| Know what to build next | `phases/README.md` → the current phase file |
| Look up a technical rule | the `spec/` file below |
| Agent rules | `../CLAUDE.md` |

## Where each § lives

Section numbers are permanent IDs. They are never renumbered when content moves, so every "§x.y" reference in code, tests and docs stays valid.

| § | Section | File |
|---|---|---|
| 1 | Executive summary | `PRD.md` |
| 2 | Problem and opportunity | `background.md` |
| 3 | Goals, non-goals and success metrics | `PRD.md` |
| 4 | Users | `PRD.md` |
| 5 | Calendar convention (the most important decision) | `spec/calendar.md` |
| 6 | Data strategy (deep dive) | `spec/calendar.md` |
| 7 | Scope by release | `PRD.md` |
| 8 | Functional requirements | `PRD.md` |
| 9 | User stories and acceptance criteria | `PRD.md` |
| 10 | Information architecture | `spec/screens.md` |
| 11 | Screen specifications | `spec/screens.md` |
| 12 | Design system | `spec/design-system.md` |
| 13 | Content & localisation | `spec/localisation.md` |
| 14 | Technical architecture | `spec/architecture.md` |
| 15 | Data model | `spec/data-model.md` |
| 16 | Calculation edge cases the app must handle | `spec/calendar.md` |
| 17 | Notifications & reminders | `spec/architecture.md` |
| 18 | Offline & sync | `spec/architecture.md` |
| 19 | Privacy, permissions & compliance | `spec/launch.md` |
| 20 | Monetization | `spec/launch.md` |
| 21 | Analytics & success measurement | `spec/launch.md` |
| 22 | QA & test plan | `spec/testing.md` |
| 23 | Release | `spec/launch.md` |
| 25 | Risks & mitigations | `PRD.md` |
| 26 | Open questions | `PRD.md` |
| 27 | Appendix (glossary) | `spec/localisation.md` |
| 28 | Repository | `spec/architecture.md` |

Subsections kept apart from their parent (rationale and research, not needed for building):

| § | Section | File |
|---|---|---|
| 6.3 | Options compared | `background.md` |
| 20.4 | Revenue scenarios (**estimates only, not forecasts**) | `background.md` |
| 20.5 | Costs to cover (estimate ranges, fill in) | `background.md` |
| 27.2 | Sources consulted (Oct 2026) | `background.md` |

§24 (old roadmap) and §28.2–28.5 (old task list and agent rules) were replaced by `phases/` and `CLAUDE.md` in docs v2.0. §28.1 (repository layout) is in `spec/architecture.md`.

## Registers
`dependencies.md` (every package) · `assets.md` (every font/icon/image) · `decisions/` (ADRs) · `design/` (concepts and sign-offs)
