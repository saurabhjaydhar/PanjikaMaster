# Compliance, monetisation and release

> Part of the Bangla Panjika spec. Section numbers (§) are permanent IDs shared by all docs; `docs/README.md` maps each one to its file.

## 19. Privacy, permissions & compliance

| Item | Approach |
|---|---|
| Location | Coarse only (`ACCESS_COARSE_LOCATION`), on tap, never in background; stored as chosen city id, not coordinates |
| Notifications | Runtime permission on first reminder |
| Personal data | None collected by us; no accounts |
| Ads | AdMob collects device identifiers; disclose in Play Data safety; non-personalised ads option; UMP consent where required |
| Analytics | Off by default or privacy-light (aggregate screen counts, no identifiers) — decide Q8 |
| Indian law | Review obligations under the Digital Personal Data Protection Act, 2023 and its current rules with counsel |
| Children | Not directed at children; rating "Everyone"/4+ |
| Privacy policy | Bengali + English, hosted on a stable URL |

### 19.1 Consolidated licensing & compliance checklist

Status key: ✅ confirmed during research · 🔍 verify before release · ⛔ excluded.

| # | Item | Licence / obligation | Action | Status |
|---|---|---|---|---|
| L1 | Skyfield (pipeline) | MIT | Keep licence in `data/THIRD_PARTY_NOTICES` | 🔍 confirm in repo |
| L2 | JPL DE440s ephemeris (pipeline) | NASA/JPL terms | Read and record terms; ephemeris file is not shipped in the app | 🔍 |
| L3 | Astronomy Engine (v1.1, on device) | MIT | Include notice in app licences | ✅ MIT per project page |
| L4 | Swiss Ephemeris | AGPL-3.0 or paid licence | Do not use anywhere | ⛔ |
| L5 | `panchang` PyPI library (cross-check only) | Unknown | Check before use (Q9) | 🔍 |
| L6 | Tiro Bangla font | SIL OFL 1.1 | Bundle OFL text; don't sell font alone; check Reserved Font Name before renaming a subset | ✅ |
| L7 | Noto Sans Bengali font | SIL OFL 1.1 | Same as L6 | ✅ |
| L8 | Flutter/Dart packages | Mostly MIT/BSD/Apache-2.0 | Check each on pub.dev when adding; list in `docs/dependencies.md`; app shows them via `showLicensePage` | 🔍 per package |
| L9 | City coordinates | Depends on source (e.g. GeoNames is CC BY 4.0, needs attribution) | Pick source (Q13); add attribution in licences screen | 🔍 |
| L10 | Rashtriya Panchang | Government publication | Used only for validation, not shipped; confirm reuse terms (Q10) | 🔍 |
| L11 | Printed panjikas | Publisher copyright | Validation only; never copy tables, text or layout; no claimed affiliation | ✅ policy |
| L12 | Festival descriptions | Our own writing | Written in-house, reviewed; no copying from websites | ✅ policy |
| L13 | Icons, motifs, share-card art | Our own or licensed | Record source of every asset in `docs/assets.md` | 🔍 |
| L14 | App name | Trademark | Search Indian trademark registry and Play Store before finalising | 🔍 |
| L15 | Google Play target API | Must target Android 16 (API 36) for new apps and updates since 31 Aug 2026 | Set `targetSdk 36`; test edge-to-edge and predictive back | ✅ requirement confirmed |
| L16 | Play Data safety form | Declare SDK data collection (AdMob identifiers, crash data) | Fill from actual SDK behaviour | 🔍 |
| L17 | Privacy policy | Required URL, Bengali + English | Host on own domain/VPS | 🔍 |
| L18 | Permissions declarations | Notifications, coarse location, exact alarm (if used) | Rationale copy before prompts; exact-alarm eligibility (Q7) | 🔍 |
| L19 | Content rating questionnaire | Play IARC | Complete honestly (no gambling, no user content) | 🔍 |
| L20 | AdMob policy | Ad placement + consent | No ads near tap targets that cause accidental clicks; UMP consent for EEA/UK; block sensitive ad categories (gambling, dating, alcohol) in AdMob blocking controls | 🔍 |
| L21 | In-app purchase | Play Billing | Restore flow; price shown in store currency | 🔍 |
| L22 | India DPDP Act, 2023 | Data protection | We collect no personal data ourselves; confirm with counsel what SDKs imply | 🔍 |
| L23 | Religious sensitivity | Reputation | No deity images in icon or ads; reviewer checks festival copy tone | ✅ policy |
| L24 | Pack signing key | Security | Ed25519 private key never in repo; stored offline with two backups (Q12) | 🔍 |

---

## 20. Monetization
### 20.1 Principles
Free core forever: today, calendar, day detail, festivals, basic reminders, offline. Ads never sit between the user and religious information.
### 20.2 Ad placement rules

| Screen | Allowed | Not allowed |
|---|---|---|
| Today | One native ad card below "আসছে" | Anything above the fold; app-open ads |
| Calendar | Adaptive banner at the bottom, above nav bar | Ads inside the grid |
| Day detail | One native card after the observances section | — |
| Festival list | One native card every 15 rows, max 2 per screen | — |
| Festival detail | None | — |
| Anywhere | — | Interstitials, rewarded gates, auto-play video, ads in notifications |
### 20.3 Premium ("বিজ্ঞাপনমুক্ত")
- Removes ads; adds custom reminders, extra themes, dark-mode share cards, and widgets (v1.1).
- Price test: ₹99/year vs ₹199 lifetime (assumptions; test with Play price experiments).

---

## 21. Analytics & success measurement

Events (aggregate, no identifiers if Q8 = privacy-light): `app_open`, `screen_view{name}`, `festival_view{id}`, `reminder_set{kind}`, `share{kind}`, `city_change`, `tradition_change`, `error_report_sent`, `pack_import{result}`.

North-star: **days per month a user opens Today** (habit). Watch: correctness reports per 10k DAU, uninstall rate in the first 3 days, rating trend after each festival season.

---

## 23. Release

- **Android**: app bundle (AAB), Play App Signing, **target Android 16 (API 36)** — required for new apps and updates on Google Play since 31 Aug 2026; test edge-to-edge layout (cannot be opted out) and predictive back (use `PopScope`, not legacy back handling), R8 shrinking with Drift rules verified, release build tested on a physical device (sqlite native library present).
- **Store listing** (Bengali + English): title idea "বাংলা পঞ্জিকা — বিশুদ্ধ মতে" (check trademark/name conflicts); screenshots: Today, Calendar, Festival list, Day detail, Dark mode, "Sources & verification" (trust as a selling point).
- **Data safety**: declare AdMob identifiers, crash data (if any), coarse location *not collected* (used on device only — confirm with how the SDKs behave).
- **Permissions copy** shown before system prompts.
- **Launch checklist**: privacy policy live; error-report path tested; packs signed with production key (key stored offline, backup in two places); tier-1 festivals expert-reviewed; release notes in Bengali; staged rollout 10% → 50% → 100% over a week.
- **iOS** (later): App Store privacy labels, ATT prompt only if personalised ads are used.

### 23.1 Yearly maintenance
Follow §6.9. Additionally each year: bump bundled packs in the APK before Poila Boishakh, refresh store screenshots with the new Bengali year, re-run accessibility checks after Flutter upgrades.

### 23.2 Store listing copy (draft)

Keep every claim true at launch. If the Bengal periods (§6.5.9) are not validated by launch, do not mention them.

**Title (≤ 30 characters)**
- বাংলা: বাংলা পঞ্জিকা — বিশুদ্ধ মতে
- English: Bangla Panjika: Tithi & Puja

**Short description (≤ 80 characters)**
- বাংলা: আজকের তিথি, পূজা-পার্বণ, সূর্যোদয় ও রাহুকাল। অফলাইনেও চলে।
- English: Today's tithi, puja dates, sunrise and Rahu Kaal in Bengali. Works offline.

**Full description — বাংলা**

> প্রতিদিনের পঞ্জিকা, এখন ফোনে — পরিষ্কার, বাংলায়, আর বিশ্বাসযোগ্য।
>
> • আজকের তিথি, নক্ষত্র, যোগ ও করণ — কখন শেষ, তারপর কী
> • সূর্যোদয়, সূর্যাস্ত, চন্দ্রোদয়, চন্দ্রাস্ত — আপনার শহরের হিসাবে
> • রাহুকাল, যমগণ্ড, গুলিক কাল
> • বাংলা ও ইংরেজি তারিখ একসঙ্গে মাসের পাতায়; পূর্ণিমা, অমাবস্যা, একাদশী এক নজরে
> • দুর্গাপূজা, লক্ষ্মীপূজা, কালীপূজা, সরস্বতীপূজা, পয়লা বৈশাখ সহ সারা বছরের পার্বণ
> • একাদশী ও উৎসবের আগে মনে করিয়ে দেওয়া
> • ইন্টারনেট ছাড়াও চলে
>
> কোন মতে হিসাব? এই অ্যাপ বিশুদ্ধ সিদ্ধান্ত (দৃক) মত অনুসরণ করে। প্রতিটি তারিখের সঙ্গে লেখা থাকে কোন মত, কোন শহর ও কোন সময় অঞ্চল ধরে হিসাব করা হয়েছে। প্রধান উৎসবের তারিখ মুদ্রিত পঞ্জিকার সঙ্গে মিলিয়ে দেখা হয়।
>
> পূর্ণ পর্দার বিজ্ঞাপন নেই। পঞ্জিকার কোনো তথ্য টাকা দিয়ে কিনতে হয় না।

**Full description — English**

> Your daily Bengali panjika, clear and trustworthy.
>
> • Today's tithi, nakshatra, yoga and karana with end times
> • Sunrise, sunset, moonrise and moonset for your city
> • Rahu Kaal, Yamaganda and Gulika Kaal
> • Monthly calendar with Bengali and English dates; Purnima, Amavasya and Ekadashi at a glance
> • Durga Puja, Lakshmi Puja, Kali Puja, Saraswati Puja, Poila Boishakh and the full festival year
> • Reminders before Ekadashi and festivals
> • Works offline
>
> Which panjika? This app follows the Bishuddha Siddhanta (Drik) tradition. Every date screen shows the tradition, city and time zone used. Major festival dates are checked against the printed panjika.
>
> No full-screen ads. No religious information behind a paywall.

### 23.3 Icon concepts

| Concept | Description | Pros | Cons |
|---|---|---|---|
| **A — Tithi ring (recommended)** | Thin turmeric (`haldi`) ring, two-thirds filled, around a crescent, on indigo (`ink`) | Matches the in-app tithi seal; reads at 48 px; no religious imagery | Less "Bengali" at first glance |
| B — Letter প | Tiro Bangla "প" in white on sindoor red (`alta`) with a small turmeric dot | Instantly Bengali; strong on home screen | Similar letter icons exist in Bengali keyboard apps |
| C — Alpona lotus | Simple original alpona-style lotus in white linework on red | Cultural warmth | Detail is lost at small sizes |

Specs: Android adaptive icon, 108 dp canvas with the 66 dp safe zone; monochrome layer for themed icons; Play Store icon 512×512 PNG. Feature graphic 1024×500: Bengali date in display type + tithi ring, no screenshots inside.

### 23.4 Screenshot plan (phone, 1080×1920 or 1080×2400)

Captions in Bengali (English set mirrors them). Sample-data watermark must be **off** and real validated data shown.

| # | Screen | Caption (bn) | Caption (en) |
|---|---|---|---|
| 1 | Today | আজকের তিথি, এক নজরে | Today's tithi at a glance |
| 2 | Calendar (Ashwin) | বাংলা ও ইংরেজি তারিখ একসঙ্গে | Bengali and English dates together |
| 3 | Festival list | সারা বছরের পূজা-পার্বণ | Every puja and festival of the year |
| 4 | Day detail (periods) | রাহুকাল, যমগণ্ড, শুভ সময় | Rahu Kaal, Yamaganda and auspicious times |
| 5 | Sources & verification | কোন মতে হিসাব, স্পষ্ট লেখা | Which panjika, clearly stated |
| 6 | Dark mode Today | রাতেও চোখের আরাম | Easy on the eyes at night |
| 7 | English UI with names in both scripts (en set only) | — | Real panjika terms, in English and Bengali |

The Bengali store listing uses Bengali-UI screenshots and the English listing uses English-UI screenshots; never mix them in one listing.
