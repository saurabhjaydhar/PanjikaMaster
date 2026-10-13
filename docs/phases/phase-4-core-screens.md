# Phase 4 — Core screens

**Goal:** the daily-use app is complete in both languages at the quality bar: onboarding, Today, Calendar, Day detail, City picker, Settings and the More menu.

**Read first:** §8.1–8.3, §8.5, §8.8–8.9 (requirements), §9 (user stories), §10–11 (navigation and screens), §12.10–12.12 (adaptive layout, Bengali text rules, quality bar), §13.3–13.4, §13.7.

### Frontend (screens & UI)
| ID | Task | Done when |
|---|---|---|
| T-401 | Onboarding: bilingual language step → tradition → city → notifications (skippable), progress dots | US-02, US-09 |
| T-402 ✅ | Today complete: periods with active highlight, today's observances, next 3 upcoming, live updates across transitions, pull-to-refresh | US-01, US-11, FR-HOME-01..09 |
| T-403 ✅ | Calendar: Bengali/Gregorian modes, swipe + arrows, markers by shape, legend sheet, jump-to-month sheet, long-press peek, selected-day strip, year roll-over, "আজ/Today" button | US-06, US-08, FR-CAL-01..07 |
| T-404 ✅ | Day detail: all sections in §11.4 order, kshaya/vriddhi lines, "(পরদিন)/(next day)", swipe between days | FR-DAY-01..05 |
| T-405 ✅ | City picker: search in both scripts with transliteration, recent, WB by district, other cities, each with today's sunrise; city-change toast | US-04, FR-LOC-01, FR-LOC-05 |
| T-406 ✅ | Settings: language, names in both scripts, tradition (with confirm sheet), city, theme, text size with preview, 12/24 h, numerals | FR-SET-01, FR-SET-05..06, US-10, FR-L10N-04 |
| T-407 ✅ | More tab: quick language switch, menu to all §10 destinations; About screen; licences (`showLicensePage` + data/font notices) | Every §10 entry reachable |
| T-408 | Adaptive layout: landscape phone, medium/expanded width centring, 200 % text on 360 dp | Goldens at 600 dp and landscape |

### App core (state, data, platform)
| ID | Task | Done when |
|---|---|---|
| T-409 | Location: coarse permission on tap only, nearest supported city with distance, > 50 km warning, denial never blocks (Kolkata default) | FR-LOC-02..04; tests with a fake location service |
| T-410 ✅ | Tradition change: Surya Siddhanta shows "coming soon" and keeps Drik; change triggers reload and reminder reschedule hook | Unit + widget tests |
| T-411 | Deep-link routes (`/day/YYYY-MM-DD`, `/festival/<id>`) for later share links | Route tests |
| T-412 | Screen-reader labels per language (FR-L10N-08), second-script line excluded or locale-tagged | Semantics tests in both languages |

### QA
| ID | Task | Done when |
|---|---|---|
| T-413 | Integration: onboarding → Today in both languages; language switch keeps screen and back stack | Passes on emulator |

### Human gates
- Answer Q15
- Visual sign-off of every screen on a phone (bn/en × light/dark)

### Exit criteria
- [ ] All listed user stories pass
- [ ] Golden matrix approved for every screen
- [ ] 360×640 dp at 130 % text: tithi visible without scrolling, in both languages
