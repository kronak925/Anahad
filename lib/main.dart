import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/library_notifier.dart';
import 'providers/online_catalogue_notifier.dart';
import 'providers/playback_notifier.dart';
import 'providers/settings_notifier.dart';
import 'providers/theme_notifier.dart';
import 'services/audio_handler.dart';
import 'services/download_service.dart';
import 'services/media_library_service.dart';
import 'services/storage_service.dart';
import 'services/widget_sync_service.dart';
import 'ui/screens/main_navigation_screen.dart';
import 'ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  } catch (e) {
    debugPrint('SystemUiOverlayStyle error: $e');
  }

  // Initialize persistent storage safely
  try {
    await StorageService.initialize();
  } catch (e) {
    debugPrint('StorageService init error: $e');
  }

  // Initialize background audio service pipeline safely
  AnahadAudioHandler? audioHandler;
  try {
    final handler = await initAudioService();
    if (handler is AnahadAudioHandler) {
      audioHandler = handler;
    }
  } catch (e) {
    debugPrint('AudioService init error: $e');
  }

  // Fallback to direct handler if audio service binding was deferred
  audioHandler ??= AnahadAudioHandler();

  // Initialize home screen widget bidirectional communication with audio handler
  WidgetSyncService.initialize(
    onPlayPause: () {
      if (audioHandler!.player.playing) {
        audioHandler.pause();
      } else {
        audioHandler.play();
      }
    },
    onNext: () => audioHandler!.skipToNext(),
    onPrev: () => audioHandler!.skipToPrevious(),
  );

  // Initialize device media library service
  final libraryService = MediaLibraryService();

  // Initialize download service & connect library service
  final downloadService = DownloadService();
  try {
    await downloadService.initialize();
    downloadService.setMediaLibraryService(libraryService);
  } catch (e) {
    debugPrint('DownloadService init error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => SettingsNotifier()),
        ChangeNotifierProvider(
          create: (_) => PlaybackNotifier(audioHandler!),
        ),
        ChangeNotifierProvider(
          create: (_) => LibraryNotifier(libraryService),
        ),
        ChangeNotifierProvider(create: (_) => OnlineCatalogueNotifier()),
        ChangeNotifierProvider.value(value: downloadService),
      ],
      child: const AnahadApp(),
    ),
  );
}

class AnahadApp extends StatelessWidget {
  const AnahadApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();

    return MaterialApp(
      title: 'ANAHAD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(
        isDark: false,
        isAmoled: false,
        accentColor: themeNotifier.accentColor,
      ),
      darkTheme: AppTheme.getTheme(
        isDark: true,
        isAmoled: themeNotifier.isAmoled,
        accentColor: themeNotifier.accentColor,
      ),
      themeMode: themeNotifier.themeMode,
      home: const MainNavigationScreen(),
    );
  }
}
