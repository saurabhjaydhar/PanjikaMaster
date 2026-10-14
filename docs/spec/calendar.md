# Calendar rules and data pipeline

> Part of the Bangla Panjika spec. Section numbers (§) are permanent IDs shared by all docs; `docs/README.md` maps each one to its file.

## 5. Calendar convention (the most important decision)

### 5.1 Concepts the product must keep separate

| Layer | What it is | Example | Who decides it |
|---|---|---|---|
| L0 Astronomy | Positions of Sun and Moon, rise/set times | Moon's longitude at 10:00 IST | Physics + ephemeris |
| L1 Panchanga elements | Tithi, nakshatra, yoga, karana, sankranti, derived from L0 by fixed formulas | Shukla Saptami ends 14:32 | Formula + ayanamsa + siddhanta choice |
| L2 Calendar convention | How a civil day gets a Bengali date | "25 Ashwin 1433" | Regional rule (Bengal midnight rule) |
| L3 Observance rules | Which day a festival falls on | Kali Puja = night where Amavasya prevails at midnight | Smriti rules (Raghunandana) as applied by a panjika house |
| L4 Editorial | The published decision, including exceptions | "Durga Ashtami: Monday" | The panjika publisher / expert |

The app must never merge these. Each layer has its own code module, its own data tables and its own tests.

### 5.2 The two schools in West Bengal

- **Drik / Bishuddha Siddhanta** (বিশুদ্ধ সিদ্ধান্ত পঞ্জিকা, first published 1890). Uses modern astronomical positions. Described as consistent with the Government of India's national Panchang method. Followed by Belur Math and Tarakeswar Math.
- **Adrik / Surya Siddhanta** (Gupta Press, P.M. Bagchi, Benimadhab Sil and others). Uses the classical Surya Siddhanta model with Raghunandana's rules. Historically the more popular almanac; the state government has followed Gupta Press for Puja holidays.

Because the day's tithi is judged at sunrise, a few minutes' difference in a tithi's end time can move a festival to a different day between the two schools.

### 5.3 Decision for MVP

| Item | Decision | Reason | Reversible? |
|---|---|---|---|
| Default tradition | **Drik (Bishuddha-aligned)** | Reproducible from modern astronomy; validatable against Rashtriya Panchang; matches Belur Math | Yes: tradition is a data dimension from day 1 |
| Second tradition | Surya Siddhanta (Gupta Press-aligned) in v1.1 | Large user base, but needs a separate computational model and a licensed or expert-verified reference | — |
| Ayanamsa | Lahiri (Chitrapaksha) | Used by the Indian Astronomical Ephemeris and Rashtriya Panchang | Config value |
| Time zone | IST (UTC+05:30), no DST, also for places outside India until Q16 is decided | West Bengal | Per-place field |
| Day boundary | Sunrise to sunrise for panchanga purposes; midnight to midnight for the civil date | Standard Hindu practice | — |
| Reference location for festival decisions | **Open question Q1** (Kolkata vs. the publisher's own reference meridian) | Must match the panjika we validate against | — |
| Bengali date rule | Bengal midnight rule (§6.5.6) | Documented regional practice | — |
| Lunar month naming | Amanta (month ends at Amavasya) — **to confirm with expert (Q2)** | Bengal practice | — |

**User-facing honesty:** onboarding explains the two schools in two sentences and lets the user pick. Until Surya Siddhanta ships, selecting it shows "শীঘ্রই আসছে" (coming soon) and keeps Drik as active, with a clear note.

### 5.4 Things that are explicitly out of scope for the convention

Bangladesh's revised Bengali calendar (fixed month lengths, Poila Boishakh on 14 April), Tripura/Assam (Barak Valley) local variants, and Vaishnava (ISKCON/Gaudiya) observance calendars. The schema supports adding these later as new `tradition` values.

---

## 6. Data strategy (deep dive)
### 6.1 The core question: where does each number come from?

```
                ┌──────────────────────────────────────────────┐
  BUILD SERVER  │  L0 Ephemeris  →  L1 Panchanga  →  L2 Date   │   reproducible,
  (your VPS or  │  (Skyfield +      (tithi, naks.,   (Bengal     │   versioned,
   laptop, CI)  │   JPL DE440s)      yoga, karana,    midnight   │   tested
                │                    sankranti)       rule)      │
                │                         │                      │
                │              L3 Observance rule engine         │
                │                         │                      │
                │   L4 Validation: Rashtriya Panchang + printed  │
                │      panjika + expert sign-off → status flags  │
                └──────────────┬───────────────────────────────┘
                               │ signed data pack (SQLite, gzip, Ed25519)
                               ▼
  PHONE         ┌──────────────────────────────────────────────┐
                │ Drift DB ← pack importer (verify signature)   │
                │ Light on-device math: rise/set for the place  │
                │ from the pack's Sun/Moon table (§6.5.5);      │
                │ Rahu Kaal etc.; formatting; reminders         │
                └──────────────────────────────────────────────┘
```

Why not compute everything on the phone? Three reasons: (1) licensing of the best phone-ready libraries is restrictive (Swiss Ephemeris), (2) one validated dataset is easier to trust and to correct than millions of phones each computing, and (3) observance decisions (L3/L4) need human review anyway. The one exception is rise and set for the user's own place (§6.5.5): the phone does only the geometry (where is the horizon for these coordinates), and every Sun and Moon position it uses comes from the pipeline in the signed pack.
### 6.2 Global vs. location-dependent values

This split keeps the data small.

| Value | Depends on location? | Storage |
|---|---|---|
| Tithi, nakshatra, yoga, karana start/end moments | **No** (an instant in UTC, shown in IST) | One global table |
| Sankranti (solar month ingress) moments | No | Global table |
| New/full moon, eclipses | No (visibility of eclipses does) | Global table |
| Sunrise, sunset, moonrise, moonset | **Yes** | Computed on phone for the place's coordinates from the global Sun/Moon table (`body_positions`, §6.5.5) |
| Rahu Kaal, Yamaganda, Gulika, বারবেলা, কালবেলা | Yes (derived from sunrise/sunset) | Computed on phone from the place's sunrise/sunset |
| Udaya tithi (tithi at sunrise) | Yes, slightly | Computed on phone from global transitions + the place's sunrise |
| Bengali civil date | No (rule uses IST midnight) | Global table per tradition |
| Festival date | Decided per tradition for a reference location (Q1), not per user place | Observance table per tradition |

A place is a listed city (the `cities` table: names, aliases, coordinates; source Q13) or the user's own coordinates. Both go through the same code; nothing is stored per city per day.

**Size estimate.** Each year has roughly 371 tithi, 361 nakshatra (the Moon passes all 27 every 27.3 days), 388 yoga (Sun + Moon sum moves about 14.2° a day), 742 karana and 12 sankranti transitions: about 1,875 rows. 26 years (2020–2045) is about 49,000 rows, under 1 MB. The Sun/Moon table is budgeted at ≤ 200 KB per year compressed, whatever the number of places (the format is chosen in T-314 against that budget and the accuracy in §6.5.5). The place list is a few hundred rows, a few tens of KB. Ship 3 years in the APK; download more on demand.
### 6.4 Recommended pipeline (concrete)

Location: `data/` folder of the monorepo (§28.1), Python 3.12, independent of the Flutter app.

```
data/
  ephem/            # downloads + checksums for de440s.bsp
  engine/
    astro.py        # Sun/Moon apparent sidereal longitude, rise/set
    ayanamsa.py     # Lahiri, documented formula + tests
    panchanga.py    # tithi/nakshatra/yoga/karana transition search
    solar.py        # sankranti search
    bengali.py      # Bengali civil date (midnight rule)
    observances/    # rule engine + YAML rules
  reference/        # hand-entered values from Rashtriya Panchang & printed panjika (private, not shipped)
  validate/         # comparison reports, tolerances, diff HTML
  pack/             # build SQLite pack, gzip, sign (Ed25519)
  tests/
```

Steps per release:

1. **Compute** L0–L2 for the year range (deterministic; same inputs → same bytes; record library versions and ephemeris checksum in the pack metadata).
2. **Compute** L3 observances from rules. Each output row starts with `status = computed`.
3. **Validate** against references (§6.7). Rows that match get `status = reference_matched`; any mismatch blocks the build until explained.
4. **Expert review** of tier-1 and tier-2 festivals; reviewer initials + date stored. Status becomes `expert_reviewed`.
5. **Pack, sign, publish** to static hosting (your existing VPS behind a CDN is enough). The app verifies the signature with an embedded public key before import. The pack builder refuses to build if any `names` or `observances` row lacks either its Bengali or its English text (FR-L10N-09).
### 6.5 Algorithms and rules

All angles are **sidereal** (nirayana) longitudes unless stated: λ_sid = λ_tropical − ayanamsa(t).

#### 6.5.1 Tithi
`elongation = (λ_moon − λ_sun) mod 360°`. Tithi number = `floor(elongation / 12°) + 1` (1–30). 1–15 are Shukla Paksha (15 = Purnima); 16–30 are Krishna Paksha (30 = Amavasya). Tithi is independent of ayanamsa because both longitudes shift equally.

Transition search: step through time in 1-hour increments; when the integer part of `elongation/12` changes, refine with bisection (or Brent's method) to 1-second precision. Moon–Sun elongation grows ~12.2°/day on average, so 1 arcminute of position error ≈ 2 minutes of time error. This is why the build pipeline uses a high-precision ephemeris.

Tithi length varies, roughly 19 to 27 hours. Tests assert every tithi length is within that band.

#### 6.5.2 Nakshatra
`index = floor(λ_moon_sid / 13°20′)` (0–26), pada = `floor((λ_moon_sid mod 13°20′) / 3°20′) + 1`.

#### 6.5.3 Yoga
`index = floor(((λ_sun_sid + λ_moon_sid) mod 360°) / 13°20′)` (0–26).

#### 6.5.4 Karana
`k = floor(elongation / 6°)` (0–59).
- k = 0 → কিংস্তুঘ্ন (Kimstughna)
- k = 57 → শকুনি, 58 → চতুষ্পদ, 59 → নাগ
- otherwise movable karana = `(k − 1) mod 7` over: বব, বালব, কৌলব, তৈতিল, গর, বণিজ, বিষ্টি (ভদ্রা)

#### 6.5.5 Sunrise / sunset / moonrise / moonset
Default definition: upper limb at the horizon with standard refraction (Sun altitude −0.8333°). Hindu panchangs sometimes use the centre of the disc; **this is a config flag validated against the reference panjika (Q3)**. Elevation ignored (cities ≤ 2,100 m; Darjeeling is the outlier — flag for review). Moonrise uses the Moon's topocentric position with parallax.

**Where it is computed.** Two implementations of the same definition, kept in step by a shared fixture:

- *Pipeline* (`engine/riseset.py`, Skyfield + DE440s): the reference. It is validated against the Rashtriya Panchang and the Indian Astronomical Ephemeris (§6.7) and writes the shared fixture: expected sunrise, sunset, moonrise and moonset for about 40 places worldwide (incl. high latitudes up to ±60°, both sides of IST) × 24 days.
- *Phone* (`OnDeviceRiseSet`, pure Dart, no I/O): computes rise/set for any coordinates from the global pack's `body_positions` table, which holds the pipeline's apparent geocentric Sun and Moon positions (and whatever else the horizon geometry needs, e.g. Moon distance for parallax and the sidereal-time correction) in a compact form. It uses the same definition flag (Q3). It must match the fixture within **±5 s for the Sun and ±10 s for the Moon**; any larger difference fails CI.

No astronomy library runs on the phone, so the pipeline stays the single source of positions. Places beyond ±60° latitude are refused (FR-LOC-07): there the Sun may not rise or set on some days and the panjika day is undefined.

#### 6.5.6 Sankranti and the Bengali civil date
Sankranti = moment λ_sun_sid crosses a multiple of 30°. Mesha (0°) starts বৈশাখ; Vrisha → জ্যৈষ্ঠ; … Meena → চৈত্র.

**Bengal rule:** if the sankranti occurs between sunrise and midnight, the new month begins the following day; if it occurs after midnight, the month begins on the day after that.

Implementation detail to confirm with the expert (Q4): which "midnight" (civil 00:00 IST vs. local true midnight) and how a sankranti before sunrise is treated. Write the rule as a pure function with exhaustive tests around both edges.

Bengali year (Bangabda) = Gregorian year − 593 from Poila Boishakh onward, − 594 before it. Month lengths vary between 29 and 32 days; the app must never hard-code them.

#### 6.5.7 Udaya tithi, kshaya and vriddhi
- **Udaya tithi**: the tithi prevailing at local sunrise names the day.
- **Kshaya tithi**: a tithi that begins after one sunrise and ends before the next never touches a sunrise. The UI shows it as a second line on that day ("ক্ষয় তিথি").
- **Vriddhi tithi**: a tithi spanning two sunrises appears on both days.
- **Adhik / Mala masa (মলমাস)**: a lunar month with no sankranti. Festivals are not held in it; the rule engine must skip it.

#### 6.5.8 Rahu Kaal, Yamaganda, Gulika
Divide sunrise→sunset into 8 equal parts. Part number (1-based) by weekday:

| Day | Rahu Kaal | Yamaganda | Gulika |
|---|---|---|---|
| Sun | 8 | 5 | 7 |
| Mon | 2 | 4 | 6 |
| Tue | 7 | 3 | 5 |
| Wed | 5 | 2 | 4 |
| Thu | 6 | 1 | 3 |
| Fri | 4 | 7 | 2 |
| Sat | 3 | 6 | 1 |

This is the commonly published table; verify it against the reference before release.

#### 6.5.9 Bengal-specific periods (বারবেলা, কালবেলা, কালরাত্রি, অমৃতযোগ, মাহেন্দ্রযোগ)
These are what Bengali households actually look for, and the generic Rahu Kaal is less familiar. The rule tables (weekday → which division of day/night) differ in how they are presented across panjikas. **Do not invent them.** Transcribe the rule (not the daily output) from the expert, encode as data in `period_rules`, and validate the computed output against 30 sample days in the printed panjika. Until validated, these rows are hidden behind a feature flag.

#### 6.5.10 Time units
Traditional panjikas also print times in দণ্ড-পল from sunrise (1 দণ্ড = 24 minutes; 1 পল = 24 seconds). Offer as an optional display mode (v1.1). Also needed for some rules (e.g. Sandhi Puja spans the last 24 minutes of Ashtami and the first 24 minutes of Navami).
### 6.6 Observance rule engine

Festivals are **rules plus editorial overrides**, never a list of Gregorian dates. Rules live in YAML, one file per observance, reviewed like code.

```yaml
# observances/kali_puja.yaml   (DRAFT — needs expert review)
id: kali_puja
name_bn: কালীপূজা
name_en: Kali Puja
tier: 1
tradition: [drik_bishuddha]
lunar_month: kartika          # amanta naming, see Q2
tithi: amavasya
decision:
  type: prevails_at
  moment: nishita              # local midnight window
  location: reference          # see Q1
  tie_breaker: earlier_day
outputs:
  - kind: date
  - kind: window               # nishita puja window shown on day screen
review:
  status: draft
  reviewer: null
```

Supported decision types (initial set): `udaya` (tithi at sunrise), `prevails_at` (at a named moment: pratah, madhyahna, aparahna, pradosha, nishita), `sankranti_day`, `fixed_bengali_date` (e.g. 1 Boishakh), `ekadashi_smarta`, `ekadashi_vaishnava` (v1.1), `span` (multi-day: Durga Puja Shashthi→Dashami), and `override` (editorial date set by reviewer, with a mandatory reason).

Each festival declares **which windows** it outputs (e.g. Durga Ashtami: Sandhi Puja window; Lakshmi Puja: Purnima window). The engine never outputs a festival without a tradition and a status.

Tier list for MVP:

| Tier | Observances | Validation level |
|---|---|---|
| 1 | Poila Boishakh, Durga Puja (Mahalaya, Shashthi→Dashami, Sandhi Puja), Lakshmi Puja (Kojagari), Kali Puja/Diwali, Saraswati Puja, Janmashtami, Rath Yatra, Shivaratri, Dol Purnima | Reference match **and** expert review |
| 2 | All Ekadashi, Purnima, Amavasya, Sankranti, Jamai Shashthi, Bhai Phonta, Vishwakarma Puja, Annapurna Puja, Manasa Puja, Jagaddhatri Puja, Ram Navami | Reference match |
| 3 | Rabindra Jayanti, Netaji Jayanti and other civil/cultural days | Source citation |
### 6.7 Validation plan

| Check | Reference | Sample | Tolerance | Blocks release? |
|---|---|---|---|---|
| Tithi end times | Rashtriya Panchang (Bengali ed.) | Every tithi of 3 months spread over the year + all tithis near Durga Puja | ±2 min | Yes |
| Nakshatra / yoga end times | Rashtriya Panchang | Same | ±2 min | Yes |
| Sunrise / sunset Kolkata | Rashtriya Panchang + Indian Astronomical Ephemeris | 24 days (2 per month) | ±1 min | Yes |
| Sunrise other places (pipeline) | Independent computation (Astronomy Engine) | 40 places worldwide up to ±60° × 12 days | ±1 min | Yes |
| Rise/set on the phone | Pipeline values in the shared fixture (§6.5.5) | 40 places × 24 days, Sun and Moon | ±5 s Sun, ±10 s Moon | Yes (CI) |
| Bengali date | Printed Bishuddha panjika | **Every day** of 1433 and 1434 BS | Exact | Yes |
| Month start days | Printed panjika | All 24 sankrantis | Exact | Yes |
| Tier-1 festival dates | Printed panjika + expert | All | Exact | Yes |
| Tier-2 dates | Printed panjika | All | Exact | Yes (or hidden) |
| Bengal periods | Printed panjika | 30 days | Exact window | Feature-flagged until pass |

Every validation run produces an HTML diff report kept in `validate/reports/`. The harness is `python -m validate --pack <pack>`; reference file formats are documented in `data/validate/checks.py`. A mismatch is never "fixed" by editing output data; it is fixed by changing a rule, a config value or an override with a written reason.
### 6.8 Verification status model (shown to users)

| Status | Bengali label | English label | Meaning | Shown how |
|---|---|---|---|---|
| `computed` | গণনাকৃত | Computed | Computed by rules, not yet checked | Grey dot; not allowed for tier 1 in production |
| `reference_matched` | পঞ্জিকা মিলিয়ে দেখা | Checked with panjika | Matches the printed reference | Green tick |
| `expert_reviewed` | বিশেষজ্ঞ যাচাইকৃত | Expert reviewed | Reviewed by named expert | Green double tick |
| `sample` | নমুনা তথ্য | Sample data | Test fixture | Diagonal "নমুনা · SAMPLE" watermark on screen; only in debug builds |
| `stale` | তথ্য পুরনো | Data out of date | Pack older than its validity window | Amber banner |
### 6.9 Yearly data-operations calendar

Printed panjikas usually come out in Chaitra, ahead of Poila Boishakh. Plan:

| When | Task |
|---|---|
| Magh–Falgun (Jan–Feb) | Compute next Bengali year; generate draft observances |
| Chaitra (Mar–Apr), as soon as printed panjika is out | Validate Bengali dates and festivals against it; expert review |
| Before 1 Boishakh | Publish signed pack; push "new year data ready" in-app notice |
| Bhadra (Aug–Sep) | Re-check Durga Puja → Kali Puja season; publish correction pack if needed |
| Any time | Correction pack within 72 h of a confirmed error report |
### 6.10 Legal notes on data (not legal advice — get a lawyer's view before launch)

- Astronomical facts and festival dates are facts; copying a publisher's typeset tables, layout, text or artwork is not acceptable. Use printed panjikas to **check** our computed output.
- Do not claim affiliation with Belur Math, Gupta Press or any publisher without a written agreement.
- Swiss Ephemeris: its licence contract treats an app that calls a server running it as an app containing it. Avoid it entirely unless a professional licence is purchased.
- Keep a `THIRD_PARTY_NOTICES` file listing every library, font and dataset with its licence.

---

## 16. Calculation edge cases the app must handle

| Case | Behaviour |
|---|---|
| Tithi ends after midnight | Show "রাত ১:১০ (পরদিন)" (sample) |
| Two tithis touch no sunrise (kshaya) | Second line "ক্ষয় তিথি: …" |
| Same tithi at two sunrises (vriddhi) | Both days show it; day detail notes "বৃদ্ধি তিথি" |
| No moonrise on a date | "চন্দ্রোদয় নেই" |
| Place beyond ±60° latitude | Refused with an explanation; the previous place stays (FR-LOC-07) |
| Place outside India | Times still in IST with the "IST" label until Q16; the place screen says so (FR-LOC-08) |
| Own location changes slightly | Coordinates are rounded to 0.01°; a new fix within 0.01° changes nothing and does not reschedule reminders |
| Sankranti near midnight | Bengal rule tested at ±1 s of 00:00 IST |
| Bengali month of 32 days | Grid renders 5–6 rows correctly |
| Bengali year change | Grid and header roll from চৈত্র to বৈশাখ; year +1 |
| Mala masa | No festivals placed in it; month label shows "মলমাস" |
| Device time zone ≠ IST | All panjika times shown in IST with "IST" label; reminders fire at the right absolute moment |
| Device clock wrong | Use device clock; if it is outside any pack range, show "ফোনের তারিখ ঠিক আছে কিনা দেখুন" / "Please check your phone's date" |
| Language changed while reminders are pending | Cancel and reschedule all pending notifications with texts in the new language (FR-SET-05) |
| Device locale changes (e.g. user switches phone to Hindi) | App language does not change unless the user changes it in the app or in Android's per-app language setting (FR-L10N-02/03) |
| Locale the app doesn't support set via Android per-app language | Not possible: `locales_config.xml` lists only `bn` and `en` |
| Name missing in one language in an installed pack | Never happens in a valid pack (FR-L10N-09); if it does, show the other script rather than an empty label, and log it for the next correction pack |
