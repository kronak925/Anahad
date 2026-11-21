# ANAHAD | Open-Source & Proprietary Software Licensing Analysis

- **Document Version**: 1.0.0
- **Auditing Role**: Open-Source Licensing Specialist
- **Objective**: Comparative Evaluation of Software Licenses for ANAHAD GitHub Publication
- **Status**: Decision Pending User Approval

---

## 1. Executive Licensing Summary

Before publishing ANAHAD's source code on GitHub, an explicit licensing model must be adopted. The table below compares the four primary models evaluated for this project:

| License Model | Type | Permissible Uses | Commercial Redistribution | Source Disclosure Mandate (Copyleft) | Patent Grant Included | Protection for Author Branding |
|---|---|---|---|---|---|---|
| **Proprietary (Source-Available)** | Non-FOSS | Personal viewing, inspection, research | **Forbidden** without license | No (No distribution allowed) | N/A | **Maximum** (Full copyright retained) |
| **MIT License** | Permissive FOSS | Any use (commercial, private, modification) | **Permitted** by anyone | **No** (Can be closed-source in derivatives) | No explicit patent grant | Author notice must be retained |
| **Apache 2.0** | Permissive FOSS | Any use with patent protection | **Permitted** by anyone | **No** (Permits proprietary derivatives) | **Yes** (Express patent license & retaliation clause) | Trademarks expressly protected |
| **GPL v3** | Strong Copyleft | Any open-source use | **Permitted**, but derivatives MUST also be GPLv3 | **YES** (Anyone distributing must provide full source) | **Yes** | Notice must be retained |

---

## 2. Detailed License Teardowns

### Option 1: Proprietary / Source-Available ("All Rights Reserved")
- **How it works**: Code is visible publicly on GitHub for community audit, portfolio demonstration, and educational review, but with standard copyright reservation: *"Copyright © 2026 [Author Name]. All rights reserved."*
- **Pros**:
  - Prevents third-party developers from cloning the app, rebranding it, and uploading it to Google Play to monetize your work.
  - Retains 100% exclusive commercial and distribution rights with the original creator.
  - Highly suitable for showcasing technical capability on LinkedIn without forfeiting intellectual property.
- **Cons**:
  - Does not qualify as "Open Source" under the Open Source Initiative (OSI) definition.
  - Third-party open-source contributors cannot freely distribute forks.

### Option 2: Apache License 2.0 (Recommended for Open-Source Release)
- **How it works**: Permissive open-source license widely used by major foundations (Google, Apache Foundation).
- **Pros**:
  - **Trademark Protection**: Section 6 explicitly states that the license does NOT grant rights to use the trademarks, trade names, or service marks of the Licensor (safeguarding the "ANAHAD" brand and logo).
  - **Patent Indemnity**: Section 3 provides an express grant of patent rights and terminates rights if a licensee sues for patent infringement.
  - Compatible with all core libraries currently utilized (`just_audio` is Apache 2.0).
- **Cons**:
  - Others may incorporate your code into proprietary commercial apps.

### Option 3: MIT License
- **How it works**: Extremely short, permissive license granting almost unlimited freedom.
- **Pros**: Maximum adoption, simple for contributors, minimal legal overhead.
- **Cons**: Lacks explicit trademark protections and patent grants. Third parties can re-brand and republish without restriction.

### Option 4: GNU General Public License v3 (GPLv3)
- **How it works**: Reciprocal copyleft license. Anyone who distributes modified versions or derivative works of ANAHAD must release their source code under GPLv3.
- **Pros**: Prevents proprietary re-branding and monetization by competitors.
- **Cons**: Can deter enterprise contributors; strict copyleft obligations.

---

## 3. Formal Recommendation for ANAHAD

1. **If your primary goal is showcasing on LinkedIn and portfolio demonstration while preventing unauthorized app-store clones**:
   - **Recommendation**: **Source-Available / Proprietary Notice** with educational and personal use permission, or **Apache 2.0 with a clear trademark reservation**.
2. **If your primary goal is fostering a collaborative community-driven open-source project**:
   - **Recommendation**: **Apache License 2.0**. It provides formal patent protection, explicitly preserves your brand name/logo ownership, and aligns with the Flutter/Android ecosystem.

> [!IMPORTANT]
> **Pending User Action**: The repository currently holds a placeholder license notice. Please confirm whether you prefer **Apache 2.0** (Open Source) or **Proprietary Source-Available** (All Rights Reserved) before final GitHub publication.
