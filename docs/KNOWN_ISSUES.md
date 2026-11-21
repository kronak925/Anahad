# ANAHAD Prototype 1: Known Issues & Future Milestones

## 1. Prototype Scope & Verification Status

Prototype 1 fulfills all primary functional objectives of an installable Android music player:
- [x] Real device music access via Android MediaStore (MP3, AAC, M4A, FLAC).
- [x] Complete playback pipeline with `just_audio` and `audio_service`.
- [x] Persistent background audio service with lock-screen media controls and notification drawer actions.
- [x] Audio focus and headphone disconnect (audio becoming noisy) handling.
- [x] Native Android home-screen widget with interactive playback controls.
- [x] Synchronized `.lrc` and karaoke lyrics viewer with tap-to-seek.
- [x] Persistent user playlists, favorites, listening history, and theme settings.
- [x] Preservation of the 3 historical acquisition provider configurations (Universal, Deezer, DAB).

---

## 2. Known Limitations & Technical Context

### 2.1 Google Stitch MCP Cloud Availability
- **Finding**: Stitch MCP's `create_project` tool returned `{"text": "The service is currently unavailable.", "isError": true}` (HTTP 503).
- **Impact**: Prototype 1 UI was designed and built natively in Flutter using Material 3 with full Apple Music, Gaana, and Poweramp aesthetic guidelines.
- **Future Milestone**: When Google Stitch's cloud generation endpoints become accessible, screens can be registered and imported into a Stitch design project.

### 2.2 Online Provider Live Streaming (Planned for Prototype 2)
- **Current State**: Settings and provider models include full configuration for Universal (yt-dlp), Deezer (ARL session), and DAB (custom URL).
- **Context**: As documented in `docs/DEEZER_PROVIDER.md` and `docs/DAB_PROVIDER.md`, live online acquisition depends on valid Deezer ARL credentials and a hosted DAB backend. Prototype 1 focuses on the local playback engine, background service, and widget, while preserving the clean abstraction for Prototype 2 integration.

### 2.3 Non-Standard Embedded Cover Art
- **Context**: Local artwork extraction is powered by `on_audio_query` via Android's native MediaStore indexing.
- **Edge Case**: Unindexed audio files located in non-standard storage directories or files with non-standard ID3v2.4 comment blocks may display the fallback musical note art icon until indexed by Android's media scanner.
- **Future Milestone**: Prototype 2 will bundle a lightweight native tag extraction pipeline for direct bit-level ID3/FLAC metadata parsing.

### 2.4 Audio Visualizer / DSP Equalizer
- **Current State**: Prototype 1 includes audiophile format badges, track specs inspector dialog, and gapless playback.
- **Future Milestone**: An advanced multi-band parametric equalizer and real-time audio FFT visualizer will be added in Prototype 2.

---

## 3. Resolved Issues & Diagnostic Post-Mortem

### 3.1 Initial Launch Crash: ClassNotFoundException for MainActivity
- **Symptom**: Application instantly failed to launch upon installation on physical Android devices.
- **Empirical Diagnostics via Logcat**:
  ```
  java.lang.ClassNotFoundException: Didn't find class "com.anahad.audio.anahad.MainActivity" on path: DexPathList[...]
  ```
- **Root Cause**: `android/app/build.gradle.kts` was missing the Kotlin Android Gradle plugin (`id("org.jetbrains.kotlin.android")`) and source set registration. Consequently, Gradle only compiled Java classes and completely omitted `MainActivity.kt` from `classes.dex`.
- **Resolution**:
  1. Applied `id("org.jetbrains.kotlin.android")` in `build.gradle.kts` and registered `src/main/kotlin`.
  2. Configured `MainActivity` to extend `AudioServiceActivity` as strictly required by `audio_service 0.18.x`.
  3. Recompiled DEX bytecode: confirmed `MainActivity` compiled into `classes.dex` (`classes6.dex`).
  4. Verified successful boot and UI rendering on Android emulator (`verification_avd`).

### 3.2 RemoteViews Attribute Inflation Crash in AppWidget
- **Symptom**: Widget rendering crash on launchers when theme attributes were resolved in RemoteViews.
- **Root Cause**: `android:background="?android:attr/selectableItemBackgroundBorderless"` inside RemoteViews XML layout cannot be resolved by Android SystemUI/Launcher3 outside an Activity theme context.
- **Resolution**: Replaced theme attributes in `widget_now_playing.xml` with standard drawable resources (`@drawable/ic_widget_play`, `@drawable/ic_widget_next`, `@drawable/ic_widget_music`).

### 3.3 Compact Screen Layout Overflow (320px Viewports)
- **Symptom**: Minor layout overflow banners on the `Audio Pipeline Active` card and `Lossless FLAC Master Tracks` header when displayed on ultra-compact 320px screens.
- **Resolution**:
  1. Replaced `Row` with `Wrap` for the status banner badge in `home_screen.dart`.
  2. Wrapped header titles in `Expanded` with `TextOverflow.ellipsis`.
  3. Tuned `TrackTile` horizontal padding to 12px and applied compact icon constraints.
  4. Verified pixel-perfect rendering with zero overflow banners via emulator screenshot.
