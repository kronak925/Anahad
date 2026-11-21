import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anahad/models/track_model.dart';
import 'package:anahad/models/lyrics_line.dart';
import 'package:anahad/models/playlist_model.dart';
import 'package:anahad/services/lyrics_service.dart';
import 'package:anahad/services/storage_service.dart';
import 'package:anahad/ui/widgets/audio_format_badge.dart';
import 'package:anahad/ui/widgets/anahad_brand_icon.dart';
import 'package:anahad/ui/widgets/air_shuffle_button.dart';
import 'package:anahad/ui/screens/legal_privacy_screen.dart';

void main() {
  group('ANAHAD Track Model & Format Tests', () {
    test('TrackModel detects FLAC lossless accurately', () {
      const flacTrack = TrackModel(
        id: 'flac_1',
        title: 'Master Track 1',
        artist: 'ANAHAD Studio',
        album: 'Acoustics',
        duration: Duration(minutes: 3, seconds: 30),
        uri: 'content://audio/1',
        format: 'FLAC',
        sampleRate: 96000,
        bitDepth: 24,
        isLossless: true,
      );

      expect(flacTrack.isLossless, isTrue);
      expect(flacTrack.format, 'FLAC');
      expect(flacTrack.sampleRate, 96000);
      expect(flacTrack.bitDepth, 24);

      final json = flacTrack.toJson();
      final fromJson = TrackModel.fromJson(json);

      expect(fromJson.id, 'flac_1');
      expect(fromJson.title, 'Master Track 1');
      expect(fromJson.isLossless, isTrue);
      expect(fromJson.format, 'FLAC');
    });

    test('TrackModel converts to AudioService MediaItem with extras', () {
      const track = TrackModel(
        id: 'track_42',
        title: 'Test Symphony',
        artist: 'Orchestra',
        album: 'Classics',
        duration: Duration(seconds: 180),
        uri: '/storage/emulated/0/Music/track.flac',
        format: 'FLAC',
        isLossless: true,
      );

      final mediaItem = track.toMediaItem();
      expect(mediaItem.id, 'track_42');
      expect(mediaItem.title, 'Test Symphony');
      expect(mediaItem.extras?['format'], 'FLAC');
      expect(mediaItem.extras?['isLossless'], isTrue);
    });
  });

  group('ANAHAD Lyrics Engine Tests', () {
    test('LyricsService parses timestamped LRC lines accurately', () {
      const sampleLrc = '''
[00:04.50]Line 1 of the song
[00:12.00]Line 2 of the song with resonance
[01:05.25]Line 3 after one minute
''';

      final lines = LyricsService.parseLrc(sampleLrc);

      expect(lines.length, 3);
      expect(lines[0].timestamp, const Duration(seconds: 4, milliseconds: 500));
      expect(lines[0].text, 'Line 1 of the song');
      expect(lines[1].timestamp, const Duration(seconds: 12));
      expect(lines[2].timestamp, const Duration(minutes: 1, seconds: 5, milliseconds: 250));
    });

    test('LyricsService findActiveLineIndex returns correct line based on position', () {
      final lines = [
        const LyricsLine(timestamp: Duration(seconds: 0), text: 'Intro'),
        const LyricsLine(timestamp: Duration(seconds: 10), text: 'Verse 1'),
        const LyricsLine(timestamp: Duration(seconds: 25), text: 'Chorus'),
        const LyricsLine(timestamp: Duration(seconds: 50), text: 'Outro'),
      ];

      expect(LyricsService.findActiveLineIndex(lines, const Duration(seconds: 5)), 0);
      expect(LyricsService.findActiveLineIndex(lines, const Duration(seconds: 15)), 1);
      expect(LyricsService.findActiveLineIndex(lines, const Duration(seconds: 25)), 2);
      expect(LyricsService.findActiveLineIndex(lines, const Duration(seconds: 40)), 2);
      expect(LyricsService.findActiveLineIndex(lines, const Duration(seconds: 60)), 3);
    });
  });

  group('ANAHAD Playlist Tests', () {
    test('PlaylistModel serializes and deserializes properly', () {
      final playlist = PlaylistModel(
        id: 'pl_001',
        name: 'Late Night Lossless',
        description: 'Selected FLAC tracks',
        trackIds: ['flac_1', 'flac_2'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final json = playlist.toJson();
      final fromJson = PlaylistModel.fromJson(json);

      expect(fromJson.id, 'pl_001');
      expect(fromJson.name, 'Late Night Lossless');
      expect(fromJson.trackIds.length, 2);
      expect(fromJson.trackIds.contains('flac_1'), isTrue);
    });
  });

  group('ANAHAD UI Widget Tests', () {
    testWidgets('AudioFormatBadge renders Hi-Res Lossless badge correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AudioFormatBadge(
              format: 'FLAC',
              isLossless: true,
              sampleRate: 96000,
              bitDepth: 24,
            ),
          ),
        ),
      );

      expect(find.textContaining('HI-RES LOSSLESS'), findsOneWidget);
      expect(find.textContaining('24B/96.0kHz'), findsOneWidget);
    });

    testWidgets('AudioFormatBadge renders compact badge correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AudioFormatBadge(
              format: 'FLAC',
              isLossless: true,
              compact: true,
            ),
          ),
        ),
      );

      expect(find.text('FLAC'), findsOneWidget);
    });

    testWidgets('AnahadBrandIcon renders CustomPaint with specified size and animates', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnahadBrandIcon(size: 48, isPlaying: true),
          ),
        ),
      );

      expect(find.byType(AnahadBrandIcon), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      // Verify animation ticks smoothly
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AnahadBrandIcon), findsOneWidget);
    });

    testWidgets('AirShuffleButton renders compact icon and pill button with contextLabel', (tester) async {
      final List<TrackModel> sampleTracks = [
        const TrackModel(
          id: 'test_1',
          title: 'Track One',
          artist: 'Artist',
          album: 'Album',
          duration: Duration(minutes: 3),
          uri: 'http://example.com/1',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AirShuffleButton(
                  tracksProvider: () => sampleTracks,
                  contextLabel: 'Trending',
                  compact: true,
                ),
                AirShuffleButton(
                  tracksProvider: () => sampleTracks,
                  contextLabel: 'Offline',
                  compact: false,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Air Shuffle'), findsOneWidget);
      expect(find.byIcon(Icons.shuffle_rounded), findsNWidgets(2));
    });
  });

  group('ANAHAD Backup & Restore Storage Tests', () {
    test('StorageService exports and restores backup JSON seamlessly', () async {
      SharedPreferences.setMockInitialValues({
        'anahad_favorites': ['fav_track_1', 'fav_track_2'],
        'anahad_search_history': ['Arijit Singh', 'Kesariya'],
        'lockscreen_lyrics_enabled': true,
        'audio_show_lossless_badge': true,
      });

      await StorageService.initialize();

      final backupJson = StorageService.exportBackupJson();
      expect(backupJson, contains('fav_track_1'));
      expect(backupJson, contains('Arijit Singh'));
      expect(backupJson, contains('lockscreenLyrics'));

      // Now clear preferences
      SharedPreferences.setMockInitialValues({});
      await StorageService.initialize();
      expect(StorageService.getFavorites().isEmpty, isTrue);

      // Restore from backup
      final stats = await StorageService.restoreBackupData(backupJson);
      expect(stats['favorites'], 2);
      expect(stats['searches'], 2);

      final restoredFavs = StorageService.getFavorites();
      expect(restoredFavs.contains('fav_track_1'), isTrue);
      expect(restoredFavs.contains('fav_track_2'), isTrue);
      expect(StorageService.getSearchHistory().contains('Kesariya'), isTrue);
      expect(StorageService.getLockscreenLyrics(), isTrue);
    });
  });

  group('ANAHAD Legal & Privacy Screen UI Tests', () {
    testWidgets('LegalPrivacyScreen renders all policy sections and headers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LegalPrivacyScreen(),
        ),
      );

      expect(find.text('Legal & Privacy'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Legal Disclaimer'), findsOneWidget);
      expect(find.text('Copyright & Attribution'), findsOneWidget);
      expect(find.text('Third-Party Licenses'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Contact Legal & Privacy Maintainer'), 200);
      expect(find.text('Contact Legal & Privacy Maintainer'), findsOneWidget);
    });
  });
}
