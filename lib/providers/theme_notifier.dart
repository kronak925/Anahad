import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeNotifier extends ChangeNotifier {
  String _modeString = 'dark';
  int _accentValue = 0xFFFA233B; // Apple Music Red
  bool _isAmoled = false;

  static const List<Color> availableAccents = [
    Color(0xFFFA233B), // Apple Music Crimson Red
    Color(0xFF8B5CF6), // Royal Purple
    Color(0xFF06B6D4), // Electric Cyan / Teal
    Color(0xFFF59E0B), // Amber Gold
    Color(0xFF10B981), // Emerald Green
    Color(0xFFEC4899), // Pink
  ];

  ThemeNotifier() {
    _init();
  }

  String get modeString => _modeString;
  Color get accentColor => Color(_accentValue);
  bool get isAmoled => _isAmoled;

  ThemeMode get themeMode {
    switch (_modeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.dark;
    }
  }

  void _init() {
    _modeString = StorageService.getThemeMode();
    _accentValue = StorageService.getAccentColor();
    _isAmoled = _modeString == 'amoled';
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _modeString = mode;
    _isAmoled = mode == 'amoled';
    await StorageService.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentValue = color.toARGB32();
    await StorageService.setAccentColor(_accentValue);
    notifyListeners();
  }
}
