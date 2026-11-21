# ANAHAD Prototype 1: Implementation Report

## 1. Executive Summary

ANAHAD Prototype 1 is a functional, installable Android music player application engineered in Flutter with native Kotlin extensions. It combines audiophile sound engineering principles (native lossless FLAC decoding, gapless playback, format badges, track audio specifications) with a fluid user experience inspired by **Apple Music** (visual polish, layered surfaces, sliding modal player), **Gaana** (tabbed browsing, quick picks, playlists), and **Poweramp** (technical transparency, audio pipeline indicators, custom themes).

The primary deliverable — an installable Android APK — has been built, tested, and verified:
- **APK Artifact**: `build/app/outputs/flutter-apk/app-debug.apk` (119.1 MB)
- **Quality Gates**: `flutter analyze` passed with 0 errors/0 warnings; `flutter test` passed with 14/14 automated tests passing; native Gradle compilation succeeded.

---

## 2. Implemented Features & Capabilities

### 2.1 Real Local Device Music Access
- Powered by `on_audio_query 2.9.0` and Android MediaStore integration.
- Automatically queries and indexes audio files across internal storage and external SD cards:
  - Lossless formats: **FLAC**, **WAV**, **ALAC**.
  - Lossy formats: **MP3**, **M4A**, **AAC**, **OGG**.
- Automatic runtime permission management supporting both Android 13+ (`READ_MEDIA_AUDIO`) and legacy Android 12- (`READ_EXTERNAL_STORAGE`).
- Integrated offline sample pool providing 4 high-fidelity tracks (including 24-bit/96kHz studio FLAC) so that emulators and clean phones without music files can be tested immediately out of the box.

### 2.2 Audio Playback Engine & Background Service
- Engine core built on `just_audio 0.9.42` and `audio_service 0.18.17`.
- **Playback Controls**: Play, pause, seek, skip next, skip previous, repeat modes (Off, All, One), shuffle modes (All, None).
- **Background Persistence**: Native Android `ForegroundService` with `mediaPlayback` type declaration, ensuring playback continues uninterrupted when the phone is locked or the app is minimized.
- **Android Media Notification & Lock Screen**: Displays track title, artist, album art thumbnail, playback progress scrub bar, and interactive media controls directly on the system notification shade and lock screen.
- **Audio Focus & Headphone Disconnection**: Listens to system audio interruptions (calls, alarms) with automatic pause/resume, and handles the "Audio Becoming Noisy" event to pause immediately when headphones or Bluetooth audio devices are disconnected.

### 2.3 Native Android Home-Screen Widget
- Registered via `AnahadAppWidgetProvider.kt` in `AndroidManifest.xml` with `widget_now_playing_info.xml`.
- Interactive `RemoteViews` layout (`res/layout/widget_now_playing.xml`):
  - Glassmorphic dark card (`#F2141923`) with 18dp rounded corners.
  - Displays live track title, artist name, and format badge (`FLAC 24-BIT LOSSLESS`).
  - Interactive playback buttons: Previous, Play/Pause, and Next wired via `PendingIntent` broadcasts.
  - Bidirectional communication via Flutter MethodChannel `com.anahad.audio/widget`:
    - Dart updates the widget RemoteViews immediately whenever track or playback state changes.
    - Widget button clicks are received in native Kotlin and dispatched directly to Dart's playback engine.

### 2.4 Synchronized Karaoke Lyrics Engine
- Dedicated `LyricsService` and `LyricsView` component.
- Automatically searches for and parses local `.lrc` files adjacent to audio tracks or provides synchronized lyrics for demonstration.
- Regex parser (`r'\[(\d{2}):(\d{2})(?:\.(\d{2,3}))?\](.*)'`) extracts millisecond-accurate timestamps.
- **Dynamic Karaoke Styling**:
  - Active line rendered in 22sp bold, prominent primary accent color, with smooth auto-centering in the viewport.
  - Inactive lines rendered at 35% opacity.
- **Tap-to-Seek**: Tapping any lyric line seeks playback directly to that exact timestamp in the song.

### 2.5 Five Core Destinations & Persistent Mini-Player
1. **Home Screen**:
   - Audio Pipeline Active status banner with format badge.
   - Poweramp-style library stats (Tracks, Lossless, Artists, Playlists).
   - Recently Played horizontal carousel.
   - Lossless FLAC Master Highlights section with "Play All".
   - Quick Picks track list with "Shuffle" action.
2. **Library Screen**:
   - 5 filterable tabs: Tracks, Lossless FLAC, Albums, Artists, Playlists.
   - Interactive Sort bottom sheet (sort by Title, Artist, Duration, Date Added).
   - Album grid view and Artist list view leading to dedicated detail screens.
   - Custom playlist creation and management.
3. **Search Screen**:
   - Instant search input bar with quick clear button.
   - Format filter chips (`All Tracks`, `FLAC Lossless Only`, `Hi-Res`, `Classical`).
   - Live real-time filtered results.
4. **Now Playing Screen**:
   - Sliding modal presentation with Apple Music dismiss chevron.
   - High-resolution artwork view with ambient primary glow shadow.
   - Synchronized lyrics mode toggle.
   - Audiophile precision seekbar with elapsed and remaining timestamps.
   - Full control cluster: Shuffle, Previous, 72dp Play/Pause pill, Next, Repeat.
   - Bottom actions: Audio output info, Lyrics toggle, Queue sheet.
5. **Settings Screen**:
   - Theme picker: Dark (Obsidian), AMOLED Black, Light (Apple).
   - Accent color picker: Apple Red, Royal Purple, Electric Teal, Amber Gold, Emerald Green.
   - Lossless badges toggle & Gapless playback toggle.
   - Home-screen widget test sync button.
   - Historical Provider configurations: Universal (yt-dlp), Deezer (ARL token), DAB (custom URL).
   - Rescan device media and clear history actions.
6. **Persistent Mini-Player (`MiniPlayer`)**:
   - Floats above the bottom navigation bar across all screens.
   - Displays artwork thumbnail, title, artist, format badge, play/pause, skip next, and an integrated bottom progress bar.
   - Tapping expands the full Now Playing screen.

### 2.6 Reconstructed Online Music & Resumable Downloads (ANAHAD 2.1 Restoration)
- **JioSaavn Online Catalogue**: Full song, album, and artist search, detailed album tracklists, artist discography, recommendations, and high-resolution (500x500) cover art.
- **DES Stream Decryption**: In-memory DES-ECB stream decryption with key `38346591` and automatic mapping to 320kbps CD-quality AAC (`_320.mp4`).
- **YouTube Explode Audio Engine (`youtube_explode_dart`)**: Secondary stream resolution engine providing fallback stream URLs.
- **Resumable Offline Download Manager (`DownloadService`)**: Resumable chunked file downloader with HTTP Range headers, file validation (>50KB), automatic offline `.lrc` lyric storage, and automatic library registration.
- **LRCLIB Live Synchronized Lyrics (`LyricsService`)**: Real-time querying against LRCLIB API with autoscrolling display.
- **Apple Music / Gaana UI Screens**: Dedicated `OnlineAlbumScreen`, `OnlineArtistScreen`, unified `SearchScreen` with genre chips and filter tabs, and a dedicated `Downloaded` tab in `LibraryScreen`.

---

## 3. Technology Stack & Key Dependencies

| Component | Technology / Version | Purpose |
|---|---|---|
| **Framework** | Flutter 3.29.3 / Dart 3.7.2 | Cross-platform UI and reactive state |
| **Audio Playback** | `just_audio: ^0.9.42` | ExoPlayer-backed native audio decoding |
| **Background Service** | `audio_service: ^0.18.17` | MediaSession, lock-screen & notification controls |
| **MediaStore Access** | `on_audio_query: ^2.9.0` | Query local songs, albums, artists & artwork |
| **State Management** | `provider: ^6.1.2` | Clean reactive ChangeNotifier architecture |
| **Storage** | `shared_preferences: ^2.3.4` | Playlists, favorites, history, settings persistence |
| **Permissions** | `permission_handler: ^11.3.1` | Granular Android runtime permission handling |
| **Native Android** | Kotlin 1.9.24 / Gradle 8.9 / AGP 8.7.2 | AppWidgetProvider, MethodChannels, RemoteViews |
| **Target SDK** | Android SDK 35 (compile & target) | Modern Android 15 compatibility |

---

## 4. Documentation Index

The following documentation suite in `docs/` completely specifies ANAHAD:

1. `docs/PROTOTYPE_1_IMPLEMENTATION.md`: This comprehensive implementation report.
2. `docs/ARCHITECTURE.md`: Complete system architecture and pipeline specification.
3. `docs/DESIGN.md`: Full design system documentation (colors, typography, components, Stitch MCP report).
4. `docs/TEST_REPORT.md`: Comprehensive test report covering automated and manual verification.
5. `docs/BUILD_AND_INSTALL.md`: Step-by-step APK build, file transfer, and phone installation guide.
6. `docs/KNOWN_ISSUES.md`: Documented edge cases, limitations, and Prototype 2 roadmap.
7. `docs/FLAC_MUSIC_STORE_ASSESSMENT.md`: FlacMusicStore repository technical and legal audit.
8. `docs/FLAC_API_CONTRACT.md`: FlacMusicStore API endpoints and response contracts.
9. `docs/FLAC_AUDIO_QUALITY_VERIFICATION.md`: Mutagen stream analysis and spectral cutoff test.
10. `docs/MUSIC_SOURCE_LEGAL_ASSESSMENT.md`: Music distribution copyright and licensing audit.
11. `docs/ANAHAD_MUSIC_SOURCE_ARCHITECTURE.md`: Hexagonal music source architecture.
12. `docs/MUSIC_PROVIDER_ARCHITECTURE.md`: Multi-provider architecture (Universal, Deezer, DAB).
13. `docs/UNIVERSAL_PROVIDER.md`: Universal acquisition engine (yt-dlp) specification.
14. `docs/DEEZER_PROVIDER.md`: Deezer acquisition provider (ARL session) specification.
15. `docs/DAB_PROVIDER.md`: DAB acquisition provider specification and endpoint analysis.
16. `docs/DOWNLOAD_MANAGER.md`: Resumable range-download manager architecture.
17. `docs/MUSIC_SOURCE_VERIFICATION.md`: 10-point provider classification and evaluation summary.
