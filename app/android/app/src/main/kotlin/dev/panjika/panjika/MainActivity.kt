package dev.panjika.panjika

import android.app.LocaleManager
import android.os.Build
import android.os.LocaleList
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
    }
}
