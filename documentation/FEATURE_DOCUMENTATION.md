# ANAHAD | Complete Feature Documentation

This document describes each functional module, screen, and capability in ANAHAD.

---

## 1. Home Screen (Discovery & Exploration)

- **Language Selector Carousels**: 12 regional language tiles displaying native typography, dual-color gradients, and pre-filtered discovery queries (Hindi, English, Punjabi, Telugu, Tamil, Marathi, Gujarati, Rajasthani, Bhojpuri, Bengali, Malayalam, Kannada).
- **Trending Tracks**: Displays trending songs with album covers, artist labels, and playback format tags.
- **Featured Artists**: Quick-access circles for top artists (Arijit Singh, Shreya Ghoshal, A.R. Rahman, Diljit Dosanjh, Pritam, Anirudh). Tapping an artist opens their dedicated discography screen.
- **Global Air Shuffle**: Prominent floating or header pill button triggering a shuffle queue dynamically tailored to the currently active language or trending view.

---

## 2. Search Screen (Online & Local)

- **Search Bar**: Debounced text search querying songs, albums, and artists simultaneously.
- **Recent Search History**: Persisted list of user queries stored locally in `SharedPreferences`. Allows one-tap re-querying or clearing individual entries.
- **Contextual Results**: Distinct tabbed or sectioned view for songs, albums, and artists with immediate play buttons.

---

## 3. Library Screen (Local & Saved Collections)

- **Device Library Scanner**: Scans internal and SD card storage for audio files using Android MediaStore APIs. Supports sorting by title, artist, duration, and date added.
- **Playlists Manager**: User-created playlists with custom names, creation timestamps, and reorderable track lists.
- **Favorites**: Instant one-tap heart toggle on any track, accumulating a dedicated quick-playback playlist.
- **Downloaded Media**: Dedicated offline tab showing files downloaded through ANAHAD's download engine.

---

## 4. Now Playing Screen (Audiophile Player)

- **Dynamic Background**: Real-time blurred artwork background computed using Flutter image filters.
- **Lossless Format Badges**: Prominent badge displaying audio format and resolution metrics (e.g. `HI-RES LOSSLESS • 24B/96.0kHz` in cyan).
- **Time Scrub Bar**: Custom slider showing elapsed time and total duration. Tapping the total duration toggles between total track duration and remaining countdown time.
- **Transport Controls**: Play/Pause, Next, Previous, Repeat mode (Off / All / One), and Shuffle toggle.
- **Quick Actions**: Direct Add to Playlist button, in-player Download button, and Lyrics view toggle.

---

## 5. Synchronized Lyrics Engine

- **Timestamped LRC Support**: Parses standard `[mm:ss.xx]` timestamped lyrics.
- **Active Line Tracking**: Binary search indexer highlighting the current lyric line in real-time as playback advances.
- **Interactive Seek**: Tapping any lyric line automatically seeks audio playback to that exact timestamp.
- **Dual Source Providers**: Queries LRCLIB community database with automatic fallback to JioSaavn lyric APIs.

---

## 6. Download Manager & Storage Customization

- **Parallel Stream Downloader**: Downloads audio streams directly to local storage with real-time percentage progress.
- **Lyrics Auto-Bundling**: Automatically downloads matching `.lrc` file alongside the audio file for permanent offline lyric availability.
- **Storage Location Customizer**: Select between Internal App Storage (`/downloads`), Device Music (`/storage/emulated/0/Music/ANAHAD`), Device Downloads (`/storage/emulated/0/Download/ANAHAD`), or any custom filesystem directory.

---

## 7. Android Home Screen Widget

- **Native AppWidget**: Compact 4x1 and 4x2 widget for Android home screens.
- **Real-Time Synchronisation**: Displays current playing track title, artist, live artwork bitmap, and current lyric line.
- **Interactive Controls**: Transport buttons (Play/Pause, Next, Previous) with instant broadcast receiver execution.
