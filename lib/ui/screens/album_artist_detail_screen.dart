import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/track_model.dart';
import '../../providers/playback_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/track_tile.dart';

class AlbumArtistDetailScreen extends StatelessWidget {
  final String title;
  final bool isArtist;
  final List<TrackModel> tracks;

  const AlbumArtistDetailScreen({
    super.key,
    required this.title,
    required this.isArtist,
    required this.tracks,
  });

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<PlaybackNotifier>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
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
                      shape: isArtist ? BoxShape.circle : BoxShape.rectangle,
                      borderRadius: isArtist ? null : BorderRadius.circular(24),
                      border: Border.all(
                        color: primary.withValues(alpha: isDark ? 0.35 : 0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: isDark ? 0.2 : 0.1),
                          blurRadius: 24,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        isArtist ? Icons.person_rounded : Icons.album_rounded,
                        size: 64,
                        color: primary,
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
                    '${isArtist ? 'Artist' : 'Album'} • ${tracks.length} tracks',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: tracks.isNotEmpty
                            ? () {
                                playback.playTrack(tracks.first, playlist: tracks, index: 0);
                              }
                            : null,
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
                        onTap: tracks.isNotEmpty
                            ? () {
                                playback.playTrack(tracks.first, playlist: tracks, index: 0);
                                playback.toggleShuffle();
                              }
                            : null,
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, index) {
                final track = tracks[index];
                return TrackTile(
                  track: track,
                  playlistContext: tracks,
                  indexInPlaylist: index,
                );
              },
              childCount: tracks.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}
