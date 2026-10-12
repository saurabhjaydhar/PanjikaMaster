# ADR-001: Android minSdk 24, targetSdk 36

**Status:** accepted (agent proposal, T-104; the owner may revise) · **Date:** 2026-10-12

## Context
- Google Play requires targetSdk 36 for new apps and updates since 31 Aug 2026 (spec §19.1 L15).
- The audience includes older users on low-cost phones (PRD §4.1, §3.3 guardrail: ₹10k phone).
- Flutter 3.47 supports minSdk 24 (Android 7.0) and uses it as its default.
- Planned packages (Drift + sqlite3_flutter_libs, flutter_local_notifications, geolocator, google_mobile_ads, in_app_purchase) all support API 24.

## Decision
- `minSdk = 24`, `targetSdk = 36`, `compileSdk = 36`, pinned in `app/android/app/build.gradle.kts` instead of following Flutter's defaults, so a Flutter upgrade cannot change them silently.
- The device test matrix (spec §22.2) starts at Android 10; API 24–28 are supported but only smoke-tested.

## Consequences
- Edge-to-edge is enforced by Android 15+ at targetSdk 36; the app enables it on every version (`SystemUiMode.edgeToEdge`) for consistent layouts.
- Predictive back is opted in (`android:enableOnBackInvokedCallback="true"`); navigation must use `PopScope`.
- Raising minSdk later (e.g. to 26 for native adaptive icons only) is cheap; lowering it is not.
