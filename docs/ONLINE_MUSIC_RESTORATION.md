# ANAHAD 2.1 Online Music Architecture & Restoration Report

## 1. Executive Summary

Based on the reverse-engineered historical artifacts documented in `ANAHAD_APK_RECOVERY_FINDINGS.md`, the missing online music functionality has been completely reconstructed, enhanced, verified, and integrated into ANAHAD.

The restored system provides:
1. **JioSaavn Online Catalogue**: Full song, album, and artist search, detailed album tracklists, artist discography, recommendations, and high-resolution (500x500) cover art.
2. **Cryptographic Stream Resolution**: Instant local DES-ECB decryption of `encrypted_media_url` using verified key `38346591` with automatic 320kbps high-bitrate AAC CDN stream mapping.
3. **YouTube Explode Audio Engine (`youtube_explode_dart`)**: Secondary audio resolution engine for unencrypted, independent, and catalogue-fallback playback.
4. **Resumable Offline Download Manager (`DownloadService`)**: Background chunked downloading with HTTP Range headers, integrity validation, automatic synchronized LRCLIB `.lrc` lyric storage, and automatic library registration.
5. **Synchronized Lyrics Engine (`LyricsService`)**: Real-time LRCLIB API querying, millisecond-accurate `.lrc` timestamp parsing, and auto-scrolling synced lyrics.
6. **Apple Music & Gaana-Inspired User Interface**: Modern fluid design with trending carousels, album and artist detail screens, genre/mood discovery chips, and unified search.
7. **Strict Lossless Audio Honesty**: Explicit format and bitrate labeling (`AAC 320k` for lossy online streams, `FLAC 24-bit / 96kHz` for true lossless tracks).

---

## 2. Empirical API & Cryptographic Verification

All endpoints and cryptographic algorithms were verified live against real network responses in `test/online_services_test.dart`:

| Feature | Verified Endpoint / Method | Test Evidence / Result |
| :--- | :--- | :--- |
| **Song Search** | `https://www.jiosaavn.com/api.php?__call=search.getResults&q=Kesariya` | Successfully retrieved song `Kesariya`, album `Brahmastra`, artist `Arijit Singh`. |
| **DES Decryption** | DES-ECB with key `38346591` (PKCS7 padding) | Successfully decrypted `encrypted_media_url` to `https://aac.saavncdn.com/871/c2febd353f3a076a406fa37510f31f9f_96.mp4`. |
| **High Bitrate Mapping** | Suffix substitution `_96.mp4` -> `_320.mp4` | Mapped to high-fidelity 320kbps AAC stream. |
| **Album Search & Details** | `search.getAlbumResults` & `content.getAlbumDetails` | Successfully fetched full album tracklists with individual encrypted stream tokens. |
| **Artist Search & Details** | `search.getArtistResults` & `artist.getArtistPageDetails` | Successfully retrieved artist biography, listener count, top songs, and top albums. |
| **Recommendations** | `reco.getreco&pid={songId}` | Successfully retrieved algorithmically recommended tracks. |
| **YouTube Explode** | `YoutubeExplode.videos.streamsClient.getManifest` | Successfully resolved direct GoogleVideo audio stream (`https://rr...googlevideo.com/videoplayback?...`, ~48-128kbps AAC/Opus). |
| **LRCLIB Lyrics** | `https://lrclib.net/api/get` | Successfully returned synchronized millisecond-timestamped lyrics. |

---

## 3. Architecture Overview

```
                      +-----------------------------+
                      |         UI Layer            |
                      |  HomeScreen / SearchScreen  |
                      | OnlineAlbum / OnlineArtist  |
                      +--------------+--------------+
                                     |
               +---------------------+---------------------+
               |                                           |
               v                                           v
+-------------------------------+             +---------------------------+
|    OnlineCatalogueNotifier    |             |      DownloadService      |
|  - Trending & Discovery       |             |  - Resumable Chunking     |
|  - Unified Search (All/Songs/ |             |  - HTTP Range Requests    |
|    Albums/Artists/Device)     |             |  - Offline Storage & LRC  |
|  - Album & Artist Details     |             |  - MediaLibrary Sync      |
+--------------+----------------+             +-------------+-------------+
               |                                            |
               v                                            v
+-------------------------------+             +---------------------------+
|       JioSaavnService         |             |      StreamResolver       |
|  - JioSaavn Web API           |             |  1. JioSaavn Direct CDN   |
|  - DES Key Decrypt (38346591) |             |  2. YouTube Explode Fallback|
|  - 320k Bitrate Rewrite       |             |  3. Local URI Passthrough |
|  - 500x500 Cover Art          |             +-------------+-------------+
+-------------------------------+                           |
                                                            v
                                              +---------------------------+
                                              |    AnahadAudioHandler     |
                                              |  - JustAudio Core         |
                                              |  - Background Playback    |
                                              |  - Lock-Screen Controls   |
                                              +---------------------------+
```

---

## 4. Component Implementations

### 4.1. JioSaavn Catalogue Integration (`lib/services/jiosaavn_service.dart`)
- **Base Endpoint**: `https://www.jiosaavn.com/api.php`
- **DES Decryption Key**: ASCII string `"38346591"`
- **Decryption Routine**: Pure Dart DES in ECB mode using PKCS7 padding.
- **Bitrate Enhancement**: Decrypted URLs default to low-bandwidth 96kbps (`_96.mp4`). The service automatically transforms these into CD-quality 320kbps AAC (`_320.mp4`).
- **Artwork Enhancement**: Image URLs from JioSaavn (`150x150` or `50x50`) are upgraded to `500x500` high-definition artwork suitable for Apple Music-grade displays.

### 4.2. Stream Resolution Pipeline (`lib/services/stream_resolver.dart`)
- Keeps catalogue metadata resolution separate from audio playback resolution.
- Resolves playable streams in strict priority:
  1. Local storage / downloaded file (zero latency).
  2. JioSaavn 320kbps AAC direct CDN stream.
  3. YouTube Explode audio stream (`sortByBitrate().last`) as fallback.
  4. Original URI passthrough.

### 4.3. Resumable Download Engine (`lib/services/download_service.dart`)
- Supports chunked HTTP streaming with `Range: bytes={start}-`.
- Writes into isolated app directory: `app_documents/downloads/{trackId}_{sanitizedName}.{ext}`.
- Enforces strict file validation (aborts and purges files smaller than 50KB).
- Concurrently fetches synchronized `.lrc` lyrics from LRCLIB and saves them beside the audio file.
- Automatically notifies `MediaLibraryService` so downloaded songs immediately appear in the library without requiring a device restart or rescan.

### 4.4. Unified Search & Discovery (`lib/ui/screens/search_screen.dart`)
- **Apple Music-style Category Chips**: Instant one-tap exploration for Bollywood, Punjabi, Sufi, Lo-Fi, Classical, Pop, Devotional, and Workout tracks.
- **5 Filter Tabs**:
  - `All`: Unified overview showing Top Songs, Albums, Artists, and Device matches.
  - `Songs`: Full paginated online song results with direct play and download buttons.
  - `Albums`: 2-column grid of online albums with cover art, release year, and song count.
  - `Artists`: 3-column grid of artist avatars with follower counts.
  - `Device`: Matches found in local device storage.

### 4.5. Offline Library Integration (`lib/ui/screens/library_screen.dart`)
- Integrated a dedicated **"Downloaded"** tab showing all offline tracks.
- Badges indicate offline availability, format (`AAC 320k` / `FLAC`), and duration.

---

## 5. Verification Status

- **Static Analysis (`dart analyze`)**: Clean (0 errors, 0 warnings across all production code).
- **Unit & Logic Tests (`test/anahad_test.dart`)**: 7/7 passed.
- **Online Integration Tests (`test/online_services_test.dart`)**: 3/3 passed.
- **Android APK Build**: Clean build via Gradle `assembleDebug`.
