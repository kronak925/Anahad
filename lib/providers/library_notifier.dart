import 'package:flutter/foundation.dart';
import '../models/playlist_model.dart';
import '../models/track_model.dart';
import '../services/media_library_service.dart';
import '../services/storage_service.dart';

enum SortOption { title, artist, duration, dateAdded }

class LibraryNotifier extends ChangeNotifier {
  final MediaLibraryService _service;

  List<TrackModel> _tracks = [];
  Set<String> _favoriteIds = {};
  List<PlaylistModel> _playlists = [];
  List<String> _historyIds = [];

  bool _isLoading = false;
  SortOption _sortOption = SortOption.dateAdded;
  bool _sortAscending = false;

  LibraryNotifier(this._service) {
    _init();
  }

  MediaLibraryService get service => _service;
  bool get isLoading => _isLoading;
  bool get hasPermission => _service.hasPermission;
  SortOption get sortOption => _sortOption;
  bool get sortAscending => _sortAscending;

  List<TrackModel> get allTracks => _sortedTracks(_tracks);
  List<PlaylistModel> get playlists => _playlists;
  Set<String> get favoriteIds => _favoriteIds;

  List<TrackModel> get favoriteTracks {
    return _sortedTracks(_tracks.where((t) => _favoriteIds.contains(t.id)).toList());
  }

  List<TrackModel> get losslessTracks {
    return _sortedTracks(_tracks.where((t) => t.isLossless).toList());
  }

  List<TrackModel> get downloadedTracks {
    return _sortedTracks(_tracks.where((t) => t.isDownloaded).toList());
  }

  List<TrackModel> get recentTracks {
    final Map<String, TrackModel> trackMap = {for (var t in _tracks) t.id: t};
    return _historyIds.map((id) => trackMap[id]).whereType<TrackModel>().toList();
  }

  List<String> get artists => _service.getArtists();
  List<String> get albums => _service.getAlbums();

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    _favoriteIds = StorageService.getFavorites();
    _playlists = StorageService.getPlaylists();
    _historyIds = StorageService.getHistory();

    await refreshLibrary();
  }

  Future<void> refreshLibrary() async {
    _isLoading = true;
    notifyListeners();

    _tracks = await _service.scanLibrary();
    _historyIds = StorageService.getHistory();
    _favoriteIds = StorageService.getFavorites();
    _playlists = StorageService.getPlaylists();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(String trackId) async {
    final isFav = await StorageService.toggleFavorite(trackId);
    if (isFav) {
      _favoriteIds.add(trackId);
    } else {
      _favoriteIds.remove(trackId);
    }
    notifyListeners();
  }

  bool isFavorite(String trackId) => _favoriteIds.contains(trackId);

  Future<void> createPlaylist(String name, {String? description}) async {
    await StorageService.createPlaylist(name, description: description);
    _playlists = StorageService.getPlaylists();
    notifyListeners();
  }

  Future<void> deletePlaylist(String id) async {
    await StorageService.deletePlaylist(id);
    _playlists = StorageService.getPlaylists();
    notifyListeners();
  }

  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    await StorageService.addTrackToPlaylist(playlistId, trackId);
    _playlists = StorageService.getPlaylists();
    notifyListeners();
  }

  Future<void> removeTrackFromPlaylist(String playlistId, String trackId) async {
    await StorageService.removeTrackFromPlaylist(playlistId, trackId);
    _playlists = StorageService.getPlaylists();
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    if (_sortOption == option) {
      _sortAscending = !_sortAscending;
    } else {
      _sortOption = option;
      _sortAscending = option == SortOption.title || option == SortOption.artist;
    }
    notifyListeners();
  }

  List<TrackModel> _sortedTracks(List<TrackModel> list) {
    final sorted = List<TrackModel>.from(list);
    sorted.sort((a, b) {
      int cmp = 0;
      switch (_sortOption) {
        case SortOption.title:
          cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case SortOption.artist:
          cmp = a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
          break;
        case SortOption.duration:
          cmp = a.duration.compareTo(b.duration);
          break;
        case SortOption.dateAdded:
          final aDate = a.dateAdded ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.dateAdded ?? DateTime.fromMillisecondsSinceEpoch(0);
          cmp = aDate.compareTo(bDate);
          break;
      }
      return _sortAscending ? cmp : -cmp;
    });
    return sorted;
  }

  List<TrackModel> searchTracks(String query, {bool flacOnly = false}) {
    return _service.searchTracks(query, flacOnly: flacOnly);
  }

  List<TrackModel> getTracksByArtist(String artist) => _service.getTracksByArtist(artist);
  List<TrackModel> getTracksByAlbum(String album) => _service.getTracksByAlbum(album);
}
