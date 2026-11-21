# ANAHAD Design System & UI/UX Specification

## 1. Executive Summary & Design Philosophy

ANAHAD Prototype 1 delivers a premium music listening experience inspired by three distinct design and engineering philosophies:

1. **Apple Music (Visual Polish & Hierarchy)**:
   - Elevated layered surfaces, clean typography, large rounded artwork presentations, ambient drop shadows, and an intuitive sliding modal Now Playing screen.
2. **Gaana (Browsing & Discovery Ergonomics)**:
   - Fluid tabbed navigation across Tracks, Lossless audio, Albums, Artists, and Playlists; quick picks and instant horizontal carousels.
3. **Poweramp (Audiophile Rigor & Customization)**:
   - Uncompromising technical transparency: visual lossless format badges (`FLAC 24-BIT / 96kHz`, `LOSSLESS FLAC`, `AAC 256k`), detailed track audio specifications dialog, real-time audio pipeline status card, gapless playback, and high-precision scrub controls.

---

## 2. Google Stitch MCP Assessment & Execution Strategy

In accordance with Section 4 of the product directive, Google Stitch MCP was evaluated for UI design system generation:

- **Verification**: Stitch MCP connection was tested via MCP tools (`list_screens`, `list_projects`, `create_project`).
- **Status Finding**: While `list_projects` completed, `create_project` returned `{"text": "The service is currently unavailable.", "isError": true}` (HTTP 503).
- **Execution Decision**: Per the engineering fallback rule ("If Stitch is unavailable, use your best Flutter UI capabilities and document the limitation. Do not pretend Stitch was used"), ANAHAD's complete design system and component architecture were engineered natively in Flutter using Material 3 with custom surface layering, responsive typography, and fluid micro-animations.

---

## 3. Color System & Palettes

ANAHAD supports three distinct surface modes with dynamic user-selectable accent colors:

### 3.1 Dark Mode (Obsidian — Default)
- **Scaffold Background**: `#0B0E14` (Deep Midnight Obsidian)
- **Elevated Card Surface**: `#151B26` (Subtle blue-slate elevation)
- **High Surface**: `#1E2638` (Active modal headers & search inputs)
- **Border & Dividers**: `#2A3447` (0.8dp crisp separation)
- **Text Primary**: `#F8FAFC` (100% white-slate legibility)
- **Text Secondary**: `#94A3B8` (Soft slate for artists and albums)
- **Text Muted**: `#64748B` (Timestamps and badges)

### 3.2 AMOLED Pitch Black Mode
- **Scaffold Background**: `#000000` (Pure true black for OLED power savings)
- **Elevated Card Surface**: `#101014`
- **High Surface**: `#18181F`
- **Border**: `#272730`

### 3.3 Light Mode (Apple Studio)
- **Scaffold Background**: `#F8F9FA` (Clean frosted white)
- **Surface**: `#FFFFFF` (Pure white cards)
- **Border**: `#E2E8F0`
- **Text Primary**: `#0F172A`
- **Text Secondary**: `#64748B`

### 3.4 Dynamic Accent Palettes
Users can dynamically switch accent colors in Settings with zero restart:
- **Apple Crimson Red (Default)**: `#FA233B`
- **Royal Purple**: `#8B5CF6`
- **Electric Teal / Cyan**: `#06B6D4`
- **Amber Gold**: `#F59E0B`
- **Emerald Green**: `#10B981`
- **Vibrant Pink**: `#EC4899`

---

## 4. Typography Hierarchy

| Style Role | Font Weight | Size (sp) | Tracking | Usage |
|---|---|---|---|---|
| **Display Header** | Black / 900 | 28 | -0.5 | Main Home header ("ANAHAD") |
| **Headline Large** | Bold / 700 | 22 | -0.4 | Now Playing track title, screen titles |
| **Title Medium** | SemiBold / 600 | 16 | -0.2 | Section headers, card titles |
| **Body Primary** | Medium / 500 | 15 | 0.0 | Track list titles, menu items |
| **Body Secondary** | Regular / 400 | 13 | 0.0 | Artist name, album name |
| **Caption / Timestamp**| Medium / 500 | 12 | 0.2 | Elapsed/remaining playback times |
| **Format Badge** | Bold / 700 | 9 - 10 | 0.4 | `FLAC`, `HI-RES LOSSLESS`, `AAC` pills |
| **Karaoke Lyrics** | Bold / 700 | 22 | -0.3 | Active synchronized LRC lyric line |

---

## 5. Core Component Architecture

### 5.1 Persistent Mini-Player (`MiniPlayer`)
- **Positioning**: Floats persistently above the bottom navigation bar across all screens (except when the Now Playing screen is fullscreen).
- **Geometry**: 16dp rounded card, subtle border (`#2A3447`), elevated drop shadow.
- **Micro-Indicators**:
  - 44x44dp album art thumbnail with smooth fallback icon.
  - Track title with text overflow ellipsis.
  - Compact format badge (`FLAC` or `MP3`).
  - Tactile Play/Pause and Skip Next buttons.
  - Integrated 2.5dp bottom progress bar tracking exact playback position.
- **Interaction**: Tap anywhere on the card to smoothly slide open the full Now Playing screen.

### 5.2 Flagship Now Playing Screen (`NowPlayingScreen`)
- **Navigation**: Apple Music-style downward dismiss chevron (`Icons.keyboard_arrow_down_rounded`).
- **Artwork Container**:
  - High-resolution square artwork with 24dp rounded corners.
  - Primary-accent ambient glow shadow (`blurRadius: 36, alpha: 0.25`).
- **Dual Presentation Modes**:
  1. **Artwork Mode**: Center visual showcase of album art and track metadata.
  2. **Lyrics Mode**: Replaces artwork with the real-time karaoke `LyricsView`.
- **Audiophile Slider**:
  - 4dp track height with 6dp circular thumb.
  - Active scrub state with live drag timestamp feedback.
  - Elapsed and remaining time displays (`mm:ss` / `-mm:ss`).
- **Primary Control Cluster**:
  - Shuffle toggle with active highlight.
  - Skip previous track / restart track.
  - 72x72dp circular Play/Pause button with drop shadow.
  - Skip next track.
  - Repeat mode toggle cycling Off -> All -> One with custom badges.
- **Action Bar**:
  - Audio Engine info pill (`ANAHAD Audio Engine`).
  - Synchronized Lyrics modal toggle button.
  - Playing Queue modal sheet button.

### 5.3 Synchronized Karaoke Lyrics (`LyricsView`)
- Real-time millisecond timestamp tracking against `playback.positionStream`.
- Dynamic visual hierarchy:
  - **Active Line**: 22sp bold, full opacity accent/primary color, 1.35 line height.
  - **Inactive Lines**: 17sp medium, 35% opacity text color.
- Smooth auto-scroll keeping the active lyric centered in the viewport.
- **Tap-to-Seek**: Tapping any lyrics line immediately seeks the playback engine to that exact timestamp.

### 5.4 Track Tile (`TrackTile`)
- Compact list row with 48x48dp album artwork (backed by `on_audio_query.QueryArtworkWidget`).
- Title, artist, duration, format badge, and favorite toggle heart.
- Popup menu providing "Play next" and "Add to playlist" actions.
- Active playing indicator: subtle primary background tint (`alpha: 0.08`) and colored title.

### 5.5 Native Android Home-Screen Widget (`widget_now_playing.xml`)
- Glassmorphic dark card (`#F2141923`) with 18dp rounded corners.
- Live track title, artist name, and format badge.
- Interactive Previous, Play/Pause, and Next buttons wired via `PendingIntent` broadcasts directly to the playback engine.
- Clicking the widget opens ANAHAD immediately.
