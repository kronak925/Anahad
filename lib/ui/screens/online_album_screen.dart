import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/online_album_model.dart';
import '../../providers/online_catalogue_notifier.dart';
import '../../providers/playback_notifier.dart';
import '../../services/download_service.dart';
import '../theme/app_theme.dart';
import '../widgets/track_artwork.dart';
import '../widgets/track_tile.dart';

class OnlineAlbumScreen extends StatefulWidget {
  final OnlineAlbumModel album;

  const OnlineAlbumScreen({super.key, required this.album});

  @override
  State<OnlineAlbumScreen> createState() => _OnlineAlbumScreenState();
}

class _OnlineAlbumScreenState extends State<OnlineAlbumScreen> {
  OnlineAlbumModel? _fullAlbum;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlbumDetails();
  }

  Future<void> _loadAlbumDetails() async {
    if (widget.album.tracks.isNotEmpty) {
      setState(() {
        _fullAlbum = widget.album;
        _isLoading = false;
      });
      return;
    }

    final catalogue = context.read<OnlineCatalogueNotifier>();
    final loaded = await catalogue.getAlbumDetails(widget.album.id);
    if (mounted) {
      setState(() {
        _fullAlbum = loaded ?? widget.album;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final playback = context.watch<PlaybackNotifier>();
    final downloadService = context.watch<DownloadService>();

    final album = _fullAlbum ?? widget.album;
    final tracks = album.tracks;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkObsidianBackground : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar with back navigation
          SliverAppBar(
            pinned: true,
            expandedHeight: 350,
            backgroundColor: isDark ? AppTheme.darkObsidianBackground : null,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withValues(alpha: isDark ? 0.3 : 0.2),
                      isDark ? AppTheme.darkObsidianBackground : theme.scaffoldBackgroundColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Album Cover Art
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.2),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: TrackArtwork(
                          id: album.id,
                          artUri: album.image,
                          size: 175,
                          borderRadius: 22,
                          fallbackIcon: Icons.album_rounded,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Album Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          album.title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Artist & Year
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          '${album.artist}${album.year != null && album.year!.isNotEmpty ? " • ${album.year}" : ""}',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Action Buttons: Play All & Download All
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: tracks.isNotEmpty
                          ? () {
                              playback.playTrack(tracks.first, playlist: tracks, index: 0);
                            }
                          : null,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 24),
                            const SizedBox(width: 6),
                            Text(
                              'Play All (${tracks.length})',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: tracks.isNotEmpty
                        ? () {
                            for (final t in tracks) {
                              downloadService.startDownload(t);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Downloading ${tracks.length} songs from "${album.title}"')),
                            );
                          }
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F151B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        Icons.download_for_offline_rounded,
                        color: primary,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading state or Tracklist
          if (_isLoading)
            SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: primary)),
            )
          else if (tracks.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.album_outlined, size: 48, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                    const SizedBox(height: 12),
                    Text(
                      'No tracks available for this album',
                      style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
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
            ),
        ],
      ),
    );
  }
}
