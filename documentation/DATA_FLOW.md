# ANAHAD | Data Flow Architecture

This document describes the flow of data through ANAHAD across local storage, playback, and network operations.

---

## 1. Local Music Playback Data Flow

```mermaid
sequenceDiagram
    participant User
    participant LibraryScreen
    participant MediaLibService
    participant AndroidMediaStore
    participant PlaybackNotifier
    participant AudioHandler
    participant ExoPlayer

    User->>LibraryScreen: Open Library tab
    LibraryScreen->>MediaLibService: queryLocalTracks()
    MediaLibService->>AndroidMediaStore: ContentResolver query (audio/*)
    AndroidMediaStore-->>MediaLibService: Returns Cursor (Title, Artist, Duration, URI)
    MediaLibService-->>LibraryScreen: Returns List<TrackModel>
    User->>LibraryScreen: Tap Track
    LibraryScreen->>PlaybackNotifier: playTrack(track)
    PlaybackNotifier->>AudioHandler: playMediaItem(mediaItem)
    AudioHandler->>ExoPlayer: setAudioSource(ProgressiveAudioSource)
    ExoPlayer-->>AudioHandler: playbackState = playing
    AudioHandler-->>PlaybackNotifier: Stream update
    PlaybackNotifier-->>User: UI updates (MiniPlayer & NowPlaying)
```

---

## 2. Online Search & Streaming Data Flow

```mermaid
sequenceDiagram
    participant User
    participant SearchScreen
    participant CatalogService
    participant JioSaavnAPI
    participant StreamResolver
    participant Downloader
    participant LocalStorage

    User->>SearchScreen: Enter Query ("Kesariya")
    SearchScreen->>CatalogService: search(query)
    CatalogService->>JioSaavnAPI: HTTPS GET (search.getResults)
    JioSaavnAPI-->>CatalogService: JSON (Tracks, Artists, Encrypted Media URLs)
    CatalogService-->>SearchScreen: Display Results
    User->>SearchScreen: Tap Download
    SearchScreen->>Downloader: downloadTrack(track)
    Downloader->>StreamResolver: resolveStreamUrl(track)
    StreamResolver-->>Downloader: CDN Direct Audio URL
    Downloader->>LocalStorage: Pipe Byte Stream to File (/Music/ANAHAD/track.flac)
    Downloader-->>User: Notification: Download Complete
```

---

## 3. Synchronized Lyrics Retrieval Flow

1. When a track begins playback, `PlaybackNotifier._loadLyricsForCurrentItem` triggers.
2. `LyricsService` sanitizes title and artist strings (stripping parenthetical movie credits or remastered tags).
3. First checks local device storage for a matching `.lrc` file in the download directory.
4. If missing locally, issues an HTTPS GET request to LRCLIB (`https://lrclib.net/api/get`).
5. If LRCLIB returns 404, issues a secondary search query to LRCLIB (`/api/search`).
6. If still unverified, falls back to JioSaavn lyric endpoint (`lyrics.getLyrics`).
7. Parses raw text into `List<LyricsLine>` with millisecond timestamps and notifies the UI.
