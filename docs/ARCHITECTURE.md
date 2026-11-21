# ANAHAD Prototype 1: System Architecture

## 1. Architectural Overview

ANAHAD Prototype 1 is structured around a decoupled, hexagonal architecture designed for high-fidelity local audio playback, rock-solid Android background execution, and forward compatibility with online music acquisition engines.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                             PRESENTATION LAYER                              │
│                                                                             │
│   HomeScreen       LibraryScreen      SearchScreen     NowPlayingScreen     │
│   SettingsScreen   MiniPlayer         QueueSheet       LyricsView           │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ Watches
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          APPLICATION STATE (PROVIDERS)                      │
│                                                                             │
│   PlaybackNotifier    LibraryNotifier    ThemeNotifier    SettingsNotifier  │
└──────────────┬───────────────────────┬───────────────────────────┬──────────┘
               │                       │                           │
               ▼                       ▼                           ▼
┌──────────────────────────┐ ┌──────────────────────┐ ┌───────────────────────┐
│     AUDIO SUBSYSTEM      │ │   LIBRARY & MEDIA    │ │   STORAGE & PREFS     │
│                          │ │                      │ │                       │
│ AnahadAudioHandler       │ │ MediaLibraryService  │ │ StorageService        │
│ (audio_service)          │ │ (on_audio_query)     │ │ (shared_preferences) │
│                          │ │                      │ │                       │
│ just_audio (AudioPlayer) │ │ MediaStore Scanners  │ │ Playlists, Favorites, │
│ ConcatenatingAudioSource │ │ Offline Sample Pool  │ │ History & Themes      │
└──────────────┬───────────┘ └──────────────────────┘ └───────────────────────┘
               │
               ▼ MethodChannel ('com.anahad.audio/widget')
┌─────────────────────────────────────────────────────────────────────────────┐
│                        NATIVE ANDROID SYSTEM LAYER                          │
│                                                                             │
│   MainActivity (AudioServiceActivity)                                       │
│   AudioService & MediaButtonReceiver                                        │
│   AnahadAppWidgetProvider (RemoteViews, PendingIntents)                     │
│   Android MediaSession & System Notification Controls                       │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Audio Subsystem & Background Engine

### 2.1 Audio Pipeline & Player
The core audio decoding engine is powered by `just_audio 0.9.42`, utilizing Android's ExoPlayer media stack:
- **Lossless FLAC**: Direct native decoding of FLAC files up to 24-bit / 96kHz without lossy downsampling.
- **MP3 / AAC / M4A / WAV**: Full container and codec support.
- **Concatenating Audio Source**: Seamless gapless playback and pre-buffering between consecutive tracks.

### 2.2 Background Playback & MediaSession (`audio_service`)
Background playback is governed by `AnahadAudioHandler`, extending `BaseAudioHandler`:
- **Foreground Service**: Registered in `AndroidManifest.xml` with `android:foregroundServiceType="mediaPlayback"`.
- **Media Notification**: Displays track title, artist, album art, play/pause, next, previous, and scrub seekbar directly on the Android notification drawer and lock screen.
- **Audio Focus Management**: Automatically handles audio interruptions (e.g. phone calls, alarms) and transient ducking.
- **Audio Becoming Noisy**: Automatically pauses playback when headphones or Bluetooth audio devices are disconnected, preventing unintended speaker blast.

---

## 3. Native Android Home-Screen Widget Architecture

To fulfill the requirement for an interactive home-screen widget, a native Kotlin widget provider was built and integrated via Flutter MethodChannels:

1. **Provider (`AnahadAppWidgetProvider.kt`)**:
   - Extends Android `AppWidgetProvider`.
   - Renders a custom `RemoteViews` layout (`res/layout/widget_now_playing.xml`).
   - Displays real-time track title, artist name, format badge (`FLAC 24-BIT LOSSLESS`), and dynamic play/pause icon.
   - Attaches `PendingIntent` broadcasts for `ACTION_PLAY_PAUSE`, `ACTION_NEXT`, and `ACTION_PREV`.
2. **MethodChannel Bridge (`MainActivity.kt`)**:
   - Implements `com.anahad.audio/widget`.
   - Transmits playback changes (`updateWidget`) from Dart to the Android widget manager.
   - Forwards widget click actions (`onWidgetPlayPause`, `onWidgetNext`, `onWidgetPrev`) back to `PlaybackNotifier` to control audio playback in real time.

---

## 4. Local Media Library & Fallback Pool

### 4.1 MediaStore Scanners (`MediaLibraryService`)
- Interacts with Android MediaStore using `on_audio_query 2.9.0`.
- Requests runtime permissions (`READ_MEDIA_AUDIO` on Android 13+, `READ_EXTERNAL_STORAGE` on Android 12-).
- Automatically maps songs into `TrackModel`, categorizing tracks by format (`FLAC`, `MP3`, `AAC`, `M4A`, `WAV`), sample rate, bit depth, and duration.

### 4.2 Offline Testing Pool
To ensure that fresh phone installations or Android emulators without pre-loaded MP3s can be tested immediately, `MediaLibraryService` includes a curated pool of sample tracks:
- `sample_flac_01`: Celestial Resonance (FLAC 24-bit/96kHz)
- `sample_flac_02`: Morning Raag Bhairav (FLAC 16-bit/44.1kHz)
- `sample_mp3_01`: Midnight Synthwave Drive (320kbps MP3)
- `sample_m4a_01`: Golden Sunset Acoustic (AAC 256kbps)

---

## 5. Synchronized Lyrics Engine (`LyricsService`)

- **Parsing**: Automatically locates local `.lrc` files adjacent to the audio track or provides sample synchronized lyrics for demonstration.
- **Parser Logic**: Extracts millisecond timestamps via regex `r'\[(\d{2}):(\d{2})(?:\.(\d{2,3}))?\](.*)'`.
- **Karaoke Synchronization**: Compares stream `playback.position` against timestamp intervals, dynamically highlighting the active line and auto-centering via `ScrollController`.
- **Interactive Seeking**: Tapping any lyrics line triggers `playback.seek(line.timestamp)` to immediately jump playback to that exact lyric.

---

## 6. Multi-Provider Architecture Preservation

In strict alignment with the historical ANAHAD architecture (detailed in `docs/MUSIC_PROVIDER_ARCHITECTURE.md`), Prototype 1 maintains provider contracts and configurations for all three acquisition providers:

1. **Universal Acquisition Provider**:
   - Architecture: yt-dlp extraction engine abstraction.
   - Configuration: Enabled toggle, bundled engine path, bit-perfect extraction policy.
2. **Deezer Provider**:
   - Architecture: Direct ARL session authentication and Blowfish stream resolution.
   - Configuration: ARL token input, quality preference (`FLAC`, `MP3_320`).
3. **DAB Provider**:
   - Architecture: Dedicated DAB endpoint consumer.
   - Configuration: Base URL input (`http://127.0.0.1:8080`), session status indicator (marked as `Offline / Architectural Stub`).
- **No Silent Fallback**: The architecture strictly guarantees that provider selection remains transparent and independent.
