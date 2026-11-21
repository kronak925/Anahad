import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/track_model.dart';
import 'stream_resolver.dart';
import 'widget_sync_service.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => AnahadAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.anahad.audio.channel.playback',
      androidNotificationChannelName: 'ANAHAD Music Playback',
      androidNotificationChannelDescription: 'Live playback controls for ANAHAD lossless music player',
      androidNotificationOngoing: false,
      androidStopForegroundOnPause: false,
      androidNotificationIcon: 'drawable/ic_notification',
      androidShowNotificationBadge: true,
    ),
  );
}

class AnahadAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  int? _currentIndex;
  List<TrackModel> _rawQueue = [];
  final StreamResolver _resolver = StreamResolver();

  AnahadAudioHandler() {
    _initAudioPipeline();
  }

  void _initAudioPipeline() {
    // Pipe player events to AudioService PlaybackState
    _player.playbackEventStream.listen(_broadcastState);

    // Track sequence changes
    _player.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < queue.value.length) {
        _currentIndex = index;
        mediaItem.add(queue.value[index]);
        _updateHomeScreenWidget();
      }
    });

    // Synchronize mediaItem duration with decoded player duration
    _player.durationStream.listen((dur) {
      if (dur != null && dur > Duration.zero) {
        final current = mediaItem.value;
        if (current != null && (current.duration == null || (current.duration! - dur).abs().inSeconds >= 1)) {
          mediaItem.add(current.copyWith(duration: dur));
        }
      }
    });

    // Handle end of playlist or track completion
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        if (_player.loopMode == LoopMode.off && _currentIndex == queue.value.length - 1) {
          stop();
        }
      }
    });
  }

  List<TrackModel> get rawQueue => List.unmodifiable(_rawQueue);
  AudioPlayer get player => _player;

  /// Sets up a new queue of tracks and starts playing from startIndex
  Future<void> loadPlaylist(List<TrackModel> tracks, {int initialIndex = 0}) async {
    if (tracks.isEmpty) return;
    final playlistTracks = List<TrackModel>.from(tracks);
    final safeIndex = (initialIndex >= 0 && initialIndex < playlistTracks.length) ? initialIndex : 0;

    // Resolve starting track stream URL if needed
    var startingTrack = playlistTracks[safeIndex];
    if ((startingTrack.uri.isEmpty || !startingTrack.uri.startsWith('http')) &&
        (startingTrack.path == null || startingTrack.path!.isEmpty)) {
      try {
        final resolved = await _resolver.resolveStream(startingTrack);
        if (resolved != null && resolved.url.isNotEmpty) {
          startingTrack = startingTrack.copyWith(uri: resolved.url);
          playlistTracks[safeIndex] = startingTrack;
        }
      } catch (e) {
        debugPrint('[AudioHandler] Failed to resolve initial track stream: $e');
      }
    }

    _rawQueue = List.from(playlistTracks);
    final mediaItems = playlistTracks.map((t) => t.toMediaItem()).toList();
    queue.add(mediaItems);

    final audioSources = <AudioSource>[];
    for (final track in playlistTracks) {
      if (track.path != null && track.path!.isNotEmpty) {
        audioSources.add(AudioSource.uri(Uri.file(track.path!), tag: track.toMediaItem()));
      } else if (track.uri.isNotEmpty && track.uri.startsWith('http')) {
        audioSources.add(AudioSource.uri(Uri.parse(track.uri), tag: track.toMediaItem()));
      } else {
        // Fallback placeholder URI
        audioSources.add(AudioSource.uri(Uri.parse('https://aac.saavncdn.com/fallback.mp4'), tag: track.toMediaItem()));
      }
    }

    try {
      await _playlist.clear();
      await _playlist.addAll(audioSources);

      await _player.setAudioSource(
        _playlist,
        initialIndex: safeIndex,
        initialPosition: Duration.zero,
      );

      _currentIndex = safeIndex;
      mediaItem.add(mediaItems[safeIndex]);
      await play();
    } catch (e) {
      debugPrint('[AudioHandler] Player setAudioSource error: $e');
      // Resilient Fallback Recovery:
      // If initial stream fails (e.g. HTTP 403 Forbidden on CDN or unavailable bitrate),
      // seamlessly resolve audio stream via YouTube Explode or 160k fallback
      try {
        final fallbackStream = await _resolver.resolveStream(startingTrack, forceFallback: true);
        if (fallbackStream != null && fallbackStream.url.isNotEmpty && fallbackStream.url != startingTrack.uri) {
          debugPrint('[AudioHandler] Recovering playback with fallback stream: ${fallbackStream.url}');
          final fallbackTrack = startingTrack.copyWith(uri: fallbackStream.url);
          final fallbackSource = AudioSource.uri(Uri.parse(fallbackStream.url), tag: fallbackTrack.toMediaItem());
          await _player.setAudioSource(fallbackSource);
          _currentIndex = 0;
          mediaItem.add(fallbackTrack.toMediaItem());
          await play();
        }
      } catch (fallbackError) {
        debugPrint('[AudioHandler] Fallback playback recovery error: $fallbackError');
      }
    }
  }

  /// Play a single track immediately, inserting it into current position
  Future<void> playTrack(TrackModel track) async {
    var resolvedTrack = track;
    if ((resolvedTrack.uri.isEmpty || !resolvedTrack.uri.startsWith('http')) &&
        (resolvedTrack.path == null || resolvedTrack.path!.isEmpty)) {
      try {
        final resolved = await _resolver.resolveStream(resolvedTrack);
        if (resolved != null && resolved.url.isNotEmpty) {
          resolvedTrack = resolvedTrack.copyWith(uri: resolved.url);
        }
      } catch (e) {
        debugPrint('[AudioHandler] Failed to resolve track stream: $e');
      }
    }
    await loadPlaylist([resolvedTrack], initialIndex: 0);
  }

  @override
  Future<void> play() async {
    await _player.play();
    _updateHomeScreenWidget();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    _updateHomeScreenWidget();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
    _updateHomeScreenWidget();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    } else if (queue.value.isNotEmpty && _player.loopMode == LoopMode.all) {
      await _player.seek(Duration.zero, index: 0);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else if (queue.value.isNotEmpty) {
      await _player.seek(Duration.zero, index: queue.value.length - 1);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= 0 && index < queue.value.length) {
      await _player.seek(Duration.zero, index: index);
      await play();
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        await _player.setLoopMode(LoopMode.all);
        break;
    }
    _broadcastState(_player.playbackEvent);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;
    if (enabled) {
      await _player.shuffle();
    }
    await _player.setShuffleModeEnabled(enabled);
    _broadcastState(_player.playbackEvent);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final uriStr = mediaItem.extras?['uri'] ?? '';
    final pathStr = mediaItem.extras?['path'];
    final source = pathStr != null && pathStr.isNotEmpty
        ? AudioSource.uri(Uri.file(pathStr), tag: mediaItem)
        : AudioSource.uri(Uri.parse(uriStr), tag: mediaItem);

    await _playlist.add(source);
    final newQueue = List<MediaItem>.from(queue.value)..add(mediaItem);
    queue.add(newQueue);
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index >= 0 && index < queue.value.length) {
      await _playlist.removeAt(index);
      final newQueue = List<MediaItem>.from(queue.value)..removeAt(index);
      queue.add(newQueue);
    }
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    final queueIndex = _player.currentIndex;

    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.setRepeatMode,
          MediaAction.setShuffleMode,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: queueIndex,
      ),
    );
  }

  void _updateHomeScreenWidget() {
    final item = mediaItem.value;
    final isPlaying = _player.playing;
    final format = item?.extras?['format'] ?? 'FLAC LOSSLESS';
    final isLossless = item?.extras?['isLossless'] == true;
    final badge = isLossless ? 'FLAC 24-BIT LOSSLESS' : format;

    WidgetSyncService.updateWidget(
      title: item?.title ?? 'ANAHAD Music',
      artist: item?.artist ?? 'Lossless Audio Player',
      format: badge,
      isPlaying: isPlaying,
      artPath: item?.artUri?.toString() ?? item?.extras?['path'],
    );
  }

  void updateLockscreenLyrics(String? lyric) {
    final item = mediaItem.value;
    if (item == null) return;
    final originalArtist = item.extras?['originalArtist'] as String? ?? item.artist ?? 'ANAHAD';
    final hasLyric = lyric != null && lyric.trim().isNotEmpty;
    final displayArtist = hasLyric ? '$originalArtist • ♪ ${lyric.trim()}' : originalArtist;

    if (item.artist != displayArtist) {
      final updated = item.copyWith(
        artist: displayArtist,
        displaySubtitle: hasLyric ? lyric.trim() : originalArtist,
        extras: {
          ...?item.extras,
          'originalArtist': originalArtist,
        },
      );
      mediaItem.add(updated);
    }
  }
}
