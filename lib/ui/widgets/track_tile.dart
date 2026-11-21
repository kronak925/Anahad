import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/track_model.dart';
import '../../providers/library_notifier.dart';
import '../../providers/playback_notifier.dart';
import '../../services/download_service.dart';
import 'audio_format_badge.dart';
import 'track_artwork.dart';

class TrackTile extends StatelessWidget {
  final TrackModel track;
  final List<TrackModel>? playlistContext;
  final int? indexInPlaylist;
  final VoidCallback? onTap;

  const TrackTile({
    super.key,
    required this.track,
    this.playlistContext,
    this.indexInPlaylist,
    this.onTap,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<PlaybackNotifier>();
    final library = context.watch<LibraryNotifier>();
    final downloadService = context.watch<DownloadService>();
    final isPlayingThis = playback.currentMediaItem?.id == track.id;
    final isPlaying = isPlayingThis && playback.isPlaying;
    final isFavorite = library.isFavorite(track.id);
    final isDownloaded = downloadService.isDownloaded(track.id);
    final isDownloading = downloadService.isDownloading(track.id);
    final downloadTask = downloadService.getTask(track.id);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: isPlayingThis ? 12 : 0, sigmaY: isPlayingThis ? 12 : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isPlayingThis
                  ? (isDark
                      ? primary.withValues(alpha: 0.12)
                      : primary.withValues(alpha: 0.08))
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.02)
                      : Colors.black.withValues(alpha: 0.015)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPlayingThis
                    ? primary.withValues(alpha: 0.35)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.black.withValues(alpha: 0.03)),
                width: isPlayingThis ? 1.0 : 0.6,
              ),
              boxShadow: isPlayingThis && isDark
                  ? [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: InkWell(
              onTap: onTap ??
                  () {
                    playback.playTrack(
                      track,
                      playlist: playlistContext ?? [track],
                      index: indexInPlaylist ?? 0,
                    );
                  },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    // Squircle Artwork with Drop Shadow & Live Equalizer Overlay
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        TrackArtwork(
                          id: track.id,
                          artUri: track.artUri,
                          size: 50,
                          borderRadius: 14,
                        ),
                        if (isPlayingThis)
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              isPlaying ? Icons.graphic_eq_rounded : Icons.pause_rounded,
                              color: primary,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Metadata: Title, Artist, Badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  track.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: isPlayingThis ? FontWeight.w800 : FontWeight.w600,
                                    fontSize: 14.5,
                                    letterSpacing: -0.2,
                                    color: isPlayingThis
                                        ? primary
                                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  track.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              AudioFormatBadge(
                                format: track.format,
                                isLossless: track.isLossless,
                                sampleRate: track.sampleRate,
                                bitDepth: track.bitDepth,
                                compact: true,
                              ),
                              if (isDownloaded) ...[
                                const SizedBox(width: 5),
                                Icon(
                                  Icons.offline_pin_rounded,
                                  size: 13,
                                  color: primary,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Duration
                    Text(
                      _formatDuration(track.duration),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 2),

                    // Download Action / Progress Indicator
                    if (isDownloading)
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: CircularProgressIndicator(
                            value: downloadTask?.progress != null && downloadTask!.progress > 0
                                ? downloadTask.progress
                                : null,
                            strokeWidth: 2.2,
                            color: primary,
                          ),
                        ),
                      )
                    else if (isDownloaded)
                      IconButton(
                        iconSize: 19,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        tooltip: 'Downloaded Offline',
                        icon: Icon(
                          Icons.check_circle_rounded,
                          color: primary,
                          size: 19,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('"${track.title}" is saved for offline listening')),
                          );
                        },
                      )
                    else if (track.sourceType == AudioSourceType.saavn || track.sourceType == AudioSourceType.youtube)
                      IconButton(
                        iconSize: 19,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        tooltip: 'Download Offline',
                        icon: Icon(
                          Icons.arrow_downward_rounded,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          size: 19,
                        ),
                        onPressed: () {
                          downloadService.startDownload(track);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Downloading "${track.title}"...')),
                          );
                        },
                      ),

                    // Favorite Button
                    IconButton(
                      iconSize: 19,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      icon: Icon(
                        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFavorite ? primary : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                        size: 19,
                      ),
                      onPressed: () => library.toggleFavorite(track.id),
                    ),

                    // More Options Popup Menu
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      color: isDark ? const Color(0xFF0F151B) : Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      icon: Icon(
                        Icons.more_vert_rounded,
                        size: 19,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                      onSelected: (val) {
                        if (val == 'play_next') {
                          playback.handler.addQueueItem(track.toMediaItem());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added "${track.title}" to play next')),
                          );
                        } else if (val == 'download') {
                          downloadService.startDownload(track);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Downloading "${track.title}"...')),
                          );
                        } else if (val.startsWith('add_to_')) {
                          final plId = val.replaceFirst('add_to_', '');
                          library.addTrackToPlaylist(plId, track.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to playlist')),
                          );
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'play_next',
                          child: Row(
                            children: [
                              Icon(Icons.queue_music_rounded, size: 18),
                              SizedBox(width: 10),
                              Text('Play next', style: TextStyle(fontSize: 13.5)),
                            ],
                          ),
                        ),
                        if (!isDownloaded &&
                            (track.sourceType == AudioSourceType.saavn || track.sourceType == AudioSourceType.youtube))
                          const PopupMenuItem(
                            value: 'download',
                            child: Row(
                              children: [
                                Icon(Icons.download_rounded, size: 18),
                                SizedBox(width: 10),
                                Text('Download Offline', style: TextStyle(fontSize: 13.5)),
                              ],
                            ),
                          ),
                        ...library.playlists.map(
                          (pl) => PopupMenuItem(
                            value: 'add_to_${pl.id}',
                            child: Row(
                              children: [
                                const Icon(Icons.playlist_add_rounded, size: 18),
                                const SizedBox(width: 10),
                                Text('Add to ${pl.name}', style: const TextStyle(fontSize: 13.5)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
