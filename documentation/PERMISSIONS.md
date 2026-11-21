# ANAHAD | Android Permissions Specification

This document details all Android permissions requested by ANAHAD, their scope, runtime handling, and user privacy protections.

---

## 1. Permissions Matrix

| Permission Name | Constant | Max SDK | Protection Level | Runtime Prompt? | Required For |
|---|---|---|---|---|---|
| **Internet Access** | `android.permission.INTERNET` | None | Normal | No | Streaming audio, searching public gateways, fetching lyrics and artwork. |
| **Wake Lock** | `android.permission.WAKE_LOCK` | None | Normal | No | Keeping CPU awake during playback with screen off. |
| **Foreground Service** | `android.permission.FOREGROUND_SERVICE` | None | Normal | No | Continuous audio playback service. |
| **Media Playback Type** | `android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK` | None | Normal (API 34+) | No | Explicit Android 14 media playback service classification. |
| **Read Audio Files** | `android.permission.READ_MEDIA_AUDIO` | None | Dangerous (API 33+) | **YES** | Reading local music files on Android 13+. |
| **Read External Storage** | `android.permission.READ_EXTERNAL_STORAGE` | 32 | Dangerous (<= API 32) | **YES** | Reading local music files on Android 12 and below. |
| **Post Notifications** | `android.permission.POST_NOTIFICATIONS` | None | Dangerous (API 33+) | **YES** | Displaying media playback controls in notification drawer. |

---

## 2. Dynamic Runtime Request Workflow

ANAHAD follows modern Android runtime permission best practices:
1. **Deferred Requesting**: Permissions are not requested immediately on first launch. Storage permission is requested only when the user navigates to the Library tab or initiates a local scan.
2. **Clear Rationale**: Before triggering the system dialog, a clear in-app rationale explains that storage access is strictly used to index audio files.
3. **Graceful Degradation**: If storage permission is denied:
   - ANAHAD remains fully functional for online search, language exploration, and streaming.
   - The Library view displays an informative card with a button to grant permission or open Android App Settings.
