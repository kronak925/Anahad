# ANAHAD | Engineering Build Guide

This document details the complete environment setup, compilation steps, and toolchain configurations for building ANAHAD from source.

---

## 1. Environment Requirements

- **Operating System**: Windows 10/11, macOS (Apple Silicon or Intel), or Linux
- **Flutter SDK**: 3.27.x or later (channel stable)
- **Dart SDK**: 3.6.x or later
- **Java Development Kit**: JDK 17 (Azul Zulu, Eclipse Temurin, or Oracle)
- **Android SDK**:
  - `compileSdk`: 34
  - `targetSdk`: 34
  - `minSdk`: 21
  - NDK: 27.0.12077973 (optional, required if building native C++ audio plugins)
  - Android Build Tools: 34.0.0

---

## 2. Step-by-Step Compilation

### 2.1 Clone and Setup
```bash
git clone https://github.com/[username]/anahad.git
cd anahad
flutter pub get
```

### 2.2 Quality Verification
Before building, execute static analysis and the test suite:
```bash
flutter analyze
flutter test
```

### 2.3 Build Debug APK
```bash
flutter build apk --debug
```
*Output*: `build/app/outputs/flutter-apk/app-debug.apk`

### 2.4 Build Release APK
```bash
flutter build apk --release
```
*Output*: `build/app/outputs/flutter-apk/app-release.apk`

### 2.5 Build App Bundle (For Google Play Store Release)
```bash
flutter build appbundle --release
```
*Output*: `build/app/outputs/bundle/release/app-release.aab`

---

## 3. Production Keystore Signing Configuration

To sign with a custom production release keystore rather than development debug certificates:

1. Generate keystore:
   ```bash
   keytool -genkey -v -keystore anahad-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias anahad
   ```
2. Create `android/key.properties` (never commit this file):
   ```properties
   storePassword=your_keystore_password
   keyPassword=your_key_password
   keyAlias=anahad
   storeFile=/path/to/anahad-release-key.jks
   ```
3. Update `android/app/build.gradle.kts` to load `key.properties` into `signingConfigs.create("release")`.
