# Phase 2 — Engine & components

**Goal:** the pipeline computes every transition and city sunrise/sunset for 2020–2045 and passes its property tests. The app has its domain logic and full component kit with an approved look.

**Read first:** §5.1, §6.1–6.2, §6.4–6.5 (pipeline and algorithms), §16 (edge cases), §15.4 (engine interfaces), §12 (design system), §11.2 (Today layout), §13.4 (names in both scripts).

## Tasks

| ID | Track | Task | Done when |
|---|---|---|---|
| T-201 | data | Ephemeris fetch for DE440s with a SHA-256 lock file | Re-run verifies the checksum; a mismatch fails. Human confirms the first checksum |
| T-202 | data | `astro.py`: apparent geocentric Sun/Moon ecliptic longitude via Skyfield | Tests against Skyfield's documented examples |
| T-203 | data | `ayanamsa.py`: Lahiri, formula and source cited | Within 1″ of human-entered values in `reference/ayanamsa.csv` (test is skipped, with a visible notice, until the file exists) |
| T-204 | data | `panchanga.py`: tithi, nakshatra, yoga, karana transitions (scan + bisection to 1 s) | Property tests: no gaps/overlaps, indices cycle, tithi length 19–27 h |
| T-205 | data | `solar.py`: sankranti search | 12 per year, ordered, 29–32 days apart |
| T-206 | data | City list + rise/set, sunrise definition behind a flag (Q3); coordinates source per Q13 | 10 cities × 12 days within ±1 min of Astronomy Engine (independent check) |
| T-207 | app | Domain entities + interfaces (§15.4); `PeriodCalculator` with the §6.5.8 table | Unit tests for all weekdays |
| T-208 | app | `DayAssembler` incl. kshaya/vriddhi and IST conversion | Unit tests, incl. a device in another time zone |
| T-209 | design | Turn `docs/design/today-concept.html` into approved designs for Onboarding, Today, Calendar, Day detail (bn/en × light/dark) | Human sign-off recorded in `docs/design/README.md` |
| T-210 | app | Components (§12.5) incl. `NameText`, `TithiSeal`, `PeriodRow`, `CalendarDayCell`, `StateMessage` | Widget tests at 100/130/200 %; golden matrix bn/en × light/dark |

## Human gates
- Confirm the DE440s checksum (T-201)
- Enter `reference/ayanamsa.csv` from a published source (T-203)
- Answer Q9 and Q13
- Design sign-off (T-209)

## Exit criteria
- [ ] Pipeline produces 2020–2045 transitions and city rise/set deterministically (same input → same bytes)
- [ ] All property tests and the Astronomy Engine cross-check pass
- [ ] Designs signed off; component goldens match them

## Not in this phase
Bengali dates, validation against the printed panjika, signing, screens beyond components.
