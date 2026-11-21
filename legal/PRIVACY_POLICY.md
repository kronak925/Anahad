# ANAHAD | Privacy Policy

**Effective Date**: November 19, 2026  
**Last Updated**: November 19, 2026  
**Version**: 1.0.0  

---

## 1. Introduction and Philosophy

This Privacy Policy describes how **ANAHAD** ("Application", "we", "us", or "our"), developed by [Maintainer Name / Independent Developer], handles information when you use our Android music player application.

ANAHAD is built upon **Privacy-by-Design** principles. We believe that your personal media library, listening habits, and playlists belong exclusively to you. The Application is architected to operate with **zero tracking, zero user accounts, zero analytics SDKs, and zero remote profiling**.

---

## 2. Information We Do NOT Collect

To be completely transparent, ANAHAD does **NOT**:
1. Require user registration, account sign-in, email addresses, phone numbers, or passwords.
2. Collect or store personal identifiers, device serial numbers, IMEI, MAC addresses, or Android Advertising IDs (AAID).
3. Access or track your physical location (GPS or network geolocation).
4. Access your contacts, call logs, SMS, camera, or microphone.
5. Transmit crash reports, diagnostic logs, or performance telemetry to remote tracking services.
6. Sell, rent, lease, or monetize user data with third-party advertisers, data brokers, or marketing networks.

---

## 3. Information Handled Locally on Your Device

All core user data is processed and stored strictly within your device's isolated local application sandbox (`SharedPreferences` and local file directories):

| Data Category | Description | Purpose | Retention |
|---|---|---|---|
| **Local Music Files** | Audio files located on your internal or SD card storage (`.mp3`, `.m4a`, `.flac`, `.wav`, `.ogg`). | Indexed locally via Android MediaStore to build your offline library view and enable playback. | Remains on your device until deleted by you. |
| **Playlists & Favorites** | User-created playlist records and favorite track identifiers. | Preserving your custom playlists and favorites. Stored in local JSON/Preferences. | Retained until deleted by you or app is uninstalled. |
| **Search History** | Recent search terms entered in the search bar. | Displayed for user convenience on the search screen. | Can be manually cleared anytime via app settings. |
| **Settings & Preferences** | Theme mode (Dark/AMOLED/Light), accent color, audio badge toggle, download save path. | Customizing user experience and player preferences. | Retained locally until cleared. |
| **Offline Downloaded Tracks** | Audio streams and lyrics files downloaded by user request. | Stored in app storage or user-selected folder (`/Music/ANAHAD` or `/Download/ANAHAD`). | Retained until deleted by you. |

---

## 4. Android System Permissions and Justification

ANAHAD requests only permissions strictly necessary for core music playback functionality:

- `android.permission.READ_MEDIA_AUDIO` (Android 13+ / API 33+):  
  **Purpose**: Allows ANAHAD to discover and play audio files stored in your device's shared storage.
- `android.permission.READ_EXTERNAL_STORAGE` (Android 12 and below / maxSdkVersion 32):  
  **Purpose**: Required on older Android versions to read local music files from device storage.
- `android.permission.FOREGROUND_SERVICE` & `FOREGROUND_SERVICE_MEDIA_PLAYBACK` (Android 14+):  
  **Purpose**: Ensures audio playback continues seamlessly when the screen is turned off or when switching to other apps, displaying persistent notification controls.
- `android.permission.WAKE_LOCK`:  
  **Purpose**: Prevents the CPU from going into deep sleep during active music playback, avoiding stutter or playback interruptions.
- `android.permission.POST_NOTIFICATIONS` (Android 13+):  
  **Purpose**: Required to display playback controls (Play, Pause, Next, Previous, Artwork) in the notification shade and lock-screen media player.
- `android.permission.INTERNET`:  
  **Purpose**: Required to perform online searches, stream audio from public gateways, fetch synchronized lyrics, and load album cover images.

ANAHAD does not request or use background location, camera, microphone, or storage management permissions beyond what is needed for audio.

---

## 5. External Network Communications

When you interact with online features, ANAHAD initiates outbound HTTPS requests directly from your device to third-party endpoints:

1. **JioSaavn Gateway (`saavn.me` / `jiosaavn.com`)**:
   - **Data Transmitted**: Search keywords (e.g., song title, artist), album IDs, song IDs.
   - **Purpose**: Querying public music catalogues, album art URLs, and stream endpoints.
   - **Privacy Impact**: No personal identifiers sent. Standard IP address logging at server edge.
2. **YouTube Explode (`youtube.com` / `googlevideo.com`)**:
   - **Data Transmitted**: Search query strings and video IDs to resolve audio streams.
   - **Privacy Impact**: Requests are subject to Google's standard network privacy policy.
3. **LRCLIB (`lrclib.net`)**:
   - **Data Transmitted**: Track title, artist name, and duration.
   - **Purpose**: Fetching synchronized karaoke `.lrc` and plain-text lyrics.
   - **Privacy Impact**: Anonymous metadata query. No user profile transmitted.
4. **Content Delivery Networks (CDNs)**:
   - **Data Transmitted**: Standard HTTP GET requests for audio stream byte-ranges and image files.
   - **Privacy Impact**: Transient edge caching of IP address and user-agent string.

---

## 6. Third-Party SDKs and Code Dependencies

ANAHAD does NOT integrate:
- Google Analytics for Firebase
- Firebase Crashlytics
- Facebook Audience Network / Meta SDK
- Unity Ads, AdMob, AppLovin, or IronSource
- AppsFlyer, Branch, or Adjust

All bundled libraries are open-source utilities (e.g., `just_audio`, `audio_service`, `provider`, `http`) that run client-side without remote tracking capabilities.

---

## 7. Data Security and Safe Handling

- **Transport Security**: All external communications are conducted exclusively over TLS/HTTPS with encryption in transit. Cleartext HTTP is disabled in production builds.
- **Local Isolation**: App settings and playlist data reside in Android's private app sandbox, preventing unauthorized access by other third-party applications on the device.
- **Backup & Export**: Exported backup files are generated in plain, human-readable JSON format so you can inspect exactly what data is included before sharing or archiving.

---

## 8. Compliance with Applicable Laws

### A. Digital Personal Data Protection Act (DPDP), 2023 (India)
- ANAHAD acts as a local client tool. Since no personal data is collected or stored on remote servers by the Developer, the Developer does not operate as a Data Fiduciary storing personal data databases.
- Users have full autonomy to inspect, modify, export, and delete all locally retained data at any time.

### B. Information Technology Act, 2000 & Reasonable Security Practices (India)
- ANAHAD adheres to reasonable security standards under Section 43A of the IT Act by maintaining secure, local-first storage and encrypted transport.

### C. General Data Protection Regulation (GDPR) (European Union)
- **Legal Basis**: Processing of local audio files and transient search terms is based on user consent and necessity for contractual performance (fulfilling your request to play or search music).
- **Data Subject Rights**: Because ANAHAD stores all data locally, you can exercise your rights to access, rectification, portability, and erasure directly by exporting your data, clearing app cache, or uninstalling the Application.

---

## 9. Children's Privacy

ANAHAD does not knowingly collect, solicit, or maintain personal information from children under the age of 13 (or under 18 under India's DPDP Act). Because the Application collects zero personal identifiers from all users, children's personal information is neither requested nor stored.

---

## 10. Changes to This Privacy Policy

We may update this Privacy Policy periodically to reflect architectural changes or regulatory updates. Any changes will be published in the application repository and incorporated into the in-app `Settings → About ANAHAD → Legal & Privacy` screen with an updated revision date.

---

## 11. Privacy Contact Information

If you have questions, feedback, or concerns regarding this Privacy Policy or your data privacy while using ANAHAD, please contact:
- **Privacy Lead / Maintainer**: [Maintainer Name]
- **Email**: [Contact Email - e.g., privacy@anahad.app or maintainer@example.com]
- **Project URL**: [GitHub Repository URL]
