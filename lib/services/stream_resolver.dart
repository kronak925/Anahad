import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/track_model.dart';
import 'jiosaavn_service.dart';

class ResolvedStream {
  final String url;
  final String format;
  final int bitrate;
  final String source; // "saavn", "youtube", "local"

  const ResolvedStream({
    required this.url,
    required this.format,
    required this.bitrate,
    required this.source,
  });
}

class StreamResolver {
  final YoutubeExplode _yt;

  StreamResolver({YoutubeExplode? yt}) : _yt = yt ?? YoutubeExplode();

  /// Resolves the playable audio stream for any given TrackModel
  Future<ResolvedStream?> resolveStream(TrackModel track, {bool forceFallback = false}) async {
    // 1. Local or sample track
    if (track.sourceType == AudioSourceType.local || track.sourceType == AudioSourceType.sample) {
      return ResolvedStream(
        url: track.uri,
        format: track.format,
        bitrate: track.bitrate ?? 320,
        source: 'local',
      );
    }

    // 2. JioSaavn track
    if (track.sourceType == AudioSourceType.saavn) {
      // If forceFallback is requested, try 160k quality first
      if (forceFallback && track.encryptedMediaUrl != null && track.encryptedMediaUrl!.isNotEmpty) {
        final decrypted160 = JioSaavnService.decryptMediaUrl(track.encryptedMediaUrl, quality: '160');
        if (decrypted160 != null && decrypted160.startsWith('http') && decrypted160 != track.uri) {
          return ResolvedStream(
            url: decrypted160,
            format: 'AAC 160k',
            bitrate: 160,
            source: 'saavn',
          );
        }
      }

      // Check if already decrypted (when not forcing fallback)
      if (!forceFallback && track.uri.startsWith('http') && !track.uri.contains('preview.saavncdn.com')) {
        return ResolvedStream(
          url: track.uri,
          format: 'AAC 320k',
          bitrate: 320,
          source: 'saavn',
        );
      }

      // Try decrypting encrypted_media_url
      if (!forceFallback && track.encryptedMediaUrl != null && track.encryptedMediaUrl!.isNotEmpty) {
        final decrypted = JioSaavnService.decryptMediaUrl(track.encryptedMediaUrl, quality: '320');
        if (decrypted != null && decrypted.startsWith('http')) {
          return ResolvedStream(
            url: decrypted,
            format: 'AAC 320k',
            bitrate: 320,
            source: 'saavn',
          );
        }
      }

      // If JioSaavn direct CDN URL is not available or failed, fall back to YouTube resolution
      debugPrint('[StreamResolver] JioSaavn CDN unavailable, attempting YouTube fallback for: ${track.title}');
    }

    // 3. YouTube stream resolution (primary for YouTube tracks, fallback for JioSaavn/Universal)
    try {
      debugPrint('[StreamResolver] YouTube query: "${track.title} ${track.artist} Audio"');
      final query = '${track.title} ${track.artist} Audio';
      final searchResults = await _yt.search.search(query);

      if (searchResults.isNotEmpty) {
        final video = searchResults.first;
        debugPrint('[StreamResolver] Direct YouTube id: ${video.id.value} ("${video.title}")');

        final manifest = await _yt.videos.streamsClient.getManifest(video.id);
        final audioStreams = manifest.audioOnly.sortByBitrate();

        if (audioStreams.isNotEmpty) {
          final bestAudio = audioStreams.last;
          final bitrateKbps = (bestAudio.bitrate.kiloBitsPerSecond).round();
          final codec = bestAudio.audioCodec.contains('mp4a') ? 'AAC' : 'Opus';

          return ResolvedStream(
            url: bestAudio.url.toString(),
            format: '$codec ${bitrateKbps}k',
            bitrate: bitrateKbps,
            source: 'youtube',
          );
        }
      }
    } catch (e) {
      debugPrint('[StreamResolver] YouTube resolution error: $e');
    }

    // 4. Return existing URI as last-resort fallback
    if (track.uri.startsWith('http')) {
      return ResolvedStream(
        url: track.uri,
        format: track.format,
        bitrate: track.bitrate ?? 128,
        source: track.sourceType.name,
      );
    }

    return null;
  }

  void dispose() {
    _yt.close();
  }
}
