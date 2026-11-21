import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import '../models/lyrics_line.dart';
import '../models/track_model.dart';
import '../services/audio_handler.dart';
import '../services/lyrics_service.dart';
import '../services/storage_service.dart';
import '../services/widget_sync_service.dart';

class PlaybackNotifier extends ChangeNotifier {
  final AnahadAudioHandler _handler;

  PlaybackState _playbackState = PlaybackState();
  MediaItem? _currentMediaItem;
  List<MediaItem> _queue = [];
  Duration _position = Duration.zero;
  Duration _bufferedPosition = Duration.zero;
  Duration _duration = Duration.zero;

  List<LyricsLine> _currentTrackLyrics = [];
  String? _lastLoadedTrackId;
  int _lastActiveLyricIndex = -2;

  StreamSubscription? _stateSub;
  StreamSubscription? _itemSub;
  StreamSubscription? _queueSub;
  StreamSubscription? _posSub;
  StreamSubscription? _bufSub;
  StreamSubscription? _durSub;

  PlaybackNotifier(this._handler) {
    _initListeners();
    _initWidgetSync();
  }

  AnahadAudioHandler get handler => _handler;
  bool get isPlaying => _playbackState.playing;
  MediaItem? get currentMediaItem => _currentMediaItem;
  List<MediaItem> get queue => _queue;
  Duration get position => _position;
  Duration get bufferedPosition => _bufferedPosition;
  Duration get duration => _duration;
  PlaybackState get playbackState => _playbackState;
  List<LyricsLine> get currentTrackLyrics => _currentTrackLyrics;
  bool get hasLyrics => _currentTrackLyrics.isNotEmpty;

  bool get isShuffleEnabled => _playbackState.shuffleMode == AudioServiceShuffleMode.all;
  AudioServiceRepeatMode get repeatMode => _playbackState.repeatMode;

  void _initListeners() {
    _stateSub = _handler.playbackState.listen((state) {
      _playbackState = state;
      _syncWidget();
      notifyListeners();
    });

    _itemSub = _handler.mediaItem.listen((item) {
      _currentMediaItem = item;
      if (item != null) {
        _duration = item.duration ?? Duration.zero;
        StorageService.addToHistory(item.id);
        if (_lastLoadedTrackId != item.id) {
          _lastLoadedTrackId = item.id;
          _currentLyric = null;
          _lastActiveLyricIndex = -1;
          _loadLyricsForCurrentItem(item);
        }
      }
      _syncWidget();
      notifyListeners();
    });

    _queueSub = _handler.queue.listen((q) {
      _queue = q;
      notifyListeners();
    });

    _posSub = _handler.player.positionStream.listen((pos) {
      _position = pos;
      _updateLiveLockscreenLyric(pos);
      notifyListeners();
    });

    _bufSub = _handler.player.bufferedPositionStream.listen((buf) {
      _bufferedPosition = buf;
      notifyListeners();
    });

    _durSub = _handler.player.durationStream.listen((dur) {
      if (dur != null) {
        _duration = dur;
        notifyListeners();
      }
    });
  }

  Future<void> _loadLyricsForCurrentItem(MediaItem item) async {
    _currentTrackLyrics = [];
    _lastActiveLyricIndex = -2;
    try {
      final track = TrackModel(
        id: item.id,
        title: item.title,
        artist: item.extras?['originalArtist'] ?? item.artist ?? 'Unknown',
        album: item.album ?? '',
        duration: item.duration ?? Duration.zero,
        uri: item.extras?['uri'] ?? '',
        path: item.extras?['path'],
        format: item.extras?['format'] ?? 'MP3',
        isLossless: item.extras?['isLossless'] == true,
      );
      final lyrics = await LyricsService.loadLyricsForTrack(track);
      if (_lastLoadedTrackId == item.id) {
        _currentTrackLyrics = lyrics;
        _updateLiveLockscreenLyric(_position);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[PlaybackNotifier] Failed to load lyrics: $e');
    }
  }

  String? _currentLyric;

  void _updateLiveLockscreenLyric(Duration pos) {
    if (_currentTrackLyrics.isEmpty) return;

    final activeIdx = LyricsService.findActiveLineIndex(_currentTrackLyrics, pos);
    if (activeIdx != _lastActiveLyricIndex) {
      _lastActiveLyricIndex = activeIdx;
      final lyric = (activeIdx >= 0 && activeIdx < _currentTrackLyrics.length)
          ? _currentTrackLyrics[activeIdx].text
          : null;
      _currentLyric = lyric;
      if (StorageService.getLockscreenLyrics()) {
        _handler.updateLockscreenLyrics(lyric);
      }
      _syncWidget();
    }
  }

  String? _lastSyncedTitle;
  String? _lastSyncedArtist;
  bool? _lastSyncedPlaying;
  String? _lastSyncedLyric;

  void _syncWidget() {
    final item = _currentMediaItem;
    if (item == null) return;
    final isLossless = item.extras?['isLossless'] == true;
    final rawFormat = item.extras?['format'] ?? 'FLAC';
    final badge = isLossless ? 'FLAC 24-BIT' : rawFormat;
    final title = item.title;
    final artist = item.extras?['originalArtist'] ?? item.artist ?? 'Ready to play';
    final playing = isPlaying;
    final lyric = _currentLyric;

    if (_lastSyncedTitle == title &&
        _lastSyncedArtist == artist &&
        _lastSyncedPlaying == playing &&
        _lastSyncedLyric == lyric) {
      return;
    }

    _lastSyncedTitle = title;
    _lastSyncedArtist = artist;
    _lastSyncedPlaying = playing;
    _lastSyncedLyric = lyric;

    WidgetSyncService.updateWidget(
      title: title,
      artist: artist,
      format: badge,
      isPlaying: playing,
      artPath: item.artUri?.toString() ?? item.extras?['path'],
      lyric: lyric,
    );
  }

  void _initWidgetSync() {
    WidgetSyncService.initialize(
      onPlayPause: () => togglePlayPause(),
      onNext: () => skipToNext(),
      onPrev: () => skipToPrevious(),
    );
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await _handler.pause();
    } else {
      await _handler.play();
    }
  }

  Future<void> play() async => await _handler.play();
  Future<void> pause() async => await _handler.pause();
  Future<void> stop() async => await _handler.stop();
  Future<void> seek(Duration pos) async => await _handler.seek(pos);
  Future<void> skipToNext() async => await _handler.skipToNext();
  Future<void> skipToPrevious() async => await _handler.skipToPrevious();
  Future<void> skipToQueueItem(int index) async => await _handler.skipToQueueItem(index);

  Future<void> playTrack(TrackModel track, {List<TrackModel>? playlist, int? index}) async {
    if (playlist != null && playlist.isNotEmpty) {
      final initialIdx = index ?? playlist.indexWhere((t) => t.id == track.id);
      await _handler.loadPlaylist(playlist, initialIndex: initialIdx != -1 ? initialIdx : 0);
    } else {
      await _handler.playTrack(track);
    }
  }

  Future<void> toggleShuffle() async {
    final nextMode = isShuffleEnabled ? AudioServiceShuffleMode.none : AudioServiceShuffleMode.all;
    await _handler.setShuffleMode(nextMode);
  }

  Future<void> cycleRepeatMode() async {
    final nextMode = switch (repeatMode) {
      AudioServiceRepeatMode.none => AudioServiceRepeatMode.all,
      AudioServiceRepeatMode.all => AudioServiceRepeatMode.one,
      AudioServiceRepeatMode.one => AudioServiceRepeatMode.none,
      _ => AudioServiceRepeatMode.none,
    };
    await _handler.setRepeatMode(nextMode);
  }

  Future<void> removeQueueItem(int index) async {
    await _handler.removeQueueItemAt(index);
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _itemSub?.cancel();
    _queueSub?.cancel();
    _posSub?.cancel();
    _bufSub?.cancel();
    _durSub?.cancel();
    super.dispose();
  }
}
