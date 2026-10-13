package dev.panjika.panjika

import android.app.LocaleManager
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.LocaleList
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Two-way sync with Android 13+ per-app language (FR-L10N-03); see app_locale_channel.dart.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "panjika/app_locale")
            .setMethodCallHandler { call, result ->
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                    result.success(null)
                    return@setMethodCallHandler
                }
                val manager = getSystemService(LocaleManager::class.java)
                when (call.method) {
                    "get" -> result.success(manager.applicationLocales.toLanguageTags())
                    "set" -> {
                        val tag = call.argument<String>("tag") ?: ""
                        manager.applicationLocales = LocaleList.forLanguageTags(tag)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        // Help (T-613): open the system page for TTS voices, notifications or battery.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "panjika/system_settings")
            .setMethodCallHandler { call, result ->
                if (call.method != "open") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val intent = when (call.argument<String>("page")) {
                    "tts" -> Intent("com.android.settings.TTS_SETTINGS")
                    "notifications" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                            .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                    } else {
                        appDetails() // minSdk 24: no per-app notification page before 26
                    }
                    "battery" -> Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                    else -> null
                }
                if (intent == null) {
                    result.success(false)
                    return@setMethodCallHandler
                }
                result.success(open(intent) || open(appDetails()))
            }
    }

    private fun appDetails() = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        .setData(Uri.fromParts("package", packageName, null))

    private fun open(intent: Intent): Boolean = try {
        startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        true
    } catch (e: ActivityNotFoundException) {
        false
    } catch (e: SecurityException) {
        false
    }
}
