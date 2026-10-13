# Screens and navigation

> Part of the Bangla Panjika spec. Section numbers (§) are permanent IDs shared by all docs; `docs/README.md` maps each one to its file.

## 10. Information architecture

```
Onboarding (first run only)
  1 ভাষা (Language) → 2 পঞ্জিকা (Tradition) → 3 শহর (City) → 4 বিজ্ঞপ্তি (Notifications, optional)

Bottom navigation (4 tabs)            bn label      en label
  ├─ আজ        Today                  আজ           Today
  │    └─ Day detail (same component as Calendar → day)
  ├─ পঞ্জিকা     Calendar (month)       পঞ্জিকা        Calendar
  │    ├─ Day detail
  │    └─ Jump-to-month sheet, Legend sheet
  ├─ পার্বণ      Festivals              পার্বণ         Festivals
  │    └─ Festival detail → Reminder sheet, Share
  └─ আরও       More                   আরও          More
       ├─ অনুস্মারক   Reminders
       ├─ খুঁজুন      Search
       ├─ শহর        City
       ├─ শব্দকোষ     Glossary
       ├─ সেটিংস      Settings (language, names in both scripts, tradition, theme, text size, time format, numerals)
       ├─ তথ্যসূত্র ও যাচাই  Sources & verification
       ├─ ভুল জানান    Report an error
       ├─ বিজ্ঞাপন সরান  Remove ads
       └─ সম্পর্কে / গোপনীয়তা  About / Privacy
```

Navigation labels are always visible (never icon-only), in the UI language. A quick language switch (বাংলা | English) sits at the top of More as well as in Settings, because a shared family phone often changes hands.

Global elements: top bar shows **city chip** (tap → city picker) on Today, Calendar and Day screens.

---

## 11. Screen specifications

Wireframes are 360 dp wide. All example values are **নমুনা (sample)**.

### 11.1 Onboarding

```
┌──────────────────────────────┐
│        বাংলা পঞ্জিকা          │
│                              │
│  কোন পঞ্জিকা মেনে চলেন?        │
│ ┌──────────────────────────┐ │
│ │◉ বিশুদ্ধ সিদ্ধান্ত (দৃক)     │ │
│ │  আধুনিক জ্যোতির্বিজ্ঞান মতে।   │ │
│ │  বেলুড় মঠ এই মত মানে।        │ │
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │○ গুপ্তপ্রেস (সূর্যসিদ্ধান্ত)   │ │
│ │  প্রাচীন পদ্ধতি। শীঘ্রই আসছে   │ │
│ └──────────────────────────┘ │
│  দুই মতে কখনো উৎসবের দিন আলাদা │
│  হয়। পরে সেটিংসে বদলাতে পারবেন। │
│                              │
│ [        এগিয়ে যান         ]   │
└──────────────────────────────┘
```

Language step (step 1), shown in both scripts at once because the user has not chosen yet:

```
┌──────────────────────────────┐
│          ● ○ ○ ○               │
│      ◐  বাংলা পঞ্জিকা           │
│         Bangla Panjika        │
│                              │
│  ভাষা বেছে নিন                  │
│  Choose your language         │
│ ┌──────────────────────────┐ │
│ │◉ বাংলা                    │ │  ← each option written in its own script
│ │  আজ শুক্লা সপ্তমী           │ │  ← live preview line (sample)
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │○ English                  │ │
│ │  Today is Shukla Saptami  │ │
│ └──────────────────────────┘ │
│  পরে সেটিংসে বদলানো যাবে।       │
│  You can change this later.  │
│ [   এগিয়ে যান · Continue   ]   │
└──────────────────────────────┘
```

From step 2 onwards every screen is in the chosen language only. The same tradition step in English:

```
┌──────────────────────────────┐
│          ○ ● ○ ○               │
│  Which panjika do you follow?│
│ ┌──────────────────────────┐ │
│ │◉ Bishuddha Siddhanta (Drik)│ │
│ │  Based on modern astronomy.│ │
│ │  Followed by Belur Math.   │ │
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │○ Gupta Press (Surya        │ │
│ │  Siddhanta) · Coming soon  │ │
│ │  The traditional method.   │ │
│ └──────────────────────────┘ │
│  The two can put a festival  │
│  on different days. You can  │
│  change this in Settings.    │
│ [         Continue         ]  │
└──────────────────────────────┘
```

- Steps: language → tradition → city → notifications (skippable). Progress dots at top.
- The language step defaults to the device locale (FR-L10N-02) and choosing the other option re-renders the step immediately, so the user sees the result before continuing.
- City step: search field, "আমার অবস্থান ব্যবহার করুন" button, list of popular cities.
- Notifications step: explains value ("একাদশী ও পূজার আগে মনে করিয়ে দেব"), then requests permission only on "চালু করুন".

### 11.2 Today (আজ) — the hero screen

```
┌──────────────────────────────┐
│ সোমবার        [📍 কলকাতা ▾]   │
│ ২৫ আশ্বিন ১৪৩৩                │  ← Bengali date, display size
│ ১২ অক্টোবর ২০২৬                │  ← Gregorian, secondary
│ ┌──────────────────────────┐ │
│ │   ◐  শুক্লা সপ্তমী          │ │  ← TITHI SEAL (the one bold element)
│ │      দুপুর ২:৩২ পর্যন্ত      │ │     moon arc = progress through tithi
│ │      তারপর অষ্টমী            │ │
│ └──────────────────────────┘ │
│  নক্ষত্র  মূলা · বিকেল ৪:১০ পর্যন্ত │
│  যোগ    শোভন · রাত ৮:০৫ পর্যন্ত  │
│  করণ    গর · দুপুর ২:৩২ পর্যন্ত   │
│ ──────────────────────────── │
│  ☀ ৫:৩৮  ☾ ৫:১৪   চাঁদ ↑১১:৫২ ↓১০:৪০│
│ ──────────────────────────── │
│  এখন: রাহুকাল ৭:৩২–৯:০০  ●     │  ← active period highlighted
│  বারবেলা ১০:৩০–১১:৫৮            │
│ ──────────────────────────── │
│  আজ  ▌দুর্গাষষ্ঠী  ✓✓          │
│ ──────────────────────────── │
│  আসছে                         │
│  ▌মহাষ্টমী        ২ দিন বাকি    │
│  ▌লক্ষ্মীপূজা       ৮ দিন বাকি    │
│ ──────────────────────────── │
│  দৃক (বিশুদ্ধ) · কলকাতা · IST     │
├──────────────────────────────┤
│  আজ   পঞ্জিকা   পার্বণ   আরও    │
└──────────────────────────────┘
```

The same screen in English, with "Names in both scripts" on (all values sample):

```
┌──────────────────────────────┐
│ Monday         [📍 Kolkata ▾] │
│ 25 Ashwin 1433                │  ← Bengali date stays the hero in English too
│ ২৫ আশ্বিন ১৪৩৩                 │  ← second script (only when the toggle is on)
│ 12 October 2026               │
│ ┌──────────────────────────┐ │
│ │   ◐  Shukla Saptami        │ │
│ │      শুক্লা সপ্তমী            │ │
│ │      until 2:32 PM         │ │
│ │      then Ashtami          │ │
│ └──────────────────────────┘ │
│  Nakshatra  Mula · until 4:10 PM│
│  Yoga       Shobhana · until 8:05 PM│
│  Karana     Gara · until 2:32 PM│
│ ──────────────────────────── │
│  ☀ 5:38 AM  ☾ 5:14 PM  Moon ↑11:52 AM ↓10:40 PM│
│ ──────────────────────────── │
│  Now: Rahu Kaal 7:32–9:00 AM ●│
│  Barabela 10:30–11:58 AM      │
│ ──────────────────────────── │
│  Today ▌Durga Shashthi  ✓✓    │
│ ──────────────────────────── │
│  Coming up                    │
│  ▌Maha Ashtami     in 2 days  │
│  ▌Lakshmi Puja     in 8 days  │
│ ──────────────────────────── │
│  Drik (Bishuddha) · Kolkata · IST│
├──────────────────────────────┤
│  Today  Calendar  Festivals  More│
└──────────────────────────────┘
```

English rows are longer than Bengali ones ("until 4:10 PM" vs "বিকেল ৪:১০ পর্যন্ত" is similar, but "Shobhana · until 8:05 PM" can wrap). PanchangRow therefore wraps the value under the label at narrow widths or large text instead of truncating.

Components: DateHeader, TithiSeal, PanchangRow ×3, TimingStrip, PeriodList, ObservanceChip, UpcomingFestivalCard, ProvenanceFooter.

Behaviour: pull-to-refresh only re-reads local data and checks for new packs. Tapping the tithi seal opens Day detail. Ad placement: none on this screen above the fold; at most one native ad card **below** the "আসছে" section (§20).

States: loading skeleton (≤ 300 ms, usually invisible), data missing (§11.9), stale pack (amber banner "তথ্য হালনাগাদ প্রয়োজন" + update button), sample build (diagonal watermark).

### 11.3 Calendar (পঞ্জিকা)

```
┌──────────────────────────────┐
│  ‹   আশ্বিন ১৪৩৩  ▾   ›   [আজ] │
│  [ বাংলা মাস | ইংরেজি মাস ]  (i) │
│ রবি  সোম  মঙ্গল বুধ  বৃহ  শুক্র শনি │
│ ┌───┬───┬───┬───┬───┬───┬───┐│
│ │   │   │   │ ১ │ ২ │ ৩ │ ৪ ││
│ │   │   │   │১৮ │১৯ │২০ │২১ ││  ← Gregorian small, below
│ ├───┼───┼───┼───┼───┼───┼───┤│
│ │ ৫ │ ৬ │ ৭ │ ৮ │ ৯ │১০ │১১ ││
│ │২২ │২৩ │২৪ │২৫ │২৬ │২৭ │২৮ ││
│ │   │ ● │   │   │ এ │   │   ││  ● Purnima  ○ Amavasya  এ Ekadashi
│ ├───┼───┼───┼───┼───┼───┼───┤│
│ │…  │   │   │   │   │   │   ││  ▌ coloured bar = festival
│ └───┴───┴───┴───┴───┴───┴───┘│
│  নির্বাচিত: ২৫ আশ্বিন            │
│  শুক্লা সপ্তমী · দুর্গাষষ্ঠী  [দেখুন]│  ← selected-day summary strip
├──────────────────────────────┤
│  আজ   পঞ্জিকা   পার্বণ   আরও    │
└──────────────────────────────┘
```

- Cell minimum 48×56 dp. Sundays' numerals in red (traditional), but never colour-only information.
- Below the grid: selected-day summary strip with a "দেখুন" (view) button.
- Year transition: swiping past চৈত্র goes to বৈশাখ of next year; title animates the year change.

### 11.4 Day detail (দিন)
Wireframe: §11.10.

Sections in order: date header → tithi (with kshaya/vriddhi line) → nakshatra/yoga/karana → sun & moon → শুভ সময় (auspicious) → অশুভ সময় (Rahu Kaal, Yamaganda, Gulika, বারবেলা, কালবেলা, কালরাত্রি) → observances → provenance footer. Each time row: label left, time range right, active row highlighted. Share button in app bar.

### 11.5 Festivals (পার্বণ)

```
┌──────────────────────────────┐
│ পার্বণ ১৪৩৩         [🔍]       │
│ [সব] [পূজা] [ব্রত] [তিথি] [উৎসব] │  ← filter chips
│ ── আশ্বিন ─────────────────── │
│ ▌দুর্গাষষ্ঠী   সোম, ১২ অক্টো  ✓✓ 🔔│
│ ▌মহাসপ্তমী   মঙ্গল, ১৩ অক্টো ✓✓  │
│ ▌মহাষ্টমী    বুধ, ১৪ অক্টো  ✓✓ 🔔│
│ ── কার্তিক ────────────────── │
│ ▌কালীপূজা    …                │
└──────────────────────────────┘
```

Sticky month headers; list auto-scrolls to the current month. Badge: ✓ reference matched, ✓✓ expert reviewed.

### 11.6 Festival detail
Wireframe: §11.11.
Hero band in the festival's category colour; name in the UI language (display) with the other script below it (always shown here, regardless of FR-SET-06); date(s); relevant windows (e.g. সন্ধিপূজা ০০:০০–০০:৪৮, sample); tithi involved and its span; 80–150-word original description; verification card ("বিশুদ্ধ সিদ্ধান্ত পঞ্জিকার সঙ্গে মিলিয়ে দেখা হয়েছে, চৈত্র ১৪৩২"); buttons: মনে করিয়ে দিন, শেয়ার করুন.

### 11.7 City picker
Wireframe: §11.12.
Search field (Bengali/English, transliteration-tolerant: "bardhaman", "burdwan", "বর্ধমান"); "আমার অবস্থান" row; sections: সাম্প্রতিক (recent), পশ্চিমবঙ্গ (by district), অন্যান্য শহর (metros). Each row shows district and today's sunrise for that city, which helps users understand why city matters.

### 11.8 Share card (image, 1080×1350)
Festival name in display Bengali type, date in both calendars, a simple original motif (alpona-inspired linework, drawn by us), app name and small "বিশুদ্ধ সিদ্ধান্ত মতে". No QR code clutter; optional store link in the share text.

Language: the share sheet offers **বাংলা**, **English** and **দুই ভাষায় / Both** (Bengali name as the hero with the English name below), defaulting to the UI language. Family WhatsApp groups often mix readers of both scripts. The card text, the share-message text and the provenance line ("As per Bishuddha Siddhanta") all follow the chosen option. Cards render at a fixed 1080×1350 regardless of the device text scale, and each layout is golden-tested in both languages with the longest festival name in the catalogue.

### 11.9 System states (applies to every data screen)

| State | Copy (Bengali) | Copy (English) | Action (bn / en) |
|---|---|---|---|
| Data not downloaded for this range | এই সময়ের তথ্য ডাউনলোড করা নেই। | Data for these dates isn't downloaded yet. | ডাউনলোড করুন / Download |
| Offline + not downloaded | ইন্টারনেট সংযোগ নেই। সংযোগ পেলে তথ্য ডাউনলোড হবে। | You're offline. The data will download when you're connected. | — |
| Pack stale | তথ্য হালনাগাদ প্রয়োজন। | This data needs an update. | হালনাগাদ করুন / Update |
| Signature failed | তথ্য যাচাই করা যায়নি, তাই দেখানো হচ্ছে না। | We couldn't verify this data, so it isn't shown. | আবার চেষ্টা করুন / Try again |
| Festival unverified (tier 2/3) | এই তারিখ এখনও পঞ্জিকা মিলিয়ে দেখা হয়নি। | This date hasn't been checked against the panjika yet. | — |

All other copy in this document is given in Bengali (the source language). Each string gets an English counterpart in `app_en.arb`, written to the voice rules in §13.2. English copy here is a draft for review, like the Bengali.

### 11.10 Day detail — wireframe

```
┌──────────────────────────────┐
│ ‹ পঞ্জিকা            [শেয়ার]   │
│ মঙ্গলবার                       │
│ ১৮ আশ্বিন ১৪৩৩                │
│ ৫ অক্টোবর ২০২৬                 │
│ ── তিথি ──────────────────── │
│ তিথি     পূর্ণিমা               │
│          রাত ৯:১৪ পর্যন্ত,       │
│          তারপর কৃষ্ণা প্রতিপদ     │
│ ক্ষয় তিথি  (শুধু প্রযোজ্য হলে)   │
│ পক্ষ     শুক্লপক্ষ               │
│ নক্ষত্র    রেবতী · …পর্যন্ত       │
│ যোগ      ধ্রুব · …পর্যন্ত        │
│ করণ      বিষ্টি                 │
│ ── সূর্য ও চন্দ্র ────────────── │
│ সূর্যোদয় / সূর্যাস্ত   ৫:৪০ / ৫:১১ │
│ চন্দ্রোদয় / চন্দ্রাস্ত  ৫:২২ / ৫:৫০ │
│ ── শুভ সময় ───────────────── │
│ অমৃতযোগ   …   মাহেন্দ্রযোগ …    │
│ ── অশুভ সময় ──────────────── │
│ রাহুকাল · যমগণ্ড · গুলিক · বারবেলা│
│ কালবেলা · কালরাত্রি              │
│ ── উৎসব ও ব্রত ────────────── │
│ ▌কোজাগরী লক্ষ্মীপূজা  ✓✓         │
│ ──────────────────────────── │
│ বিশুদ্ধ সিদ্ধান্ত · কলকাতা · IST    │
│ তথ্য v৩ · যাচাই: পঞ্জিকা মিলিয়ে দেখা │
└──────────────────────────────┘
```
Swipe left/right = next/previous day. Times that fall after midnight show "(পরদিন)".

### 11.11 Festival detail — wireframe

```
┌──────────────────────────────┐
│ ‹ পার্বণ                       │
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│
│▓ মহাষ্টমী                      ▓│  ← category-colour band
│▓ বুধবার, ১১ আশ্বিন ১৪৩৩           ▓│
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│
│ তিথি      অষ্টমী · …পর্যন্ত       │
│ সন্ধিপূজা   …–…                   │
│           অষ্টমীর শেষ ২৪ মিনিট ও   │
│           নবমীর প্রথম ২৪ মিনিট     │
│                              │
│ ছোট বিবরণ (৮০–১৫০ শব্দ, নিজেদের লেখা)│
│                              │
│ ┌✓✓ বিশুদ্ধ সিদ্ধান্ত পঞ্জিকার সঙ্গে  ┐│
│ │   মিলিয়ে দেখা ও বিশেষজ্ঞ যাচাইকৃত।  ││
│ └   যাচাই: চৈত্র ১৪৩২             ┘│
│ [ মনে করিয়ে দিন ] [ শেয়ার করুন ]  │
└──────────────────────────────┘
```
Multi-day festivals (Durga Puja) show a horizontal day selector (ষষ্ঠী · সপ্তমী · অষ্টমী · নবমী · দশমী) under the band.

### 11.12 City picker — wireframe

```
┌──────────────────────────────┐
│ ‹ শহর বেছে নিন                 │
│ [🔍 শহরের নাম লিখুন ………… ]      │
│ ◎ আমার অবস্থান ব্যবহার করুন       │
│ ── সাম্প্রতিক ─────────────── │
│ কলকাতা           সূর্যোদয় ৫:৩৮ ✓ │
│ ── পশ্চিমবঙ্গ ─────────────── │
│ হাওড়া   · হাওড়া    সূর্যোদয় ৫:৩৯ │
│ বর্ধমান · পূর্ব বর্ধমান  সূর্যোদয় ৫:৪২│
│ শিলিগুড়ি · দার্জিলিং  সূর্যোদয় ৫:৩৪ │
│ …                            │
│ ── অন্যান্য শহর ───────────── │
│ দিল্লি · মুম্বই · বেঙ্গালুরু · চেন্নাই …  │
└──────────────────────────────┘
```
Location result sheet: "নিকটতম শহর: বর্ধমান (১২ কিমি)। [এটি বেছে নিন] [অন্য শহর]". If > 50 km: extra line "সময় কয়েক মিনিট আলাদা হতে পারে।"
Permission denied: inline note "অবস্থানের অনুমতি দেওয়া হয়নি। তালিকা থেকে শহর বেছে নিন।" — no repeated prompts.

### 11.13 Reminders (অনুস্মারক) — wireframe

```
┌──────────────────────────────┐
│ ‹ অনুস্মারক                    │
│ ── নিয়মিত ────────────────── │
│ একাদশী                    [●] │
│   আগের দিন রাত ৮টা ▾           │
│ পূর্ণিমা                    [○] │
│ অমাবস্যা                   [○] │
│ ── উৎসব ───────────────────  │
│ কালীপূজা   আগের দিন রাত ৮টা   [●]│
│ লক্ষ্মীপূজা  সকাল ৬টা         [●]│
│ [+ উৎসব যোগ করুন]               │
│ ── নিজের অনুস্মারক (v1.1) ──── │
│ ──────────────────────────── │
│ বিজ্ঞপ্তি বন্ধ আছে? [সেটিংস খুলুন]   │  ← only if OS permission off
└──────────────────────────────┘
```
Timing options: আগের দিন (time picker), সেদিন সকালে (time picker), তিথি শুরুর সময় (only if exact alarms allowed — §17).
Empty state: "এখনো কোনো অনুস্মারক নেই। একাদশী বা কোনো উৎসবের জন্য চালু করুন।"

### 11.14 Search (খুঁজুন) — wireframe

```
┌──────────────────────────────┐
│ ‹ [🔍 তারিখ বা উৎসবের নাম ……]   │
│ উদাহরণ: ২৫ আশ্বিন ১৪৩৩ ·          │
│         12/10/2026 · কালীপূজা    │
│ ── ফলাফল ────────────────── │
│ 📅 ২৫ আশ্বিন ১৪৩৩ = ১২ অক্টোবর   │
│ ▌কালীপূজা  ১৪৩৩               │
│ ▌কালীপূজা  ১৪৩৪               │
└──────────────────────────────┘
```
Date results open Day detail; festival results open Festival detail. Out-of-range dates show the "not downloaded" state (§11.9). No results: "কিছু পাওয়া যায়নি। বানান বা তারিখের ধরন দেখে নিন।"

### 11.15 Settings (সেটিংস) — wireframe

```
┌──────────────────────────────┐
│ ‹ সেটিংস                      │
│ ভাষা          [বাংলা | English]│  ← segmented, each label in its own script
│ নাম দুই লিপিতে              [○] │  ← FR-SET-06, preview line below
│ পঞ্জিকার মত      বিশুদ্ধ সিদ্ধান্ত ▾│
│ শহর                 কলকাতা ›  │
│ থিম          স্বয়ংক্রিয় / হালকা / গাঢ় │
│ লেখার আকার      [অ ─●──── অ]   │  ← preview line below slider
│ সময়ের ধরন         ১২ ঘণ্টা ▾    │
│ সংখ্যা            বাংলা (১২৩) ▾  │
│ ── তথ্য ─────────────────── │
│ তথ্য হালনাগাদ      এখন দেখুন ›   │
│ ডাউনলোড করা বছর    ১৪৩২–১৪৩৫ ›   │
│ ── অন্যান্য ───────────────── │
│ বিজ্ঞাপন সরান ›  · গোপনীয়তা ›      │
│ লাইসেন্স ›  · সম্পর্কে ›           │
└──────────────────────────────┘
```
Changing tradition shows a confirm sheet: "পঞ্জিকার মত বদলালে কিছু উৎসবের তারিখ বদলাতে পারে। অনুস্মারক নতুন করে সাজানো হবে।" [বদলান] [থাক]
"লাইসেন্স" opens Flutter's `showLicensePage` plus our data/font notices.

### 11.16 Sources & verification (তথ্যসূত্র ও যাচাই) — wireframe

```
┌──────────────────────────────┐
│ ‹ তথ্যসূত্র ও যাচাই              │
│ আমরা কীভাবে হিসাব করি            │
│ ১ জ্যোতির্বিজ্ঞানের হিসাব (NASA JPL)│  ← genuine sequence, so numbered
│ ২ রাষ্ট্রীয় পঞ্চাঙ্গের সঙ্গে মিলানো    │
│ ৩ মুদ্রিত পঞ্জিকার সঙ্গে মিলানো      │
│ ৪ প্রধান উৎসব বিশেষজ্ঞের যাচাই      │
│ ── চিহ্নের অর্থ ─────────────── │
│ ✓✓ বিশেষজ্ঞ যাচাইকৃত               │
│ ✓  পঞ্জিকা মিলিয়ে দেখা              │
│ ●  শুধু গণনাকৃত                    │
│ ── এই ফোনের তথ্য ───────────── │
│ গ্লোবাল v৩ · শহর v২ · উৎসব v৪       │
│ শেষ যাচাই: চৈত্র ১৪৩২              │
│ দুই মত কেন আলাদা? ›               │
│ [ ভুল জানান ]                     │
└──────────────────────────────┘
```
"দুই মত কেন আলাদা?" opens a 150-word plain-language explainer about Drik vs Surya Siddhanta.

### 11.17 Report an error (ভুল জানান) — wireframe

```
┌──────────────────────────────┐
│ ‹ ভুল জানান                    │
│ কোন তারিখ?     ১১ আশ্বিন ১৪৩৩ ▾ │
│ কী ভুল?  ○ তিথির সময় ○ উৎসবের দিন │
│          ○ বাংলা তারিখ ○ অন্য     │
│ আপনার পঞ্জিকায় কী আছে?            │
│ [ ……………………………………… ]         │
│ পঞ্জিকার নাম (ঐচ্ছিক) [……]         │
│ সঙ্গে যাবে: শহর, মত, তথ্যের সংস্করণ  │
│ [        পাঠান          ]        │
└──────────────────────────────┘
```
No name, phone or email requested. Offline: "ইন্টারনেট পেলে পাঠানো হবে।" Success: "পাঠানো হয়েছে। যাচাই করে প্রয়োজনে সংশোধন করা হবে।"

### 11.18 Remove ads / Premium (বিজ্ঞাপনমুক্ত) — wireframe

```
┌──────────────────────────────┐
│ ‹ বিজ্ঞাপনমুক্ত                  │
│ সব পঞ্জিকা তথ্য সবসময় বিনামূল্যে।   │
│ বিজ্ঞাপনমুক্ত নিলে পাবেন:           │
│ · কোনো বিজ্ঞাপন নেই               │
│ · নিজের অনুস্মারক (v1.1)           │
│ · অতিরিক্ত থিম ও শেয়ার কার্ড         │
│ [ ₹৯৯ / বছর ]  [ ₹১৯৯ একবারে ]    │  ← prices are assumptions (§20.3)
│ কেনা আছে? [পুনরুদ্ধার করুন]          │
└──────────────────────────────┘
```
The first line is a product promise and must stay true (§20.1).
