import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist_model.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static const _keyFavorites = 'anahad_favorites';
  static const _keyPlaylists = 'anahad_playlists';
  static const _keyHistory = 'anahad_history';
  static const _keySearchHistory = 'anahad_search_history';
  static const _keyThemeMode = 'anahad_theme_mode';
  static const _keyAccentColor = 'anahad_accent_color';

  // Lockscreen & Notification settings
  static const _keyLockscreenLyrics = 'lockscreen_lyrics_enabled';
  static const _keyLockscreenFormatBadge = 'lockscreen_format_badge_enabled';

  // Provider configs
  static const _keyUniversalEnabled = 'provider_universal_enabled';
  static const _keyUniversalYtDlp = 'provider_universal_ytdlp';
  static const _keyDeezerEnabled = 'provider_deezer_enabled';
  static const _keyDeezerArl = 'provider_deezer_arl';
  static const _keyDeezerQuality = 'provider_deezer_quality';
  static const _keyDabEnabled = 'provider_dab_enabled';
  static const _keyDabBaseUrl = 'provider_dab_base_url';

  // Audio settings
  static const _keyShowLosslessBadge = 'audio_show_lossless_badge';
  static const _keyGaplessPlayback = 'audio_gapless_playback';

  // Storage & Download location settings
  static const _keyDownloadLocationType = 'download_location_type';
  static const _keyCustomDownloadDir = 'custom_download_dir';

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Generic Storage Helpers ---
  static String? getString(String key) => _prefs.getString(key);
  static Future<void> setString(String key, String value) => _prefs.setString(key, value);

  // --- Favorites ---
  static Set<String> getFavorites() {
    final list = _prefs.getStringList(_keyFavorites) ?? [];
    return list.toSet();
  }

  static Future<void> saveFavorites(Set<String> favorites) async {
    await _prefs.setStringList(_keyFavorites, favorites.toList());
  }

  static Future<bool> toggleFavorite(String trackId) async {
    final favs = getFavorites();
    final bool isFav;
    if (favs.contains(trackId)) {
      favs.remove(trackId);
      isFav = false;
    } else {
      favs.add(trackId);
      isFav = true;
    }
    await saveFavorites(favs);
    return isFav;
  }

  // --- History ---
  static List<String> getHistory() {
    return _prefs.getStringList(_keyHistory) ?? [];
  }

  static Future<void> addToHistory(String trackId) async {
    final history = getHistory();
    history.remove(trackId);
    history.insert(0, trackId);
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }
    await _prefs.setStringList(_keyHistory, history);
  }

  static Future<void> clearHistory() async {
    await _prefs.remove(_keyHistory);
  }

  // --- Search History ---
  static List<String> getSearchHistory() {
    return _prefs.getStringList(_keySearchHistory) ?? [];
  }

  static Future<void> addSearchHistory(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;
    final list = getSearchHistory();
    list.removeWhere((item) => item.toLowerCase() == clean.toLowerCase());
    list.insert(0, clean);
    if (list.length > 25) {
      list.removeRange(25, list.length);
    }
    await _prefs.setStringList(_keySearchHistory, list);
  }

  static Future<void> removeSearchHistory(String query) async {
    final list = getSearchHistory();
    list.removeWhere((item) => item.toLowerCase() == query.trim().toLowerCase());
    await _prefs.setStringList(_keySearchHistory, list);
  }

  static Future<void> clearSearchHistory() async {
    await _prefs.remove(_keySearchHistory);
  }

  // --- Playlists ---
  static List<PlaylistModel> getPlaylists() {
    final rawList = _prefs.getStringList(_keyPlaylists) ?? [];
    return rawList.map((str) {
      try {
        return PlaylistModel.fromJson(jsonDecode(str) as Map<String, dynamic>);
      } catch (e) {
        return null;
      }
    }).whereType<PlaylistModel>().toList();
  }

  static Future<void> savePlaylists(List<PlaylistModel> playlists) async {
    final rawList = playlists.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs.setStringList(_keyPlaylists, rawList);
  }

  static Future<void> createPlaylist(String name, {String? description}) async {
    final playlists = getPlaylists();
    final newPlaylist = PlaylistModel(
      id: 'pl_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      trackIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    playlists.add(newPlaylist);
    await savePlaylists(playlists);
  }

  static Future<void> deletePlaylist(String id) async {
    final playlists = getPlaylists();
    playlists.removeWhere((p) => p.id == id);
    await savePlaylists(playlists);
  }

  static Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    final playlists = getPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final pl = playlists[index];
      if (!pl.trackIds.contains(trackId)) {
        final updated = pl.copyWith(
          trackIds: [...pl.trackIds, trackId],
          updatedAt: DateTime.now(),
        );
        playlists[index] = updated;
        await savePlaylists(playlists);
      }
    }
  }

  static Future<void> removeTrackFromPlaylist(String playlistId, String trackId) async {
    final playlists = getPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final pl = playlists[index];
      final newTracks = List<String>.from(pl.trackIds)..remove(trackId);
      playlists[index] = pl.copyWith(
        trackIds: newTracks,
        updatedAt: DateTime.now(),
      );
      await savePlaylists(playlists);
    }
  }

  // --- Theme & Appearance ---
  static String getThemeMode() => _prefs.getString(_keyThemeMode) ?? 'dark';
  static Future<void> setThemeMode(String mode) async => await _prefs.setString(_keyThemeMode, mode);

  static int getAccentColor() => _prefs.getInt(_keyAccentColor) ?? 0xFFFA233B; // Apple Music Red default
  static Future<void> setAccentColor(int color) async => await _prefs.setInt(_keyAccentColor, color);

  // --- Provider Configs ---
  static bool getUniversalEnabled() => _prefs.getBool(_keyUniversalEnabled) ?? true;
  static Future<void> setUniversalEnabled(bool val) async => await _prefs.setBool(_keyUniversalEnabled, val);

  static String getUniversalYtDlp() => _prefs.getString(_keyUniversalYtDlp) ?? 'bundled';
  static Future<void> setUniversalYtDlp(String val) async => await _prefs.setString(_keyUniversalYtDlp, val);

  static bool getDeezerEnabled() => _prefs.getBool(_keyDeezerEnabled) ?? false;
  static Future<void> setDeezerEnabled(bool val) async => await _prefs.setBool(_keyDeezerEnabled, val);

  static String getDeezerArl() => _prefs.getString(_keyDeezerArl) ?? '';
  static Future<void> setDeezerArl(String val) async => await _prefs.setString(_keyDeezerArl, val);

  static String getDeezerQuality() => _prefs.getString(_keyDeezerQuality) ?? 'FLAC';
  static Future<void> setDeezerQuality(String val) async => await _prefs.setString(_keyDeezerQuality, val);

  static bool getDabEnabled() => _prefs.getBool(_keyDabEnabled) ?? false;
  static Future<void> setDabEnabled(bool val) async => await _prefs.setBool(_keyDabEnabled, val);

  static String getDabBaseUrl() => _prefs.getString(_keyDabBaseUrl) ?? 'http://127.0.0.1:8080';
  static Future<void> setDabBaseUrl(String val) async => await _prefs.setString(_keyDabBaseUrl, val);

  // --- Audio Settings ---
  static bool getShowLosslessBadge() => _prefs.getBool(_keyShowLosslessBadge) ?? true;
  static Future<void> setShowLosslessBadge(bool val) async => await _prefs.setBool(_keyShowLosslessBadge, val);

  static bool getGaplessPlayback() => _prefs.getBool(_keyGaplessPlayback) ?? true;
  static Future<void> setGaplessPlayback(bool val) async => await _prefs.setBool(_keyGaplessPlayback, val);

  // --- Lockscreen & Notification Settings ---
  static bool getLockscreenLyrics() => _prefs.getBool(_keyLockscreenLyrics) ?? true;
  static Future<void> setLockscreenLyrics(bool val) async => await _prefs.setBool(_keyLockscreenLyrics, val);

  static bool getLockscreenFormatBadge() => _prefs.getBool(_keyLockscreenFormatBadge) ?? true;
  static Future<void> setLockscreenFormatBadge(bool val) async => await _prefs.setBool(_keyLockscreenFormatBadge, val);

  // --- Storage & Download Location Settings ---
  static String getDownloadLocationType() => _prefs.getString(_keyDownloadLocationType) ?? 'app_storage';
  static Future<void> setDownloadLocationType(String type) async => await _prefs.setString(_keyDownloadLocationType, type);

  static String? getCustomDownloadDirectory() => _prefs.getString(_keyCustomDownloadDir);
  static Future<void> setCustomDownloadDirectory(String? path) async {
    if (path == null) {
      await _prefs.remove(_keyCustomDownloadDir);
    } else {
      await _prefs.setString(_keyCustomDownloadDir, path);
    }
  }

  // --- Backup & Restore (Import & Export) ---
  static Map<String, dynamic> createBackupData() {
    return {
      'version': 1,
      'appName': 'ANAHAD',
      'timestamp': DateTime.now().toIso8601String(),
      'favorites': getFavorites().toList(),
      'history': getHistory(),
      'searchHistory': getSearchHistory(),
      'playlists': getPlaylists().map((p) => p.toJson()).toList(),
      'settings': {
        'themeMode': getThemeMode(),
        'accentColor': getAccentColor(),
        'lockscreenLyrics': getLockscreenLyrics(),
        'lockscreenFormatBadge': getLockscreenFormatBadge(),
        'showLosslessBadge': getShowLosslessBadge(),
        'gaplessPlayback': getGaplessPlayback(),
        'universalEnabled': getUniversalEnabled(),
        'deezerEnabled': getDeezerEnabled(),
        'dabEnabled': getDabEnabled(),
      },
    };
  }

  static String exportBackupJson() {
    final data = createBackupData();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static Future<String> saveBackupToFile() async {
    final jsonStr = exportBackupJson();
    final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/ANAHAD_Backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonStr, flush: true);
    return file.path;
  }

  static Future<Map<String, int>> restoreBackupData(String jsonString) async {
    try {
      final decoded = jsonDecode(jsonString.trim()) as Map<String, dynamic>;

      int favsCount = 0;
      int playlistsCount = 0;
      int searchCount = 0;

      // Restore favorites
      if (decoded['favorites'] is List) {
        final favList = (decoded['favorites'] as List).map((e) => e.toString()).toSet();
        await saveFavorites(favList);
        favsCount = favList.length;
      }

      // Restore history
      if (decoded['history'] is List) {
        final hist = (decoded['history'] as List).map((e) => e.toString()).toList();
        await _prefs.setStringList(_keyHistory, hist);
      }

      // Restore search history
      if (decoded['searchHistory'] is List) {
        final searches = (decoded['searchHistory'] as List).map((e) => e.toString()).toList();
        await _prefs.setStringList(_keySearchHistory, searches);
        searchCount = searches.length;
      }

      // Restore playlists
      if (decoded['playlists'] is List) {
        final restoredPlaylists = (decoded['playlists'] as List)
            .whereType<Map<String, dynamic>>()
            .map((item) => PlaylistModel.fromJson(item))
            .toList();
        await savePlaylists(restoredPlaylists);
        playlistsCount = restoredPlaylists.length;
      }

      // Restore settings
      if (decoded['settings'] is Map<String, dynamic>) {
        final s = decoded['settings'] as Map<String, dynamic>;
        if (s['themeMode'] is String) await setThemeMode(s['themeMode'] as String);
        if (s['accentColor'] is int) await setAccentColor(s['accentColor'] as int);
        if (s['lockscreenLyrics'] is bool) await setLockscreenLyrics(s['lockscreenLyrics'] as bool);
        if (s['lockscreenFormatBadge'] is bool) await setLockscreenFormatBadge(s['lockscreenFormatBadge'] as bool);
        if (s['showLosslessBadge'] is bool) await setShowLosslessBadge(s['showLosslessBadge'] as bool);
        if (s['gaplessPlayback'] is bool) await setGaplessPlayback(s['gaplessPlayback'] as bool);
      }

      return {
        'favorites': favsCount,
        'playlists': playlistsCount,
        'searches': searchCount,
      };
    } catch (e) {
      throw Exception('Invalid or corrupted backup JSON: $e');
    }
  }
}
