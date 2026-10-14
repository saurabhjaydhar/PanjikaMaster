# Data model and pack format

> Part of the Bangla Panjika spec. Section numbers (§) are permanent IDs shared by all docs; `docs/README.md` maps each one to its file.

## 15. Data model

### 15.1 Drift tables (device)

The executable version of the pack tables is `data/pack/schema.sql` (STRICT tables, foreign keys and CHECK constraints for index ranges, statuses and both-language text). If this sketch and `schema.sql` ever disagree, `schema.sql` wins and this section is fixed. The app's Drift tables are generated from it (`scripts/sync_drift_schema.py` → `app/lib/data/db/pack_tables.drift`, checked in CI) and a test compares the live Drift database with `schema.sql` column by column.

**Pending (decision 2026-10-13, any-place timings):** the sketch below already shows `body_positions` and no `city_days`; `schema.sql` changes with T-314 and T-316. Until then `schema.sql` is the current truth.

```
packs(id TEXT PK, tradition TEXT, kind TEXT,           -- 'global' | 'cities' (the place list) | 'observances'
      is_sample INT,                                    -- 1 = fixture pack (debug/test only, §6.8)
      covers_from DATE, covers_to DATE, version INT,
      generated_at DATETIME, engine_version TEXT, ephemeris_sha256 TEXT,
      validation_summary TEXT, installed_at DATETIME, sha256 TEXT)

transitions(id INT PK, pack_id TEXT FK, tradition TEXT, -- Surya Siddhanta (v1.1) yields different moments
            kind TEXT,                                -- tithi|nakshatra|yoga|karana|sankranti
            idx INT, starts_utc INT, ends_utc INT)     -- unix seconds
  INDEX(tradition, kind, starts_utc), INDEX(tradition, kind, ends_utc)

lunar_months(tradition TEXT, month_idx INT,             -- amanta naming per Q2
             is_adhik INT,                              -- 1 = মলমাস (no sankranti inside)
             starts_utc INT, ends_utc INT, pack_id TEXT,
             PRIMARY KEY(tradition, starts_utc))

cities(id TEXT PK, name_bn TEXT, name_en TEXT,          -- the place list (§6.2, Q13): India + major cities abroad
       aliases TEXT,                                    -- both scripts + common romanisations, for search
       district_bn TEXT, district_en TEXT, state TEXT,  -- state = country or Indian state
       lat REAL, lon REAL, elevation_m INT, tz TEXT,
       popular INT, pack_id TEXT)                       -- popular = shown in onboarding list

body_positions(...)                                     -- in the global pack: the pipeline's apparent geocentric
                                                        -- Sun/Moon positions in a compact form, enough for
                                                        -- OnDeviceRiseSet (§6.5.5) at any coordinates. Exact
                                                        -- columns are fixed by T-314 in schema.sql; budget
                                                        -- ≤ 200 KB per year compressed

-- city_days (per-city rise/set rows) is retired: rise/set is computed on the phone for
-- any place. The pipeline's riseset.py stays as the reference and writes the shared fixture.

bengali_dates(tradition TEXT, date DATE, bn_day INT, bn_month_idx INT, bn_year INT,
              pack_id TEXT, PRIMARY KEY(tradition, date))

names(kind TEXT, idx INT, name_bn TEXT, name_en TEXT, translit TEXT,
      gloss_bn TEXT NULL, gloss_en TEXT NULL,          -- 1–2 sentence meaning for the glossary (FR-SET-07)
      pack_id TEXT,
      PRIMARY KEY(kind, idx))
  -- kinds: tithi, paksha, nakshatra, yoga, karana, solar_month, lunar_month,
  --        weekday, gregorian_month, period, tradition, category,
  --        term (glossary entries, FR-SET-07; translit = term id)

observances(id TEXT PK, name_bn TEXT, name_en TEXT, category TEXT, tier INT,
            description_bn TEXT, description_en TEXT, pack_id TEXT)

observance_dates(observance_id TEXT, tradition TEXT, date DATE, day_index INT,
                 status TEXT, reviewed_by TEXT NULL, reviewed_on DATE NULL,
                 note_bn TEXT NULL, note_en TEXT NULL, pack_id TEXT,
                 PRIMARY KEY(observance_id, tradition, date))

observance_windows(observance_id TEXT, tradition TEXT, date DATE,
                   window_kind TEXT NOT NULL,           -- sandhi_puja | nishita | purnima_span …
                   start_utc INT, end_utc INT, pack_id TEXT,
                   PRIMARY KEY(observance_id, tradition, date, window_kind))

period_rules(tradition TEXT, name_idx INT,              -- names(kind='period')
             kind TEXT,                                 -- shubh|ashubh
             weekday INT, basis TEXT,                   -- day|night
             divisions INT, part INT, enabled INT, pack_id TEXT,
             PRIMARY KEY(tradition, name_idx, weekday, basis))   -- part is 1-based, as in §6.5.8

reminders(id INT PK, target_kind TEXT, target_id TEXT, offset_minutes INT,
          time_of_day TEXT NULL, enabled INT, created_at DATETIME)

settings(key TEXT PK, value TEXT)
  -- keys: locale (bn|en), numerals (beng|latn), names_both_scripts (0|1),
  --       tradition, place (city:<id> | geo:<lat>,<lon>, rounded to 0.01°, never leaves the phone),
  --       recent_places, theme (system|light|dark), text_scale, time_format (12|24),
  --       onboarding_done, last_manifest_check
error_reports_queue(id INT PK, payload TEXT, created_at DATETIME)
observance_corrections(tradition TEXT, observance_id TEXT, corrected_at DATETIME,
                       PK(tradition, observance_id))   -- §18 "corrected" label, 7 days
```

**Index convention.** Every `idx` / `*_idx` column is 0-based: tithi 0 = Shukla Pratipada … 14 = Purnima, 15 = Krishna Pratipada … 29 = Amavasya (the 1–30 tithi number in §6.5.1 minus one); nakshatra and yoga 0–26; karana transitions store `k` (0–59, §6.5.4) and the domain maps `k` to a `names(kind='karana')` row (0–10); `solar_month` 0 = বৈশাখ; `weekday` 0 = Sunday. `bn_day` and `bn_year` are the numbers as written. Pipeline and app share one test fixture that checks this mapping.

**Why `observance_windows` is separate.** In v1.1 `window_kind` was a nullable column inside the primary key. SQLite treats NULLs in a primary key as distinct, so duplicate "no window" rows would not be rejected. Splitting dates from windows keeps both keys strict.

Rule: **no table without a `pack_id` or user ownership**, so every displayed datum can be traced to the pack that delivered it.

### 15.2 Pack format

A pack is an SQLite file with the same tables (subset), gzip-compressed, plus a detached signature:

```
packs/global-drik-2020-2045-v3.sqlite.gz
packs/global-drik-2020-2045-v3.sqlite.gz.sig      # Ed25519 over the gzip bytes
```

Importer: download → verify SHA-256 from manifest → verify signature → open as attached DB → copy rows in a transaction → mark old pack superseded → reschedule reminders.

### 15.3 API contract (static, read-only)

`GET /v1/manifest.json`

```json
{
  "schema": 1,
  "generated_at": "2026-10-12T00:00:00Z",
  "min_app_version": "1.0.0",
  "packs": [
    {
      "id": "global-drik-2020-2045",
      "kind": "global",
      "tradition": "drik_bishuddha",
      "version": 3,
      "covers": ["2020-01-01", "2045-12-31"],
      "url": "/v1/packs/global-drik-2020-2045-v3.sqlite.gz",
      "size": 812345,
      "sha256": "…",
      "sig_url": "/v1/packs/global-drik-2020-2045-v3.sqlite.gz.sig"
    }
  ],
  "notices": [
    {"id": "n-2026-09", "level": "info", "text_bn": "…", "text_en": "…", "until": "2026-10-31"}
  ]
}
```

The values above are illustrative of the shape, not real packs. `POST /v1/reports` (optional, Q6) accepts `{date, city_id, tradition, pack_versions, message, app_version}` and stores nothing else. For a user on their own location, `city_id` is the nearest listed city and `message` gets an `own_location: true` line; coordinates are never sent (FR-LOC-06).

### 15.4 Engine interfaces (Dart, domain layer)

```dart
/// Where panchanga data comes from: DriftPanjikaSource (pack data), with rise/set
/// for any place computed by OnDeviceRiseSet from the pack's body_positions.
abstract interface class PanjikaSource {
  Future<List<Transition>> transitions(
      TransitionKind kind, DateTime fromUtc, DateTime toUtc);
  Future<SunMoonTimes?> sunMoonTimes(Place place, LocalDate date);
  Future<BengaliDate?> bengaliDate(Tradition t, LocalDate date);
  Future<List<LunarMonth>> lunarMonths(
      Tradition t, DateTime fromUtc, DateTime toUtc); // incl. isAdhik (মলমাস)
  Future<List<ObservanceDate>> observances(
      Tradition t, LocalDate from, LocalDate to);
  Future<DataCoverage> coverage(Tradition t);   // no longer per city
}

/// A listed city or the user's own coordinates (rounded to 0.01°). Equal places
/// give equal results; the label is for display only.
sealed class Place { double get lat; double get lon; }
final class ListedPlace extends Place { /* CityId id, names, lat, lon */ }
final class OwnLocation extends Place { /* lat, lon, nearest ListedPlace for the label */ }

/// Pure, synchronous, no I/O. Same definition flag as the pipeline (Q3).
abstract interface class RiseSetCalculator {
  SunMoonTimes timesFor(
      {required double lat,
      required double lon,
      required LocalDate date,          // civil date in IST (Q16)
      required BodyPositions positions});
}

/// Pure, synchronous, fully unit-tested. No I/O.
abstract interface class PeriodCalculator {
  List<TimePeriod> periodsFor(
      {required DateTime sunriseUtc,
      required DateTime sunsetUtc,
      required DateTime nextSunriseUtc,
      required Weekday weekday,
      required List<PeriodRule> rules});
}

/// Builds the user-facing day from raw parts. Pure.
abstract interface class DayAssembler {
  DayPanjika assemble(DayInputs inputs, DateTime nowUtc);
}

sealed class DataCoverage {}
final class Covered extends DataCoverage { /* from, to */ }
final class NotDownloaded extends DataCoverage {}
final class Stale extends DataCoverage { /* reason */ }
```

`DayPanjika` carries `provenance` (tradition, place with coordinates, tz, packIds, statuses) so the UI cannot render a value without its source.
