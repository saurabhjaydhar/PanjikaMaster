# Phase 5 — Festivals & reminders

**Goal:** the full festival year with verified tier-1 dates, reminders that fire reliably, and share cards.

**Read first:** §6.6 (observance rule engine), §6.7 (validation), §8.4, §8.6 (requirements), §11.5–11.6, §11.8, §11.11, §11.13 (screens), §17 (notifications).

## Tasks

| ID | Track | Task | Done when |
|---|---|---|---|
| T-501 | data | Observance rule engine + YAML schema; tier-1/2 rules drafted (`review.status: draft`) | Engine outputs only rows with tradition + status; drafts never reach production packs |
| T-502 | data | Festival validation vs the printed panjika; overrides need a written reason | Tier 1 and tier 2: exact match or hidden |
| T-503 | data | Festival descriptions, written natively in Bengali and English (`review: pending`) | Every tier-1/2 observance has both |
| T-504 | app | Festival list + filters, sticky month headers | FR-FEST-01..02 |
| T-505 | app | Festival detail incl. multi-day selector and windows (e.g. Sandhi Puja) | FR-FEST-03..04 |
| T-506 | app | Reminders + rescheduling (app start, pack import, city/tradition/language change, boot, time-zone change) | US-03, FR-REM-01..04 |
| T-507 | app | Share cards (bn / en / both) | FR-DAY-06, §11.8 goldens |

## Human gates
- Expert review of tier-1 festivals (reviewer initials and date stored), Q1
- Q7 (exact alarms)
- Review of festival descriptions in both languages

## Exit criteria
- [ ] Tier-1 dates: 100 % reference match and expert reviewed
- [ ] Reminder fires the evening before on a real device, in the UI language
