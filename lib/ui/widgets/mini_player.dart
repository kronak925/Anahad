import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/playback_notifier.dart';
import '../screens/now_playing_screen.dart';
import 'track_artwork.dart';
import 'audio_format_badge.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<PlaybackNotifier>();
    final currentItem = playback.currentMediaItem;

    if (currentItem == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final isLossless = currentItem.extras?['isLossless'] == true;
    final format = currentItem.extras?['format'] ?? 'MP3';
    final progress = playback.duration.inMilliseconds > 0
        ? (playback.position.inMilliseconds / playback.duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: false,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withValues(alpha: 0.7),
          builder: (ctx) => const NowPlayingScreen(),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xF0121B23),
                        const Color(0xF00A1016),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.94),
                        const Color(0xFFF1F5F9).withValues(alpha: 0.94),
                      ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? primary.withValues(alpha: 0.22)
                    : Colors.black.withValues(alpha: 0.08),
                width: 0.9,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
                if (isDark)
                  BoxShadow(
                    color: primary.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Track Info & Controls Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
                  child: Row(
                    children: [
                      // Squircle Album Artwork with Hero tag
                      Hero(
                        tag: 'now_playing_artwork_${currentItem.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TrackArtwork(
                            id: currentItem.id,
                            artUri: currentItem.artUri?.toString(),
                            size: 46,
                            borderRadius: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title & Artist
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    currentItem.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                AudioFormatBadge(
                                  format: format,
                                  isLossless: isLossless,
                                  compact: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentItem.artist ?? 'ANAHAD Studio',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Transport: Play/Pause button
                      GestureDetector(
                        onTap: () {
                          if (playback.isPlaying) {
                            playback.pause();
                          } else {
                            playback.play();
                          }
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: isDark ? 0.2 : 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primary.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            playback.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 22,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Transport: Next button
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, size: 24),
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        onPressed: () => playback.skipToNext(),
                      ),
                    ],
                  ),
                ),

                // Sleek glowing progress indicator along bottom edge
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 2.2,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
