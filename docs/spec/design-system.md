# Design system

> Part of the Bangla Panjika spec. Section numbers (§) are permanent IDs shared by all docs; `docs/README.md` maps each one to its file.

## 12. Design system

### 12.1 Direction
"The printed panjika, made calm." Bengali almanacs are red-and-black on paper with dense tables. We keep the **ink colours and Bengali typography**, drop the density, and spend boldness in exactly one place: the **tithi seal** on Today — a large tithi name inside a thin moon-phase ring that fills as the tithi progresses.

Design principles (use them to settle design arguments):

1. **One bold element per screen.** Today: the tithi seal. Calendar: today's ring. Festival detail: the category band. Everything else is quiet.
2. **Answer first.** What the user opened the screen for is readable without scrolling at 130% text on a 360×640 dp phone, in both languages.
3. **Calm density.** Keep the panjika's information and lose its clutter. Group with whitespace and section headers, not boxes inside boxes.
4. **Both scripts are first-class.** Every layout is designed, reviewed and golden-tested in Bengali and English. Neither is fitted in afterwards.
5. **Trust is visible.** Provenance and verification status are part of the layout, not fine print.
6. **Kind to the eyes.** Large type, honest contrast, a real dark mode, and motion only when it carries meaning.

### 12.2 Colour tokens

| Token | Light | Dark | Use |
|---|---|---|---|
| `ink` | #1F1A3D (indigo ink) | #ECEAF7 | Primary text |
| `ink-muted` | #5B567A | #A9A5C4 | Secondary text, second-script line (§13.4) |
| `paper` | #FFFFFF | #15132B | Background |
| `paper-raised` | #F6F4FB | #1E1C38 | Section backgrounds |
| `alta` (sindoor red) | #B4232C | #F0707A | Festivals, Sundays, inauspicious |
| `haldi` (turmeric) | #E3A21A | #F2BE4E | Large decorative fills and glows only (light value is not a text or indicator colour) |
| `haldi-strong` | #B07607 | #F2BE4E | Tithi ring progress, today marker, focus ring |
| `durba` (grass green) | #2E7A4E | #6CC596 | Auspicious, verification ticks |
| `rule` | #E2DFEE | #2E2B4D | Dividers (decorative only) |
| `alta-container` | #FBE9EA | #4A1D26 | Background of the active inauspicious period row |
| `haldi-container` | #FCF1D6 | #3D3014 | Tithi seal background, "today" cell fill |
| `on-haldi-container` | #5C3D00 | #FFE3A3 | Text/icons on `haldi-container` when not `ink` |
| `durba-container` | #E3F2E9 | #173A2A | Background of the active auspicious period row, verification card |

Festival category colours (the coloured bar on chips and lists; always paired with the category's name or icon, never colour alone):

| Category | Token | Light | Dark |
|---|---|---|---|
| পূজা / Puja | `alta` | #B4232C | #F0707A |
| ব্রত/উপবাস / Vrata & fasts | `neel` | #3949AB | #9FA8DA |
| তিথি / Tithi | `haldi-strong` | #B07607 | #F2BE4E |
| উৎসব / Festival | `padma` | #AD1457 | #F48FB1 |
| জয়ন্তী / Jayanti | `ink-muted` | #5B567A | #A9A5C4 |

**Measured contrast (WCAG 2.x formula).** Text on `paper` / `paper-raised`: `ink` 16.5/15.1 light, 15.2/13.8 dark; `ink-muted` 6.9/6.3 light, 7.6/6.9 dark; `alta` 6.5/6.0 light, 6.3/5.7 dark; `durba` 5.2/4.8 light, 8.7/7.9 dark. `ink` on every container ≥ 10.5. Category colours ≥ 3.5 on both backgrounds. **Light `haldi` is only 2.2:1 on white.** It fails the 3:1 minimum for meaningful graphics (WCAG 1.4.11), so the ring progress and today marker use `haldi-strong` (3.9:1). Re-measure after any token change; CI runs a contrast test over the token table.

Material 3 mapping: build a custom `ColorScheme` from these tokens (`primary` = `ink`, `error` = `alta`, `tertiary` = `durba`, surface containers from `paper`/`paper-raised`). **No dynamic colour (Material You) in MVP**: the ink-and-alta identity and the measured contrast matter more than wallpaper matching. Widgets read tokens through a `PanjikaColors` theme extension and never use hex literals.

### 12.3 Typography

Bengali and Latin need different metrics. Matras, reph and conjuncts take more vertical room, and Bengali at very small sizes becomes illegible sooner than Latin. Each role therefore has a per-script size and line height. One `TextTheme` per locale is generated from this table; widgets never set `fontFamily` or sizes directly.

| Role | Typeface (bn) | bn size / line (sp) | Typeface (en) | en size / line (sp) | Used for |
|---|---|---|---|---|---|
| Display | Tiro Bangla | 34/48 | Tiro Bangla (Latin glyphs) | 32/40 | Bengali date, tithi name in the seal |
| Headline | Tiro Bangla | 26/36 | Tiro Bangla (Latin) | 24/32 | Festival detail band, onboarding questions |
| Title | Tiro Bangla | 22/30 | Tiro Bangla (Latin) | 20/28 | Screen titles, month title |
| Body | Noto Sans Bengali | 16/26 | Noto Sans | 16/24 | Rows, descriptions |
| Label | Noto Sans Bengali Medium | 14/22 | Noto Sans Medium | 14/20 | Row labels, chips, buttons, nav |
| Caption | Noto Sans Bengali | 13/20 | Noto Sans | 12/16 | Provenance footer, second-script line. **Bengali never below 13 sp.** |

- Tiro Bangla includes Latin, so the display voice is the same in both languages. Check during T-109 (Phase 1) that its Latin covers the romanisation diacritics we use (Q14); if not, fall back to Noto Serif for display Latin.
- Fallback chains: Bengali styles → `NotoSansBengali`, then `NotoSans`; English styles → `NotoSans`, then `NotoSansBengali` (needed for "Names in both scripts"). Mixed strings (a Bengali name with Latin digits) must render without tofu in either theme.
- Weights: Noto Sans Bengali 400 body, 500 label, 600 emphasis. Avoid 700+ below 18 sp in Bengali (counters fill in on low-DPI screens). Tiro Bangla is regular-only; do not synthesise bold.
- Times in columns use tabular figures (`FontFeature.tabularFigures()`) where the font supports them; check by eye that Bengali digits align in the period list.
- Bundle and subset the fonts (Bengali + Latin + Latin-ext + punctuation + both digit sets). Font budget ≤ 1.5 MB of the 30 MB app budget (§3.3).

### 12.4 Numerals & time formatting
Full per-language rules are in §13.3. In short:
- Default Bengali numerals (০–৯) in the Bengali UI and Latin numerals in the English UI; either can be chosen in Settings (FR-L10N-04).
- Bengali 12-hour times carry day-part words: ভোর (04–06), সকাল (06–12), দুপুর (12–15), বিকেল (15–17:30), সন্ধ্যা (17:30–19:30), রাত (19:30–04). Exact boundaries are a copy decision — confirm with 5 target users. English 12-hour times use AM/PM.
- After-midnight times inside a panjika day are written with the next date, e.g. "রাত ১:১০ (পরদিন)" / "1:10 AM (next day)".

### 12.5 Components (reusable widgets)

| Component | Props (key) | Notes |
|---|---|---|
| `DateHeader` | gregorian, bengaliDate, weekday, city | Display + secondary line |
| `TithiSeal` | tithi, paksha, start, end, now, next | Ring progress in `haldi-strong` on a `haldi-container` disc; semantics label reads full sentence |
| `NameText` | nameRef, style, showSecondScript | **The only widget allowed to render a panchanga or festival name.** Picks `name_bn`/`name_en` from the UI language and adds the second-script line (§13.4) |
| `PanchangRow` | label, value, endsAt | 48 dp min height; value wraps under the label when it doesn't fit |
| `TimingStrip` | sunrise, sunset, moonrise, moonset | Icons + times; moonrise may be "নেই" / "None" |
| `PeriodRow` | name, kind (shubh/ashubh), start, end, active | Active = `alta-container` / `durba-container` fill + "এখন"/"Now" label (not colour alone) |
| `CalendarDayCell` | bengaliDay, gregorianDay, markers, isToday, isSelected | Shape-coded markers |
| `ObservanceChip` | name, category, status | Category colour bar + status icon |
| `FestivalCard` | observance, daysLeft | Used on Today + lists |
| `VerificationBadge` | status | ✓ / ✓✓ / grey dot, with a text label for screen readers |
| `ProvenanceFooter` | tradition, city, tz, packVersion | Every date screen |
| `CityChip` / `CityPicker` | city | |
| `ReminderToggle` | target, schedule | Handles permission flow |
| `StateMessage` | kind, action | §11.9 |
| `LanguageSwitch` | current | Segmented "বাংলা \| English"; each label in its own script, never translated |
| `GlossaryTerm` | termId, child | Wraps a label; long-press or (i) opens the glossary sheet (FR-SET-07) |
| `SectionHeader` | title, action? | Sticky in lists; Title role |
| `Skeleton` | shape | Exactly the size of the content it stands for (no layout shift) |
| `SampleWatermark` | — | Diagonal "নমুনা · SAMPLE" overlay; compiled only in debug/test builds |

Every component has a widget test and golden images for bn/en × light/dark × 100%/200% text scale.

### 12.6 Accessibility
- Text scales to 200% without truncating the tithi or Bengali date (wraps instead). Use Flutter's `TextScaler` so Android 14+ nonlinear font scaling is honoured; never clamp the text scale.
- Touch targets ≥ 48×48 dp.
- Markers use shape + colour.
- Text contrast ≥ 4.5:1, meaningful graphics ≥ 3:1 (§12.2); never convey state by colour alone.
- Semantics labels in the UI language (§13.7); Bengali TalkBack voice tested on 2 devices, English TalkBack on 2 devices.
- Logical focus order (top to bottom, the tithi seal first on Today); visible focus ring in `haldi-strong` for keyboard/D-pad users.
- Reduced-motion setting (`MediaQuery.disableAnimations`) disables the ring animation and page transitions.

### 12.7 Layout, spacing and shape
- **Grid:** 4 dp base. Spacing tokens: `xs` 4, `s` 8, `m` 12, `l` 16, `xl` 24, `xxl` 32, `xxxl` 48.
- **Screen margins:** 16 dp on compact widths, 24 dp on medium and expanded. Content max width 640 dp, centred, on wide screens.
- **Shape:** radius 8 (chips, small buttons), 12 (cards, rows with fills), 20 (bottom sheets, tithi seal container), full (pills, segmented controls).
- **Elevation:** flat by default. Hierarchy comes from tonal surfaces (`paper` → `paper-raised` → containers), not shadows. One shadow level, for bottom sheets and menus only.
- **Rhythm:** sections are separated by `xl` (24 dp) and a section header; rows inside a section by `s` (8 dp). Avoid dividers between every row; use them between sections only.

### 12.8 Motion and haptics
- **Durations:** 150 ms (micro: toggles, chips), 250 ms (standard: sheets, page transitions), 500 ms (emphasis: tithi ring first fill). Material 3 emphasised easing.
- **Tithi ring:** animates from empty to current progress once per day on first view, then advances silently with the clock (FR-HOME-08). The tithi name itself never animates; when the tithi changes, the old and new names cross-fade (250 ms).
- **Calendar:** month swipe uses a horizontal shared-axis transition; when the Bengali year changes (চৈত্র → বৈশাখ) the year digits in the title slide vertically (§11.3).
- **Reduced motion:** all of the above become instant.
- **Haptics:** light selection click on calendar day selection, segmented controls and toggles. None on scroll or navigation.

### 12.9 Iconography and illustration
- UI icons: Material Symbols Rounded (Apache-2.0), 24 dp, 2 dp optical stroke. Record in `docs/assets.md`.
- Custom glyphs drawn in-house to the same stroke: 8-step moon phase set, sunrise, sunset, moonrise, moonset, Purnima/Amavasya/Ekadashi markers.
- Illustration: original alpona-inspired linework for onboarding, empty states and share cards, in `ink`/`alta`/`haldi` only. No deity images anywhere (L23).
- App icon: concept A (tithi ring) recommended (§23.3); the Android 12+ splash screen uses the same mark on `ink` with no extra delay.

### 12.10 Adaptive layout and system UI
- **Width classes** (Material 3): compact < 600 dp, medium 600–839 dp, expanded ≥ 840 dp. MVP is designed for compact. On medium/expanded the content is centred at max 640 dp and calendar cells grow. A two-pane layout (calendar + day detail, festival list + detail) follows in v1.1.
- **Landscape phones:** Today scrolls normally; calendar cells keep ≥ 48×48 dp and the selected-day strip moves beside the grid if height < 480 dp.
- **Edge-to-edge** (mandatory at targetSdk 36): draw behind the status and navigation bars, pad content with system insets, keep the bottom navigation above the gesture area. Test 3-button and gesture navigation.
- **Predictive back:** `PopScope` only; sheets and the onboarding flow animate correctly with the back preview.
- **Large text + small screen:** at 200% on 360 dp the bottom navigation keeps its labels (they may wrap to two lines), and Today becomes a single column with no side-by-side rows.

### 12.11 Bengali text-rendering rules (engineering)
These avoid the defects that make Bengali apps look cheap:
- **Never set `letterSpacing` on Bengali text.** It pulls conjuncts and vowel signs apart.
- **Never fix the height of a text container.** Vowel signs (ি ী ু ূ ৃ), reph and chandrabindu go above and below Latin ascenders and descenders, and fixed heights clip them. Use min heights and padding.
- Use `TextHeightBehavior(leadingDistribution: TextLeadingDistribution.even)` with the per-script line heights (§12.3), so mixed Bengali/Latin rows share a comfortable baseline.
- **Prefer wrapping to ellipsis** for names. Where truncation is unavoidable (dense list rows), the full text goes in the semantics label and a tooltip.
- **No string concatenation of translated fragments.** Word order differs ("দুপুর ২:৩২ পর্যন্ত" vs "until 2:32 PM"). Use whole ICU messages with placeholders (§13.5).
- Bengali sentences end with দাঁড়ি (।), English with a full stop; never mix within a language.
- English uses sentence case. No all-caps labels (Bengali has no case, and caps would make the two UIs feel different).
- Widget tests include long, conjunct-heavy strings, e.g. "উত্তরভাদ্রপদ", "কোজাগরী লক্ষ্মীপূজা", "জগদ্ধাত্রী পূজা", and their long English forms ("Uttara Bhadrapada", "Kojagari Lakshmi Puja").

### 12.12 UI quality bar ("top notch", made testable)
A screen is not done until all of these hold:
- **Eight reviewed states:** bn/en × light/dark × 100%/200% text, each with a golden image, plus the empty, loading, stale and error states from §11.9.
- **No layout shift** after the first frame; skeletons are exactly the size of the content (§12.5).
- **Smooth:** no frames over 16 ms while swiping the calendar or flinging the festival list, measured in profile mode on the low-end reference phone (§22.2).
- **Tokens only:** no hex colours, raw font sizes or string literals in widget code (CI grep/lint check).
- **Feedback everywhere:** every tappable element shows a pressed state; every async action shows progress within 100 ms.
- **Visual sign-off:** each screen is compared with the approved design (Phase 2, T-215) before merge; the human signs off. Starting concept for that review: `docs/design/today-concept.html` (sample data, watermarked).
