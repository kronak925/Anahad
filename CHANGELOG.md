# Changelog

All notable changes to the **ANAHAD** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-11-19

### Added
- **Core Playback Architecture**:
  - Offline local media scanning with `on_audio_query` across standard storage directories.
  - High-performance playback engine powered by `just_audio` and `audio_service`.
  - Background audio playback lifecycle with persistent Android notification controls.
  - Headphone disconnection detection ("Becoming Noisy") with automatic pause.
- **Visual Design & Audio Fidelity**:
  - Real-time lossless audio detection (FLAC, ALAC, WAV, 24-bit/96kHz / 192kHz).
  - Poweramp-inspired Hi-Res Lossless cyan badges and compact format pills.
  - Adaptive blurred artwork background on Now Playing screen.
  - Tap-to-toggle remaining/elapsed playback duration on seekbar.
- **Online Music Catalogue & Discovery**:
  - JioSaavn search integration for songs, albums, and artist exploration.
  - YouTube Explode fallback audio stream resolver.
  - Regional language discovery tiles: Hindi, English, Punjabi, Telugu, Tamil, Marathi, Gujarati, Rajasthani, Bhojpuri, Bengali, Malayalam, Kannada.
  - Global "Air Shuffle" button providing contextual playback across library, search, and language views.
- **Synchronized Lyrics Engine**:
  - Real-time timestamped LRC parsing via LRCLIB and JioSaavn fallback.
  - Auto-scrolling karaoke view with active line highlighting.
  - Direct seek-to-timestamp upon tapping any lyric line.
- **Offline Download Manager**:
  - Parallel background file downloading for offline playback.
  - User-configurable save directory: App Storage, Device Music (`/Music/ANAHAD`), Device Downloads (`/Download/ANAHAD`), or Custom Path.
  - Automatic download and local bundling of `.lrc` lyrics files.
- **Native Android Widget**:
  - Custom `AnahadAppWidgetProvider` in Kotlin.
  - Bidirectional MethodChannel synchronization for real-time track metadata and artwork.
- **Trust, Security & Legal**:
  - In-app `Settings → About ANAHAD → Legal & Privacy` hub with offline bundled documentation.
  - Complete legal suite: Terms of Service, Privacy Policy, Disclaimer, Copyright Policy, and Third-Party Notices.
  - Zero-telemetry architecture adhering to India's DPDP Act 2023 and GDPR principles.
- **Backup & Restore**:
  - Complete JSON export and import for user playlists, favorites, and settings.
