import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LegalPrivacyScreen extends StatelessWidget {
  const LegalPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal & Privacy', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Header Card
          Card(
            color: isDark ? const Color(0xFF0F1B22) : const Color(0xFFF0F4F8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(40),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.verified_user_rounded, color: theme.colorScheme.primary, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Trust, Safety & Privacy',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ANAHAD operates offline-first with zero tracking, zero personal data harvesting, and full transparency.',
                          style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          _sectionTitle(context, 'Legal Agreements & Policies'),
          _legalItem(
            context,
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Usage conditions, user content obligations & disclaimers',
            version: 'v1.0.0 • Nov 2026',
            onTap: () => _openDocument(
              context,
              title: 'Terms of Service',
              version: 'Version 1.0.0 • Effective November 19, 2026',
              content: _termsOfServiceContent,
            ),
          ),
          _legalItem(
            context,
            icon: Icons.shield_outlined,
            title: 'Privacy Policy',
            subtitle: 'Local-only data storage, zero telemetry & DPDP compliance',
            version: 'v1.0.0 • Nov 2026',
            onTap: () => _openDocument(
              context,
              title: 'Privacy Policy',
              version: 'Version 1.0.0 • Effective November 19, 2026',
              content: _privacyPolicyContent,
            ),
          ),
          _legalItem(
            context,
            icon: Icons.info_outline_rounded,
            title: 'Legal Disclaimer',
            subtitle: 'Media ownership responsibilities & third-party services',
            version: 'v1.0.0 • Nov 2026',
            onTap: () => _openDocument(
              context,
              title: 'Legal Disclaimer',
              version: 'Version 1.0.0 • Effective November 19, 2026',
              content: _disclaimerContent,
            ),
          ),
          _legalItem(
            context,
            icon: Icons.copyright_rounded,
            title: 'Copyright & Attribution',
            subtitle: 'IP rights, branding, nominative fair use & DMCA takedown',
            version: 'v1.0.0 • Nov 2026',
            onTap: () => _openDocument(
              context,
              title: 'Copyright & IP Policy',
              version: 'Version 1.0.0 • Effective November 19, 2026',
              content: _copyrightContent,
            ),
          ),
          _legalItem(
            context,
            icon: Icons.code_rounded,
            title: 'Third-Party Licenses',
            subtitle: 'Open-source software acknowledgements & attributions',
            version: '14 Core Libraries',
            onTap: () => _openDocument(
              context,
              title: 'Third-Party Licenses',
              version: 'Open-Source Notices • November 2026',
              content: _thirdPartyLicensesContent,
            ),
          ),
          const SizedBox(height: 20),

          _sectionTitle(context, 'Contact & Support'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: const Icon(Icons.forum_rounded),
              title: const Text('Telegram Community & Bug Reports'),
              subtitle: const Text('Join Anahad Bug Reports on Telegram'),
              trailing: const Icon(Icons.copy_rounded, size: 20),
              onTap: () {
                Clipboard.setData(const ClipboardData(text: 'https://t.me/+3gyWZ-jgfGQxNjg1'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Telegram invite link copied: https://t.me/+3gyWZ-jgfGQxNjg1'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: const Icon(Icons.mail_outline_rounded),
              title: const Text('Contact Legal & Privacy Maintainer'),
              subtitle: const Text('For copyright notices, privacy queries, or support'),
              trailing: const Icon(Icons.copy_rounded, size: 20),
              onTap: () {
                Clipboard.setData(const ClipboardData(text: 'contact@anahad.app'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contact email copied to clipboard: contact@anahad.app'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _legalItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String version,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        title: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(version, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(subtitle, style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }

  void _openDocument(
    BuildContext context, {
    required String title,
    required String version,
    required String content,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => _DocumentViewerScreen(title: title, version: version, content: content),
      ),
    );
  }
}

class _DocumentViewerScreen extends StatelessWidget {
  final String title;
  final String version;
  final String content;

  const _DocumentViewerScreen({
    required this.title,
    required this.version,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history_rounded, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(version, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SelectableText(
            content,
            style: const TextStyle(fontSize: 13.5, height: 1.55),
          ),
          const Divider(height: 40),
          Center(
            child: Text(
              'ANAHAD Music Player • Offline Legal Document',
              style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color),
            ),
          ),
        ],
      ),
    );
  }
}

// Offline Bundled Legal Content
const String _termsOfServiceContent = '''
1. ACCEPTANCE OF TERMS
By installing, downloading, or using ANAHAD ("Application"), you agree to these Terms of Service. If you do not agree, do not use the Application.

2. PRODUCT DESCRIPTION
ANAHAD is an independent audio player client engineered for Android. The Application provides playback for local audio files on your device, format badge visualizers (FLAC, Lossless, AAC), synchronized lyrics viewing, client-side search querying public web gateways, and local download management. ANAHAD does NOT host, own, or remotely distribute copyrighted music recordings.

3. USER RESPONSIBILITIES & CONTENT RIGHTS
You are solely and exclusively responsible for ensuring you have lawful authorization, licenses, or personal fair dealing rights for any audio files, sound recordings, or lyrics played or downloaded via the Application.

4. PROHIBITED ACTIVITIES
You agree NOT to:
- Infringe intellectual property or copyright laws.
- Circumvent, disable, or tamper with digital rights management (DRM) or access restrictions.
- Flood, scrape, or disrupt third-party endpoints or CDNs with automated bots.
- Distribute modified versions of the Application containing malware or unauthorized telemetry.

5. THIRD-PARTY SERVICES
ANAHAD interacts with independent third-party endpoints (e.g., JioSaavn, YouTube Explode, LRCLIB). These services operate under their own independent policies. We assume no liability for third-party service uptime, content, or modifications.

6. DISCLAIMER OF WARRANTIES
THE APPLICATION IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. USE OF THE APPLICATION IS AT YOUR OWN SOLE RISK.

7. LIMITATION OF LIABILITY
TO THE MAXIMUM EXTENT PERMITTED BY LAW, THE DEVELOPER SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING FROM YOUR USE OF THE APPLICATION.

8. GOVERNING LAW
These Terms shall be governed by and construed in accordance with the laws of India.
''';

const String _privacyPolicyContent = '''
1. PRIVACY PHILOSOPHY
ANAHAD is designed with strict Privacy-by-Design and local-first architecture. We believe your media library and listening habits belong solely to you.

2. ZERO DATA COLLECTION
ANAHAD does NOT:
- Require user sign-in, accounts, phone numbers, or passwords.
- Collect device identifiers (IMEI, MAC, Android Advertising ID).
- Track physical location.
- Include analytics SDKs, tracking pixels, or crash reporting daemons (no Firebase, no Facebook SDK, no Sentry).
- Sell or monetize user data.

3. LOCAL-ONLY DATA STORAGE
The following data is stored exclusively on your device:
- Local audio files in your storage.
- Custom playlists and favorite tracks (stored in local SharedPreferences).
- Search history (stored locally; can be cleared anytime in the app).
- Application preferences (theme, accent color, audio badges).
- Downloaded audio and .lrc lyrics files (in app storage or user-selected folder).

4. ANDROID SYSTEM PERMISSIONS
ANAHAD requests only permissions strictly necessary for music playback:
- READ_MEDIA_AUDIO / READ_EXTERNAL_STORAGE: To scan and play your device's audio files.
- FOREGROUND_SERVICE & MEDIA_PLAYBACK: To maintain playback when the screen is off.
- WAKE_LOCK: To prevent CPU sleep stutter during playback.
- POST_NOTIFICATIONS: To display playback controls in notification shade and lock-screen.
- INTERNET: To query public search gateways, stream online audio, and fetch lyrics.

5. THIRD-PARTY NETWORK REQUESTS
When using online features, your device makes direct HTTPS requests to:
- JioSaavn / saavn.me (catalogue search & metadata).
- YouTube Explode (audio stream resolution).
- LRCLIB / lrclib.net (lyrics text retrieval).
No personal profiles or tracking identifiers are transmitted.

6. REGULATORY COMPLIANCE
- Digital Personal Data Protection Act, 2023 (India): Complies fully as a local client processing data for personal use.
- GDPR (EU): Zero remote storage of personal data; all data can be cleared or exported by user.
''';

const String _disclaimerContent = '''
1. GENERAL DISCLAIMER
ANAHAD is an independent audio playback application. ANAHAD is NOT a music publishing house, record label, streaming service distributor, or commercial media hosting platform.

2. MEDIA RIGHTS & FAIR USE
Users are solely responsible for ensuring that any audio files played, cached, or downloaded comply with copyright laws and licensing terms in their respective jurisdiction. The Application does not endorse unauthorized downloading or copyright infringement.

3. THIRD-PARTY ASSETS & INTELLECTUAL PROPERTY
- All sound recordings, compositions, album titles, and artist names belong to their respective copyright owners.
- Album cover images and lyrics fetched from online endpoints are displayed strictly for personal identification under nominative fair use / fair dealing principles.
- Third-party trademarks (Android, Google, YouTube, JioSaavn, Deezer, Apple Music, Gaana, Poweramp) are property of their respective owners and used purely for descriptive comparison.

4. "AS-IS" SOFTWARE DISCLAIMER
THE APPLICATION IS DISTRIBUTED WITHOUT WARRANTIES OF ANY KIND. THE DEVELOPER DISCLAIMS ALL IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.
''';

const String _copyrightContent = '''
1. ORIGINAL CODE & BRANDING
All original Dart code, Kotlin code, architectural designs, UI layouts, and the ANAHAD brand identity and glowing cyan logo (anahad_logo.png, AnahadBrandIcon) are copyright © 2026 [Maintainer Name / Independent Developer].

2. THIRD-PARTY PACKAGES
All third-party libraries bundled in the application are used under their respective permissive open-source licenses (MIT, Apache 2.0, BSD-3-Clause).

3. NOTICE AND TAKEDOWN PROCEDURE (DMCA / INDIAN COPYRIGHT ACT)
If you are a copyright owner or legal representative and believe that any material or reference in this project infringes upon your copyright, please submit a formal notification to:

- Designated Contact: [Maintainer Name / Legal Contact]
- Email: contact@anahad.app
- Include: Identification of the copyrighted work, exact file/code reference, statement of ownership, and contact details.
Valid takedown notices will be addressed expeditiously.
''';

const String _thirdPartyLicensesContent = '''
CORE OPEN-SOURCE LIBRARIES IN ANAHAD:

1. just_audio (v0.9.46)
   License: Apache License 2.0
   Copyright © Ryan Heise
   Purpose: Audio playback and streaming engine

2. audio_service (v0.18.19)
   License: MIT License
   Copyright © Ryan Heise
   Purpose: Background media session and notification controls

3. on_audio_query (v2.9.0)
   License: BSD-3-Clause License
   Copyright © Lucas Cavalheiro
   Purpose: Local Android MediaStore scanning

4. permission_handler (v11.4.0)
   License: MIT License
   Copyright © Baseflow
   Purpose: Android runtime permission management

5. provider (v6.1.5+1)
   License: MIT License
   Copyright © Remi Rousselet
   Purpose: State management and dependency injection

6. shared_preferences (v2.5.3)
   License: BSD-3-Clause License
   Copyright © The Flutter Authors
   Purpose: Local key-value persistent storage

7. path_provider (v2.1.5)
   License: BSD-3-Clause License
   Copyright © The Flutter Authors
   Purpose: Local filesystem directory resolution

8. http (v1.6.0)
   License: BSD-3-Clause License
   Copyright © The Dart Project Authors
   Purpose: Composable HTTP networking

9. youtube_explode_dart (v3.1.0)
   License: MIT License
   Copyright © Hexer10
   Purpose: Audio stream fallback resolver

10. dart_des (v1.0.2)
    License: MIT License
    Copyright © Kenneth E. Bell
    Purpose: DES stream URL deciphering

11. intl (v0.19.0) & crypto (v3.0.8)
    License: BSD-3-Clause License
    Copyright © The Dart Project Authors
    Purpose: Date formatting and cryptographic hashing
''';
