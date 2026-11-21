import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:provider/provider.dart';
import '../../models/track_model.dart';
import '../../providers/library_notifier.dart';
import '../../providers/playback_notifier.dart';
import '../../services/download_service.dart';
import '../../services/storage_service.dart';
import '../widgets/audio_format_badge.dart';
import '../widgets/lyrics_view.dart';
import '../widgets/queue_sheet.dart';
import '../widgets/track_artwork.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  bool _showLyrics = false;
  bool _showRemainingTime = false;
  double? _dragValue;

  String _formatTime(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<PlaybackNotifier>();
    final library = context.watch<LibraryNotifier>();
    final downloadService = context.watch<DownloadService>();
    final currentItem = playback.currentMediaItem;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    if (currentItem == null) {
      return Scaffold(
        appBar: AppBar(leading: const CloseButton()),
        body: const Center(child: Text('No track loaded')),
      );
    }

    final isLossless = currentItem.extras?['isLossless'] == true;
    final format = currentItem.extras?['format'] ?? 'MP3';
    final sampleRate = currentItem.extras?['sampleRate'] as int?;
    final bitDepth = currentItem.extras?['bitDepth'] as int?;
    final isFavorite = library.isFavorite(currentItem.id);

    final trackModel = TrackModel(
      id: currentItem.id,
      title: currentItem.title,
      artist: currentItem.artist ?? 'ANAHAD Studio',
      album: currentItem.album ?? 'Original Master',
      duration: playback.duration,
      uri: currentItem.extras?['uri'] ?? '',
      path: currentItem.extras?['path'],
      format: format,
      sampleRate: sampleRate,
      bitDepth: bitDepth,
      isLossless: isLossless,
    );

    final currentPosition = Duration(
      milliseconds: (_dragValue ?? playback.position.inMilliseconds.toDouble()).round(),
    );
    final totalDuration = playback.duration;
    final remainingDuration = totalDuration - currentPosition;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF040608) : theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            // 1. Dynamic Ambient Glowing Backdrop (Obsidian style)
            if (isDark)
              Positioned(
                top: -60,
                left: -40,
                right: -40,
                height: 480,
                child: Center(
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          primary.withValues(alpha: 0.28),
                          const Color(0xFF0D2538).withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

            // Backdrop blur layer for subtle diffusion
            if (isDark)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                  child: const SizedBox.expand(),
                ),
              ),

            // 2. Main Player Foreground Content
            SafeArea(
              child: Column(
                children: [
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                          tooltip: 'Dismiss',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                currentItem.album ?? 'ANAHAD AUDIO',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 3),
                              AudioFormatBadge(
                                format: format,
                                isLossless: isLossless,
                                sampleRate: sampleRate,
                                bitDepth: bitDepth,
                                compact: false,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_horiz_rounded, size: 28),
                          tooltip: 'Track Specs',
                          onPressed: () => _showTrackInfoDialog(context, trackModel),
                        ),
                      ],
                    ),
                  ),

                  // Middle View: Swipable Artwork or Synced Lyrics
                  Expanded(
                    child: _showLyrics
                        ? LyricsView(track: trackModel)
                        : GestureDetector(
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity != null) {
                                if (details.primaryVelocity! < -250) {
                                  playback.skipToNext();
                                } else if (details.primaryVelocity! > 250) {
                                  playback.skipToPrevious();
                                }
                              }
                            },
                            onTap: () => setState(() => _showLyrics = true),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Hero(
                                    tag: 'now_playing_artwork_${currentItem.id}',
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDark
                                                ? primary.withValues(alpha: 0.32)
                                                : Colors.black.withValues(alpha: 0.2),
                                            blurRadius: 44,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 16),
                                          ),
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.15),
                                            blurRadius: 24,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: TrackArtwork(
                                          id: currentItem.id,
                                          artUri: currentItem.artUri?.toString(),
                                          size: double.infinity,
                                          borderRadius: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),

                  // Track Title, Artist & Favorite Toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentItem.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentItem.artist ?? 'ANAHAD Studio',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          iconSize: 28,
                          tooltip: isFavorite ? 'Favorited' : 'Add to Favorites',
                          icon: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFavorite ? primary : theme.iconTheme.color?.withValues(alpha: 0.45),
                          ),
                          onPressed: () => library.toggleFavorite(currentItem.id),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Fluid Audiophile Seekbar Slider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4.5,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                        activeTrackColor: primary,
                        inactiveTrackColor: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.08),
                        thumbColor: primary,
                      ),
                      child: Slider(
                        min: 0.0,
                        max: totalDuration.inMilliseconds.toDouble() > 0
                            ? totalDuration.inMilliseconds.toDouble()
                            : 1.0,
                        value: (_dragValue ?? playback.position.inMilliseconds.toDouble()).clamp(
                          0.0,
                          totalDuration.inMilliseconds.toDouble() > 0
                              ? totalDuration.inMilliseconds.toDouble()
                              : 1.0,
                        ),
                        onChanged: (val) {
                          setState(() => _dragValue = val);
                        },
                        onChangeEnd: (val) {
                          playback.seek(Duration(milliseconds: val.round()));
                          setState(() => _dragValue = null);
                        },
                      ),
                    ),
                  ),

                  // Elapsed & Remaining Time Indicators
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(currentPosition),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _showRemainingTime = !_showRemainingTime),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _showRemainingTime
                                  ? '-${_formatTime(remainingDuration.isNegative ? Duration.zero : remainingDuration)}'
                                  : _formatTime(totalDuration),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Main Audiophile Transport Row (Shuffle, Prev, Hero Play/Pause, Next, Repeat)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Shuffle Button
                        IconButton(
                          iconSize: 26,
                          tooltip: 'Shuffle',
                          icon: Icon(
                            playback.isShuffleEnabled ? Icons.shuffle_on_rounded : Icons.shuffle_rounded,
                            color: playback.isShuffleEnabled
                                ? primary
                                : theme.iconTheme.color?.withValues(alpha: 0.45),
                          ),
                          onPressed: () => playback.toggleShuffle(),
                        ),

                        // Previous Track
                        IconButton(
                          iconSize: 38,
                          tooltip: 'Previous',
                          icon: const Icon(Icons.skip_previous_rounded),
                          onPressed: () => playback.skipToPrevious(),
                        ),

                        // Hero Circular Play / Pause Action Button (Obsidian Glow)
                        GestureDetector(
                          onTap: () => playback.togglePlayPause(),
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  primary,
                                  primary.withValues(alpha: 0.85),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withValues(alpha: isDark ? 0.45 : 0.3),
                                  blurRadius: 26,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              playback.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              size: 38,
                              color: const Color(0xFF040608),
                            ),
                          ),
                        ),

                        // Next Track
                        IconButton(
                          iconSize: 38,
                          tooltip: 'Next',
                          icon: const Icon(Icons.skip_next_rounded),
                          onPressed: () => playback.skipToNext(),
                        ),

                        // Repeat Mode
                        IconButton(
                          iconSize: 26,
                          tooltip: 'Repeat',
                          icon: Icon(
                            playback.repeatMode == AudioServiceRepeatMode.one
                                ? Icons.repeat_one_rounded
                                : Icons.repeat_rounded,
                            color: playback.repeatMode != AudioServiceRepeatMode.none
                                ? primary
                                : theme.iconTheme.color?.withValues(alpha: 0.45),
                          ),
                          onPressed: () => playback.cycleRepeatMode(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bottom Floating Glass Action Capsule (Lyrics, Playlist, Download, Queue)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xCC0E151C) : Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // 1. Live Karaoke Lyrics Toggle
                              IconButton(
                                iconSize: 24,
                                tooltip: 'Karaoke Lyrics',
                                icon: Icon(
                                  Icons.lyrics_rounded,
                                  color: _showLyrics ? primary : theme.iconTheme.color?.withValues(alpha: 0.6),
                                ),
                                onPressed: () {
                                  setState(() => _showLyrics = !_showLyrics);
                                },
                              ),

                              // 2. Add to Playlist
                              IconButton(
                                iconSize: 24,
                                tooltip: 'Add to Playlist',
                                icon: Icon(
                                  Icons.playlist_add_rounded,
                                  color: theme.iconTheme.color?.withValues(alpha: 0.75),
                                ),
                                onPressed: () => _showAddToPlaylistSheet(context, trackModel, library),
                              ),

                              // 3. Offline Download
                              _buildDownloadButton(context, trackModel, downloadService, theme),

                              // 4. Playing Queue
                              IconButton(
                                iconSize: 24,
                                tooltip: 'Queue',
                                icon: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(Icons.queue_music_rounded, color: theme.iconTheme.color?.withValues(alpha: 0.75)),
                                    if (playback.queue.isNotEmpty)
                                      Positioned(
                                        top: -3,
                                        right: -4,
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${playback.queue.length}',
                                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    barrierColor: Colors.black.withValues(alpha: 0.6),
                                    builder: (ctx) => const QueueSheet(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(
    BuildContext context,
    TrackModel track,
    DownloadService downloadService,
    ThemeData theme,
  ) {
    final isDownloaded = downloadService.isDownloaded(track.id);
    final isDownloading = downloadService.isDownloading(track.id);
    final progress = downloadService.getProgress(track.id);

    if (isDownloading) {
      return SizedBox(
        width: 32,
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progress > 0 ? progress : null,
              strokeWidth: 2.5,
              color: theme.colorScheme.primary,
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    if (isDownloaded) {
      return IconButton(
        iconSize: 24,
        tooltip: 'Downloaded Offline',
        icon: Icon(Icons.download_done_rounded, color: theme.colorScheme.primary),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Track is already downloaded and saved offline.')),
          );
        },
      );
    }

    return IconButton(
      iconSize: 24,
      tooltip: 'Download Track',
      icon: Icon(Icons.download_rounded, color: theme.iconTheme.color?.withValues(alpha: 0.75)),
      onPressed: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Starting download for "${track.title}"...')),
        );
        final success = await downloadService.downloadTrack(track);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Successfully downloaded "${track.title}" with offline lyrics!'
                    : 'Download failed for "${track.title}".',
              ),
            ),
          );
        }
      },
    );
  }

  void _showAddToPlaylistSheet(BuildContext context, TrackModel track, LibraryNotifier library) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final playlists = library.playlists;
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add to Playlist',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('New Playlist'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showCreatePlaylistDialog(context, track, library);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                if (playlists.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    child: Center(
                      child: Text(
                        'No playlists yet. Tap "New Playlist" above to create one.',
                        style: TextStyle(color: theme.textTheme.bodySmall?.color),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: playlists.length,
                      itemBuilder: (c, idx) {
                        final pl = playlists[idx];
                        final contains = pl.trackIds.contains(track.id);
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.queue_music_rounded, color: theme.colorScheme.primary),
                          ),
                          title: Text(pl.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${pl.trackIds.length} tracks'),
                          trailing: contains
                              ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                              : const Icon(Icons.add_circle_outline_rounded),
                          onTap: () async {
                            if (contains) {
                              await StorageService.removeTrackFromPlaylist(pl.id, track.id);
                              library.refreshLibrary();
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Removed "${track.title}" from ${pl.name}')),
                                );
                              }
                            } else {
                              await StorageService.addTrackToPlaylist(pl.id, track.id);
                              library.refreshLibrary();
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Added "${track.title}" to ${pl.name}')),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, TrackModel track, LibraryNotifier library) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Playlist Name',
            hintText: 'e.g. Late Night Lossless, Acoustics',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await StorageService.createPlaylist(name);
                final updated = StorageService.getPlaylists();
                final created = updated.lastWhere((p) => p.name == name);
                await StorageService.addTrackToPlaylist(created.id, track.id);
                library.refreshLibrary();
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Created "$name" and added "${track.title}"')),
                  );
                }
              }
            },
            child: const Text('Create & Add'),
          ),
        ],
      ),
    );
  }

  void _showTrackInfoDialog(BuildContext context, TrackModel track) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.graphic_eq_rounded, color: Color(0xFF00E5FF)),
            SizedBox(width: 10),
            Text('Audio Specs & Decoding', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _specRow('Title', track.title),
            _specRow('Artist', track.artist),
            _specRow('Album', track.album),
            _specRow('Format', track.format),
            _specRow('Fidelity', track.isLossless ? 'Studio Lossless FLAC / PCM' : 'Lossy Transcoded Audio'),
            if (track.bitDepth != null) _specRow('Bit Depth', '${track.bitDepth}-bit High-Resolution'),
            if (track.sampleRate != null) _specRow('Sample Rate', '${track.sampleRate} Hz (Hi-Res Audio)'),
            if (track.bitrate != null) _specRow('Bitrate', '${track.bitrate} kbps'),
            if (track.path != null) _specRow('Storage Path', track.path!),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
