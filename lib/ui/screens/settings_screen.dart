import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/library_notifier.dart';
import '../../providers/settings_notifier.dart';
import '../../providers/theme_notifier.dart';
import '../../services/storage_service.dart';
import '../../services/widget_sync_service.dart';
import '../theme/app_theme.dart';
import 'legal_privacy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final settings = context.watch<SettingsNotifier>();
    final library = context.watch<LibraryNotifier>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkObsidianBackground : null,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkObsidianBackground.withValues(alpha: 0.85) : null,
        elevation: 0,
        title: Text(
          'Settings & Configuration',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // Section: Appearance
          _sectionHeader(context, 'Appearance & Theme', primary),
          _glassCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: _iconBadge(Icons.palette_outlined, primary),
                title: const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  themeNotifier.modeString.toUpperCase(),
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12.5),
                ),
                trailing: DropdownButton<String>(
                  value: themeNotifier.modeString,
                  dropdownColor: isDark ? const Color(0xFF0F151B) : Colors.white,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'dark', child: Text('Dark (Obsidian)')),
                    DropdownMenuItem(value: 'amoled', child: Text('AMOLED Black')),
                    DropdownMenuItem(value: 'light', child: Text('Light (Apple)')),
                  ],
                  onChanged: (val) {
                    if (val != null) themeNotifier.setThemeMode(val);
                  },
                ),
              ),
              _divider(isDark),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Accent Color', style: TextStyle(fontWeight: FontWeight.w600)),
                    Row(
                      children: ThemeNotifier.availableAccents.map((c) {
                        final isSelected = themeNotifier.accentColor.toARGB32() == c.toARGB32();
                        return GestureDetector(
                          onTap: () => themeNotifier.setAccentColor(c),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(color: Colors.white, width: 2.5) : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: c.withValues(alpha: 0.5),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Section: Audio Engine
          _sectionHeader(context, 'Audio Playback Engine', primary),
          _glassCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                secondary: _iconBadge(Icons.high_quality_rounded, primary),
                title: const Text('Show Lossless / Hi-Res Badges', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Display golden/cyan badges on verified FLAC tracks',
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12.5),
                ),
                activeColor: primary,
                value: settings.showLosslessBadges,
                onChanged: (val) => settings.setShowLosslessBadges(val),
              ),
              _divider(isDark),
              SwitchListTile(
                secondary: _iconBadge(Icons.graphic_eq_rounded, primary),
                title: const Text('Gapless Playback', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Seamless transitions between queued tracks',
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12.5),
                ),
                activeColor: primary,
                value: settings.gaplessPlayback,
                onChanged: (val) => settings.setGaplessPlayback(val),
              ),
              _divider(isDark),
              ListTile(
                leading: _iconBadge(Icons.info_outline_rounded, primary),
                title: const Text('Engine Specs', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'just_audio 0.9.42 • Android MediaSession • FLAC Lossless Decoder',
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Section: Home Screen Widget
          _sectionHeader(context, 'Android Home Screen Widget', primary),
          _glassCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: _iconBadge(Icons.widgets_outlined, primary),
                title: const Text('Widget Status', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'AnahadAppWidgetProvider registered with live controls',
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12.5),
                ),
                trailing: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    WidgetSyncService.updateWidget(
                      title: 'ANAHAD Studio Test',
                      artist: 'Lossless Audio Pipeline',
                      format: 'FLAC 24-BIT / 96kHz',
                      isPlaying: false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sent sync broadcast to Home Screen Widget!')),
                    );
                  },
                  child: const Text('Test Sync'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Section: Lock Screen & Notification Customization
          _sectionHeader(context, 'Lock Screen & Notification', primary),
          _glassCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                secondary: _iconBadge(Icons.lyrics_rounded, primary),
                title: const Text('Live Lyrics on Lock Screen', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Show real-time synchronized karaoke lyrics in lock screen media player & notification shade',
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12.5),
                ),
                activeColor: primary,
                value: settings.lockscreenLyrics,
                onChanged: (val) => settings.setLockscreenLyrics(val),
              ),
              _divider(isDark),
              SwitchListTile(
                secondary: _iconBadge(Icons.badge_outlined, primary),
                title: const Text('Lock Screen Format Badge', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Display lossless encoding badge (e.g. FLAC / AAC 320k) on notification',
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12.5),
                ),
                activeColor: primary,
                value: settings.lockscreenFormatBadge,
                onChanged: (val) => settings.setLockscreenFormatBadge(val),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Section: Music Storage & Download Location
          _sectionHeader(context, 'Music Storage & Download Location', primary),
          _glassCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: _iconBadge(Icons.folder_special_outlined, primary),
                title: const Text('Music Save Destination', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  _getDownloadLocationLabel(StorageService.getDownloadLocationType()),
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12.5),
                ),
                trailing: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _showDownloadLocationDialog(context, isDark, primary),
                  child: const Text('Customize'),
                ),
              ),
              _divider(isDark),
              ListTile(
                leading: _iconBadge(Icons.verified_outlined, primary),
                title: const Text('Offline Storage Structure', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Full resolution master stream bundled with synchronized .lrc lyrics',
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Section: Multi-Provider Architecture
          _sectionHeader(context, 'Music Acquisition Providers', primary),
          _glassCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                secondary: _iconBadge(Icons.public_rounded, primary),
                title: const Text('Universal Provider (yt-dlp)', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Status: ${settings.universalEnabled ? 'Active' : 'Disabled'} • Direct Lossless Streamer',
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12.5),
                ),
                activeColor: primary,
                value: settings.universalEnabled,
                onChanged: (val) => settings.setUniversalEnabled(val),
              ),
              _divider(isDark),
              SwitchListTile(
                secondary: _iconBadge(Icons.music_video_rounded, primary),
                title: const Text('Deezer Provider', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Status: ${settings.deezerEnabled ? 'Active' : 'Standby'} • ARL Session Authentication',
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12.5),
                ),
                activeColor: primary,
                value: settings.deezerEnabled,
                onChanged: (val) => settings.setDeezerEnabled(val),
              ),
              if (settings.deezerEnabled)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'ARL Token',
                      hintText: 'Enter Deezer 192-char ARL cookie',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    controller: TextEditingController(text: settings.deezerArl),
                    onChanged: (val) => settings.setDeezerArl(val),
                  ),
                ),
              _divider(isDark),
              SwitchListTile(
                secondary: _iconBadge(Icons.cloud_off_rounded, primary),
                title: const Text('DAB Provider', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Status: ${settings.dabEnabled ? 'Connected' : 'Offline / Architectural Stub'}',
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12.5),
                ),
                activeColor: primary,
                value: settings.dabEnabled,
                onChanged: (val) => settings.setDabEnabled(val),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Section: Library & Storage
          _sectionHeader(context, 'Data & Library Storage', primary),
          _glassCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: _iconBadge(Icons.refresh_rounded, primary),
                title: const Text('Rescan Device Music', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Re-index all audio files from device storage',
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12.5),
                ),
                trailing: Icon(Icons.chevron_right_rounded, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                onTap: () {
                  library.refreshLibrary();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scanning device storage for music...')),
                  );
                },
              ),
              _divider(isDark),
              ListTile(
                leading: _iconBadge(Icons.history_rounded, primary),
                title: const Text('Clear Listening History', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Remove recently played cache',
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12.5),
                ),
                trailing: Icon(Icons.chevron_right_rounded, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                onTap: () async {
                  await StorageService.clearHistory();
                  library.refreshLibrary();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('History cleared')),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Section: Backup & Restore
          _sectionHeader(context, 'Backup & Restore (Import & Export)', primary),
          _glassCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: _iconBadge(Icons.file_upload_outlined, primary),
                title: const Text('Export Backup to Device', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Export playlists, favorites and settings to JSON file',
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12.5),
                ),
                trailing: Icon(Icons.download_rounded, color: primary),
                onTap: () async {
                  try {
                    final path = await StorageService.saveBackupToFile();
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: isDark ? const Color(0xFF0F151B) : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          title: const Text('Backup Exported Successfully', style: TextStyle(fontWeight: FontWeight.w800)),
                          content: Text('Your ANAHAD backup has been saved to:\n\n$path\n\nAll playlists, favorites, and settings are preserved.'),
                          actions: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Export error: $e')),
                      );
                    }
                  }
                },
              ),
              _divider(isDark),
              ListTile(
                leading: _iconBadge(Icons.copy_all_rounded, primary),
                title: const Text('Copy Backup JSON', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Copy full backup payload to clipboard',
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12.5),
                ),
                trailing: Icon(Icons.copy_rounded, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                onTap: () async {
                  final jsonStr = StorageService.exportBackupJson();
                  await Clipboard.setData(ClipboardData(text: jsonStr));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Backup JSON copied to clipboard!')),
                    );
                  }
                },
              ),
              _divider(isDark),
              ListTile(
                leading: _iconBadge(Icons.settings_backup_restore_rounded, primary),
                title: const Text('Import & Restore Backup', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Restore playlists and data from backup JSON',
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12.5),
                ),
                trailing: Icon(Icons.chevron_right_rounded, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                onTap: () => _showRestoreDialog(context, library, isDark, primary),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Section: About
          _sectionHeader(context, 'About ANAHAD', primary),
          _glassCard(
            isDark: isDark,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: primary.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Icon(Icons.headphones_rounded, color: primary, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ANAHAD Audio Player',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Version 1.0.0 (Release 1) • Build 1.0.0+1',
                            style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _divider(isDark),
              ListTile(
                leading: _iconBadge(Icons.policy_rounded, primary),
                title: const Text('Legal & Privacy', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  'Terms, Privacy Policy, Disclaimer & Open-Source Licenses',
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12.5),
                ),
                trailing: Icon(Icons.chevron_right_rounded, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const LegalPrivacyScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, Color primary) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: primary,
        ),
      ),
    );
  }

  Widget _iconBadge(IconData icon, Color primary) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: primary, size: 20),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      indent: 56,
      color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
    );
  }

  Widget _glassCard({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F151B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  void _showRestoreDialog(BuildContext context, LibraryNotifier library, bool isDark, Color primary) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0F151B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Restore Backup', style: TextStyle(fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paste your exported ANAHAD backup JSON below to restore playlists, favorites, and settings:',
              style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 6,
              style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Paste backup JSON here...',
                hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                filled: true,
                fillColor: isDark ? const Color(0xFF070B0E) : Colors.black.withValues(alpha: 0.03),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final data = await Clipboard.getData('text/plain');
                    if (data?.text != null) {
                      textController.text = data!.text!;
                    }
                  },
                  icon: Icon(Icons.paste_rounded, size: 16, color: primary),
                  label: Text('Paste from Clipboard', style: TextStyle(color: primary)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              final raw = textController.text.trim();
              if (raw.isEmpty) return;

              try {
                final result = await StorageService.restoreBackupData(raw);
                await library.refreshLibrary();
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Restored successfully: ${result['playlists']} playlists, ${result['favorites']} favorites!',
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Restore failed: $e')),
                  );
                }
              }
            },
            child: const Text('Restore Data', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static String _getDownloadLocationLabel(String type) {
    switch (type) {
      case 'music_dir':
        return 'Device Music Folder (/storage/emulated/0/Music/ANAHAD)';
      case 'downloads_dir':
        return 'Device Downloads (/storage/emulated/0/Download/ANAHAD)';
      case 'custom':
        final custom = StorageService.getCustomDownloadDirectory();
        return custom != null && custom.isNotEmpty ? custom : 'Custom Directory';
      case 'app_storage':
      default:
        return 'Internal App Storage (/downloads)';
    }
  }

  void _showDownloadLocationDialog(BuildContext context, bool isDark, Color primary) {
    final currentType = StorageService.getDownloadLocationType();
    final customPath = StorageService.getCustomDownloadDirectory() ?? '';
    final customController = TextEditingController(text: customPath);

    showDialog(
      context: context,
      builder: (ctx) {
        String selectedType = currentType;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF0F151B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  Icon(Icons.folder_special_rounded, color: primary),
                  const SizedBox(width: 10),
                  Text('Music Save Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select or customize the folder where offline FLAC/audio files and synchronized .lrc lyrics are saved:',
                      style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      activeColor: primary,
                      title: const Text('App Storage (Default)'),
                      subtitle: const Text('Internal app files, private & isolated'),
                      value: 'app_storage',
                      groupValue: selectedType,
                      onChanged: (val) => setDialogState(() => selectedType = val!),
                    ),
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      activeColor: primary,
                      title: const Text('Device Music Folder'),
                      subtitle: const Text('/storage/emulated/0/Music/ANAHAD'),
                      value: 'music_dir',
                      groupValue: selectedType,
                      onChanged: (val) => setDialogState(() => selectedType = val!),
                    ),
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      activeColor: primary,
                      title: const Text('Device Downloads Folder'),
                      subtitle: const Text('/storage/emulated/0/Download/ANAHAD'),
                      value: 'downloads_dir',
                      groupValue: selectedType,
                      onChanged: (val) => setDialogState(() => selectedType = val!),
                    ),
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      activeColor: primary,
                      title: const Text('Custom Folder Path...'),
                      subtitle: const Text('Specify any accessible directory'),
                      value: 'custom',
                      groupValue: selectedType,
                      onChanged: (val) => setDialogState(() => selectedType = val!),
                    ),
                    if (selectedType == 'custom') ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: customController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Custom Directory Path',
                          hintText: '/storage/emulated/0/MyMusic',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          isDense: true,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel', style: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    await StorageService.setDownloadLocationType(selectedType);
                    if (selectedType == 'custom') {
                      await StorageService.setCustomDownloadDirectory(customController.text.trim());
                    }
                    setState(() {});
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Music save location set to: ${_getDownloadLocationLabel(selectedType)}'),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  child: const Text('Save Destination', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
