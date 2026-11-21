import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/online_artist_model.dart';
import '../../providers/online_catalogue_notifier.dart';
import '../../providers/playback_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/track_artwork.dart';
import '../widgets/track_tile.dart';
import 'online_album_screen.dart';

class OnlineArtistScreen extends StatefulWidget {
  final OnlineArtistModel artist;

  const OnlineArtistScreen({super.key, required this.artist});

  @override
  State<OnlineArtistScreen> createState() => _OnlineArtistScreenState();
}

class _OnlineArtistScreenState extends State<OnlineArtistScreen> {
  OnlineArtistModel? _fullArtist;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArtistDetails();
  }

  Future<void> _loadArtistDetails() async {
    if (widget.artist.topSongs.isNotEmpty) {
      setState(() {
        _fullArtist = widget.artist;
        _isLoading = false;
      });
      return;
    }

    final catalogue = context.read<OnlineCatalogueNotifier>();
    var loaded = await catalogue.getArtistDetails(widget.artist.id);
    if ((loaded == null || loaded.topSongs.isEmpty) && widget.artist.name.isNotEmpty) {
      try {
        final fallbackSongs = await catalogue.searchSongsDirect(widget.artist.name, limit: 30);
        if (fallbackSongs.isNotEmpty) {
          loaded = (loaded ?? widget.artist).copyWith(topSongs: fallbackSongs);
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _fullArtist = loaded ?? widget.artist;
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

    final artist = _fullArtist ?? widget.artist;
    final topSongs = artist.topSongs;
    final topAlbums = artist.topAlbums;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkObsidianBackground : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header with circular avatar and artist info
          SliverAppBar(
            pinned: true,
            expandedHeight: 310,
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
                      primary.withValues(alpha: isDark ? 0.25 : 0.2),
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
                      // Circular Avatar with Glowing Ring
                      Container(
                        padding: const EdgeInsets.all(3.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primary.withValues(alpha: isDark ? 0.45 : 0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: isDark ? 0.25 : 0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: TrackArtwork(
                            id: artist.id,
                            artUri: artist.image,
                            size: 130,
                            borderRadius: 65,
                            fallbackIcon: Icons.person_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Artist Name
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          artist.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Role / Followers
                      Text(
                        artist.followerCount != null
                            ? '${artist.followerCount} Monthly Listeners'
                            : (artist.role ?? 'Featured Artist'),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Play Top Songs action button
          if (topSongs.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: InkWell(
                  onTap: () {
                    playback.playTrack(topSongs.first, playlist: topSongs, index: 0);
                  },
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
                          'Play Popular Songs (${topSongs.length})',
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
            ),

          // Loading state
          if (_isLoading)
            SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: primary)),
            )
          else ...[
            // Top Albums Horizontal Section
            if (topAlbums.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Text(
                    'Albums & Singles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 190,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: topAlbums.length,
                    itemBuilder: (ctx, idx) {
                      final alb = topAlbums[idx];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OnlineAlbumScreen(album: alb),
                            ),
                          );
                        },
                        child: Container(
                          width: 130,
                          margin: const EdgeInsets.only(right: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TrackArtwork(
                                  id: alb.id,
                                  artUri: alb.image,
                                  size: 130,
                                  borderRadius: 16,
                                  fallbackIcon: Icons.album_rounded,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                alb.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              if (alb.year != null && alb.year!.isNotEmpty)
                                Text(
                                  alb.year!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            // Top Songs Section
            if (topSongs.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    'Top Songs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final track = topSongs[index];
                      return TrackTile(
                        track: track,
                        playlistContext: topSongs,
                        indexInPlaylist: index,
                      );
                    },
                    childCount: topSongs.length,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
