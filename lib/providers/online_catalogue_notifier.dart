import 'package:flutter/foundation.dart';
import '../models/online_album_model.dart';
import '../models/online_artist_model.dart';
import '../models/track_model.dart';
import '../services/jiosaavn_service.dart';

enum SearchTab { all, songs, albums, artists, local }

class OnlineCatalogueNotifier extends ChangeNotifier {
  final JioSaavnService _service;

  String _query = '';
  SearchTab _currentTab = SearchTab.all;
  bool _isLoading = false;
  String? _error;

  List<TrackModel> _songResults = [];
  List<OnlineAlbumModel> _albumResults = [];
  List<OnlineArtistModel> _artistResults = [];

  List<TrackModel> _trendingTracks = [];
  List<OnlineAlbumModel> _featuredAlbums = [];
  List<OnlineArtistModel> _featuredArtists = [];
  bool _isDiscoveryLoading = false;

  OnlineCatalogueNotifier({JioSaavnService? service}) : _service = service ?? JioSaavnService() {
    loadDiscoveryContent();
  }

  String get query => _query;
  SearchTab get currentTab => _currentTab;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TrackModel> get songResults => _songResults;
  List<OnlineAlbumModel> get albumResults => _albumResults;
  List<OnlineArtistModel> get artistResults => _artistResults;

  List<TrackModel> get trendingTracks => _trendingTracks;
  List<OnlineAlbumModel> get featuredAlbums => _featuredAlbums;
  List<OnlineArtistModel> get featuredArtists => _featuredArtists;
  bool get isDiscoveryLoading => _isDiscoveryLoading;

  void setTab(SearchTab tab) {
    _currentTab = tab;
    notifyListeners();
  }

  /// Initial load of trending tracks, featured albums and artists for home discovery
  Future<void> loadDiscoveryContent() async {
    _isDiscoveryLoading = true;
    notifyListeners();

    try {
      final trending = await _service.getTrendingTracks();
      final albums = await _service.getFeaturedAlbums();
      final artists = await _service.getFeaturedArtists();

      _trendingTracks = trending;
      _featuredAlbums = albums;
      _featuredArtists = artists;
    } catch (e) {
      debugPrint('[CatalogService] Discovery content loading error: $e');
    } finally {
      _isDiscoveryLoading = false;
      notifyListeners();
    }
  }

  /// Execute online catalogue search across songs, albums, and artists
  Future<void> search(String query) async {
    final cleanQuery = query.trim();
    _query = cleanQuery;

    if (cleanQuery.isEmpty) {
      _songResults = [];
      _albumResults = [];
      _artistResults = [];
      _isLoading = false;
      _error = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Execute searches in parallel
      final songFuture = _service.searchSongs(cleanQuery, limit: 20);
      final albumFuture = _service.searchAlbums(cleanQuery, limit: 12);
      final artistFuture = _service.searchArtists(cleanQuery, limit: 8);

      final results = await Future.wait([songFuture, albumFuture, artistFuture]);

      _songResults = results[0] as List<TrackModel>;
      _albumResults = results[1] as List<OnlineAlbumModel>;
      _artistResults = results[2] as List<OnlineArtistModel>;
    } catch (e) {
      debugPrint('[CatalogService] Online search error: $e');
      _error = 'Failed to load online results: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch full album details by ID
  Future<OnlineAlbumModel?> getAlbumDetails(String albumId) async {
    return _service.getAlbumDetails(albumId);
  }

  /// Fetch full artist details by ID
  Future<OnlineArtistModel?> getArtistDetails(String artistId) async {
    return _service.getArtistDetails(artistId);
  }

  /// Search songs directly (used for artist and language discovery)
  Future<List<TrackModel>> searchSongsDirect(String query, {int limit = 20}) async {
    return _service.searchSongs(query, limit: limit);
  }

  /// Search albums directly (used for language discovery)
  Future<List<OnlineAlbumModel>> searchAlbumsDirect(String query, {int limit = 12}) async {
    return _service.searchAlbums(query, limit: limit);
  }

  /// Fetch recommendations for track
  Future<List<TrackModel>> getRecommendations(String songId) async {
    return _service.getRecommendations(songId);
  }
}
