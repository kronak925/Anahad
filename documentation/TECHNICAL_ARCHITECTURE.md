# ANAHAD | Technical Architecture & System Design

- **Architecture Pattern**: Provider-based Reactive MVVM with Service Layer Isolation
- **Runtime Environment**: Flutter Framework (Dart) + Native Android Subsystem (Kotlin)
- **Audio Decoding**: ExoPlayer via `just_audio`

---

## 1. Architectural Overview

```mermaid
graph TD
    subgraph UI_Layer["UI Layer (Widgets & Screens)"]
        HomeScreen[HomeScreen]
        SearchScreen[SearchScreen]
        LibraryScreen[LibraryScreen]
        NowPlayingScreen[NowPlayingScreen]
        SettingsScreen[SettingsScreen]
        LegalPrivacyScreen[LegalPrivacyScreen]
    end

    subgraph State_Layer["State Management (ChangeNotifier Providers)"]
        PlaybackNotifier[PlaybackNotifier]
        LibraryNotifier[LibraryNotifier]
        CatalogNotifier[OnlineCatalogueNotifier]
        SettingsNotifier[SettingsNotifier]
        ThemeNotifier[ThemeNotifier]
    end

    subgraph Service_Layer["Service Layer (Business Logic & Hardware IO)"]
        AudioHandler[AnahadAudioHandler: BaseAudioHandler]
        MediaLibService[MediaLibraryService: on_audio_query]
        JioSaavnService[JioSaavnService: REST Gateway]
        StreamResolver[StreamResolver: YouTube Explode]
        LyricsService[LyricsService: LRCLIB]
        DownloadService[DownloadService: HTTP Pipe]
        StorageService[StorageService: SharedPreferences]
        WidgetSyncService[WidgetSyncService: MethodChannel]
    end

    subgraph Native_Layer["Android Native Subsystem"]
        ExoPlayer[ExoPlayer / MediaSessionCompat]
        WidgetProvider[AnahadAppWidgetProvider: Kotlin RemoteViews]
        AndroidFS[Android Storage: /storage/emulated/0]
    end

    UI_Layer --> State_Layer
    State_Layer --> Service_Layer
    AudioHandler --> ExoPlayer
    WidgetSyncService --> WidgetProvider
    DownloadService --> AndroidFS
    MediaLibService --> AndroidFS
```

---

## 2. Core Subsystems

### 2.1 Audio Playback Subsystem
- `AnahadAudioHandler`: Extends `audio_service.BaseAudioHandler`. Exposes streams for `playbackState`, `mediaItem`, and `queue`. Interacts with Android's system `MediaBrowserService` and `MediaSessionCompat`.
- `just_audio.AudioPlayer`: Manages audio decoding, buffering, loop modes, volume, and playback state machine transitions.
- Stream Resolution: Resolves playback URLs dynamically. If primary CDN URLs fail or expire, `StreamResolver` transparently activates YouTube Explode fallback to maintain uninterrupted playback.

### 2.2 Storage & Persistence Subsystem
- `StorageService`: Centralized manager for persistent keys using `SharedPreferences`. Stores playlists, favorites, download destination paths, search queries, and audio engine preferences.
- JSON Serialization: Playlists and favorites serialize cleanly into structured JSON dictionaries, facilitating zero-loss backup export and import.

### 2.3 Widget Synchronization Subsystem
- `WidgetSyncService`: Communicates across Flutter-to-Android boundary via `MethodChannel('com.anahad.audio/widget')`.
- Downsamples remote album art to <= 128px before transmitting to `AnahadAppWidgetProvider` to prevent Android `TransactionTooLargeException` in `RemoteViews`.
