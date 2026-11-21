import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lyrics_line.dart';
import '../../models/track_model.dart';
import '../../providers/playback_notifier.dart';
import '../../services/lyrics_service.dart';

class LyricsView extends StatefulWidget {
  final TrackModel track;

  const LyricsView({super.key, required this.track});

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  final ScrollController _scrollController = ScrollController();
  List<LyricsLine> _lines = [];
  bool _isLoading = true;
  int _lastActiveIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadLyrics();
  }

  @override
  void didUpdateWidget(covariant LyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.track.id != widget.track.id) {
      _loadLyrics();
    }
  }

  Future<void> _loadLyrics() async {
    setState(() => _isLoading = true);
    final lines = await LyricsService.loadLyricsForTrack(widget.track);
    if (mounted) {
      setState(() {
        _lines = lines;
        _isLoading = false;
      });
    }
  }

  void _scrollToActive(int index) {
    if (!_scrollController.hasClients || index < 0 || index >= _lines.length) return;
    final targetOffset = (index * 72.0) - 180.0;
    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<PlaybackNotifier>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final lines = playback.currentTrackLyrics.isNotEmpty ? playback.currentTrackLyrics : _lines;

    if (_isLoading && lines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Fetching synchronized karaoke lyrics...',
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: 13,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      );
    }

    if (lines.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lyrics_outlined, size: 32, color: primary),
              ),
              const SizedBox(height: 16),
              Text(
                'No Synced Lyrics Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Live lyrics are not available for "${widget.track.title}" on LRCLIB.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final activeIndex = LyricsService.findActiveLineIndex(lines, playback.position);
    if (activeIndex != _lastActiveIndex && activeIndex >= 0) {
      _lastActiveIndex = activeIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActive(activeIndex));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      itemCount: lines.length,
      itemBuilder: (ctx, index) {
        final line = lines[index];
        final isActive = index == activeIndex;

        return GestureDetector(
          onTap: () {
            playback.seek(line.timestamp);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: isActive ? 24 : 18,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w500,
                color: isActive
                    ? primary
                    : (isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
                letterSpacing: isActive ? -0.5 : 0.0,
                shadows: isActive && isDark
                    ? [
                        Shadow(
                          color: primary.withValues(alpha: 0.6),
                          blurRadius: 18,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                line.text,
                textAlign: TextAlign.left,
              ),
            ),
          ),
        );
      },
    );
  }
}
