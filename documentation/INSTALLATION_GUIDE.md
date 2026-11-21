# ANAHAD | Installation Guide

This guide provides instructions for installing ANAHAD on physical Android devices and emulators.

---

## 1. Sideloading Release APK on Physical Android Device

### Step 1: Download the APK
Transfer `app-release.apk` (or `app-debug.apk`) to your phone via USB cable, Google Drive, WhatsApp, or local download.

### Step 2: Enable Installation from Unknown Sources
1. Open Android **Settings → Apps → Special app access → Install unknown apps**.
2. Select the file manager or browser you used to transfer the APK (e.g., Files by Google or Chrome).
3. Toggle on **Allow from this source**.

### Step 3: Install
1. Tap the `app-release.apk` file in your file manager.
2. Tap **Install**.
3. If Google Play Protect displays an "Unrecognized developer" prompt (typical for direct open-source builds not yet published to Play Store), tap **More details → Install anyway**.

### Step 4: First Launch & Permissions
1. Open ANAHAD from your app launcher.
2. Navigate to **Library** and tap **Grant Permission** when prompted for Audio/Storage access.
3. Your local music library will automatically index and display.

---

## 2. Installing via Android Debug Bridge (ADB)

Connect your device with USB Debugging enabled, then execute:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

To verify the installation:
```bash
adb shell monkey -p com.anahad.audio.anahad -c android.intent.category.LAUNCHER 1
```
