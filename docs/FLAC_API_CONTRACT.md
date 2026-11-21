# ANAHAD: FLAC Music Store API Contract Specification

- **Document Version**: 1.0.0
- **Status**: Complete Contract Specification & Gap Analysis
- **Author**: ANAHAD Senior Engineering Architecture

---

## 1. Overview

This document specifies:
1. **The Current `flacmusicstore` API Contract**: The actual endpoints, headers, payloads, and behaviors reverse-engineered and verified from `Thepathakarpit/flacmusicstore`.
2. **Deficiencies & Breaking Limitations**: Gaps in metadata, error handling, protocol compatibility, and transport ergonomics that prevent reliable Android client integration.
3. **The Proposed ANAHAD Production API Contract (v1)**: A production-grade, versioned REST/streaming contract designed for high-fidelity audio delivery to the ANAHAD Android application.

---

## 2. Existing `flacmusicstore` API Contract (Current As-Is)

### 2.1 Base Configuration
- **Protocol**: HTTP/1.1
- **Default Port**: `5000` (Local) / `https://flacmusicstore-production.up.railway.app` (Production)
- **Authentication**: None (Open / Public)
- **Versioning**: None

---

### 2.2 Endpoint Specifications

#### 1. API Health Check
- **Route**: `GET /api/test`
- **Supported Methods**: `GET`, `OPTIONS`
- **Query Parameters**: None
- **Request Headers**:
  - `Accept: application/json`
- **Response Headers**:
  - `Content-Type: application/json`
  - `Access-Control-Allow-Origin: *`
- **Status Codes**:
  - `200 OK`: Server operational
- **Response Schema**:
```json
{
  "status": "ok",
  "message": "API is running",
  "cors": "enabled",
  "timestamp": "2026-11-14T18:58:05.293452"
}
```

---

#### 2. Search Tracks
- **Route**: `GET /api/search`
- **Supported Methods**: `GET`, `OPTIONS`
- **Query Parameters**:
  - `q` (string, optional): Search query matching substring in track title or artist. If omitted or empty, returns all catalogue records.
- **Request Headers**:
  - `Accept: application/json`
- **Response Headers**:
  - `Content-Type: application/json`
  - `Access-Control-Allow-Origin: *`
- **Status Codes**:
  - `200 OK`: Search executed successfully.
  - `404 Not Found`: Underlying CSV file missing from backend filesystem.
  - `500 Internal Server Error`: Unhandled server exception during pandas dataframe filtering.
- **Response Schema (`200 OK`)**:
```json
[
  {
    "title": "Breathless",
    "artist": "Shankar Mahadevan",
    "album": "Breathless",
    "file_id": "1xeAEboBcO0c_iQBmO97AdUb6eCalT4-A"
  },
  {
    "title": "Cornfield Chase",
    "artist": "Hans Zimmer",
    "album": "Interstellar",
    "file_id": "1BO5eSOhGl6Y_-3ek2Cyzg5RhgOZahJ-C"
  }
]
```
- **Error Schema (`404 Not Found` / `500 Internal Server Error`)**:
```json
{
  "error": "Database file not found",
  "path": "/backend/tracks.csv"
}
```
*(or for 500 exceptions)*:
```json
{
  "error": "Error description string",
  "type": "ExceptionClassName"
}
```

---

#### 3. Audio Streaming Endpoint
- **Route**: `GET /stream/<file_id>`
- **Supported Methods**: `GET`, `HEAD`, `OPTIONS`
- **URL Parameters**:
  - `file_id` (string, required): Google Drive unique file identifier.
- **Request Headers**:
  - `Range: bytes={start}-{end}` (string, optional): Standard byte-range request for seeking and progressive chunk buffering.
- **Response Headers**:
  - `Content-Type: audio/flac` (or derived from filename extension)
  - `Accept-Ranges: bytes`
  - `Content-Length: {length_in_bytes}`
  - `Content-Range: bytes {start}-{end}/{total_length}` (present only on 206 responses)
  - `Cache-Control: no-cache`
- **Status Codes**:
  - `200 OK`: Full audio stream returned (when no `Range` header is passed).
  - `206 Partial Content`: Byte-range stream returned.
  - `400 Bad Request`: Unable to determine file size or confirm download token with Google Drive.
  - `404 Not Found`: File not found on Google Drive.
  - `416 Range Not Satisfiable`: Requested `start` byte exceeds `content_length`.
  - `500 Internal Server Error`: Google Drive transport exception.
- **Payload**: Raw binary audio stream (`direct_passthrough=True` via Flask Response).

---

#### 4. Direct Track Download Endpoint
- **Route**: `GET /api/download/<file_id>`
- **Supported Methods**: `GET`
- **URL Parameters**:
  - `file_id` (string, required): Google Drive unique file identifier.
- **Request Headers**:
  - `Accept: */*`
- **Response Headers**:
  - `Content-Type: audio/flac`
  - `Content-Disposition: attachment; filename="{filename}"`
  - `Content-Length: {file_size}`
- **Status Codes**:
  - `200 OK`: File downloaded and transmitted as an attachment.
  - `400 Bad Request`: Download failed, file missing on Google Drive, or local filesystem path resolution error (`[WinError 3]`).
- **Payload**: Raw binary audio file.

---

## 3. Shortcomings & Flaws in the Current Contract

1. **No API Versioning**: The endpoints sit under unversioned paths (`/api/search`, `/stream/<id>`), preventing non-breaking evolutionary upgrades.
2. **Missing Essential Audio Quality Metadata**:
   - No `sample_rate` (e.g. 44100 Hz, 48000 Hz, 96000 Hz, 192000 Hz).
   - No `bit_depth` (e.g. 16-bit, 24-bit).
   - No `channels` (Mono, Stereo).
   - No `duration_ms` or `duration_seconds`.
   - No `file_size_bytes` in search results.
   - No `bitrate_kbps`.
   The Android player cannot display file sizes before downloading, cannot calculate progress percentages accurately without probing the stream, and cannot display audio resolution badges to the user.
3. **No Cover Art / Artwork URLs**:
   The response lacks artwork metadata. The Android client is unable to render album art or artist avatars in search cards or the player notification.
4. **Lack of Pagination**:
   `/api/search` dumps the full array of matching records. While manageable for an 87-row CSV, any production-sized catalogue (50,000+ tracks) would saturate memory, serialize enormous JSON payloads, and degrade mobile network performance.
5. **No Unique Track ID Scheme**:
   The contract uses Google Drive's opaque `file_id` as the primary key. If the underlying storage provider changes (e.g., migrating to S3, Cloudflare R2, or IPFS), the external contract breaks.
6. **Insecure Error Responses**:
   The current error responses return internal filesystem paths and raw exception class names, creating an information disclosure vulnerability.
7. **No ETag or Resumable Download Validation**:
   The download endpoint does not provide `ETag` or `Last-Modified` validation, making it impossible for Android's `DownloadManager` to safely resume interrupted downloads.

---

## 4. Proposed Production API Contract for ANAHAD (v1)

To support high-performance streaming, robust resumable downloads, and rich visual presentation in ANAHAD, the following contract is specified for ANAHAD's remote music service adapter.

### 4.1 Global Conventions
- **Base URL**: `https://api.anahad.audio/v1`
- **Transport**: HTTPS / TLS 1.3 only
- **Authentication**: Bearer Token / API Key header (`Authorization: Bearer <token>`)
- **Error Standard**: RFC 7807 (Problem Details for HTTP APIs)

---

### 4.2 Endpoint Specifications

#### 1. Search Catalogue
`GET /v1/tracks/search`

##### Query Parameters:
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `q` | string | No | `""` | Search text across title, artist, album |
| `artist` | string | No | `""` | Filter by artist name |
| `album` | string | No | `""` | Filter by album name |
| `genre` | string | No | `""` | Filter by musical genre |
| `min_bit_depth`| integer| No | `16` | Minimum bit depth (16 or 24) |
| `page` | integer| No | `1` | Pagination page number |
| `limit` | integer| No | `25` | Results per page (max 100) |

##### Response (`200 OK`):
```json
{
  "page": 1,
  "limit": 25,
  "total_items": 1,
  "total_pages": 1,
  "items": [
    {
      "id": "trk_01h8x9p3km1",
      "title": "Breathless",
      "artist": {
        "id": "art_01h8x9p2aa1",
        "name": "Shankar Mahadevan"
      },
      "album": {
        "id": "alb_01h8x9p2bb1",
        "name": "Breathless",
        "release_year": 1998,
        "artwork_url": "https://cdn.anahad.audio/covers/alb_01h8x9p2bb1_600x600.jpg"
      },
      "genre": "Indian Pop / Fusion",
      "track_number": 1,
      "disc_number": 1,
      "duration_ms": 185720,
      "audio_profile": {
        "format": "flac",
        "container": "flac",
        "sample_rate_hz": 44100,
        "bit_depth": 16,
        "channels": 2,
        "bitrate_kbps": 1412,
        "file_size_bytes": 33058203,
        "lossless": true,
        "hi_res": false,
        "checksum_md5": "99f2f6b6f7b2ca079685bc70bfc57711"
      },
      "urls": {
        "stream_url": "https://api.anahad.audio/v1/tracks/trk_01h8x9p3km1/stream",
        "download_url": "https://api.anahad.audio/v1/tracks/trk_01h8x9p3km1/download"
      }
    }
  ]
}
```

---

#### 2. Get Track Metadata by ID
`GET /v1/tracks/{track_id}`

##### Response (`200 OK`):
Returns the single track object defined in the search schema above.

##### Response (`404 Not Found`):
```json
{
  "type": "https://anahad.audio/errors/track-not-found",
  "title": "Track Not Found",
  "status": 404,
  "detail": "No track found matching identifier 'trk_invalid'",
  "instance": "/v1/tracks/trk_invalid"
}
```

---

#### 3. High-Fidelity Audio Stream
`GET /v1/tracks/{track_id}/stream`
`HEAD /v1/tracks/{track_id}/stream`

##### Request Headers:
- `Range: bytes={start}-{end}` (optional, for progressive streaming and fast seeking)

##### Response Headers:
- `Content-Type: audio/flac`
- `Accept-Ranges: bytes`
- `Content-Length: {chunk_or_full_length}`
- `Content-Range: bytes {start}-{end}/{total_length}` (on `206 Partial Content`)
- `ETag: "{etag_hash}"`
- `Cache-Control: public, max-age=604800, immutable`

##### Status Codes:
- `200 OK`: Full file stream when no range is requested.
- `206 Partial Content`: Byte range chunk.
- `416 Range Not Satisfiable`: Requested byte range is invalid.

---

#### 4. Resumable Track Download
`GET /v1/tracks/{track_id}/download`

##### Request Headers:
- `Range: bytes={start}-` (optional, for resuming interrupted downloads)

##### Response Headers:
- `Content-Type: audio/flac`
- `Content-Disposition: attachment; filename="{sanitized_filename}.flac"`
- `Accept-Ranges: bytes`
- `Content-Length: {file_size}`
- `ETag: "{etag_hash}"`
- `X-Checksum-MD5: {md5_hash}`
- `X-Checksum-SHA256: {sha256_hash}`

##### Behaviors:
- Fully compatible with Android's system `DownloadManager` and OkHttp download engines.
- Guarantees byte-for-byte fidelity with pre-computed checksum headers for client validation.

---

## 5. Architectural Gap Analysis Table

| Feature / Attribute | Current `flacmusicstore` Contract | Proposed ANAHAD Production Contract | Gap Severity |
|---|---|---|---|
| **API Versioning** | None (`/api/...`) | Explicit (`/v1/...`) | **High** |
| **Search Pagination** | None (entire array returned) | Cursor/Page-based with limit | **High** |
| **Audio Format Metadata** | None | Format, Sample Rate, Bit Depth, Channels, Lossless Flag | **Critical** |
| **Track Duration** | None | `duration_ms` | **Critical** |
| **File Size Information** | Only on download headers | Provided upfront in track schema | **High** |
| **Artwork / Cover Art** | Missing | High-resolution CDN URLs | **High** |
| **Seeking Response Time** | ~7.95 seconds | < 150 milliseconds (CDN Edge) | **Critical** |
| **Resumable Downloads** | Broken (`[WinError 3]`, no ranges) | Native RFC 7233 Range + ETag support | **Critical** |
| **Error Format** | Raw Python exception strings | RFC 7807 Problem Details | **Medium** |
| **Authorization** | None | Bearer token / API key | **High** |
| **Identifier Decoupling** | Google Drive `file_id` | Canonical internal UUID / ULID | **Critical** |
