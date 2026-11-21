# ANAHAD Prototype 1: Build, Transfer & Installation Guide

## 1. Primary Deliverable Location

The primary deliverable for Prototype 1 is the compiled, installable Android APK:

```
build/app/outputs/flutter-apk/app-debug.apk
```

- **Application Name**: ANAHAD
- **Package ID**: `com.anahad.audio.anahad`
- **Build Type**: Debug (`app-debug.apk`, signed with standard Android debug keystore)
- **Minimum Android SDK**: API 21 (Android 5.0+)
- **Target Android SDK**: API 35 (Android 15)
- **Architecture**: Universal (ARM64-v8a, ARMv7, x86_64)

---

## 2. Transferring and Installing on an Android Phone

### Method A: Direct USB ADB Install (Fastest for Developers)
If your phone is connected to your computer via USB with USB Debugging enabled:
```powershell
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

### Method B: Direct File Transfer to Phone
1. Connect your Android phone to your PC using a USB cable and select **File Transfer / MTP**.
2. Copy `build/app/outputs/flutter-apk/app-debug.apk` from your computer to your phone's **Downloads** or **Music** folder.
   *(Alternatively, send the `.apk` file to yourself via Google Drive, WhatsApp Web, Telegram, or LocalSend).*
3. On your phone, open the **Files** app (e.g. *Files by Google* or your device file manager).
4. Navigate to the folder containing `app-debug.apk` and tap on it.
5. If prompted with *"For your security, your phone is not allowed to install unknown apps from this source"*:
   - Tap **Settings**.
   - Toggle **Allow from this source**.
   - Return and tap **Install**.
6. Tap **Open** once installation completes.

---

## 3. Initial App Setup on Your Phone

1. **Permission Grant**:
   - On first launch, ANAHAD will request permission to access your audio files (`READ_MEDIA_AUDIO` on Android 13+ or Storage on Android 12-).
   - Tap **Allow** so ANAHAD can scan and index your local music library.
   - On Android 13+, also allow the Notification permission so the media notification controls appear in your notification shade and lock screen.
2. **Library Scan**:
   - ANAHAD will immediately scan your internal storage and SD card for music files (`.flac`, `.mp3`, `.m4a`, `.aac`, `.wav`).
   - If your phone currently has no music files, ANAHAD automatically loads 4 curated sample tracks (including 24-bit/96kHz studio FLAC) so you can test playback immediately!

---

## 4. Adding the Home-Screen Widget

1. Return to your phone's home screen.
2. Long-press on an empty space on the home screen until the menu appears.
3. Tap **Widgets**.
4. Scroll through the widget list to **ANAHAD**.
5. Touch and hold the **ANAHAD Now Playing** widget, then drag it onto your home screen.
6. The widget will display the current track, artist, format badge (`FLAC 24-BIT LOSSLESS`), and interactive playback controls (Play/Pause, Next, Previous).

---

## 5. Building from Source (Environment Reference)

If rebuilding the APK from source in the future:
```powershell
# Run tests
& "C:\Users\krona\.gemini\antigravity\scratch\tools\flutter\bin\flutter.bat" test

# Analyze static quality
& "C:\Users\krona\.gemini\antigravity\scratch\tools\flutter\bin\flutter.bat" analyze

# Compile debug APK
& "C:\Users\krona\.gemini\antigravity\scratch\tools\flutter\bin\flutter.bat" build apk --debug
```
