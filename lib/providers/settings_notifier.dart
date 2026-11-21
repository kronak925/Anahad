import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class SettingsNotifier extends ChangeNotifier {
  late bool _universalEnabled;
  late String _universalYtDlp;

  late bool _deezerEnabled;
  late String _deezerArl;
  late String _deezerQuality;

  late bool _dabEnabled;
  late String _dabBaseUrl;

  late bool _showLosslessBadges;
  late bool _gaplessPlayback;
  late bool _lockscreenLyrics;
  late bool _lockscreenFormatBadge;

  SettingsNotifier() {
    _load();
  }

  bool get universalEnabled => _universalEnabled;
  String get universalYtDlp => _universalYtDlp;

  bool get deezerEnabled => _deezerEnabled;
  String get deezerArl => _deezerArl;
  String get deezerQuality => _deezerQuality;

  bool get dabEnabled => _dabEnabled;
  String get dabBaseUrl => _dabBaseUrl;

  bool get showLosslessBadges => _showLosslessBadges;
  bool get gaplessPlayback => _gaplessPlayback;
  bool get lockscreenLyrics => _lockscreenLyrics;
  bool get lockscreenFormatBadge => _lockscreenFormatBadge;

  void _load() {
    _universalEnabled = StorageService.getUniversalEnabled();
    _universalYtDlp = StorageService.getUniversalYtDlp();

    _deezerEnabled = StorageService.getDeezerEnabled();
    _deezerArl = StorageService.getDeezerArl();
    _deezerQuality = StorageService.getDeezerQuality();

    _dabEnabled = StorageService.getDabEnabled();
    _dabBaseUrl = StorageService.getDabBaseUrl();

    _showLosslessBadges = StorageService.getShowLosslessBadge();
    _gaplessPlayback = StorageService.getGaplessPlayback();
    _lockscreenLyrics = StorageService.getLockscreenLyrics();
    _lockscreenFormatBadge = StorageService.getLockscreenFormatBadge();
  }

  Future<void> setUniversalEnabled(bool val) async {
    _universalEnabled = val;
    await StorageService.setUniversalEnabled(val);
    notifyListeners();
  }

  Future<void> setUniversalYtDlp(String val) async {
    _universalYtDlp = val;
    await StorageService.setUniversalYtDlp(val);
    notifyListeners();
  }

  Future<void> setDeezerEnabled(bool val) async {
    _deezerEnabled = val;
    await StorageService.setDeezerEnabled(val);
    notifyListeners();
  }

  Future<void> setDeezerArl(String val) async {
    _deezerArl = val;
    await StorageService.setDeezerArl(val);
    notifyListeners();
  }

  Future<void> setDeezerQuality(String val) async {
    _deezerQuality = val;
    await StorageService.setDeezerQuality(val);
    notifyListeners();
  }

  Future<void> setDabEnabled(bool val) async {
    _dabEnabled = val;
    await StorageService.setDabEnabled(val);
    notifyListeners();
  }

  Future<void> setDabBaseUrl(String val) async {
    _dabBaseUrl = val;
    await StorageService.setDabBaseUrl(val);
    notifyListeners();
  }

  Future<void> setShowLosslessBadges(bool val) async {
    _showLosslessBadges = val;
    await StorageService.setShowLosslessBadge(val);
    notifyListeners();
  }

  Future<void> setGaplessPlayback(bool val) async {
    _gaplessPlayback = val;
    await StorageService.setGaplessPlayback(val);
    notifyListeners();
  }

  Future<void> setLockscreenLyrics(bool val) async {
    _lockscreenLyrics = val;
    await StorageService.setLockscreenLyrics(val);
    notifyListeners();
  }

  Future<void> setLockscreenFormatBadge(bool val) async {
    _lockscreenFormatBadge = val;
    await StorageService.setLockscreenFormatBadge(val);
    notifyListeners();
  }
}
