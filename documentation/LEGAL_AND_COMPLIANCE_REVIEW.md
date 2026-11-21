# ANAHAD | Indian & International Legal, Regulatory & Copyright Review

- **Document Version**: 1.0.0
- **Scope**: Comprehensive Regulatory, Data Protection, and Copyright Compliance Analysis
- **Target Market / Distribution**: India (Primary) & Global (Secondary via GitHub)
- **Status**: Completed Compliance Assessment

---

## 1. Statutory Framework Analysis (India)

### 1.1 Digital Personal Data Protection Act, 2023 (DPDP Act) & Draft Rules 2025
- **Legislative Status**:
  - The Digital Personal Data Protection Act, 2023 was enacted by the Parliament of India in August 2023.
  - Subordinate rules (DPDP Rules 2025) and establishment of the Data Protection Board of India (DPBI) are in transition phases.
- **Applicability to ANAHAD**:
  - The DPDP Act applies to the processing of digital personal data within the territory of India where such data is collected in digital form or digitized subsequently (Section 3).
  - **Critical Finding for ANAHAD**: ANAHAD does not operate remote databases, servers, or user account systems. User listening history, playlists, favorites, and settings reside strictly on the user's client hardware. Under Section 3(c)(i), personal data processed by an individual for personal or domestic purposes is exempted.
  - Furthermore, because the Developer collects no personal identifiers (no names, emails, phone numbers, or device IDs), the Developer does not hold or control personal data of users on any remote server.
- **Recommended Safeguards**:
  - Maintain the zero-telemetry architecture.
  - Provide in-app transparency regarding local storage and network request destinations.

### 1.2 Information Technology Act, 2000 (IT Act) & Subordinate Rules
- **Section 43A & Reasonable Security Practices**:
  - Entities handling data must possess reasonable security practices. ANAHAD adheres to this by enforcing TLS 1.2/1.3 for all outgoing network connections, disabling cleartext HTTP, and sandboxing local data in Android private storage.
- **Section 79 (Intermediary Safe Harbor & Due Diligence)**:
  - If ANAHAD is distributed as a client application rather than an online intermediary hosting user content, intermediary liability does not directly apply to the software publisher in the traditional SaaS sense. However, to maintain safe harbor principles, the application provides an explicit Notice and Takedown mechanism (`legal/COPYRIGHT_AND_INTELLECTUAL_PROPERTY.md`) and Acceptable Use Policy (`legal/ACCEPTABLE_USE_POLICY.md`).
- **Section 66A / Cyber Security**:
  - The app contains no malicious code, spyware, unauthorized listeners, or hidden backdoors.

### 1.3 Copyright Act, 1957 (India)
- **Exclusive Rights of Copyright Owners (Section 14)**:
  - Rightsholders possess exclusive rights regarding reproduction, public performance, communication to the public, and adaptation of sound recordings and underlying musical/lyric works.
- **Infringement Provisions (Section 51)**:
  - Facilitating unauthorized commercial distribution or public broadcasting can constitute copyright infringement.
- **Fair Dealing Exceptions (Section 52)**:
  - Section 52 permits fair dealing with works for personal or private use (including research and study). However, mass digital distribution of commercial sound recordings without mechanical or digital licenses does not qualify as fair dealing.
- **Architectural Safeguards in ANAHAD**:
  1. ANAHAD does NOT bundle or distribute any copyrighted sound recordings in the APK or repository.
  2. ANAHAD operates as a media decoder and player for user-owned files.
  3. For online streaming and caching features, ANAHAD acts as a client querying public web gateways; the Terms of Service and Disclaimer clearly establish that users must possess necessary rights and licenses for any media accessed.

### 1.4 Consumer Protection Act, 2019 & E-Commerce Rules
- ANAHAD is provided free of charge without mandatory subscriptions, in-app purchases, or deceptive dark patterns.
- Clear disclosures regarding features, limitations, and third-party dependencies prevent misleading representations.

---

## 2. Music Content, APIs & Copyright Audit

| Feature | Technical Architecture | Copyright & Licensing Analysis | Risk Level | Mitigation & Compliance Implemented |
|---|---|---|---|---|
| **Local Music Playback** | Decodes local files (`.mp3`, `.m4a`, `.flac`, `.wav`) via `just_audio` / platform ExoPlayer. | Permissible. User plays their own lawfully possessed files. | **NONE** | No action needed. Core playback is fully authorized. |
| **FLAC Hi-Res Badge Detection** | Parses audio stream headers (`TrackModel.isLossless`, bit depth, sample rate). | Permissible. Technical metadata inspection. | **NONE** | Visual badge accurately reflects decoded audio metrics without false claims. |
| **Lyrics Display & Karaoke** | Queries `lrclib.net` and JioSaavn public endpoints for timestamped text. | Permissible for personal reference. Lyrics remain property of songwriters and publishers. | **LOW** | Transparent attribution to LRCLIB community database; clear disclaimer in `legal/DISCLAIMER.md`. |
| **Album Artwork Display** | Fetches public thumbnail URLs via CDN into temporary image cache. | Permissible under nominative fair use to visually identify songs in user interface. | **LOW** | Cached temporarily on device; no commercial redistribution or bundling in app assets. |
| **Online Catalogue Search** | Queries public search gateway (`saavn.me` / `jiosaavn.com`). | Indexing public search endpoints. | **MEDIUM** | Uses client-side query parameters; does not harvest or replicate database; disclaimer included. |
| **Audio Stream Decryption (DES)** | Decrypts stream URL token with public key `38346591`. | Technical protocol compatibility. Stream remains on public CDN. | **MEDIUM** | Key is treated as protocol constant; app explicitly disclaims ownership of stream servers. |
| **Audio Downloads** | Pipes remote audio stream directly into user's local storage folder. | User-directed downloading of online streams must be for personal use under local law. | **MEDIUM-HIGH** | Prominent disclaimer that user is responsible for content rights; user selects custom destination. |

---

## 3. Matters Requiring Formal Legal Review (Notice to Maintainer)

While this technical and regulatory audit aligns ANAHAD with standard software engineering practices, the following areas should be reviewed by a qualified intellectual property attorney prior to commercial monetization or formal enterprise distribution:
1. **Third-Party API Terms of Service**: Direct API contracts with music aggregators if the app transitions from an open-source hobbyist project to a commercial entity.
2. **Statutory Licensing under Indian Copyright Act**: If launching a dedicated streaming backend with hosted audio files, statutory streaming licenses (under Section 31D) must be acquired from copyright societies (such as IPRS and PPL).
3. **Trademark Registration**: Formal trademark filing for the wordmark "ANAHAD" in Class 9 (computer software) and Class 41 (entertainment services) in India.
