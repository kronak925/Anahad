import 'package:flutter/services.dart';

class WidgetSyncService {
  static const MethodChannel _channel = MethodChannel('com.anahad.audio/widget');

  static Function()? onPlayPausePressed;
  static Function()? onNextPressed;
  static Function()? onPrevPressed;

  static void initialize({
    Function()? onPlayPause,
    Function()? onNext,
    Function()? onPrev,
  }) {
    onPlayPausePressed = onPlayPause;
    onNextPressed = onNext;
    onPrevPressed = onPrev;

    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onWidgetPlayPause':
          onPlayPausePressed?.call();
          break;
        case 'onWidgetNext':
          onNextPressed?.call();
          break;
        case 'onWidgetPrev':
          onPrevPressed?.call();
          break;
      }
    });
  }

  static Future<void> updateWidget({
    required String title,
    required String artist,
    required String format,
    required bool isPlaying,
    String? artPath,
    String? lyric,
  }) async {
    try {
      await _channel.invokeMethod('updateWidget', {
        'title': title,
        'artist': artist,
        'format': format,
        'isPlaying': isPlaying,
        'artPath': artPath,
        'lyric': lyric,
      });
    } catch (e) {
      // Best-effort widget update
    }
  }
}
