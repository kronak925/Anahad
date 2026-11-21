# ANAHAD | Cookie & Local Storage Policy

**Effective Date**: November 19, 2026  
**Version**: 1.0.0  

---

## 1. Do We Use HTTP Cookies?

**No.** The ANAHAD mobile application does not use HTTP cookies, tracking beacons, pixel tags, or web storage identifiers. 

Because ANAHAD is a native Android application built using Flutter and native Kotlin components (without embedded webviews or advertising SDKs), traditional browser cookies are neither generated, received, stored, nor transmitted by the core application.

---

## 2. Local Device Storage

Instead of cookies, ANAHAD utilizes standard Android local storage mechanisms strictly for essential application functionality:

| Mechanism | Purpose | Contains Personal Info? | Transmitted Remotely? |
|---|---|---|---|
| **Android SharedPreferences** | Saves user UI preferences (Theme, Accent Color), player settings, local playlist definitions, and recent search history. | No | No |
| **Local File Directory** | Stores user-downloaded audio files, `.lrc` lyrics files, and temporary image cache files. | No | No |

---

## 3. Third-Party Endpoints

When ANAHAD fetches album artwork, audio streams, or lyrics over HTTPS from external servers (e.g., CDNs, LRCLIB, JioSaavn), those servers may log standard HTTP request metadata (such as IP address and User-Agent) as part of normal web server operation. ANAHAD does not inject, parse, or store persistent tracking cookies returned in HTTP response headers.

---

## 4. Managing Local Storage

You have complete control over local data stored by ANAHAD:
- **Clear Search History**: Within the app's Search screen.
- **Clear Cache & Data**: Through Android System Settings (`Settings → Apps → ANAHAD → Storage & Cache → Clear Storage`).
- **Remove Media**: By deleting files from your device storage or uninstalling the Application.
