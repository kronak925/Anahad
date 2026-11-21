package com.anahad.audio.anahad

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.view.KeyEvent
import android.view.View
import android.widget.RemoteViews
import java.io.File
import java.net.HttpURLConnection
import java.net.URL

class AnahadAppWidgetProvider : AppWidgetProvider() {

    companion object {
        const val ACTION_PLAY_PAUSE = "com.anahad.audio.ACTION_PLAY_PAUSE"
        const val ACTION_NEXT = "com.anahad.audio.ACTION_NEXT"
        const val ACTION_PREV = "com.anahad.audio.ACTION_PREV"

        private const val PREFS_NAME = "AnahadWidgetPrefs"
        private const val KEY_TITLE = "widget_title"
        private const val KEY_ARTIST = "widget_artist"
        private const val KEY_FORMAT = "widget_format"
        private const val KEY_PLAYING = "widget_is_playing"
        private const val KEY_ART_PATH = "widget_art_path"
        private const val KEY_LYRIC = "widget_lyric"

        @Volatile private var cachedArtUrl: String? = null
        @Volatile private var cachedBitmap: android.graphics.Bitmap? = null

        var widgetActionListener: ((String) -> Unit)? = null

        private fun scaleBitmap(bitmap: android.graphics.Bitmap, maxDim: Int = 128): android.graphics.Bitmap {
            val width = bitmap.width
            val height = bitmap.height
            if (width <= maxDim && height <= maxDim) return bitmap
            val ratio = width.toFloat() / height.toFloat()
            val newW = if (width >= height) maxDim else (maxDim * ratio).toInt()
            val newH = if (height >= width) maxDim else (maxDim / ratio).toInt()
            return android.graphics.Bitmap.createScaledBitmap(bitmap, newW.coerceAtLeast(1), newH.coerceAtLeast(1), true)
        }

        fun updateWidget(
            context: Context,
            title: String,
            artist: String,
            format: String,
            isPlaying: Boolean,
            artPath: String?,
            lyric: String? = null
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit()
                .putString(KEY_TITLE, title)
                .putString(KEY_ARTIST, artist)
                .putString(KEY_FORMAT, format)
                .putBoolean(KEY_PLAYING, isPlaying)
                .putString(KEY_ART_PATH, artPath)
                .putString(KEY_LYRIC, lyric)
                .apply()

            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, AnahadAppWidgetProvider::class.java)
            val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)

            for (widgetId in allWidgetIds) {
                renderWidget(context, appWidgetManager, widgetId, title, artist, format, isPlaying, artPath, lyric)
            }
        }

        private fun renderWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            title: String,
            artist: String,
            format: String,
            isPlaying: Boolean,
            artPath: String?,
            lyric: String? = null
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_now_playing)

            views.setTextViewText(R.id.widget_track_title, title.ifEmpty { "ANAHAD Music" })
            views.setTextViewText(R.id.widget_track_artist, artist.ifEmpty { "Ready to play" })
            views.setTextViewText(R.id.widget_format_badge, format.ifEmpty { "ANAHAD AUDIO" })

            // Live Synchronized Lyrics
            if (!lyric.isNullOrEmpty()) {
                views.setViewVisibility(R.id.widget_lyrics, View.VISIBLE)
                views.setTextViewText(R.id.widget_lyrics, "♪ $lyric")
            } else {
                views.setViewVisibility(R.id.widget_lyrics, View.GONE)
            }

            val playPauseRes = if (isPlaying) R.drawable.ic_widget_pause else R.drawable.ic_widget_play
            views.setImageViewResource(R.id.widget_btn_play_pause, playPauseRes)

            // Safely load and downsample album art (max 128px to prevent TransactionTooLargeException)
            if (!artPath.isNullOrEmpty()) {
                if (cachedArtUrl == artPath && cachedBitmap != null) {
                    views.setImageViewBitmap(R.id.widget_album_art, cachedBitmap)
                } else if (artPath.startsWith("http://") || artPath.startsWith("https://")) {
                    // Load remote image in background thread with downsampling
                    Thread {
                        try {
                            val url = URL(artPath)
                            val conn = url.openConnection() as HttpURLConnection
                            conn.connectTimeout = 3000
                            conn.readTimeout = 3000
                            conn.doInput = true
                            conn.connect()
                            val input = conn.inputStream
                            val rawBitmap = BitmapFactory.decodeStream(input)
                            input.close()
                            if (rawBitmap != null) {
                                val scaled = scaleBitmap(rawBitmap, 128)
                                cachedArtUrl = artPath
                                cachedBitmap = scaled
                                val updatedViews = RemoteViews(context.packageName, R.layout.widget_now_playing)
                                updatedViews.setImageViewBitmap(R.id.widget_album_art, scaled)
                                appWidgetManager.partiallyUpdateAppWidget(appWidgetId, updatedViews)
                            }
                        } catch (_: Exception) {
                        }
                    }.start()
                    // Show cached or default while loading
                    if (cachedBitmap != null) {
                        views.setImageViewBitmap(R.id.widget_album_art, cachedBitmap)
                    } else {
                        views.setImageViewResource(R.id.widget_album_art, R.drawable.ic_widget_music)
                    }
                } else {
                    try {
                        val file = File(artPath)
                        if (file.exists()) {
                            val rawBitmap = BitmapFactory.decodeFile(file.absolutePath)
                            if (rawBitmap != null) {
                                val scaled = scaleBitmap(rawBitmap, 128)
                                cachedArtUrl = artPath
                                cachedBitmap = scaled
                                views.setImageViewBitmap(R.id.widget_album_art, scaled)
                            } else {
                                views.setImageViewResource(R.id.widget_album_art, R.drawable.ic_widget_music)
                            }
                        } else {
                            views.setImageViewResource(R.id.widget_album_art, R.drawable.ic_widget_music)
                        }
                    } catch (_: Exception) {
                        views.setImageViewResource(R.id.widget_album_art, R.drawable.ic_widget_music)
                    }
                }
            } else {
                cachedArtUrl = null
                cachedBitmap = null
                views.setImageViewResource(R.id.widget_album_art, R.drawable.ic_widget_music)
            }

            // Click Intent to open App
            val openAppIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
            }
            val openAppPendingIntent = PendingIntent.getActivity(
                context,
                0,
                openAppIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, openAppPendingIntent)

            // Play/Pause Action
            val playPauseIntent = Intent(context, AnahadAppWidgetProvider::class.java).apply {
                action = ACTION_PLAY_PAUSE
            }
            val playPausePendingIntent = PendingIntent.getBroadcast(
                context,
                101,
                playPauseIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_btn_play_pause, playPausePendingIntent)

            // Next Action
            val nextIntent = Intent(context, AnahadAppWidgetProvider::class.java).apply {
                action = ACTION_NEXT
            }
            val nextPendingIntent = PendingIntent.getBroadcast(
                context,
                102,
                nextIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_btn_next, nextPendingIntent)

            // Prev Action
            val prevIntent = Intent(context, AnahadAppWidgetProvider::class.java).apply {
                action = ACTION_PREV
            }
            val prevPendingIntent = PendingIntent.getBroadcast(
                context,
                103,
                prevIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_btn_prev, prevPendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun sendMediaButton(context: Context, keyCode: Int) {
            try {
                val mediaReceiver = ComponentName(context, "com.ryanheise.audioservice.MediaButtonReceiver")
                
                val downIntent = Intent(Intent.ACTION_MEDIA_BUTTON).apply {
                    component = mediaReceiver
                    setPackage(context.packageName)
                    putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(KeyEvent.ACTION_DOWN, keyCode))
                }
                context.sendBroadcast(downIntent)

                val upIntent = Intent(Intent.ACTION_MEDIA_BUTTON).apply {
                    component = mediaReceiver
                    setPackage(context.packageName)
                    putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(KeyEvent.ACTION_UP, keyCode))
                }
                context.sendBroadcast(upIntent)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val title = prefs.getString(KEY_TITLE, "ANAHAD Music") ?: "ANAHAD Music"
        val artist = prefs.getString(KEY_ARTIST, "Ready to play") ?: "Ready to play"
        val format = prefs.getString(KEY_FORMAT, "ANAHAD AUDIO") ?: "ANAHAD AUDIO"
        val isPlaying = prefs.getBoolean(KEY_PLAYING, false)
        val artPath = prefs.getString(KEY_ART_PATH, null)
        val lyric = prefs.getString(KEY_LYRIC, null)

        for (appWidgetId in appWidgetIds) {
            renderWidget(context, appWidgetManager, appWidgetId, title, artist, format, isPlaying, artPath, lyric)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_PLAY_PAUSE -> {
                // Immediate local visual toggle for responsive feedback
                try {
                    val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                    val wasPlaying = prefs.getBoolean(KEY_PLAYING, false)
                    val newPlaying = !wasPlaying
                    prefs.edit().putBoolean(KEY_PLAYING, newPlaying).apply()
                    val appWidgetManager = AppWidgetManager.getInstance(context)
                    val thisWidget = ComponentName(context, AnahadAppWidgetProvider::class.java)
                    val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
                    for (widgetId in allWidgetIds) {
                        val views = RemoteViews(context.packageName, R.layout.widget_now_playing)
                        val iconRes = if (newPlaying) R.drawable.ic_widget_pause else R.drawable.ic_widget_play
                        views.setImageViewResource(R.id.widget_btn_play_pause, iconRes)
                        appWidgetManager.partiallyUpdateAppWidget(widgetId, views)
                    }
                } catch (_: Exception) {}

                if (widgetActionListener != null) {
                    widgetActionListener?.invoke("play_pause")
                } else {
                    sendMediaButton(context, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE)
                }
            }
            ACTION_NEXT -> {
                if (widgetActionListener != null) {
                    widgetActionListener?.invoke("next")
                } else {
                    sendMediaButton(context, KeyEvent.KEYCODE_MEDIA_NEXT)
                }
            }
            ACTION_PREV -> {
                if (widgetActionListener != null) {
                    widgetActionListener?.invoke("prev")
                } else {
                    sendMediaButton(context, KeyEvent.KEYCODE_MEDIA_PREVIOUS)
                }
            }
        }
    }
}
