# Bangla Panjika — Product Requirements (PRD)

| | |
|---|---|
| Product | বাংলা পঞ্জিকা (working name "Panjika"), by Scaleroot |
| Owner | Saurabh |
| Version | 2.0, 12 Oct 2026 |
| Platforms | Android first (Flutter), iOS later |
| Languages | Bengali (default, source) and English, both complete |
| Market | West Bengal and the Bengali diaspora |

> **Sample data rule.** Every date, time or festival shown anywhere in these docs is sample data (নমুনা), not a verified religious date.

**What this file is.** The product: why, for whom, what is in scope and how we know it works. It is short on purpose.
**How it gets built:** `docs/phases/` (one file per phase; start at `docs/phases/README.md`).
**Technical detail:** `docs/spec/` (calendar rules, screens, design system, localisation, architecture, data model, testing, launch). `docs/README.md` maps every § number to its file.

---

## Key decisions

| Decision | Choice | Detail |
|---|---|---|
| Default tradition | Drik / Bishuddha Siddhanta. Surya Siddhanta (Gupta Press) follows in v1.1 | §5.2–5.3 |
| Where data comes from | Computed offline with Skyfield + JPL DE440s, validated against Rashtriya Panchang and the printed panjika, shipped as signed SQLite packs. The phone reads data; it never guesses | §6 |
| Ayanamsa, time zone | Lahiri; IST, shown with an "IST" label (places outside India: Q16) | §5.3 |
| Location | Any place on Earth up to ±60° latitude: sunrise, sunset, moonrise, moonset, periods and the tithi at sunrise are computed on the phone for the place's own coordinates, from a Sun/Moon table in the signed pack. Festival and Bengali dates follow one reference place (Q1) for everyone | §6.2, §8.5 |
| Trust | Every date screen shows tradition, city and time zone; every festival shows a verification status | §6.8 |
| Languages | Bengali and English both complete at launch; optional "names in both scripts" | §13 |
| Ads | Never above the fold on Today, never full-screen; nothing religious behind a paywall | §20 |
| Stack | Flutter, Riverpod 3, Drift, go_router, gen-l10n; Python 3.12 pipeline | §14 |
| Not allowed | Swiss Ephemeris, any AGPL/GPL dependency, invented calendar data | §6.3, §6.10 |

---

## 1. Executive summary

Bengali families still buy a printed panjika every Chaitra, and the leading apps that try to replace it are trusted less than the paper. Public reviews of the market leaders complain about two things: **wrong dates** and **intrusive ads**. None of the apps reviewed clearly tells the user *which panjika tradition* its dates follow, even though West Bengal has two schools (Bishuddha Siddhanta and Surya Siddhanta / Gupta Press) that sometimes put the same festival on different days.

This product's position is simple: **the panjika you can trust, without the clutter.**

Three pillars:

1. **Trust.** Every screen states its tradition, location and time zone. Every festival carries a verification status. Data comes from a documented, reproducible astronomical pipeline that is validated against the Government of India's Rashtriya Panchang (Bengali edition) and a printed Bengali panjika before release.
2. **Bengali-first, truly bilingual daily use.** Native Bengali UI by default and an equally polished English UI (not a translation afterthought), Bengali numerals, traditional Bengali periods (বারবেলা, কালবেলা, অমৃতযোগ, মাহেন্দ্রযোগ) and large readable type for older users. An optional bilingual display shows panchanga names in both scripts, so an English reader can still match the printed panjika.
3. **Respectful monetization.** No interstitials, no app-open ads, no ads blocking content, nothing religious behind a paywall.

**Core technical idea:** compute astronomy *offline on a build server* with permissively licensed, high-precision tools, validate it, then ship it to phones as small **signed data packs** stored in SQLite. The phone reads data. It does not guess.

---

## 3. Goals, non-goals and success metrics

### 3.1 Product goals (first 12 months after launch)

| # | Goal | Metric | Target (assumption, to be revisited) |
|---|---|---|---|
| G1 | Be correct | Tier-1 festival dates matching the chosen reference panjika | 100% before release; 0 unresolved correctness reports older than 72 h |
| G2 | Be a daily habit | D30 retention | ≥ 20% |
| G3 | Be pleasant | Play Store rating | ≥ 4.5★; < 2% of reviews mention ads |
| G4 | Be accessible | Screens usable at 200% system font scale | 100% of MVP screens |
| G5 | Be sustainable | Revenue covers hosting + one expert review cycle per year | See §20 scenarios |
| G6 | Be bilingual | Every MVP screen, notification, share card and store asset available in Bengali and English | 100% of strings in both ARB files (CI-enforced); both languages copy-reviewed by native speakers; < 1% of reviews mention language problems |

### 3.2 Non-goals for MVP

Kundli/horoscope generation, daily rashifal, matchmaking, astrologer consultation, social features, Bangladesh's revised calendar, Muslim/Christian calendars, user accounts, cloud sync, iOS launch (follows Android).

### 3.3 Guardrail metrics

Crash-free sessions ≥ 99.5%. Cold start to Today screen < 1.5 s on a ₹10k Android phone. App size < 30 MB. Battery: no background work except scheduled notifications.

---

## 4. Users

### 4.1 Personas

**Mamata, 62, Howrah — "the keeper of the panjika".** Buys Gupta Press every year. Checks tithi each morning, Ekadashi and Purnima for fasting, বারবেলা before travel. Uses a mid-range Android with large system font. Pain: apps disagree with her printed panjika and are full of ads. Needs: large type, Bengali, her panjika's tradition, no surprises.

**Arindam, 35, Bengaluru (from Kolkata) — "the long-distance son".** Wants Puja dates to plan leave and call home on the right day. Pain: has to ask his mother; apps feel spammy. Needs: festival list, reminders, IST and local-time clarity, sharing a festival card to family WhatsApp.

**Riya, 24, Siliguri — "the occasional checker".** Opens the app around Durga Puja, Saraswati Puja, Poila Boishakh. Needs: fast "when is X" answer, good-looking share cards, dark mode.

**Ananya, 17, Pune — "the second generation".** Grew up outside Bengal; speaks Bengali at home but reads it slowly. Sets the phone to English. Needs: an English UI that uses the real terms (Tithi, Ekadashi, Barabela) rather than vague translations, a short explanation of each term, and the Bengali names alongside so she can read them out to her grandmother. Pain: English panchang apps follow North Indian (purnimanta) conventions and miss Bengali festivals.

### 4.2 Jobs to be done

1. "When I wake up, tell me today's tithi and whether today has a fast or puja."
2. "Before I travel or start something, tell me the inauspicious periods today."
3. "Tell me when the next big festival is and remind me before it."
4. "When my printed panjika and the app disagree, show me why."
5. "When I read in English, use the real Bengali terms, explain them briefly, and show me the Bengali so I can match it with the printed panjika."

---

## 7. Scope by release

| Feature | MVP (v1.0) | v1.1 | v2 | Never / out |
|---|---|---|---|---|
| Today screen with full daily panjika | ✅ | | | |
| Monthly calendar (Bengali + Gregorian) | ✅ | | | |
| Day detail | ✅ | | | |
| Festival list, month filter, details | ✅ | | | |
| Place picker (India + major cities abroad, searchable) | ✅ | | | |
| Device location → timings for the exact coordinates, anywhere up to ±60° latitude | ✅ | | | |
| Exact-coordinate on-device rise/set (from the pack's Sun/Moon table) | ✅ (moved from v1.1, decision 2026-10-13) | | | |
| Offline data (3 years bundled) | ✅ | | | |
| Festival + tithi reminders (Ekadashi, Purnima, Amavasya) | ✅ | | | |
| Custom reminders | | ✅ | | |
| Share festival card (image) | ✅ | | | |
| Search by Bengali / Gregorian date | ✅ | | | |
| Bengali + English UI, both complete (§13) | ✅ | | | |
| Bilingual name display (both scripts) | ✅ | | | |
| In-app glossary (শব্দকোষ / Glossary) | ✅ | | | |
| Dark mode, text size control | ✅ | | | |
| Adaptive layout (phone portrait + landscape, large text) | ✅ | | | |
| Two-pane tablet / foldable layout | | ✅ | | |
| Hindi or other UI languages | | | ✅ (architecture allows it; no MVP work) | |
| Bengal periods (বারবেলা etc.) | ✅ behind flag until validated | | | |
| Surya Siddhanta / Gupta Press tradition | | ✅ | | |
| দণ্ড-পল time display | | ✅ | | |
| Home-screen widget (Android) | | ✅ | | |
| Marriage / Griha Pravesh / Annaprashan dates | | | ✅ (only from licensed or expert data) | |
| Daily rashifal | | | ✅ optional, clearly labelled entertainment | |
| Bangladesh calendar | | | ✅ | |
| Kundli generation, paid astrologer chat | | | | ❌ |
| Paywalled religious data | | | | ❌ |

---

## 8. Functional requirements

Screen layouts for these are in §11 (`spec/screens.md`).

IDs are referenced by tests and tickets.

### 8.1 Today (আজ)
- **FR-HOME-01** Show Gregorian date, weekday, Bengali date (day, month, year) in Bengali numerals.
- **FR-HOME-02** Show current tithi with paksha, end time, and progress through the tithi. If the tithi changes later today, show the next tithi and its start.
- **FR-HOME-03** Show nakshatra, yoga, karana with end times.
- **FR-HOME-04** Show sunrise, sunset, moonrise, moonset for the selected place; label the place and "IST".
- **FR-HOME-05** Show today's observances with verification badge.
- **FR-HOME-06** Show the next 3 upcoming tier-1/2 observances with "N দিন বাকি".
- **FR-HOME-07** Show today's inauspicious and auspicious periods; highlight the one currently active.
- **FR-HOME-08** Update automatically when the app is open across a tithi transition, sunrise, or midnight.
- **FR-HOME-09** If data for today is missing or stale, show an explicit state (§11.9), never placeholder numbers.

### 8.2 Calendar (মাস)
- **FR-CAL-01** Month grid with both Bengali and Gregorian day numbers in each cell.
- **FR-CAL-02** Two modes: Bengali month view (default; e.g. আশ্বিন ১৪৩৩) and Gregorian month view. A segmented control switches modes and keeps the selected day.
- **FR-CAL-03** Swipe and arrow buttons for previous/next month; tap the title to jump to any month/year.
- **FR-CAL-04** Cell markers: Purnima (filled circle), Amavasya (hollow circle), Ekadashi (small "এ"), festival (colour bar), today (ring), selected (fill). Legend reachable from the header.
- **FR-CAL-05** Tap a day → Day detail. Long-press → quick peek sheet.
- **FR-CAL-06** Bengali month grids start on the 1st of the Bengali month, which may fall mid-Gregorian-month; month lengths 29–32 come from data.
- **FR-CAL-07** "আজ" button returns to today.

### 8.3 Day detail (দিন)
- **FR-DAY-01** Everything from FR-HOME-02..07 for any date.
- **FR-DAY-02** Show kshaya/vriddhi tithi information when applicable.
- **FR-DAY-03** Show Rahu Kaal, Yamaganda, Gulika, and validated Bengal periods as time ranges.
- **FR-DAY-04** Footer: tradition, city, coordinates, time zone, data-pack version, verification status.
- **FR-DAY-05** Previous/next day by swipe.
- **FR-DAY-06** Share day summary as an image.

### 8.4 Festivals (পার্বণ)
- **FR-FEST-01** Year list grouped by Bengali month, with Gregorian date.
- **FR-FEST-02** Filters: month, category (পূজা, ব্রত/উপবাস, তিথি, উৎসব, জয়ন্তী), tier.
- **FR-FEST-03** Festival detail: short description (original text, written by us), date(s), relevant windows (e.g. Sandhi Puja), tithi involved, status, reminder toggle, share.
- **FR-FEST-04** Multi-day festivals show each day (e.g. Durga Puja Shashthi→Dashami).

### 8.5 Location
A "place" is either a listed city (name + coordinates from the place list, Q13) or the user's own location (coordinates only). Both are computed the same way.

- **FR-LOC-01** Manual place picker with search in Bengali and English (e.g. "হাওড়া", "howrah", "nainital"): West Bengal by district, the rest of India, and major cities abroad with Bengali communities.
- **FR-LOC-02** "Use my location" requests coarse location only after the user taps it. Timings are computed for those coordinates (rounded to 0.01°, about 1 km), not for the nearest listed city. The place is labelled with the nearest listed name and the coordinates ("নৈনিতালের কাছে · ২৯.৩৮° উ, ৭৯.৪৬° পূ").
- **FR-LOC-03** Sunrise, sunset, moonrise, moonset, the daily periods and the tithi at sunrise are computed on the phone for the place's coordinates (§6.5.5). Tithi, nakshatra, yoga and karana moments, Bengali dates and festival dates do not depend on the place; festival dates follow the reference place (Q1), and the place screen and Sources screen say so.
- **FR-LOC-04** Denied permission never blocks the app; Kolkata is the default.
- **FR-LOC-05** After a place change, show a one-time toast listing what changed ("সূর্যোদয় ও রাহুকাল বদলেছে; তিথি ও উৎসবের তারিখ একই").
- **FR-LOC-06** The user's coordinates stay on the phone. They are never sent anywhere; an error report carries the nearest listed city id and a "own location" flag instead (§15.3).
- **FR-LOC-07** Places beyond ±60° latitude, where the Sun may not rise or set on some days, are refused with an explanation in both languages; the previous place stays selected.
- **FR-LOC-08** Outside India the times are still shown in IST with the "IST" label until Q16 is decided, and the place screen says so.

### 8.6 Reminders
- **FR-REM-01** Per-festival reminder: day before at 20:00 and/or morning of at 06:00 (defaults editable).
- **FR-REM-02** Recurring: every Ekadashi / Purnima / Amavasya, with an option "at tithi start" or "morning of udaya day".
- **FR-REM-03** Reminders are scheduled locally for the next 60 days and rescheduled on app open, data-pack update, place change, and device reboot.
- **FR-REM-04** Notification text in the UI language, e.g. "আগামীকাল একাদশী। তিথি শুরু রাত ৯:১৪" / "Ekadashi tomorrow. Tithi begins 9:14 PM" (sample).

### 8.7 Search
- **FR-SRCH-01** Search by Gregorian date ("12/10/2026"), Bengali date ("২৫ আশ্বিন ১৪৩৩"), or festival name in either script.

### 8.8 Settings & trust
- **FR-SET-01** Language, tradition, place, theme, text size, 12/24 h, numeral style (Bengali/Latin).
- **FR-SET-02** "তথ্যসূত্র ও যাচাই" (Sources & verification) screen: explains tradition, pipeline, references, pack versions, last validation date.
- **FR-SET-03** "ভুল জানান" (Report an error): pre-filled form with date, city, tradition, pack version and a free-text field; works offline (queued).
- **FR-SET-04** Remove ads (premium purchase / restore).
- **FR-SET-05** Changing language applies instantly to every screen without restarting the app or losing navigation state, and re-localises scheduled notifications (§17).
- **FR-SET-06** "নাম দুই লিপিতে" / "Names in both scripts": when on, panchanga names, Bengali dates and festival names show the other script as a smaller second line (§13.4).
- **FR-SET-07** Glossary (শব্দকোষ / Glossary): every panchanga term and period with a 1–2 sentence plain-language explanation in the UI language. Terms on Today and Day detail open their glossary entry on long-press or via an (i) affordance.

### 8.9 Localisation (both languages)
- **FR-L10N-01** Two complete UI languages: বাংলা (`bn`, source) and English (`en`, written for Indian English, `en-IN` conventions). No screen, dialog, toast, error, notification, share card, semantics label or store asset may exist in only one language.
- **FR-L10N-02** First launch picks the language from the device locale (`bn*` → বাংলা; anything else → see Q15) and the onboarding language step confirms it. The choice is stored in-app and is independent of the device locale afterwards.
- **FR-L10N-03** Android 13+: the language also appears in system Settings → App languages (per-app language preference, `locales_config.xml`); a change made there is reflected in the app and vice versa.
- **FR-L10N-04** Numeral style (Bengali ০–৯ / Latin 0–9) is a separate setting from language. Defaults: Bengali UI → Bengali numerals; English UI → Latin numerals.
- **FR-L10N-05** Panchanga names in English use romanised Indic terms (Shukla Saptami, Nakshatra, Barabela) from the `names` table, never invented English translations ("seventh waxing lunar day") as primary labels. Meanings appear in the glossary (FR-SET-07).
- **FR-L10N-06** Dates and times follow the formatting rules in §13.3 for each language, including English plural forms ("1 day left" / "3 days left") through ICU plural messages.
- **FR-L10N-07** Search accepts both scripts and both numeral systems whatever the UI language (FR-SRCH-01, §13.6).
- **FR-L10N-08** Screen-reader labels are in the UI language; in bilingual display mode the second-script line is either tagged with its locale or excluded from the label, so TalkBack never reads Bengali with an English voice (§13.7).
- **FR-L10N-09** The bundled pack carries both `name_bn` and `name_en` for every name and observance, and `description_bn` and `description_en` for every observance. A pack missing either language fails the build (§6.4 step 5).

---

## 9. User stories and acceptance criteria

**US-01 Today's tithi.** As Mamata, I want to see today's tithi in Bengali the moment I open the app.
- Given data for today exists, when I open the app, then the tithi name, paksha and end time are visible without scrolling on a 360×640 dp screen at 130% font scale.
- Given the tithi ends at 14:32 (sample), when the clock passes 14:32 with the app open, then the card switches to the next tithi within 60 s.
- Given today's data is missing, then I see "আজকের তথ্য পাওয়া যায়নি" with a "আবার চেষ্টা করুন" button, and no numbers.

**US-02 Tradition clarity.** As Mamata, I want to know which panjika the app follows so I can compare with mine.
- Every date screen footer shows the tradition name.
- The onboarding tradition step explains the two schools in ≤ 2 sentences each.

**US-03 Festival reminder.** As Arindam, I want a reminder before Kali Puja.
- When I tap "মনে করিয়ে দিন" on Kali Puja, then a notification permission prompt appears (Android 13+) only if not yet granted.
- Given permission is denied, then the toggle reverts and an inline message explains how to enable it.
- Given permission is granted, then a notification fires the evening before at the chosen time, in IST converted to device time.

**US-04 City change.** As Riya in Siliguri, I want sunrise for my city.
- When I pick শিলিগুড়ি, then sunrise/sunset/moonrise/moonset and Rahu Kaal update; tithi end times and festival dates do not change; a toast says so.

**US-12 Anywhere.** As Anirban in Nainital (not in any list), I want sunrise and Rahu Kaal for where I actually am.
- When I tap "আমার অবস্থান ব্যবহার করুন" and allow coarse location, then Today shows sunrise and sunset computed for my coordinates (equal, within the §6.7 tolerance, to the pipeline's values for the same coordinates in the shared rise/set fixture), labelled "নৈনিতালের কাছে" with the coordinates.
- Festival dates are the same as for Kolkata, and the place screen says they follow the reference place.
- With location denied, I can still type "nainital" or "নৈনিতাল" and get the same result.
- The coordinates are not in any network request (checked by a test).

**US-05 Offline.** As any user, I want the app to work without internet.
- Given airplane mode and a fresh install, then Today, Calendar, Day and Festivals work for every date covered by the bundled pack (3 Bengali years).
- Given a date outside the bundled range, then the app says the data isn't downloaded and offers download when online.

**US-06 Calendar markers.** As Mamata, I want to spot Ekadashi and Purnima at a glance.
- Purnima, Amavasya and Ekadashi markers are distinguishable by shape, not only colour (colour-blind safe).
- The legend is reachable in one tap from the calendar header.

**US-07 Report an error.** As any user, if a date looks wrong, I want to tell the team.
- The report form pre-fills date, city, tradition and pack version; submitting offline queues it and shows "পাঠানো হবে".

**US-08 Accessibility.** As a TalkBack user, I want the calendar announced properly.
- Each day cell announces e.g. "সোমবার, ১২ অক্টোবর, ২৫ আশ্বিন, শুক্লা সপ্তমী, দুর্গাষষ্ঠী" (sample).
- In English the same cell announces "Monday, 12 October, 25 Ashwin, Shukla Saptami, Durga Shashthi" (sample).

**US-09 English UI.** As Ananya, I want the whole app in English that still uses the real panjika terms.
- Given the device language is English, when I open the app for the first time, then onboarding starts in English with Bengali one tap away.
- Every screen, notification and share card is in English; no Bengali-only string appears except panchanga names when "Names in both scripts" is on.
- Tithi, nakshatra, yoga, karana and periods use romanised terms ("Shukla Saptami", "Barabela"); long-press on a term opens its glossary entry.
- At 130% font scale on a 360×640 dp screen, the English tithi seal shows name, end time and next tithi without truncation or scrolling, just as in Bengali.

**US-10 Switching language.** As Arindam, I want to switch to Bengali to show my mother, then switch back.
- When I change the language in Settings, then the current screen re-renders in the new language within one frame, stays on the same screen and date, and the back stack is preserved.
- Pending reminders are re-localised; the next notification arrives in the new language.

**US-11 Both scripts.** As Ananya, I want to see the Bengali names under the English ones.
- When "Names in both scripts" is on, then tithi, nakshatra, Bengali date and festival names show a second line in Bengali script.
- The second line never pushes the tithi seal below the fold at 130% font scale; at 200% it wraps rather than truncates.

---

## 25. Risks & mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| A festival date differs from what users' family panjika says | High | High | Tradition shown everywhere; Surya Siddhanta in v1.1; explanation screen; error report path |
| Computational rule wrong for a tier-1 festival | Medium | Very high | Expert review + reference match required; override mechanism; 72 h correction SLA |
| Licence problem (ephemeris, fonts, data) | Low (with plan) | High | Skyfield/JPL/Astronomy Engine (permissive); THIRD_PARTY_NOTICES; legal review of Rashtriya Panchang reuse |
| Can't find a reviewer | Medium | High | Approach temple trusts, Sanskrit college faculty, panjika publishers; budget a fee |
| Ads underperform | Medium | Medium | Premium tier; keep costs near zero (static hosting) |
| Notification reliability on OEM phones | High | Medium | Inexact defaults; in-app "check settings" guide for Xiaomi/Samsung |
| Competitors copy positioning | Medium | Low | Trust is earned per season; keep the verification record public |

---

## 26. Open questions

Only the owner decides these. Until then the code puts the behaviour behind a flag and leaves `TODO(Q#)`. "Blocks" is the first phase that cannot finish without the answer.

| # | Question | Owner | Blocks |
|---|---|---|---|
| Q1 | Which reference location does Bishuddha Siddhanta use for festival decisions? | Expert | Phase 5 |
| Q2 | Amanta lunar month naming and the Bengali names used for lunar months | Expert | Phase 3 |
| Q3 | Sunrise definition (upper limb vs centre, refraction) used by the reference | Validate vs reference | Phase 3 |
| Q4 | Exact midnight in the Bengal sankranti rule; treatment of a pre-sunrise sankranti | Expert | Phase 3 |
| Q5 | Bengali spelling standard, incl. Gregorian month names and ordinal dates (১লা, ২৫শে) | Reviewer | Phase 3 |
| Q6 | Error reports: own endpoint on the VPS or a form service | Saurabh | Phase 6 |
| Q7 | Exact-alarm permission eligibility under current Play policy | Saurabh | Phase 5 |
| Q8 | Analytics: none, privacy-light self-hosted, or Firebase | Saurabh | Phase 6 |
| Q9 | Licence of the `panchang` PyPI library (cross-check only) | Saurabh | Phase 2 |
| Q10 | Reuse terms of the Rashtriya Panchang e-version | Saurabh / counsel | Phase 3 |
| Q11 | App ID / package name (e.g. `com.scaleroot.panjika`) and display name | Saurabh | Phase 1 uses a placeholder; final before the first Play upload (Phase 7) |
| Q12 | Who holds the pack-signing and Play upload keys; where backups live | Saurabh | Phase 3 (dev key), Phase 7 (production key) |
| Q13 | Source for the place list's names and coordinates (GeoNames, Survey of India, open map) | Saurabh | Phase 2 |
| Q14 | English romanisation standard ("Boishakh" vs "Vaishakha"; diacritics or not) | Saurabh + reviewer | Phase 3 |
| Q15 | Language defaults: UI language for non-bn/en devices; default of "names in both scripts" | Saurabh | Phase 4 |
| Q16 | Places outside India: show times in IST (as now) or in the place's own time zone (then also: which zone database, and how the Bengali date is labelled) | Saurabh | Phase 4 |
