# Phase 5 — Festivals & reminders

**Goal:** the full festival year with verified tier-1 dates, reminders that fire reliably on real phones, and share cards.

**Read first:** §6.6–6.7 (observance rules, validation), §8.4, §8.6 (requirements), §11.5–11.6, §11.8, §11.11, §11.13 (screens), §16, §17 (notifications).

### Backend (pipeline)
| ID | Task | Done when |
|---|---|---|
| T-501 ✅ | Observance rule engine + YAML schema; decision types `udaya`, `prevails_at`, `sankranti_day`, `fixed_bengali_date`, `ekadashi_smarta`, `span`, `override` (with mandatory reason); skips মলমাস; windows (Sandhi Puja, Nishita) | Unit tests per decision type; engine never outputs a row without tradition + status |
| T-502 ✅ | Tier 1, 2, 3 rules drafted (`review.status: draft`); drafts never reach production packs | Pack builder test blocks drafts in production mode |
| T-503 | Festival validation vs the printed panjika; statuses set | Tier 1/2: exact match or hidden |
| T-504 | Festival descriptions written natively in Bengali and English (80–150 words, `review: pending`) | Every tier-1/2 observance has both |
| T-505 | Observances pack published to staging | App imports it |

### App core (state, data, platform)
| ID | Task | Done when |
|---|---|---|
| T-506 | Reminder scheduler (`flutter_local_notifications` + `timezone`): per festival (day before / morning of), recurring Ekadashi/Purnima/Amavasya, next 60 days, cap 64 | FR-REM-01..03; unit tests |
| T-507 | Permissions: Android 13+ notification prompt only on first reminder; toggle reverts on denial with inline help; inexact by default, exact only if granted (Q7) | US-03 |
| T-508 | Reschedule triggers: app start, pack import, city/tradition/language change, `BOOT_COMPLETED`, time-zone change; bilingual channels re-registered on language change | FR-REM-04; tests for each trigger |
| T-509 | Share rendering: `RepaintBoundary` → PNG 1080×1350, `share_plus`, share text with deep link | FR-DAY-06 |

### Frontend (screens & UI)
| ID | Task | Done when |
|---|---|---|
| T-510 ✅ | Festival list: grouped by Bengali month, sticky headers, filters (month, category, tier), auto-scroll to current month, badges | FR-FEST-01..02 |
| T-511 | Festival detail: category band, multi-day selector, windows, tithi span, description, verification card, reminder toggle, share | FR-FEST-03..04 |
| T-512 | Reminders screen: recurring rows with timing pickers, festival reminders, add-festival, empty state, "notifications off" banner | §11.13 |
| T-513 | Share sheet (bn / en / both) and card layouts for festival and day | §11.8 goldens with the longest names |
| T-514 | Observances shown on Today, Day detail and calendar markers from real data | FR-HOME-05..06 |

### QA
| ID | Task | Done when |
|---|---|---|
| T-515 | Reminder fires on real Samsung and Xiaomi devices; after reboot; after time-zone change | Manual test log |

### Human gates
- Expert review of tier-1 festivals (initials and date stored); answer Q1
- Answer Q7
- Review festival descriptions in both languages

### Exit criteria
- [ ] Tier-1 dates: 100 % reference match and expert reviewed
- [ ] Reminders fire the evening before, in the UI language, on the test devices
