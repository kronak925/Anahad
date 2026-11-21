import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/lyrics_line.dart';
import '../models/track_model.dart';

class LyricsService {
  static final RegExp _lrcRegex = RegExp(r'\[(\d{2}):(\d{2})(?:\.(\d{2,3}))?\](.*)');
  static final http.Client _client = http.Client();

  /// Parse raw LRC text into a list of timestamped lines
  static List<LyricsLine> parseLrc(String content) {
    final List<LyricsLine> lines = [];
    final rawLines = content.split('\n');

    for (final raw in rawLines) {
      final match = _lrcRegex.firstMatch(raw.trim());
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final millisStr = match.group(3);
        int millis = 0;
        if (millisStr != null) {
          if (millisStr.length == 2) {
            millis = int.parse(millisStr) * 10;
          } else {
            millis = int.parse(millisStr.padRight(3, '0').substring(0, 3));
          }
        }
        final text = match.group(4)?.trim() ?? '';
        final timestamp = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: millis,
        );

        if (text.isNotEmpty) {
          lines.add(LyricsLine(timestamp: timestamp, text: text));
        }
      }
    }

    lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return lines;
  }

  static String cleanTrackTitle(String title) {
    var clean = title;
    clean = clean.replaceAll(RegExp(r'\(.*?\)'), '');
    clean = clean.replaceAll(RegExp(r'\[.*?\]'), '');
    if (clean.contains(' - ')) {
      clean = clean.split(' - ').first;
    }
    if (clean.contains(' | ')) {
      clean = clean.split(' | ').first;
    }
    clean = clean.replaceAll(RegExp(r'\b(feat|ft|official|audio|video|lyric|lyrics|remix|version)\b.*', caseSensitive: false), '');
    return clean.trim().isEmpty ? title : clean.trim();
  }

  static String cleanArtistName(String artist) {
    var clean = artist;
    clean = clean.split(',').first;
    clean = clean.split('&').first;
    clean = clean.split(';').first;
    clean = clean.split('/').first;
    clean = clean.replaceAll(RegExp(r'\b(feat|ft)\b.*', caseSensitive: false), '');
    return clean.trim().isEmpty ? artist : clean.trim();
  }

  /// Locate or generate lyrics for a given track
  static Future<List<LyricsLine>> loadLyricsForTrack(TrackModel track) async {
    // 1. Check for local .lrc file next to audio file
    if (track.path != null && track.path!.isNotEmpty) {
      try {
        final lrcPath = track.path!.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '.lrc');
        final lrcFile = File(lrcPath);
        if (await lrcFile.exists()) {
          final content = await lrcFile.readAsString();
          final parsed = parseLrc(content);
          if (parsed.isNotEmpty) return parsed;
        }
      } catch (e) {
        debugPrint('[LyricsService] Local .lrc read error: $e');
      }
    }

    final cleanTitle = cleanTrackTitle(track.title);
    final cleanArtist = cleanArtistName(track.artist);

    // 2. Query LRCLIB direct get endpoint (without strict duration to avoid second mismatches)
    try {
      final uri = Uri.https('lrclib.net', '/api/get', {
        'artist_name': cleanArtist,
        'track_name': cleanTitle,
      });

      final response = await _client.get(uri, headers: {
        'User-Agent': 'ANAHAD/2.2 (Linux; Android; High-Fidelity Audio)',
      }).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final synced = data['syncedLyrics']?.toString();
        if (synced != null && synced.trim().isNotEmpty) {
          final parsed = parseLrc(synced);
          if (parsed.isNotEmpty) return parsed;
        }

        final plain = data['plainLyrics']?.toString();
        if (plain != null && plain.trim().isNotEmpty) {
          return _parsePlainLyrics(plain, track.duration);
        }
      }
    } catch (e) {
      debugPrint('[LyricsService] LRCLIB direct get error: $e');
    }

    // 3. Fallback: Query LRCLIB search endpoint
    try {
      final searchUri = Uri.https('lrclib.net', '/api/search', {
        'q': '$cleanTitle $cleanArtist',
      });

      final response = await _client.get(searchUri, headers: {
        'User-Agent': 'ANAHAD/2.2 (Linux; Android; High-Fidelity Audio)',
      }).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        for (final item in results) {
          if (item is Map<String, dynamic>) {
            final synced = item['syncedLyrics']?.toString();
            if (synced != null && synced.trim().isNotEmpty) {
              final parsed = parseLrc(synced);
              if (parsed.isNotEmpty) return parsed;
            }
          }
        }
        for (final item in results) {
          if (item is Map<String, dynamic>) {
            final plain = item['plainLyrics']?.toString();
            if (plain != null && plain.trim().isNotEmpty) {
              return _parsePlainLyrics(plain, track.duration);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[LyricsService] LRCLIB search fallback error: $e');
    }

    // 4. Query JioSaavn lyrics API for Indian music
    try {
      final saavnUri = Uri.parse(
        'https://www.jiosaavn.com/api.php?__call=lyrics.getLyrics&lyrics_id=${track.id}&ctx=web6dot0&api_version=4&_format=json&_marker=0',
      );
      final response = await _client.get(saavnUri, headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
      }).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body.trim());
        if (data is Map<String, dynamic> && data['lyrics'] != null) {
          final rawLyrics = data['lyrics'].toString();
          // Remove HTML tags (<br>, <i>, etc.)
          final cleanHtml = rawLyrics.replaceAll(RegExp(r'<[^>]*>'), '\n');
          final parsed = _parsePlainLyrics(cleanHtml, track.duration);
          if (parsed.isNotEmpty) return parsed;
        }
      }
    } catch (e) {
      debugPrint('[LyricsService] JioSaavn lyrics fetch error: $e');
    }

    // 5. Fallback only for internal sample tracks
    if (track.id.startsWith('sample_')) {
      return _generateSampleLyrics(track);
    }

    // Return empty list so UI honestly reports "No lyrics available for this track"
    return [];
  }

  static List<LyricsLine> _parsePlainLyrics(String plain, Duration totalDuration) {
    final lines = plain.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isEmpty) return [];

    final durationPerLineMs = totalDuration.inMilliseconds > 0
        ? (totalDuration.inMilliseconds / lines.length).round()
        : 3500;

    return List.generate(lines.length, (i) {
      return LyricsLine(
        timestamp: Duration(milliseconds: i * durationPerLineMs),
        text: lines[i],
      );
    });
  }

  /// Finds the currently active line index based on playback position
  static int findActiveLineIndex(List<LyricsLine> lines, Duration currentPosition) {
    if (lines.isEmpty) return -1;
    for (int i = lines.length - 1; i >= 0; i--) {
      if (currentPosition >= lines[i].timestamp) {
        return i;
      }
    }
    return 0;
  }

  static List<LyricsLine> _generateSampleLyrics(TrackModel track) {
    final title = track.title;
    final artist = track.artist;
    final isFlac = track.isLossless;

    return [
      const LyricsLine(timestamp: Duration(seconds: 0), text: '♪ Instrumental intro ♪'),
      LyricsLine(timestamp: const Duration(seconds: 4), text: 'Now playing: $title'),
      LyricsLine(timestamp: const Duration(seconds: 8), text: 'By $artist'),
      LyricsLine(
        timestamp: const Duration(seconds: 13),
        text: isFlac
            ? 'Lossless FLAC studio stream — pristine soundstage'
            : 'Pristine high-fidelity audio output decoded locally',
      ),
      const LyricsLine(timestamp: Duration(seconds: 18), text: 'Immersed in deep frequency resonances'),
      const LyricsLine(timestamp: Duration(seconds: 24), text: 'Echoes moving through the stereo field'),
      const LyricsLine(timestamp: Duration(seconds: 30), text: 'Harmonics breathing through the silence'),
      const LyricsLine(timestamp: Duration(seconds: 36), text: 'ANAHAD — pure, unadulterated musical depth'),
      const LyricsLine(timestamp: Duration(seconds: 42), text: 'Dynamic range preserved without compression'),
      const LyricsLine(timestamp: Duration(seconds: 49), text: 'Every transient and whisper crystal clear'),
      const LyricsLine(timestamp: Duration(seconds: 56), text: '♪ Instrumental bridge ♪'),
      const LyricsLine(timestamp: Duration(seconds: 68), text: 'The rhythm surges, carrying the night'),
      const LyricsLine(timestamp: Duration(seconds: 78), text: 'Soundwaves unbound in absolute clarity'),
      const LyricsLine(timestamp: Duration(seconds: 90), text: 'Fade into the infinite silence...'),
    ];
  }
}
