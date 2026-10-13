// TODO(Q11): the final app ID is the owner's decision (PRD §26) and cannot change after the
// first Play upload. Until then a placeholder is used; override without editing this file:
//   flutter build apk -P panjikaAppId=com.example.final
val panjikaAppId: String = (project.findProperty("panjikaAppId") as String?) ?: "dev.panjika.placeholder"

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "dev.panjika.panjika"
    // Pinned rather than taken from Flutter's defaults, so a Flutter upgrade can't move them.
    // targetSdk 36 is required by Google Play (spec §19.1 L15); minSdk: docs/decisions/ADR-001-min-sdk.md
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    // Only Bengali and English resources ship (FR-L10N-03 lists only these two).
    androidResources {
        localeFilters += listOf("en", "bn")
    }

    compileOptions {
        // flutter_local_notifications needs java.time on older Android (T-506).
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = panjikaAppId
        minSdk = 24
        targetSdk = 36
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Debug keys until the release pipeline exists (T-703, T-708). The upload key will come
            // from CI secrets only (CLAUDE.md); never commit a keystore. TODO(Q12)
            signingConfig = signingConfigs.getByName("debug")
            // R8 code and resource shrinking (T-608; Flutter's default, stated here so it
            // stays on). Rules: proguard-rules.pro; kept resources: res/raw/keep.xml.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
