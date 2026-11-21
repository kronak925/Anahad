# Proguard / R8 Keep Rules for ANAHAD Audio Player

# Keep AudioService and MediaBrowserService
-keep class com.ryanheise.audioservice.** { *; }
-keep interface com.ryanheise.audioservice.** { *; }

# Keep JustAudio and audio_session
-keep class com.ryanheise.just_audio.** { *; }
-keep interface com.ryanheise.just_audio.** { *; }
-keep class com.ryanheise.audio_session.** { *; }

# Keep Android ExoPlayer and Media3
-keep class com.google.android.exoplayer2.** { *; }
-keep interface com.google.android.exoplayer2.** { *; }
-keep class androidx.media3.** { *; }
-keep interface androidx.media3.** { *; }

# Keep Native ANAHAD Application and Widget Provider
-keep class com.anahad.audio.anahad.** { *; }

# Keep Media query plugins
-keep class com.lucasjosino.on_audio_query.** { *; }

# Keep Flutter Engine and Plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
