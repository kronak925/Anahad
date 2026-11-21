import 'dart:convert';
import 'package:dart_des/dart_des.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/online_album_model.dart';
import '../models/online_artist_model.dart';
import '../models/track_model.dart';

class JioSaavnService {
  static const String _baseUrl = 'https://www.jiosaavn.com/api.php';
  static const String _desKey = '38346591';

  final http.Client _client;

  JioSaavnService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'application/json',
      };

  /// Decrypts JioSaavn's DES-ECB encrypted media URL into direct CDN stream URL
  static String? decryptMediaUrl(String? encryptedUrl, {String quality = '320'}) {
    if (encryptedUrl == null || encryptedUrl.isEmpty) return null;

    try {
      final key = utf8.encode(_desKey);
      final des = DES(key: key, mode: DESMode.ECB, paddingType: DESPaddingType.PKCS7);
      final encryptedBytes = base64.decode(encryptedUrl.trim());
      final decryptedBytes = des.decrypt(encryptedBytes);
      final decryptedUrl = utf8.decode(decryptedBytes).trim();

      // Replace default preview/bitrate suffix with requested bitrate
      // Available qualities: 320, 160, 96, 48, 12
      String finalUrl = decryptedUrl;
      if (quality == '320') {
        finalUrl = finalUrl.replaceAll('_96.mp4', '_320.mp4').replaceAll('_160.mp4', '_320.mp4');
      } else if (quality == '160') {
        finalUrl = finalUrl.replaceAll('_96.mp4', '_160.mp4').replaceAll('_320.mp4', '_160.mp4');
      }

      return finalUrl;
    } catch (e) {
      debugPrint('[StreamResolver] JioSaavn DES decrypt error: $e');
      return null;
    }
  }

  /// Search online songs by query
  Future<List<TrackModel>> searchSongs(String query, {int page = 1, int limit = 25}) async {
    if (query.trim().isEmpty) return [];

    try {
      final uri = Uri.parse(
        '$_baseUrl?__call=search.getResults&_format=json&_marker=0&cc=in&p=$page&n=$limit&q=${Uri.encodeComponent(query.trim())}',
      );

      final response = await _client.get(uri, headers: _headers);
      if (response.statusCode != 200) return [];

      final body = response.body.trim();
      final data = json.decode(body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>?;

      if (results == null) return [];

      return results
          .whereType<Map<String, dynamic>>()
          .map((item) {
            final track = TrackModel.fromJioSaavnJson(item);
            // Pre-decrypt stream URL if encrypted_media_url exists
            final decrypted = decryptMediaUrl(track.encryptedMediaUrl, quality: '320');
            return track.copyWith(uri: decrypted ?? track.uri);
          })
          .toList();
    } catch (e) {
      debugPrint('[CatalogService] JioSaavn song search error: $e');
      return [];
    }
  }

  /// Search online albums by query
  Future<List<OnlineAlbumModel>> searchAlbums(String query, {int page = 1, int limit = 15}) async {
    if (query.trim().isEmpty) return [];

    try {
      final uri = Uri.parse(
        '$_baseUrl?__call=search.getAlbumResults&_format=json&_marker=0&cc=in&p=$page&n=$limit&q=${Uri.encodeComponent(query.trim())}',
      );

      final response = await _client.get(uri, headers: _headers);
      if (response.statusCode != 200) return [];

      final data = json.decode(response.body.trim()) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>?;

      if (results == null) return [];

      return results
          .whereType<Map<String, dynamic>>()
          .map((item) => OnlineAlbumModel.fromJioSaavnJson(item))
          .toList();
    } catch (e) {
      debugPrint('[CatalogService] JioSaavn album search error: $e');
      return [];
    }
  }

  /// Search online artists by query
  Future<List<OnlineArtistModel>> searchArtists(String query, {int page = 1, int limit = 15}) async {
    if (query.trim().isEmpty) return [];

    try {
      final uri = Uri.parse(
        '$_baseUrl?__call=search.getArtistResults&_format=json&_marker=0&cc=in&p=$page&n=$limit&q=${Uri.encodeComponent(query.trim())}',
      );

      final response = await _client.get(uri, headers: _headers);
      if (response.statusCode != 200) return [];

      final data = json.decode(response.body.trim()) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>?;

      if (results == null) return [];

      return results
          .whereType<Map<String, dynamic>>()
          .map((item) => OnlineArtistModel.fromJioSaavnJson(item))
          .toList();
    } catch (e) {
      debugPrint('[CatalogService] JioSaavn artist search error: $e');
      return [];
    }
  }

  /// Get detailed album tracklist by album ID
  Future<OnlineAlbumModel?> getAlbumDetails(String albumId) async {
    final cleanId = albumId.replaceAll('saavn_album_', '');
    if (cleanId.isEmpty) return null;

    try {
      final uri = Uri.parse(
        '$_baseUrl?__call=content.getAlbumDetails&_format=json&cc=in&albumid=$cleanId',
      );

      final response = await _client.get(uri, headers: _headers);
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body.trim()) as Map<String, dynamic>;
      final album = OnlineAlbumModel.fromJioSaavnJson(data);

      // Decrypt stream URLs for album tracks
      final decryptedTracks = album.tracks.map((t) {
        final stream = decryptMediaUrl(t.encryptedMediaUrl, quality: '320');
        return t.copyWith(uri: stream ?? t.uri);
      }).toList();

      return OnlineAlbumModel(
        id: album.id,
        title: album.title,
        artist: album.artist,
        year: album.year,
        image: album.image,
        songCount: decryptedTracks.length,
        tracks: decryptedTracks,
      );
    } catch (e) {
      debugPrint('[CatalogService] JioSaavn album details error: $e');
      return null;
    }
  }

  /// Get artist details and top songs/albums
  Future<OnlineArtistModel?> getArtistDetails(String artistId) async {
    final cleanId = artistId.replaceAll('saavn_artist_', '');
    if (cleanId.isEmpty) return null;

    try {
      final uri = Uri.parse(
        '$_baseUrl?__call=artist.getArtistPageDetails&_format=json&cc=in&artistId=$cleanId',
      );

      final response = await _client.get(uri, headers: _headers);
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body.trim()) as Map<String, dynamic>;
      final artist = OnlineArtistModel.fromJioSaavnJson(data);

      // Decrypt stream URLs for artist top songs
      var decryptedTracks = artist.topSongs.map((t) {
        final stream = decryptMediaUrl(t.encryptedMediaUrl, quality: '320');
        return t.copyWith(uri: stream ?? t.uri);
      }).toList();

      // If topSongs was empty, seamlessly fall back to searching songs by this artist
      if (decryptedTracks.isEmpty && artist.name.isNotEmpty && artist.name != 'Unknown Artist') {
        final searchedSongs = await searchSongs(artist.name, limit: 20);
        if (searchedSongs.isNotEmpty) {
          decryptedTracks = searchedSongs;
        }
      }

      return OnlineArtistModel(
        id: artist.id,
        name: artist.name,
        image: artist.image,
        role: artist.role,
        followerCount: artist.followerCount,
        topSongs: decryptedTracks,
        topAlbums: artist.topAlbums,
      );
    } catch (e) {
      debugPrint('[CatalogService] JioSaavn artist details error: $e');
      return null;
    }
  }

  /// Get recommendations for a given song ID
  Future<List<TrackModel>> getRecommendations(String songId) async {
    final cleanId = songId.replaceAll('saavn_', '');
    if (cleanId.isEmpty) return [];

    try {
      final uri = Uri.parse(
        '$_baseUrl?__call=reco.getreco&_format=json&_marker=0&cc=in&pid=$cleanId',
      );

      final response = await _client.get(uri, headers: _headers);
      if (response.statusCode != 200) return [];

      final data = json.decode(response.body.trim());
      List<dynamic> recoList = [];
      if (data is Map<String, dynamic>) {
        if (data.containsKey(cleanId) && data[cleanId] is List) {
          recoList = data[cleanId] as List;
        } else if (data.values.isNotEmpty && data.values.first is List) {
          recoList = data.values.first as List;
        }
      } else if (data is List) {
        recoList = data;
      }

      return recoList
          .whereType<Map<String, dynamic>>()
          .map((item) {
            final track = TrackModel.fromJioSaavnJson(item);
            final stream = decryptMediaUrl(track.encryptedMediaUrl, quality: '320');
            return track.copyWith(uri: stream ?? track.uri);
          })
          .toList();
    } catch (e) {
      debugPrint('[CatalogService] reco.getreco error: $e');
      return [];
    }
  }

  /// Fetch curated trending / charts tracks for discovery
  Future<List<TrackModel>> getTrendingTracks() async {
    final results = await searchSongs('Top Trending India', limit: 15);
    if (results.isNotEmpty) return results;
    return searchSongs('Arijit Singh Hits', limit: 15);
  }

  /// Fetch featured albums for discovery
  Future<List<OnlineAlbumModel>> getFeaturedAlbums() async {
    final results = await searchAlbums('Bollywood Hits', limit: 10);
    if (results.isNotEmpty) return results;
    return searchAlbums('Romantic', limit: 10);
  }

  /// Fetch featured artists for discovery with guaranteed distinct Indian artists
  Future<List<OnlineArtistModel>> getFeaturedArtists() async {
    const featuredNames = [
      'Arijit Singh',
      'Shreya Ghoshal',
      'A.R. Rahman',
      'Diljit Dosanjh',
      'Atif Aslam',
      'Anirudh Ravichander',
      'Pritam',
      'Neha Kakkar',
      'Sonu Nigam',
      'Badshah',
      'Sid Sriram',
      'Jubin Nautiyal',
    ];

    final List<OnlineArtistModel> artists = [];
    final Set<String> seenNames = {};

    try {
      // Query artists individually to avoid one timeout cancelling all others
      final futures = featuredNames.map((name) async {
        try {
          final res = await searchArtists(name, limit: 1);
          return res.isNotEmpty ? res.first : null;
        } catch (_) {
          return null;
        }
      });

      final results = await Future.wait(futures);
      for (final a in results) {
        if (a != null && a.name.isNotEmpty && !seenNames.contains(a.name.toLowerCase())) {
          seenNames.add(a.name.toLowerCase());
          artists.add(a);
        }
      }

      if (artists.isNotEmpty) return artists;
    } catch (e) {
      debugPrint('[CatalogService] getFeaturedArtists error: $e');
    }

    // Diverse fallback roster with distinct names and default IDs
    return const [
      OnlineArtistModel(
        id: 'saavn_artist_arijit_singh',
        name: 'Arijit Singh',
        role: 'Singer • Composer',
      ),
      OnlineArtistModel(
        id: 'saavn_artist_shreya_ghoshal',
        name: 'Shreya Ghoshal',
        role: 'Singer',
      ),
      OnlineArtistModel(
        id: 'saavn_artist_ar_rahman',
        name: 'A.R. Rahman',
        role: 'Music Director',
      ),
      OnlineArtistModel(
        id: 'saavn_artist_diljit_dosanjh',
        name: 'Diljit Dosanjh',
        role: 'Singer • Actor',
      ),
      OnlineArtistModel(
        id: 'saavn_artist_anirudh_ravichander',
        name: 'Anirudh Ravichander',
        role: 'Music Composer',
      ),
      OnlineArtistModel(
        id: 'saavn_artist_pritam',
        name: 'Pritam',
        role: 'Music Director',
      ),
      OnlineArtistModel(
        id: 'saavn_artist_atif_aslam',
        name: 'Atif Aslam',
        role: 'Singer',
      ),
      OnlineArtistModel(
        id: 'saavn_artist_sonu_nigam',
        name: 'Sonu Nigam',
        role: 'Singer',
      ),
    ];
  }
}
