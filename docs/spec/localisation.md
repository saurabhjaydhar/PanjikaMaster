# Bengali and English

> Part of the Bangla Panjika spec. Section numbers (§) are permanent IDs shared by all docs; `docs/README.md` maps each one to its file.

## 13. Content & localisation

### 13.1 Principles and sources of truth
- **Two complete languages.** Bengali (`bn`) is the source language; English (`en`, Indian English) is equally complete. Neither is machine-translated in production: each string is written by a fluent writer and reviewed (§13.8).
- **UI strings** live in ARB files: `app_bn.arb` (source of truth) and `app_en.arb`.
- **Panchanga names** (tithi, paksha, nakshatra, yoga, karana, lunar and solar months, weekdays, periods, traditions) live in the pack's `names` table with `name_bn`, `name_en` and `translit`, not in ARB. Packs can then correct spellings without an app update.
- **Festival names and descriptions** live in the `observances` table (`name_bn`, `name_en`, `description_bn`, `description_en`).
- **Spelling authority**: Bengali follows one style guide consistently (e.g. Paschimbanga Bangla Akademi spelling), decided with the reviewer (Q5). English romanisation follows one standard (Q14).

### 13.2 Voice and tone
| | বাংলা | English |
|---|---|---|
| Register | Standard colloquial (চলিত), polite আপনি form | Plain Indian English; warm, not cute |
| Sentences | Short; everyday words; Sanskrit terms only where they are the real name (তিথি, নক্ষত্র) | Short; contractions fine ("isn't"); sentence case |
| Panjika terms | As in the printed panjika | **Romanise, don't translate**: "Tithi", "Ekadashi", "Barabela", with a glossary entry, never "lunar day" as the label |
| Religious claims | Attribute to tradition ("পঞ্জিকা মতে অশুভ") | Same ("considered inauspicious in the panjika") |
| Buttons | Verb-first, imperative polite: "মনে করিয়ে দিন" | Verb-first: "Remind me" |

### 13.3 Formatting by language (all example values are sample)

| Item | বাংলা | English |
|---|---|---|
| Bengali date | ২৫ আশ্বিন ১৪৩৩ (ordinal form ২৫শে — see below) | 25 Ashwin 1433 |
| Gregorian date | ১২ অক্টোবর ২০২৬ | 12 October 2026 (day-month-year, en-IN) |
| Short date | সোম, ১২ অক্টো | Mon, 12 Oct |
| Numeric date | ১২/১০/২০২৬ | 12/10/2026 (dd/mm/yyyy — never US order) |
| Time, 12 h | দুপুর ২:৩২ | 2:32 PM |
| Time, 24 h | ১৪:৩২ | 14:32 |
| After midnight | রাত ১:১০ (পরদিন) | 1:10 AM (next day) |
| Range | সকাল ৭:৩২–৯:০০ | 7:32–9:00 AM (one AM/PM when both ends share it) |
| Until | দুপুর ২:৩২ পর্যন্ত | until 2:32 PM |
| Countdown | আজ · আগামীকাল · ৩ দিন বাকি | Today · Tomorrow · in 3 days (ICU plural: "in 1 day") |
| Distance | ১২ কিমি | 12 km |
| Large numbers | ১,০৮,০০০ (Indian grouping) | 1,08,000 (Indian grouping) |
| Prices | Store-provided localised string | Store-provided localised string — never formatted by us |
| Time zone label | IST | IST |

- All formatting goes through one `PanjikaFormatter` in `core/l10n` (dates, times, ranges, numerals, countdowns). Widgets never call `toString()`, `DateFormat` or `NumberFormat` directly. This is unit-tested per language and numeral style.
- Gregorian month and weekday names in Bengali come from our own tables (spelling per Q5), not from `intl`'s `bn` locale data, so they match our style guide.
- **Bengali ordinal dates.** Panjikas traditionally write ১লা, ২রা, ৩রা, ৪ঠা, ৫ই–১৮ই, ১৯শে–৩২শে (as in "পয়লা/১লা বৈশাখ"). The formatter supports this behind a flag (`bnOrdinalDates`); whether it is on by default, and for which calendars, is part of Q5. `TODO(Q5)`.
- Numeral style is independent of language (FR-L10N-04): an English UI with Bengali numerals, or a Bengali UI with Latin numerals, must both format correctly.

### 13.4 Bilingual name display ("Names in both scripts")
- The **primary line is always in the UI language**. The second line shows the other script in `ink-muted`, one type role smaller (Display → Title, Body → Caption), same weight.
- Applies to: tithi, paksha, nakshatra, yoga, karana, periods, Bengali month and date, festival names, city names in the picker. Does **not** apply to UI chrome (buttons, headers, settings, messages).
- Rendered only through `NameText` (§12.5), so the rule is enforced in one place.
- Default: `TODO(Q15)`. Recommendation: off in the Bengali UI, on in the English UI (the English reader most needs the Bengali to match the printed panjika).
- Layout budget: on Today, the second lines must not push the tithi seal below the fold at 130% text (US-11).

### 13.5 ARB conventions and checks
- Keys are lowerCamelCase, prefixed by feature: `todayComingUp`, `calendarLegendTitle`, `reminderPermissionDenied`.
- Every key in `app_bn.arb` has an `@key` entry with a `description` (context for the writer: where it appears, max length) and typed `placeholders` with examples.
- Use ICU `plural` and `select` for anything with numbers or variants. Bengali often needs no plural form, but English does, and the message must be one string in each language.
- No concatenation, no HTML, no leading/trailing spaces, no hard-coded numerals inside messages (numbers come in as placeholders and go through `PanjikaFormatter`).
- **CI checks (fail the build):**
  1. `app_bn.arb` and `app_en.arb` have identical key sets and identical placeholder names/types.
  2. No empty values; no English value identical to its Bengali value (or vice versa) unless whitelisted (e.g. "IST").
  3. No string literals in `Text(...)`/`Semantics(label: ...)` outside `l10n/` and tests (custom lint or grep).
  4. Every observance and name row in a pack has both languages (FR-L10N-09).
- **Expansion test locale:** a test-only generated ARB (`app_en_XA.arb`) stretches every English string by ~40% and adds accents, and a test-only Bengali variant adds heavy conjuncts. Goldens run with both to catch truncation before real copy changes.

### 13.6 Search normalisation
Search works in both scripts and with both numeral systems, whatever the UI language (FR-L10N-07):
- Bengali ↔ Latin digits; dd/mm/yyyy dates; Bengali dates with or without ordinal suffix ("২৫ আশ্বিন", "২৫শে আশ্বিন", "25 Ashwin").
- Transliteration variants from `names.translit` plus an alias list: Durga/Durgā/দুর্গা; bardhaman/burdwan/বর্ধমান; Boishakh/Baishakh/Vaisakh/বৈশাখ.
- Bengali spelling variants (কালীপূজা / কালী পূজা; লক্ষ্মী / লক্ষী as a typo-tolerant match).
- Case-, diacritic-, space- and hyphen-insensitive; results are shown in the UI language.

### 13.7 Accessibility in each language
- Semantics labels come from ARB in the UI language, written as natural sentences ("শুক্লা সপ্তমী, দুপুর ২:৩২ পর্যন্ত, তারপর অষ্টমী" / "Shukla Saptami until 2:32 PM, then Ashtami").
- In bilingual mode the second-script line is excluded from semantics (`ExcludeSemantics`) by default, or tagged with its locale (`LocaleStringAttribute`) if user testing shows people want it read. TalkBack must never read Bengali with an English voice.
- Many phones ship without a Bengali TTS voice. More → Help explains, in both languages, how to install the Bengali voice for Google Speech Services.
- Test TalkBack in both languages on 2 devices each (§22.2).

### 13.8 Content ownership and review
- Festival descriptions are written **natively in each language** (80–150 words each; the English one is not a line-by-line translation), marked `review: pending` until a human reviews accuracy and tone. No copying from websites or panjikas.
- Reviewers: a Bengali reviewer (spelling per Q5) and an English reviewer fluent in Indian English and familiar with Bengali festivals.
- **Copy freeze** before each release: after it, a string change must land in both languages at once.

### 13.9 Outside the app
Store listing (§23.2), screenshots (§23.4), privacy policy, notification channels and texts (§17), share cards (§11.8) and the error-report confirmation all exist in both languages. Exception: third-party licence texts in Flutter's licence page stay in their original language; our own notices are bilingual.

---

## 27. Appendix (glossary)

### 27.1 Glossary (bn → en)

The "English UI label" column is the romanised form shown in the English UI (FR-L10N-05). It is a **draft pending Q14** and becomes the `name_en` values in the `names` table. The "Meaning" column is source material for `gloss_en` (FR-SET-07).

| Bengali | English UI label (draft, Q14) | Meaning |
|---|---|---|
| তিথি | Tithi | Lunar day (12° of Moon–Sun elongation) |
| শুক্লপক্ষ / কৃষ্ণপক্ষ | Shukla Paksha / Krishna Paksha | Waxing / waning fortnight |
| নক্ষত্র | Nakshatra | Lunar mansion (13°20′) |
| যোগ | Yoga | Sum of Sun and Moon longitudes in 13°20′ units |
| করণ | Karana | Half-tithi |
| সংক্রান্তি | Sankranti | Solar ingress into a zodiac sign |
| অয়নাংশ | Ayanamsa | Precession offset |
| উদয়া তিথি | Udaya Tithi | Tithi prevailing at sunrise |
| ক্ষয় / বৃদ্ধি তিথি | Kshaya / Vriddhi Tithi | Omitted / repeated tithi |
| মলমাস | Mala Masa | Intercalary lunar month |
| দণ্ড, পল | Danda, Pala | 24 minutes, 24 seconds |
| রাহুকাল, যমগণ্ড, গুলিক | Rahu Kaal, Yamaganda, Gulika Kaal | Inauspicious day divisions |
| বারবেলা, কালবেলা, কালরাত্রি | Barabela, Kalabela, Kalaratri | Bengal-specific inauspicious periods |
| অমৃতযোগ, মাহেন্দ্রযোগ | Amrita Yoga, Mahendra Yoga | Bengal-specific auspicious periods |
| পঞ্জিকা | Panjika | Almanac |
| বিশুদ্ধ সিদ্ধান্ত / সূর্যসিদ্ধান্ত | Bishuddha Siddhanta / Surya Siddhanta | The two West Bengal schools (§5.2) |

Name lists (Bengali → English UI label, draft):

| Kind | Bengali | English UI label (draft, Q14) |
|---|---|---|
| Months | বৈশাখ, জ্যৈষ্ঠ, আষাঢ়, শ্রাবণ, ভাদ্র, আশ্বিন, কার্তিক, অগ্রহায়ণ, পৌষ, মাঘ, ফাল্গুন, চৈত্র | Boishakh, Jyoishtho, Asharh, Srabon, Bhadro, Ashwin, Kartik, Agrahayan, Poush, Magh, Falgun, Chaitra |
| Weekdays | রবিবার, সোমবার, মঙ্গলবার, বুধবার, বৃহস্পতিবার, শুক্রবার, শনিবার | Sunday … Saturday (English weekday names, not romanised) |
| Tithis (each paksha) | প্রতিপদ, দ্বিতীয়া, তৃতীয়া, চতুর্থী, পঞ্চমী, ষষ্ঠী, সপ্তমী, অষ্টমী, নবমী, দশমী, একাদশী, দ্বাদশী, ত্রয়োদশী, চতুর্দশী, পূর্ণিমা / অমাবস্যা | Pratipada, Dwitiya, Tritiya, Chaturthi, Panchami, Shashthi, Saptami, Ashtami, Navami, Dashami, Ekadashi, Dwadashi, Trayodashi, Chaturdashi, Purnima / Amavasya |
| Nakshatras | অশ্বিনী, ভরণী, কৃত্তিকা, রোহিণী, মৃগশিরা, আর্দ্রা, পুনর্বসু, পুষ্যা, অশ্লেষা, মঘা, পূর্বফাল্গুনী, উত্তরফাল্গুনী, হস্তা, চিত্রা, স্বাতী, বিশাখা, অনুরাধা, জ্যেষ্ঠা, মূলা, পূর্বাষাঢ়া, উত্তরাষাঢ়া, শ্রবণা, ধনিষ্ঠা, শতভিষা, পূর্বভাদ্রপদ, উত্তরভাদ্রপদ, রেবতী | Ashwini, Bharani, Krittika, Rohini, Mrigashira, Ardra, Punarvasu, Pushya, Ashlesha, Magha, Purva Phalguni, Uttara Phalguni, Hasta, Chitra, Swati, Vishakha, Anuradha, Jyeshtha, Mula, Purva Ashadha, Uttara Ashadha, Shravana, Dhanishtha, Shatabhisha, Purva Bhadrapada, Uttara Bhadrapada, Revati |
| Yogas | বিষ্কম্ভ, প্রীতি, আয়ুষ্মান, সৌভাগ্য, শোভন, অতিগণ্ড, সুকর্মা, ধৃতি, শূল, গণ্ড, বৃদ্ধি, ধ্রুব, ব্যাঘাত, হর্ষণ, বজ্র, সিদ্ধি, ব্যতীপাত, বরীয়ান, পরিঘ, শিব, সিদ্ধ, সাধ্য, শুভ, শুক্ল, ব্রহ্ম, ইন্দ্র, বৈধৃতি | Vishkambha, Priti, Ayushman, Saubhagya, Shobhana, Atiganda, Sukarma, Dhriti, Shula, Ganda, Vriddhi, Dhruva, Vyaghata, Harshana, Vajra, Siddhi, Vyatipata, Variyan, Parigha, Shiva, Siddha, Sadhya, Shubha, Shukla, Brahma, Indra, Vaidhriti |
| Karanas | বব, বালব, কৌলব, তৈতিল, গর, বণিজ, বিষ্টি (ভদ্রা), শকুনি, চতুষ্পদ, নাগ, কিংস্তুঘ্ন | Bava, Balava, Kaulava, Taitila, Gara, Vanija, Vishti (Bhadra), Shakuni, Chatushpada, Naga, Kimstughna |

(All Bengali spellings to be checked by the reviewer under Q5; all English labels under Q14. The month labels mix Bengali-pronunciation and Sanskritised forms on purpose, to show the choice Q14 has to make. "Poila Boishakh" stays as is because it is the established English name of the festival.)
