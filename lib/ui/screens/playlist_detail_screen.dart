import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/track_model.dart';
import '../../providers/library_notifier.dart';
import '../../providers/playback_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/track_tile.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String title;
  final List<TrackModel> tracks;
  final String? playlistId;
  final bool isFavorites;

  const PlaylistDetailScreen({
    super.key,
    required this.title,
    required this.tracks,
    this.playlistId,
    this.isFavorites = false,
  });

  String _formatTotalDuration(List<TrackModel> list) {
    final totalMs = list.fold<int>(0, (sum, t) => sum + t.duration.inMilliseconds);
    final total = Duration(milliseconds: totalMs);
    final hours = total.inHours;
    final minutes = total.inMinutes % 60;
    if (hours > 0) {
      return '$hours hr $minutes min';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<PlaybackNotifier>();
    final library = context.watch<LibraryNotifier>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    final currentTracks = isFavorites ? library.favoriteTracks : tracks;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkObsidianBackground : null,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkObsidianBackground.withValues(alpha: 0.85) : null,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.4,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: currentTracks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F151B) : Colors.black.withValues(alpha: 0.04),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Icon(
                      isFavorites ? Icons.favorite_border_rounded : Icons.queue_music_rounded,
                      size: 36,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isFavorites ? 'No favorite tracks yet' : 'This playlist is empty',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add tracks from your library or search',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header Banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F151B) : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isFavorites
                                  ? const Color(0xFFE91E63).withValues(alpha: 0.4)
                                  : primary.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isFavorites ? const Color(0xFFE91E63) : primary)
                                    .withValues(alpha: isDark ? 0.2 : 0.1),
                                blurRadius: 24,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              isFavorites ? Icons.favorite_rounded : Icons.queue_music_rounded,
                              size: 64,
                              color: isFavorites ? const Color(0xFFE91E63) : primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${currentTracks.length} tracks • ${_formatTotalDuration(currentTracks)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Action Buttons (Play All & Shuffle)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                playback.playTrack(currentTracks.first, playlist: currentTracks, index: 0);
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withValues(alpha: 0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.play_arrow_rounded, color: Colors.black, size: 22),
                                    SizedBox(width: 6),
                                    Text(
                                      'Play All',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () {
                                playback.playTrack(currentTracks.first, playlist: currentTracks, index: 0);
                                playback.toggleShuffle();
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F151B) : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.shuffle_rounded,
                                      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Shuffle',
                                      style: TextStyle(
                                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
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

                // Tracks List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, index) {
                      final track = currentTracks[index];
                      return TrackTile(
                        track: track,
                        playlistContext: currentTracks,
                        indexInPlaylist: index,
                      );
                    },
                    childCount: currentTracks.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
    );
  }
}
