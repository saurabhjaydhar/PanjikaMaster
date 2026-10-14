# Background and research

> Part of the Bangla Panjika spec. Section numbers (§) are permanent IDs shared by all docs; `docs/README.md` maps each one to its file.

## 2. Problem and opportunity

### 2.1 Evidence from competitor research (public listings only, Oct 2026)

| App | Platform & scale | What it offers | What users complain about |
|---|---|---|---|
| Bangla Panjika Calendar 2026 (AppsDreamers) | Google Play, 1M+ installs, 4.4★ from 134K reviews, contains ads | Tithi, nakshatra, muhurat, Ekadashi for Smarta/Goswami/Nimbark, marriage dates, offline. Listing says Drik Siddhanta support is "coming soon" | Aug–Sep 2026 reviews: forced ~1-minute video ads before features, unskippable, users closing the app |
| Bengali Calendar 2026 Panjika (Anivale) | iOS, 4.2★ (225), ads + IAP (Kundli Pro ₹49–₹399) | Tithi, nakshatra, yoga, Rahu Kaal, muhurat tabs, horoscope, West Bengal temple list | "Shows wrong date, no connection with actual Bengali calendar" (2023); missing daily Bengali date (2020). Listing in English only. Declares location used for tracking |
| Bengali Calendar 2027 (Ramesh P) | iOS, 4.3★ (548), ads | Tithi, nakshatra, festivals incl. Islamic holidays, rashifal, 12/24 h toggle | ~20 seconds of ads on opening; "too much ad" |
| Bong Calendar (Outscar) | Android + iOS (iOS 2.3★, 3 ratings) | Lets the user choose Surya Siddhanta or Drik/Bishuddha; home-screen widgets | Too few reviews to judge |

Sources: the App Store and Google Play listing pages for each app, and APKMirror's copy of the Outscar description. Not verified: in-app UX, navigation and screenshots (no app was installed or tested).

**Other references found (not app-tested):**

| Type | Name | Relevance |
|---|---|---|
| Printed panjika | Bishuddha Siddhanta Panjika (since 1890) | Drik school; our MVP reference |
| Printed panjika | Gupta Press, P.M. Bagchi, Benimadhab Sil | Surya Siddhanta school; v1.1 reference |
| Government | Rashtriya Panchang (Positional Astronomy Centre, Kolkata; Bengali edition available) | Astronomical validation reference |
| Website | Drik Panchang (drikpanchang.com) | Popular all-India panchang site; documents regional sankranti rules |
| Website | Dekho Panchang (dekhopanchang.com) | Bengali calendar pages; contains at least one questionable claim (fixed month lengths), so not a reference |
| App | Bangla Calendar India (Outscar, iOS) | Offers both Surya and Drik schools |
| App | Bangla Calendar 2026 India (Asim Roy, iOS) | New, too few ratings to assess |

### 2.2 The gap

| Gap | Why it matters | Our answer |
|---|---|---|
| Tradition is hidden | Users see a "wrong" date when the app silently follows a different school from their family's panjika | Tradition chosen at onboarding, shown on every date screen |
| Ads block religious information | Users close the app before reaching the tithi | Ad rules in §20: never above the fold on Today, never full-screen |
| English-first listings and UI, or Bengali with poor English | Older users read Bengali comfortably and English less so; younger and diaspora users are often the reverse | Bengali by default; a complete, natively written English UI; optional bilingual name display (§13) |
| No provenance | Users cannot tell if a date was checked | Verification badge per observance, "তথ্যসূত্র" (sources) screen |
| Manual yearly data drops | Apps freeze when next year's data is late | Data packs cover many years ahead; festival packs ship before Chaitra |
| Bengal-specific periods often missing | Bengali households check বারবেলা/কালবেলা before travel or puja | Included in MVP once rule tables are verified (§6.5.9) |

---

## 6. (excerpt)

### 6.3 Options compared

| Option | What it is | Licence | Accuracy | Cost | Verdict |
|---|---|---|---|---|---|
| **Swiss Ephemeris** | Industry-standard astrology ephemeris (C) | AGPL-3.0 or paid Professional Licence; pricing not public | Excellent | Licence fee (unknown) | Do not ship in a closed-source app without the paid licence. Could be used internally only after legal review |
| **Skyfield + JPL DE440s** (Python) | Research-grade astronomy library + NASA JPL ephemeris | Skyfield is MIT; JPL ephemerides are generally treated as public domain — **confirm JPL terms** | Sub-arcsecond | Free | **Recommended for the build pipeline** |
| **Astronomy Engine** (Don Cross) | Compact Sun/Moon/planet library in C, C#, JS, Python | MIT | Within ±1 arcminute of NOVAS | Free | Independent cross-check for the pipeline's rise/set (§6.7). *Was recommended for on-device rise/set; superseded 2026-10-13: the phone computes rise/set from the pipeline's own Sun/Moon table instead (§6.5.5), so no astronomy library runs on the phone and there is a single source of positions* |
| `panchang` on PyPI (Rust core) | Open panchang library with Bengali solar calendar | **Licence not yet checked** | Claims minute-level match with Drik Panchang on its own samples | Free? | Useful as a *cross-check* only after licence review |
| Commercial APIs (Divine API, Prokerala, RoxyAPI, Astro Agents) | Panchang over HTTP | Proprietary ToS | Varies; unverified | Per call / subscription | Not for core data (online dependency, cost per user, opaque method). Possibly a third cross-check |
| **Rashtriya Panchang** (Positional Astronomy Centre, Kolkata, IMD) | Government annual panchang, published in Bengali too, e-version downloadable | Government publication — reuse terms **to confirm** | Modern scientific basis; Lahiri ayanamsa | Free/low | **Primary validation reference** for L1 (tithi/nakshatra/yoga times, sunrise for metros) |
| Indian Astronomical Ephemeris (same centre) | ~500-page annual astronomical ephemeris incl. Indian calendar section | Same | High | Low | Secondary validation reference |
| Printed Bishuddha Siddhanta Panjika | The tradition we follow | Copyright of publisher | Defines the "correct" answer for L3/L4 | ₹ price of a copy | **Primary validation reference for Bengali dates and festivals.** Use for checking, not for copying tables wholesale |
| Licensing deal with a panjika house | Official data partnership | Contract | Authoritative | Negotiated | **Best long-term trust signal** ("data verified with X Panjika"). Explore in v1.1 |

---

## 20. (excerpt)

### 20.4 Revenue scenarios (**estimates only, not forecasts**)

Assumptions: 3 ad impressions per DAU per day, 80% fill rate, effective eCPM in INR as given (assumed range for Indian traffic; validate with real AdMob data after launch), 30 days/month.

Monthly ad revenue = DAU × 3 × 0.8 × (eCPM ÷ 1000) × 30 = **DAU × eCPM × 0.072**

| DAU | eCPM ₹15 | eCPM ₹30 | eCPM ₹50 |
|---|---|---|---|
| 10,000 | ₹10,800 | ₹21,600 | ₹36,000 |
| 50,000 | ₹54,000 | ₹1,08,000 | ₹1,80,000 |
| 200,000 | ₹2,16,000 | ₹4,32,000 | ₹7,20,000 |

Premium (assumption): 0.5% of monthly active users buy ₹99/year. At 100,000 MAU → 500 buyers → ₹49,500/year gross, before store fees and tax.

Seasonality: expect DAU peaks from Mahalaya to Kali Puja and around Poila Boishakh; plan ASO and share-card pushes for those windows.

### 20.5 Costs to cover (estimate ranges, fill in)
Play developer account (one-time), Apple developer (annual, when iOS ships), printed panjikas (yearly), expert review fee (yearly), hosting (your VPS already exists), optional crash reporting.

---

## 27. (excerpt)

### 27.2 Sources consulted (Oct 2026)

- App Store: Bengali calendar 2026 Panjika (Anivale) — apps.apple.com/in/app/bengali-calendar-2026-panjika/id1465602591
- Google Play: Bangla Panjika Calendar 2026 (AppsDreamers) — play.google.com/store/apps/details?id=com.appsdreamers.banglapanjikapaji
- App Store: Bengali Calendar 2027 (Ramesh P) — apps.apple.com/in/app/bengali-calendar-2027/id1448462586
- Outscar Bong Calendar description — apkmirror.com/apk/outscar/bengali-calendar-india
- Wikipedia: Panjika; Vishuddha Siddhanta Panjika
- arXiv 1102.2383 (life of R. G. Chandra; history of Bengal panjikas)
- Drik Panchang: Mesha Sankranti page (Bengal sankranti rule)
- Positional Astronomy Centre, Kolkata (IMD): Rashtriya Panchang, Indian Astronomical Ephemeris — packolkata.imd.gov.in, mausam.imd.gov.in
- Swiss Ephemeris licence text and Professional Licence contract — github.com/aloistr/swisseph (mirror), astro.com/swisseph/secont_e.pdf
- Astronomy Engine (MIT, ±1 arcminute) — github.com/cosinekitty/astronomy; CRAN astronomyengine
- Divine API, Prokerala, RoxyAPI, PyPI `panchang` documentation pages
- Google Play target API level requirements — developer.android.com/google/play/requirements/target-sdk; support.google.com/googleplay/android-developer/answer/11926878
- Tiro Bangla (Tiro Typeworks) and Noto Sans Bengali licence pages (SIL OFL 1.1)
