# R8 rules for release builds (T-608). Flutter's Gradle plugin adds its own rules for the
# engine and plugin registration; most plugins ship consumer rules. This file holds only
# what the app itself needs, each rule with its reason.
#
# - Drift / sqlite3: SQL runs through dart:ffi on a native libsqlite3; there is no Java or
#   Kotlin code to keep (sqlite3_flutter_libs 0.6 is an empty shim), so no rules.
# - flutter_local_notifications 22: its Gson rules come with the library (README, "ProGuard
#   rules": v19+). Notification icons are kept by res/raw/keep.xml.
# - MainActivity's method channels (panjika/app_locale, panjika/system_settings) are
#   reached from the manifest and by name in Dart, not by reflection: no rules.

# Flutter's deferred-components support references Play Core, which the app does not ship.
-dontwarn com.google.android.play.core.**
