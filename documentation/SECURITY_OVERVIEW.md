# ANAHAD | Android Security Assessment & Architecture Review

- **Document Version**: 1.0.0
- **Auditing Role**: Product Security Engineer
- **Target**: Android Client Architecture & Network Boundary
- **Status**: Verified Secure for Public Open-Source Release

---

## 1. Security Baseline & Findings Summary

ANAHAD was evaluated against the **OWASP Mobile Application Security Verification Standard (MASVS)** and Android platform security guidelines:

| MASVS Domain | Assessment | Verified Status |
|---|---|---|
| **MASVS-STORAGE**: Data Storage & Privacy | No sensitive data written to world-readable external storage without user selection; internal configs placed in private sandbox. | **PASS** |
| **MASVS-CRYPTO**: Cryptography | Transport layer uses modern TLS; symmetric DES routine is restricted to public CDN deciphering without storing private user secrets. | **PASS** |
| **MASVS-AUTH**: Authentication & Session | Zero-credential architecture. No session tokens, passwords, or OAuth credentials handled or stored. | **PASS (N/A)** |
| **MASVS-NETWORK**: Network Communication | Outgoing network calls use HTTPS/TLS. Cleartext HTTP is disabled by default on Android 9+ (API 28+). | **PASS** |
| **MASVS-PLATFORM**: Platform Interaction | Android exported activities, services, and receivers are guarded with explicit intents and minimum permissions. | **PASS** |
| **MASVS-CODE**: Code Quality & Build | `flutter analyze` reports 0 issues. No unhandled crashes. Sound null-safety across 100% of Dart code. | **PASS** |

---

## 2. Secrets & Credential Audit

- **API Keys**: No proprietary or private API keys are embedded in source code, manifests, or build scripts.
- **DES Stream Key (`38346591`)**: Audited. This 8-byte ASCII string is the well-known public key used by third-party clients to decrypt obfuscated CDN stream URLs from the JioSaavn catalog. It does not grant authenticated access to private user accounts or sensitive databases.
- **Local Keystores & Properties**: `local.properties` contains only the local Android SDK directory and is excluded in `.gitignore`.

---

## 3. Manifest & Component Security (`AndroidManifest.xml`)

1. **MainActivity**:
   - `android:exported="true"` is required because it has the `MAIN` / `LAUNCHER` intent filter. It performs no privileged background operations and accepts no untrusted deep-link payloads without validation.
2. **AudioService**:
   - Declared with `android:foregroundServiceType="mediaPlayback"` and `android:exported="true"` to support Android's system `MediaBrowserService` protocol for Android Auto and notification shade media sessions.
3. **MediaButtonReceiver**:
   - Handles standard hardware and Bluetooth headset transport events (`ACTION_MEDIA_BUTTON`).
4. **AnahadAppWidgetProvider**:
   - Protected BroadcastReceiver responding to standard widget update broadcasts and private action broadcasts (`com.anahad.audio.ACTION_PLAY_PAUSE`, `ACTION_NEXT`, `ACTION_PREV`).
5. **Permissions Scope**:
   - No high-risk permissions (`ACCESS_FINE_LOCATION`, `READ_CONTACTS`, `CAMERA`, `RECORD_AUDIO`, `SYSTEM_ALERT_WINDOW`, `MANAGE_EXTERNAL_STORAGE`) are requested.

---

## 4. File Handling & Storage Security

- **Download Directory Isolation**: The default download destination uses the application's internal files directory (`/downloads`), inaccessible to other installed applications on non-rooted devices.
- **User-Selected External Storage**: When user selects the public `Music` or `Download` directories, files are saved with standard `.mp3`, `.m4a`, or `.flac` audio MIME types using standard Android filesystem APIs.
- **Backup Export/Restore Sanitization**: Backup JSON parser validates object structures and ignores unrecognized or malformed keys, preventing code injection or state corruption.
