import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/playback_notifier.dart';
import 'track_artwork.dart';

class QueueSheet extends StatelessWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<PlaybackNotifier>();
    final queue = playback.queue;
    final currentItem = playback.currentMediaItem;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xF2070B0E) : Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                blurRadius: 28,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Playing Queue',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '${queue.length} tracks in queue',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: isDark ? 0.16 : 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: primary.withValues(alpha: 0.35), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded, size: 16, color: primary),
                            const SizedBox(width: 4),
                            Text(
                              'Done',
                              style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
              ),

              // Queue items list
              Expanded(
                child: queue.isEmpty
                    ? Center(
                        child: Text(
                          'Queue is empty',
                          style: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        itemCount: queue.length,
                        itemBuilder: (ctx, index) {
                          final item = queue[index];
                          final isCurrent = item.id == currentItem?.id;
                          final format = item.extras?['format'] ?? 'MP3';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? primary.withValues(alpha: isDark ? 0.14 : 0.09)
                                    : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.transparent),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isCurrent
                                      ? primary.withValues(alpha: 0.35)
                                      : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.transparent),
                                  width: isCurrent ? 1.0 : 0.6,
                                ),
                              ),
                              child: ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      child: isCurrent
                                          ? Icon(Icons.graphic_eq_rounded, size: 18, color: primary)
                                          : Text(
                                              '${index + 1}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 8),
                                    TrackArtwork(
                                      id: item.id,
                                      artUri: item.artUri?.toString(),
                                      size: 40,
                                      borderRadius: 10,
                                    ),
                                  ],
                                ),
                                title: Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                                    fontSize: 14,
                                    color: isCurrent ? primary : (isDark ? Colors.white : Colors.black87),
                                  ),
                                ),
                                subtitle: Text(
                                  '${item.artist ?? 'Unknown Artist'} • $format',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                  ),
                                  onPressed: () => playback.removeQueueItem(index),
                                ),
                                onTap: () {
                                  playback.skipToQueueItem(index);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
