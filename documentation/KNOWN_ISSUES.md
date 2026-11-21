# ANAHAD | Known Issues & Technical Limitations

This document tracks known limitations, hardware edge cases, and architectural considerations in ANAHAD v1.0.0.

---

## 1. Known Architectural Limitations

| Issue ID | Area | Description | Severity | Workaround / Status |
|---|---|---|---|---|
| **ISSUE-01** | Lock Screen | Android 11+ restricts third-party applications from rendering custom interactive view overlays on top of the secure system lock screen. | `LOW` | ANAHAD utilizes Android's official `MediaStyle` notification session, providing standard lock-screen transport controls and artwork. Lyrics are displayed on the home widget and within the full-screen player. |
| **ISSUE-02** | Hardware Equalizer | Equalizer preset curves (Flat, Bass Boost, Treble Boost, Vocal, etc.) are visualized and persisted in settings, but low-level Android NDK audio effect session DSP linkage is currently simulated. | `MEDIUM` | Scheduled for v1.1.0 via native OpenSL ES / Oboe audio effect binding. |
| **ISSUE-03** | Third-Party Gateway Stability | Online search and stream resolution rely upon public REST endpoints. Changes to external API response schemas by third-party services may temporarily impact online catalogue features. | `MEDIUM` | StreamResolver incorporates dynamic YouTube Explode fallback to ensure playback continuity if primary CDN streams fail. |
| **ISSUE-04** | Android Battery Optimizers | Aggressive OEM battery-saver daemons (MIUI, ColorOS, OxygenOS) may terminate background media playback after extended screen-off periods if battery optimization is not set to "Unrestricted". | `LOW` | Documented in installation guide; app uses standard Android `FOREGROUND_SERVICE` and `WAKE_LOCK`. |
