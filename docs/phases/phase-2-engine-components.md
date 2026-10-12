# Phase 2 — Engine & components

**Goal:** the pipeline computes every transition and city rise/set for 2020–2045 and passes its property tests. The app has its domain logic, use cases and full component kit with an approved look.

**Read first:** §5.1, §6.1–6.2, §6.4–6.5 (pipeline and algorithms), §16 (edge cases), §14.4, §15.4 (data flow, engine interfaces), §12 (design system), §11.2 (Today layout), §13.4 (names in both scripts), §23.3 (icon concepts).

### Backend (pipeline)
| ID | Task | Done when |
|---|---|---|
| T-201 🟡 | Ephemeris fetch for DE440s with a SHA-256 lock file | Re-run verifies the checksum; a mismatch fails |
| T-202 | `astro.py`: apparent geocentric Sun/Moon ecliptic longitude via Skyfield | Tests against Skyfield's documented examples |
| T-203 | `ayanamsa.py`: Lahiri, formula and source cited | Within 1″ of `reference/ayanamsa.csv` (skipped with a visible notice until the file exists) |
| T-204 | `panchanga.py`: tithi, nakshatra, yoga, karana transitions (scan + bisection to 1 s) | Property tests: no gaps/overlaps, indices cycle, tithi length 19–27 h |
| T-205 | `solar.py`: sankranti search | 12 per year, ordered, 29–32 days apart |
| T-206 | City list (source per Q13; WB districts + 10 metros, names in both languages, aliases) + sunrise/sunset/moonrise/moonset; sunrise definition behind a flag (Q3) | 10 cities × 12 days within ±1 min of Astronomy Engine (independent check) |
| T-207 | Pipeline CLI `python -m engine build --from --to` with run metadata (library versions, ephemeris checksum) | Same inputs → identical output bytes; full 2020–2045 run time recorded |

### App core (state, data, platform)
| ID | Task | Done when |
|---|---|---|
| T-208 ✅ | Domain entities + interfaces (§15.4): `BengaliDate`, `Transition`, `DayPanjika`, `Observance`, `City`, `Provenance`, `DataCoverage` | Compile-time: no UI type without `Provenance` |
| T-209 ✅ | `PeriodCalculator` with the §6.5.8 table | Unit tests for all weekdays |
| T-210 ✅ | `DayAssembler` incl. udaya tithi, kshaya/vriddhi, after-midnight times, IST conversion | Unit tests incl. a device in another time zone |
| T-211 ✅ | Repositories on Drift + use cases `GetDayPanjika`, `GetMonthGrid`, `GetUpcomingObservances` | Tests on the sample pack |
| T-212 ✅ | `clockProvider`: ticks each minute and at the next transition/sunrise/midnight | Test with a fake clock: provider fires at the transition |

### Frontend (screens & UI)
| ID | Task | Done when |
|---|---|---|
| T-213 | Components (§12.5): `DateHeader`, `TithiSeal`, `NameText`, `PanchangRow`, `TimingStrip`, `PeriodRow`, `CalendarDayCell`, `ObservanceChip`, `FestivalCard`, `VerificationBadge`, `ProvenanceFooter`, `CityChip`, `StateMessage`, `LanguageSwitch`, `GlossaryTerm`, `SectionHeader`, `Skeleton` | Widget tests at 100/130/200 %; golden matrix bn/en × light/dark |
| T-214 | Motion (§12.8): ring fill, cross-fade, reduced-motion switch | Golden/widget test with `disableAnimations` on and off |

### Design & content
| ID | Task | Done when |
|---|---|---|
| T-215 | Approved designs for Onboarding, Today, Calendar, Day detail (bn/en × light/dark), starting from `docs/design/today-concept.html` | Sign-off in `docs/design/README.md` |
| T-216 | App icon (concept choice §23.3), adaptive + monochrome layers, Android 12 splash; moon-phase glyphs and custom icons | Assets in repo; each in `docs/assets.md` |
| T-217 | `names` table content: tithi, paksha, nakshatra, yoga, karana, months, weekdays, periods in both languages + translit + glosses (drafts per Q5, Q14) | Every row has both languages; marked draft until reviewed |

### DevOps
| ID | Task | Done when |
|---|---|---|
| T-218 | Golden tests in CI with bundled fonts (deterministic rendering); hypothesis CI profile | Goldens stable across two CI runs |

### Human gates
- Confirm the DE440s checksum (T-201); enter `reference/ayanamsa.csv` (T-203)
- Answer Q9 and Q13; choose the icon concept
- Design sign-off (T-215)

### Exit criteria
- [ ] Pipeline produces 2020–2045 data deterministically; all property tests and cross-checks pass
- [ ] Domain and use-case tests green on the sample pack
- [ ] Designs signed off; component goldens match them
