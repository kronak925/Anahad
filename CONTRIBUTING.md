# Contributing to ANAHAD

Thank you for your interest in contributing to **ANAHAD**! We welcome community contributions aimed at improving audio fidelity, performance, UI polish, and cross-device compatibility.

---

## 1. Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

---

## 2. Core Philosophy & Design Principles

Before submitting a Pull Request, please ensure your contribution aligns with our core engineering rules:
- **Privacy-First**: Never introduce third-party analytics SDKs, trackers, or telemetry.
- **Minimal Dependencies**: Prefer native Flutter and Dart solutions over introducing heavy external packages.
- **Zero Broken Features**: Run all existing tests and static analysis checks before submitting.
- **Respect Intellectual Property**: Never commit copyrighted sound recordings, proprietary artwork, or private API keys.

---

## 3. Development Workflow

### Prerequisites
- Flutter SDK 3.27+ / Dart SDK 3.6+
- Android SDK (API 34 / Java 17)

### Local Setup
```bash
git clone https://github.com/kronak925/Anahad.git
cd Anahad
flutter pub get
```

### Community & Real-Time Support
If you have questions or want to discuss bug reports and feature ideas in real-time, join our [Telegram Group (Anahad Bug Reports)](https://t.me/+3gyWZ-jgfGQxNjg1).

### Running Tests & Static Analysis
```bash
flutter analyze
flutter test
```

All contributions must pass `flutter analyze` with 0 issues and all unit tests without failure.

---

## 4. Submitting a Pull Request

1. Fork the repository and create a feature branch (`git checkout -b feature/amazing-feature`).
2. Commit your changes with descriptive commit messages (`git commit -m 'feat: Add gapless playback support'`).
3. Push to your branch (`git push origin feature/amazing-feature`).
4. Open a Pull Request on GitHub detailing what changed, why it changed, and how it was tested.
