import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/track_model.dart';

class MediaLibraryService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  List<TrackModel> _tracks = [];
  bool _hasPermission = false;
  bool _isLoading = false;

  List<TrackModel> get tracks => List.unmodifiable(_tracks);
  bool get hasPermission => _hasPermission;
  bool get isLoading => _isLoading;
  OnAudioQuery get audioQuery => _audioQuery;

  /// Check and request storage/audio permissions
  Future<bool> checkAndRequestPermissions() async {
    try {
      // Try on_audio_query's built in permission check
      bool hasPerm = await _audioQuery.permissionsStatus();
      if (!hasPerm) {
        hasPerm = await _audioQuery.permissionsRequest();
      }

      if (!hasPerm) {
        // Fallback to permission_handler
        final statusAudio = await Permission.audio.request();
        if (statusAudio.isGranted) {
          hasPerm = true;
        } else {
          final statusStorage = await Permission.storage.request();
          if (statusStorage.isGranted) {
            hasPerm = true;
          }
        }
      }

      _hasPermission = hasPerm;
      return hasPerm;
    } catch (e) {
      debugPrint('Permission request error: $e');
      _hasPermission = false;
      return false;
    }
  }

  /// Scans local device media store for audio tracks
  Future<List<TrackModel>> scanLibrary({bool includeSamplesIfEmpty = false}) async {
    _isLoading = true;

    try {
      final permGranted = await checkAndRequestPermissions();

      List<SongModel> songs = [];
      if (permGranted) {
        songs = await _audioQuery.querySongs(
          sortType: SongSortType.DATE_ADDED,
          orderType: OrderType.DESC_OR_GREATER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        );
      }

      final List<TrackModel> loaded = songs.map((s) => TrackModel.fromSongModel(s)).toList();

      // If no local songs were found (e.g. fresh phone or emulator), include curated sample tracks
      if (loaded.isEmpty && includeSamplesIfEmpty) {
        loaded.addAll(_getCuratedSampleTracks());
      }

      _tracks = loaded;
      _isLoading = false;
      return _tracks;
    } catch (e) {
      debugPrint('Error scanning library: $e');
      if (includeSamplesIfEmpty) {
        _tracks = _getCuratedSampleTracks();
      }
      _isLoading = false;
      return _tracks;
    }
  }

  /// Curated sample tracks for immediate testing and verification
  List<TrackModel> _getCuratedSampleTracks() {
    return [
      const TrackModel(
        id: 'sample_flac_01',
        title: 'Celestial Resonance (FLAC 24-bit/96kHz)',
        artist: 'ANAHAD Studio Ensemble',
        album: 'Acoustic Landscapes Vol. 1',
        duration: Duration(minutes: 3, seconds: 45),
        uri: 'https://archive.org/download/test_audio_flac_sample/sample1.flac',
        format: 'FLAC',
        sampleRate: 96000,
        bitDepth: 24,
        bitrate: 4608,
        isLossless: true,
        sourceType: AudioSourceType.sample,
      ),
      const TrackModel(
        id: 'sample_flac_02',
        title: 'Morning Raag Bhairav (FLAC 16-bit/44.1kHz)',
        artist: 'Pandit Shivkumar Collective',
        album: 'Eternal Indian Classical',
        duration: Duration(minutes: 4, seconds: 20),
        uri: 'https://archive.org/download/test_audio_flac_sample/sample2.flac',
        format: 'FLAC',
        sampleRate: 44100,
        bitDepth: 16,
        bitrate: 1411,
        isLossless: true,
        sourceType: AudioSourceType.sample,
      ),
      const TrackModel(
        id: 'sample_mp3_01',
        title: 'Midnight Synthwave Drive (320kbps MP3)',
        artist: 'Cyber Voyager',
        album: 'Neon Horizons',
        duration: Duration(minutes: 3, seconds: 12),
        uri: 'https://archive.org/download/test_audio_flac_sample/sample3.mp3',
        format: 'MP3',
        sampleRate: 44100,
        bitDepth: 16,
        bitrate: 320,
        isLossless: false,
        sourceType: AudioSourceType.sample,
      ),
      const TrackModel(
        id: 'sample_m4a_01',
        title: 'Golden Sunset Acoustic (AAC 256kbps)',
        artist: 'Aura String Quartet',
        album: 'Pure Strings Sessions',
        duration: Duration(minutes: 2, seconds: 58),
        uri: 'https://archive.org/download/test_audio_flac_sample/sample4.m4a',
        format: 'M4A',
        sampleRate: 44100,
        bitDepth: 16,
        bitrate: 256,
        isLossless: false,
        sourceType: AudioSourceType.sample,
      ),
    ];
  }

  /// Adds a locally saved or downloaded track to the library
  void addLocalTrack(TrackModel track) {
    _tracks.removeWhere((t) => t.id == track.id);
    _tracks.insert(0, track);
  }

  /// Get list of unique artists
  List<String> getArtists() {
    final artists = _tracks.map((t) => t.artist).toSet().toList();
    artists.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return artists;
  }

  /// Get list of unique albums
  List<String> getAlbums() {
    final albums = _tracks.map((t) => t.album).toSet().toList();
    albums.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return albums;
  }

  /// Get tracks for a specific artist
  List<TrackModel> getTracksByArtist(String artist) {
    return _tracks.where((t) => t.artist.toLowerCase() == artist.toLowerCase()).toList();
  }

  /// Get tracks for a specific album
  List<TrackModel> getTracksByAlbum(String album) {
    return _tracks.where((t) => t.album.toLowerCase() == album.toLowerCase()).toList();
  }

  /// Filter tracks by query string
  List<TrackModel> searchTracks(String query, {bool flacOnly = false}) {
    if (query.isEmpty && !flacOnly) return _tracks;
    final lower = query.toLowerCase();
    return _tracks.where((t) {
      final matchesQuery = query.isEmpty ||
          t.title.toLowerCase().contains(lower) ||
          t.artist.toLowerCase().contains(lower) ||
          t.album.toLowerCase().contains(lower);
      final matchesFormat = !flacOnly || t.isLossless;
      return matchesQuery && matchesFormat;
    }).toList();
  }
}
