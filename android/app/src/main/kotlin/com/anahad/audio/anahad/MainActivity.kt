package com.anahad.audio.anahad

import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private val WIDGET_CHANNEL = "com.anahad.audio/widget"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidget" -> {
                    val title = call.argument<String>("title") ?: "ANAHAD Music"
                    val artist = call.argument<String>("artist") ?: "Ready to play"
                    val format = call.argument<String>("format") ?: "ANAHAD AUDIO"
                    val isPlaying = call.argument<Boolean>("isPlaying") ?: false
                    val artPath = call.argument<String>("artPath")
                    val lyric = call.argument<String>("lyric")

                    AnahadAppWidgetProvider.updateWidget(
                        context = this,
                        title = title,
                        artist = artist,
                        format = format,
                        isPlaying = isPlaying,
                        artPath = artPath,
                        lyric = lyric
                    )
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Connect widget button clicks back to Flutter
        AnahadAppWidgetProvider.widgetActionListener = { action ->
            runOnUiThread {
                when (action) {
                    "play_pause" -> methodChannel?.invokeMethod("onWidgetPlayPause", null)
                    "next" -> methodChannel?.invokeMethod("onWidgetNext", null)
                    "prev" -> methodChannel?.invokeMethod("onWidgetPrev", null)
                }
            }
        }
    }

    override fun onDestroy() {
        AnahadAppWidgetProvider.widgetActionListener = null
        super.onDestroy()
    }
}
