# ANAHAD | Copyright & Intellectual Property Policy

**Effective Date**: November 19, 2026  
**Version**: 1.0.0  

---

## 1. Overview and Ownership

This document details the intellectual property rights governing the **ANAHAD** audio player project, its original source code, visual design assets, third-party library dependencies, and the formal process for submitting intellectual property notices.

---

## 2. Original Application Code and Assets

### 2.1 Software Codebase
All original software architecture, Dart code, Kotlin code, custom widgets, state management logic, audio pipeline integrations, and configuration files created for ANAHAD are copyright © 2026 [Maintainer Name / Independent Developer]. All rights reserved, subject to the chosen software distribution license.

### 2.2 Branding, Logos & Icons
- The name **ANAHAD**, the wordmark, and the custom glowing cyan/emerald headphone and waveform audio icon (`anahad_logo.png`, `AnahadBrandIcon`, and native adaptive launcher icons) are original artistic works created specifically for this project.
- Unauthorized reproduction, commercial distribution, or confusingly similar imitation of the ANAHAD branding without prior written consent is strictly prohibited.

### 2.3 Typography and UI Assets
- System fonts utilized within ANAHAD rely upon standard open-source Android and Flutter platform fonts (such as Roboto and Cupertino Icons).
- All vector iconography is derived from standard Flutter Material Design icons or original custom canvas paint routines (`CustomPainter`).

---

## 3. Third-Party Code and Open-Source Attribution

ANAHAD incorporates several open-source libraries under permissive licenses. Each component remains the intellectual property of its respective authors:

| Package / Library | Copyright Holder | License | Purpose in ANAHAD |
|---|---|---|---|
| **just_audio** | Ryan Heise | Apache 2.0 | Core audio playback and streaming engine |
| **audio_service** | Ryan Heise | MIT | Background playback lifecycle & notification controls |
| **on_audio_query** | Lucas Cavalheiro | BSD-3-Clause | Android MediaStore device music scanner |
| **permission_handler** | Baseflow | MIT | Android runtime permission management |
| **provider** | Remi Rousselet | MIT | Reactive Flutter state management |
| **shared_preferences** | The Flutter Authors | BSD-3-Clause | Local key-value preferences storage |
| **path_provider** | The Flutter Authors | BSD-3-Clause | Platform filesystem path resolution |
| **http** | The Dart Project Authors | BSD-3-Clause | Composable HTTP client |
| **youtube_explode_dart** | Hexer10 | MIT | Public YouTube metadata and stream resolution |
| **dart_des** | Kenneth E. Bell | MIT | DES cryptographic cipher implementation |

*For complete copyright notices and verbatim license texts, please inspect `legal/THIRD_PARTY_LICENSES.md` and `legal/THIRD_PARTY_NOTICES.md`.*

---

## 4. Third-Party Musical Content, Lyrics & Metadata

1. **No Bundled Copyrighted Media**:  
   The ANAHAD application package, repository, and release builds contain **ZERO** copyrighted sound recordings, commercial musical compositions, or bundled commercial album covers.
2. **Client-Side Indexing**:  
   ANAHAD functions as a search client and playback tool. Audio streams, album artwork, and synchronized lyrics fetched from third-party public endpoints remain the intellectual property of their respective creators, publishers, and distributors.
3. **Nominative Fair Use**:  
   Any display of artist names, album titles, or song titles within the search catalog is conducted under nominative fair use / fair dealing to identify the musical work requested by the user.

---

## 5. Notice and Takedown Procedure (DMCA / Indian Copyright Act)

The Developer respects the intellectual property rights of creators and rightsholders and complies with applicable copyright laws, including the Indian Copyright Act (1957) and the Digital Millennium Copyright Act (DMCA, 17 U.S.C. § 512).

If you are a copyright owner, or authorized to act on behalf of one, and you believe that any component of the ANAHAD software, repository, or documentation infringes upon your copyright, please submit a formal notification containing the following details:

### Required Information for Infringement Notices:
1. **Identification of the Work**: A detailed description of the copyrighted work claimed to have been infringed.
2. **Identification of the Infringing Material**: The specific file, URL, or code location within the ANAHAD repository or application that allegedly infringes your rights.
3. **Contact Information**: Your full legal name, title, organization (if applicable), mailing address, telephone number, and valid email address.
4. **Statement of Good Faith**: A statement that you have a good-faith belief that the disputed use of the material is not authorized by the copyright owner, its agent, or the law.
5. **Statement of Accuracy and Authority**: A statement made under penalty of perjury that the information provided in your notice is accurate and that you are the copyright owner or authorized to act on the owner's behalf.
6. **Physical or Electronic Signature**: An electronic or physical signature of the authorized person submitting the notification.

### Submission Address:
- **Designated Copyright Contact**: [Maintainer Name / Legal Contact]
- **Email**: [Contact Email - e.g., copyright@anahad.app or maintainer@example.com]
- **Repository Issues**: [GitHub Issues URL - e.g., https://github.com/[username]/anahad/issues]

Upon receipt of a valid and complete infringement notice, the Developer will expeditiously review the claim, investigate the matter, and take appropriate action, including modifying the codebase or removing references to the disputed material.
