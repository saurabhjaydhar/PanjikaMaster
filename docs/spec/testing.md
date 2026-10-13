# Testing and quality

> Part of the Bangla Panjika spec. Section numbers (§) are permanent IDs shared by all docs; `docs/README.md` maps each one to its file.

## 22. QA & test plan

### 22.1 Automated

| Layer | Tests | Tooling |
|---|---|---|
| Pipeline (Python) | Ayanamsa vs published values; tithi/nakshatra transitions vs reference sample; Bengali dates vs every day of reference years; property tests (no gaps/overlaps; tithi length 19–27 h; indices cycle correctly) | pytest, hypothesis |
| Domain (Dart) | PeriodCalculator tables for all weekdays; DayAssembler with kshaya/vriddhi; Bengali numeral + day-part formatter; IST conversions for devices in other zones | `flutter test` |
| Data | Pack importer: bad signature rejected; partial download rejected; migration from v1→v2 schema | `flutter test` with in-memory Drift |
| Localisation | ARB parity (keys, placeholders, no empty or copied values); no string literals in widgets; `PanjikaFormatter` for every item in §13.3 × {bn, en} × {Bengali, Latin numerals}; ICU plurals in English; search normaliser cases from §13.6; pack builder rejects a row missing a language | `flutter test`, CI script, pytest |
| Design tokens | Contrast test over the §12.2 token table (text ≥ 4.5, graphics ≥ 3); no hex literals or raw font sizes in `features/` | `flutter test`, CI grep |
| Widget | Today at 100/130/200% text scale; calendar grid for 29/30/31/32-day months; empty/stale states — **each in bn and en** | widget + golden tests |
| Golden matrix | Every §12.5 component and every MVP screen: {bn, en} × {light, dark} × {100%, 200%}, plus the expansion test locale (§13.5) | golden tests |
| Integration | Onboarding → Today (in both languages); switch language in Settings → screen and back stack preserved, reminders re-localised; set reminder → notification scheduled; airplane mode | `integration_test` on emulator |

Commands (local machine):

```
flutter analyze
flutter test
flutter test --update-goldens   # only when a visual change is intended
flutter test integration_test
```

Determinism (T-218): goldens load the bundled subset fonts and the icon font of the pinned Flutter SDK (`test/helpers/fonts.dart`), and every golden test fixes the view size, pixel ratio and text scale, so images are identical on every Linux run; CI uploads the diff images when one fails. Generate goldens on Linux with the CI's Flutter version. Python property tests use Hypothesis profiles: `dev` (50 examples, random) locally and `ci` (500 examples, derandomised, no deadline) in ci-data via `HYPOTHESIS_PROFILE=ci`.

### 22.2 Manual

- Compare 60 random days on device vs printed panjika (two testers, independently).
- Older-user test: 5 users aged 55+ complete "find today's tithi", "find next Ekadashi", "set a reminder for Kali Puja".
- English-user test: 3 users who read English more easily than Bengali do the same tasks in English and explain three terms using only the glossary.
- Copy review: native Bengali and English reviewers read every screen on a device (not the ARB file) in both themes.
- Device matrix: Android 10, 13, 14, 15; 1 low-end (2 GB RAM), 1 mid, 1 Samsung (aggressive battery management), 1 Xiaomi (notification restrictions).
- TalkBack in Bengali and in English (2 devices each), including one device without a Bengali TTS voice installed.

### 22.3 Definition of done (per feature)
Code reviewed; unit + widget tests pass; `flutter analyze` clean; works offline; works at 200% text; complete in Bengali **and** English with both copies reviewed; golden matrix updated and approved (§12.12); no sample data reachable in release build (CI check greps the release bundle for fixture markers).
