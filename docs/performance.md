# Performance budgets and how they are checked (T-608)

The guardrails come from PRD §3.3. This file says what is enforced automatically and
what a person measures on a device.

| Budget | Limit | How it is checked |
|---|---|---|
| App size | < 30 MB | CI (`ci-app`): `scripts/check_apk_size.sh` checks each ABI's share of the release APK (the APK minus the other ABIs' native libraries, which is what Play delivers to a phone from the app bundle). It fails the build when the largest is over 30 MiB and writes the sizes to the job summary. The universal APK carries three ABIs (65 MB on 2026-10-13) and is not what a phone downloads. |
| Fonts | ≤ 1.5 MB of the app (§12) | Subset by `scripts/build_fonts.sh`; 788 KB today (`docs/assets.md`). |
| Code shrinking | R8 on in release | `android/app/build.gradle.kts` turns on code and resource shrinking; rules in `android/app/proguard-rules.pro`, with the reason for each; kept resources in `res/raw/keep.xml`. Drift needs no rules (SQL goes through `dart:ffi` on native SQLite). |
| Cold start to Today | < 1.5 s on a ₹10k Android phone | **Measured by a person** on the low-end phone of the device matrix (§22.2, T-616); see below. |
| On-device rise/set (§6.5.5) | < 2 ms per place per day on the low-end phone; a month grid (≤ 32 days + 1) < 60 ms | Benchmark test in `ci-app` (desktop VM, scaled limit) + the person's measurement with T-616 |
| Sun/Moon table | ≤ 200 KB per year compressed | Pack builder prints the size; T-314 test fails above it |
| Background work | none except scheduled notifications | No background services or work managers; the pack check runs on app open (§18). |

## Measuring cold start

On the low-end phone (2 GB RAM, Android 10–13), with a release-signed build that has the
real packs installed:

1. `flutter build apk --release` (or install the release bundle from internal testing).
2. Force-stop the app, then run five times and take the median:
   `adb shell am start-activity -W -S <app id>/.MainActivity`.
   `TotalTime` is the time to the first frame. That frame is already in the user's
   language and theme, because settings are read before `runApp` (`lib/main.dart`).
   Today's content follows a few frames later, once the day has been read from the
   database. If `TotalTime` is close to the budget, time the moment the content
   appears with a 60 fps screen recording.
3. For a breakdown, use `flutter run --profile --trace-startup` and read
   `build/start_up_info.json` (`timeToFirstFrameMicros`).

Record the median, the phone model and the Android version in the phase log. Fix
anything over 1.5 s before release.

## What runs before the first frame

- The database is opened, and settings are read so the first screen is already in the
  user's language and theme.
- Edge-to-edge mode is set.

Everything else waits until after the first frame:
- the pack check (§18);
- rescheduling reminders;
- sending queued error reports.

The licence texts are read only when the licences page opens.
