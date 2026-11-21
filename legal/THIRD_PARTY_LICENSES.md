# ANAHAD | Third-Party Software Licenses & Attributions

**Application Target**: ANAHAD Audio Player  
**Date**: November 2026  
**Status**: Open-Source Dependency Review  

---

## 1. Overview

ANAHAD is constructed using open-source packages and frameworks. This document inventories the core dependencies, their respective licenses, and attribution obligations.

---

## 2. Core Dependencies & License Classifications

| Component Name | Version | License | Upstream Project / Repository | Attribution Requirement |
|---|---|---|---|---|
| **Flutter Framework** | 3.27+ | BSD-3-Clause | `flutter/flutter` | Include copyright notice |
| **just_audio** | 0.9.46 | Apache 2.0 | `ryanheise/just_audio` | Include license and state changes |
| **audio_service** | 0.18.19 | MIT | `ryanheise/audio_service` | Include copyright notice |
| **on_audio_query** | 2.9.0 | BSD-3-Clause | `LucJReis/on_audio_query` | Include copyright notice |
| **permission_handler** | 11.4.0 | MIT | `Baseflow/flutter-permission-handler` | Include copyright notice |
| **provider** | 6.1.5+1 | MIT | `rrousselGit/provider` | Include copyright notice |
| **shared_preferences** | 2.5.3 | BSD-3-Clause | `flutter/packages` | Include copyright notice |
| **path_provider** | 2.1.5 | BSD-3-Clause | `flutter/packages` | Include copyright notice |
| **http** | 1.6.0 | BSD-3-Clause | `dart-lang/http` | Include copyright notice |
| **youtube_explode_dart** | 3.1.0 | MIT | `Hexer10/youtube_explode_dart` | Include copyright notice |
| **dart_des** | 1.0.2 | MIT | `kenneth-bell/dart_des` | Include copyright notice |
| **intl** | 0.19.0 | BSD-3-Clause | `dart-lang/intl` | Include copyright notice |
| **crypto** | 3.0.8 | BSD-3-Clause | `dart-lang/crypto` | Include copyright notice |
| **cupertino_icons** | 1.0.8 | MIT | `flutter/packages` | Include copyright notice |

---

## 3. License Summaries

### 3.1 MIT License Components
Components under the MIT License grant permission, free of charge, to deal in the software without restriction, including the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, subject to including the original copyright notice and permission notice in all copies or substantial portions of the software.

### 3.2 BSD-3-Clause License Components
Components under the BSD-3-Clause License allow redistribution and use in source and binary forms, with or without modification, provided that:
1. Redistributions of source code retain the above copyright notice, list of conditions, and disclaimer.
2. Redistributions in binary form reproduce the above copyright notice, list of conditions, and disclaimer in documentation and/or materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of contributors may be used to endorse or promote products derived from the software without specific prior written permission.

### 3.3 Apache License 2.0 Components
Components under the Apache 2.0 License grant a perpetual, worldwide, non-exclusive, no-charge, royalty-free copyright and patent license to reproduce, prepare derivative works of, publicly display, sublicense, and distribute the work, subject to retaining copyright notices, providing copies of the license, and stating modifications made.

---

## 4. Verification and Compliance

All direct dependencies utilize permissive, open-source licenses compatible with both open-source and proprietary client distribution models. No copyleft GPL/AGPL libraries with source-disclosure mandates are linked in the application runtime binary.
