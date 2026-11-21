# ANAHAD | Release Process & Versioning Protocol

- **Release Governance**: Ponytail / Release Engineer
- **Versioning Standard**: Semantic Versioning 2.0.0 (`MAJOR.MINOR.PATCH+BUILD`)

---

## 1. Versioning Strategy

- **MAJOR (v1.0.0)**: Initial public release milestone, or future incompatible architectural overhauls.
- **MINOR (v1.1.0)**: New functional features (e.g. desktop cross-platform support, DSP graphic equalizer engine).
- **PATCH (v1.0.1)**: Backward-compatible bug fixes, UI adjustments, and performance patches.
- **BUILD (+1, +2)**: Monotonically increasing Android `versionCode` for package manager differential installs.

**Current Recommended Release Version**: `1.0.0+1` (Milestone 1 — Launch Candidate).

---

## 2. Pre-Release Quality Checklist

Before building any official public release:

- [ ] **Static Analysis**: `flutter analyze` passes with 0 errors and 0 warnings.
- [ ] **Automated Tests**: `flutter test` executes with 100% pass rate.
- [ ] **Security Sanitization**: Inspect `.gitignore` and ensure no `key.properties`, keystores, or `.env` files are tracked.
- [ ] **License Check**: Ensure all third-party dependencies are permissively licensed.
- [ ] **Version Alignment**: Update version in `pubspec.yaml`, `android/app/build.gradle.kts`, and `CHANGELOG.md`.
- [ ] **Clean Build**: Run `flutter clean` followed by `flutter pub get`.
- [ ] **Release Build**: Execute `flutter build apk --release`.
- [ ] **Smoke Test**: Install release APK on physical device or emulator and verify:
  - Audio playback starts smoothly.
  - Background audio notification controls respond.
  - Widget displays and updates artwork.
  - Legal & Privacy screen opens and displays offline text.

---

## 3. GitHub Release Creation Workflow

1. Commit all release assets:
   ```bash
   git add .
   git commit -m "chore(release): Prepare v1.0.0 publication package"
   git tag -a v1.0.0 -m "Release v1.0.0 - Initial Public Release"
   ```
2. Push tags (only when approved by user):
   ```bash
   git push origin main --tags
   ```
3. Draft GitHub Release:
   - Title: `ANAHAD v1.0.0 — Hi-Res Music Player for Android`
   - Attach `app-release.apk`.
   - Paste release notes from `CHANGELOG.md`.
