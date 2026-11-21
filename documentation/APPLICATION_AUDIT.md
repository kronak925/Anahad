# ANAHAD | Complete Application Audit & System Inventory

- **Document Version**: 1.0.0
- **Evaluation Date**: November 2026
- **Auditing Roles**: Senior Android Application Architect, Product Security Engineer, Privacy Specialist, Open-Source Licensing Specialist, QA & Release Engineer
- **Status**: Complete Comprehensive Audit (Phases 1 to 12)

---

## 1. Executive System Summary

ANAHAD is an offline/online hybrid Android audio player application engineered with Flutter (Dart 3.6 / Flutter 3.27) and native Android components (Kotlin, Android AppWidgetProvider, MediaSessionCompat, Foreground Services). It provides local device music playback, lossless audio badge visualization, cloud catalogue streaming/indexing via public search gateways (JioSaavn, YouTube Explode), synchronized LRC lyrics (LRCLIB, JioSaavn), offline file caching/downloads to user-specified directories, and home screen widget synchronization.

The application contains **zero analytics, zero telemetry SDKs, zero ads, and zero user account requirements**.

---

## 2. Comprehensive Inventory

### A. Implemented Features
1. **Local Media Library Discovery & Playback**:
   - Device audio scanning via `on_audio_query` (supporting MP3, AAC, FLAC, WAV, OGG, M4A).
   - Instant playback with `just_audio` and `audio_service`.
   - Track sorting by title, artist, date added, duration.
2. **Audio Engine & Format Badge Detection**:
   - Lossless audio detection (FLAC, ALAC, WAV, Hi-Res 24-bit/96kHz / 192kHz).
   - Visual audio format badges in cyan and gold styling (`FLAC`, `HI-RES LOSSLESS`, `AAC 320K`, `MP3`).
3. **Now Playing Screen & Player Controls**:
   - Full-screen audio player with blurred adaptive artwork background.
   - Seek slider with elapsed time and total duration (tap to toggle remaining time).
   - Play/Pause, Next, Previous, Shuffle, Repeat (Off, One, All).
   - "Air Shuffle" button operating across all screen contexts (offline library, search, language, trending).
   - Quick Add to Playlist modal dialog.
   - In-player direct Download action button.
4. **Online Music Catalogue & Multi-Language Exploration**:
   - JioSaavn search integration (`search.getResults`, `search.getAlbumResults`, `search.getArtistResults`, `content.getAlbumDetails`, `song.getDetails`).
   - Regional Language Tiles on Home Screen: Hindi (हिंदी), English, Punjabi (ਪੰਜਾਬੀ), Telugu (తెలుగు), Tamil (தமிழ்), Marathi (मराठी), Gujarati (ગુજરાતી), Rajasthani (राजस्थानी), Bhojpuri (भोजपुरी), Bengali (বাংলা), Malayalam (മലയാളം), Kannada (ಕನ್ನಡ).
   - Trending songs, featured artists (Arijit Singh, Shreya Ghoshal, Diljit Dosanjh, A.R. Rahman, Pritam, Anirudh Ravichander).
   - Fallback audio stream resolution using YouTube Explode.
5. **Synchronized Karaoke & Plain Lyrics Engine**:
   - LRCLIB API integration (`https://lrclib.net/api/get` and `/api/search`).
   - JioSaavn lyrics fallback (`lyrics.getLyrics`).
   - Real-time timestamp synchronization with auto-scrolling lyrics view.
   - Tap-to-seek playback directly from any lyric line.
6. **Download & Offline Storage Manager**:
   - Background file download via HTTP stream pipe.
   - Parallel download progress and error state handling.
   - User-customizable save destination (`App Storage`, `Device Music /storage/emulated/0/Music/ANAHAD`, `Device Downloads /storage/emulated/0/Download/ANAHAD`, or `Custom Folder`).
7. **Android Native Home Screen Widget**:
   - Custom `AnahadAppWidgetProvider` in Kotlin.
   - Bidirectional MethodChannel sync (`com.anahad.audio/widget`).
   - Real-time artwork display, track title, artist, lyrics snippet, play/pause toggle.
8. **Lock Screen & Background Audio**:
   - Background audio playback handled via `AudioService` (MediaBrowserService, MediaSessionCompat).
   - Lock screen media controls with transport actions and artwork.
   - "Becoming Noisy" receiver for headphone unplug pause.
9. **Theming & UI Customization**:
   - Dark (Obsidian #071217), AMOLED Pure Black (#000000), and Light (Apple-inspired) themes.
   - Dynamic accent color palette (Cyan, Emerald, Amber, Rose, Purple, Blue).
10. **Backup & Restore System**:
    - JSON export and import of user playlists, favorites, and settings.
    - Clipboard and direct file payload support.

### B. Partially Implemented Features
1. **DSP / Hardware Equalizer**:
   - Equalizer settings UI with 10 presets (Flat, Bass Boost, Treble Boost, Vocal, Electronic, Rock, Jazz, Classical, Acoustic, Hip-Hop).
   - Presets persist in `SharedPreferences`. Native DSP equalizer linkage relies on platform audio session effects.
2. **Lock Screen Lyrics Overlay**:
   - Lyrics display works within full-screen app and on widget; native Android system lock-screens (Android 11+) restrict custom view overlays in favor of standard MediaStyle notifications.

### C. Planned / Architectural Candidate Features (In Documentation Only)
1. **Universal Go/yt-dlp Acquisition Provider**:
   - Researched and documented in `docs/UNIVERSAL_PROVIDER.md`; candidate for future desktop/daemon build, not compiled in mobile client.
2. **Deezer ARL & DAB Native Acquisition Providers**:
   - Documented in `docs/DEEZER_PROVIDER.md` and `docs/DAB_PROVIDER.md`; configuration keys present in settings, external proprietary engines deferred.

### D. Third-Party Services & Dependencies
- `just_audio` (0.9.42): Core audio playback engine (Apache 2.0).
- `audio_service` (0.18.17): Background media service and notifications (MIT).
- `on_audio_query` (2.9.0): Local Android MediaStore query (BSD-3-Clause).
- `permission_handler` (11.3.1): Android runtime permissions (MIT).
- `shared_preferences` (2.3.4): Key-value persistent storage (BSD-3-Clause).
- `path_provider` (2.1.5): Local filesystem directory paths (BSD-3-Clause).
- `provider` (6.1.2): Reactive state management (MIT).
- `http` (1.6.0): HTTP client for REST requests (BSD-3-Clause).
- `youtube_explode_dart` (3.1.0): Headless YouTube audio stream resolver (MIT).
- `dart_des` (1.0.2): DES encryption/decryption algorithm (MIT).
- `intl` (0.19.0): Formatting and date utilities (BSD-3-Clause).
- `crypto` (3.0.6): Hashing utilities (BSD-3-Clause).
- `LRCLIB API`: Community lyrics provider (`lrclib.net`).
- `JioSaavn Gateway`: Public search and metadata endpoint (`saavn.me` / `jiosaavn.com`).

### E. Data Collected, Processed, Stored, or Transmitted
- *Full inventory documented in `documentation/privacy/DATA_INVENTORY.md`.*
- No personal user data, device identifiers, location, or credentials collected or transmitted.

### F. Android Permissions
- `android.permission.INTERNET`: Required for streaming, downloading online audio, lyrics, and artwork.
- `android.permission.WAKE_LOCK`: Required to keep audio playback smooth when screen turns off.
- `android.permission.FOREGROUND_SERVICE`: Required for background playback service.
- `android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK`: Required on Android 14+ (API 34) for foreground media playback.
- `android.permission.READ_EXTERNAL_STORAGE` (`android:maxSdkVersion="32"`): Required on Android 12 and below for scanning device music files.
- `android.permission.READ_MEDIA_AUDIO`: Required on Android 13+ (API 33) for scanning device music files.
- `android.permission.POST_NOTIFICATIONS`: Required on Android 13+ for persistent media playback notification controls.

### G. Copyright and Intellectual Property Considerations
- Application contains original Dart and Kotlin source code and original vector branding (`anahad_logo.png`, `AnahadBrandIcon`).
- Client-side music indexing/acquisition features must be accompanied by explicit terms stating the user is solely responsible for having legal rights to any content accessed or downloaded.
- No copyrighted songs, master recordings, or commercial media files are bundled in the repository or APK.

### H. Security Vulnerabilities
- No hardcoded secret API keys or private tokens.
- DES key `38346591` is the public CDN decryptor constant historically used in JioSaavn client-side applications.
- Android exported components: `MainActivity`, `AudioService`, `MediaButtonReceiver`, and `AnahadAppWidgetProvider` have explicit `android:exported="true"` with necessary intent filters as mandated by Android 12+.

### I. Missing Documentation (Resolved in this Release)
- Initial release lacked structured `/legal/` directory and comprehensive `/documentation/` guides. All created during this preparation cycle.

### J. Existing Technical Debt
- Offline tests for online services require mocked HTTP responses when executed in sandboxed/network-isolated environments.
- Native equalizer visualizer curves in `SettingsScreen` are currently simulated UI controls pending native AudioEffect NDK binding.

---

## 3. Prioritised Audit Findings Matrix

| Finding ID | Classification | Component | Description | Remediation | Status |
|---|---|---|---|---|---|
| **SEC-01** | `HIGH` | Legal & Compliance | Lack of formalized Terms of Service, Privacy Policy, and Copyright Disclaimers prior to public GitHub release. | Author comprehensive `/legal/` documents and integrate into in-app settings. | **RESOLVED** |
| **SEC-02** | `HIGH` | Privacy & Compliance | DPDP Act 2023 & Indian IT Act compliance verification required for public release. | Conduct legal review, draft Data Inventory, establish local-first data processing statement. | **RESOLVED** |
| **SEC-03** | `MEDIUM` | In-App Integration | In-app settings lacked accessible legal and privacy navigation viewable offline. | Implement `Settings -> About ANAHAD -> Legal & Privacy` screen with offline bundled text. | **RESOLVED** |
| **SEC-04** | `MEDIUM` | Repository Sanitization | Ensure `.gitignore` cleanly excludes build artifacts, keystores, `.dartServer`, and local caches. | Update `.gitignore` and audit repository tracking. | **RESOLVED** |
| **SEC-05** | `LOW` | Release Configuration | Release signing configuration uses debug keystore for development APK. | Maintain debug signature for easy installation by test users; document production keystore workflow. | **DOCUMENTED** |
| **SEC-06** | `LOW` | Documentation | Lack of technical architecture, build, and contribution guides for open-source contributors. | Author 10 standard guides in `/documentation/` and complete `README.md`. | **RESOLVED** |
