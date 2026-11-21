import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/library_notifier.dart';
import '../../providers/online_catalogue_notifier.dart';
import '../../providers/playback_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/air_shuffle_button.dart';
import '../widgets/anahad_brand_icon.dart';
import '../widgets/track_artwork.dart';
import '../widgets/track_tile.dart';
import '../../models/music_language.dart';
import 'online_album_screen.dart';
import 'online_artist_screen.dart';
import 'online_language_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryNotifier>();
    final playback = context.watch<PlaybackNotifier>();
    final catalogue = context.watch<OnlineCatalogueNotifier>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    final recentTracks = library.recentTracks;
    final trendingTracks = catalogue.trendingTracks;
    final featuredAlbums = catalogue.featuredAlbums;
    final featuredArtists = catalogue.featuredArtists;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkObsidianBackground : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar with Obsidian Glass Styling
          SliverAppBar(
            floating: true,
            pinned: false,
            backgroundColor: isDark ? AppTheme.darkObsidianBackground.withValues(alpha: 0.85) : null,
            elevation: 0,
            title: Row(
              children: [
                AnahadBrandIcon(
                  size: 34,
                  isPlaying: playback.isPlaying,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Listen Now',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                          fontSize: 22,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'Lossless Hi-Res & Online Streaming',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              AirShuffleButton(
                contextLabel: 'Trending Hits',
                tracksProvider: () => trendingTracks,
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
                tooltip: 'Refresh Online Hits',
                onPressed: () {
                  catalogue.loadDiscoveryContent();
                  library.refreshLibrary();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Refreshing online charts and featured music...')),
                  );
                },
              ),
              const SizedBox(width: 10),
            ],
          ),

          // Quick Mood / Genre Filter Chips with Obsidian Glass Capsule Design
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                children: [
                  _moodChip(context, 'Trending Hits', () => catalogue.search('Top Hits India'), isDark, primary),
                  _moodChip(context, 'Bollywood Romance', () => catalogue.search('Bollywood Romantic'), isDark, primary),
                  _moodChip(context, 'Punjabi Beats', () => catalogue.search('Punjabi Pop Hits'), isDark, primary),
                  _moodChip(context, 'Lo-Fi Midnight', () => catalogue.search('Lofi Chill Hindi'), isDark, primary),
                  _moodChip(context, 'Acoustic & Sufi', () => catalogue.search('Sufi Classics'), isDark, primary),
                  _moodChip(context, 'Dance & Party', () => catalogue.search('Party Songs Hindi'), isDark, primary),
                  _moodChip(context, 'Devotional', () => catalogue.search('Bhajan'), isDark, primary),
                ],
              ),
            ),
          ),

          // 1. Trending Now Carousel (Obsidian Glass Floating Cards)
          if (trendingTracks.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trending in India',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        playback.playTrack(trendingTracks.first, playlist: trendingTracks, index: 0);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: isDark ? 0.16 : 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: primary.withValues(alpha: 0.3), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow_rounded, size: 16, color: primary),
                            const SizedBox(width: 4),
                            Text(
                              'Play All',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: trendingTracks.length,
                  itemBuilder: (ctx, index) {
                    final track = trendingTracks[index];
                    return Container(
                      width: 145,
                      margin: const EdgeInsets.only(right: 14),
                      child: InkWell(
                        onTap: () {
                          playback.playTrack(track, playlist: trendingTracks, index: index);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.15),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: TrackArtwork(
                                    id: track.id,
                                    artUri: track.artUri,
                                    size: 145,
                                    borderRadius: 20,
                                    fallbackIcon: Icons.music_note_rounded,
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: primary.withValues(alpha: 0.45),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              track.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
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

          // 2. Music by Language (Gaana / Apple Music style with Glass Squircles)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Music by Language',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    '${MusicLanguage.supportedLanguages.length} Languages',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 105,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: MusicLanguage.supportedLanguages.length,
                itemBuilder: (ctx, index) {
                  final lang = MusicLanguage.supportedLanguages[index];
                  return _languageCard(context, lang, isDark);
                },
              ),
            ),
          ),

          // 3. Featured Albums Section
          if (featuredAlbums.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'Featured Albums',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 195,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: featuredAlbums.length,
                  itemBuilder: (ctx, index) {
                    final album = featuredAlbums[index];
                    return Container(
                      width: 135,
                      margin: const EdgeInsets.only(right: 14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OnlineAlbumScreen(album: album),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: TrackArtwork(
                                id: album.id,
                                artUri: album.image,
                                size: 135,
                                borderRadius: 18,
                                fallbackIcon: Icons.album_rounded,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              album.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              album.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
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

          // 4. Popular Artists (Distinct Avatars with Glowing Rings)
          if (featuredArtists.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'Popular Artists',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: featuredArtists.length,
                  itemBuilder: (ctx, index) {
                    final artist = featuredArtists[index];
                    return Container(
                      width: 94,
                      margin: const EdgeInsets.only(right: 14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(44),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OnlineArtistScreen(artist: artist),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primary.withValues(alpha: isDark ? 0.35 : 0.25),
                                  width: 1.5,
                                ),
                                boxShadow: isDark
                                    ? [
                                        BoxShadow(
                                          color: primary.withValues(alpha: 0.12),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: ClipOval(
                                child: TrackArtwork(
                                  id: artist.id,
                                  artUri: artist.image,
                                  size: 80,
                                  borderRadius: 40,
                                  fallbackIcon: Icons.person_rounded,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              artist.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: isDark ? Colors.white : Colors.black87,
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

          // 5. Recently Played (if any)
          if (recentTracks.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Text(
                  'Recently Played',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 165,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: recentTracks.length,
                  itemBuilder: (ctx, index) {
                    final track = recentTracks[index];
                    return Container(
                      width: 115,
                      margin: const EdgeInsets.only(right: 12),
                      child: InkWell(
                        onTap: () => playback.playTrack(track, playlist: recentTracks, index: index),
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TrackArtwork(
                              id: track.id,
                              artUri: track.artUri,
                              size: 105,
                              borderRadius: 16,
                              fallbackIcon: Icons.history_rounded,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              track.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

          // 6. Curated Playlists & Moods
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Curated Playlists & Moods',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _curatedCard(
                    context,
                    title: 'Bollywood Romance',
                    subtitle: 'Arijit, Shreya & Pritam Classics',
                    colors: [const Color(0xFFE91E63), const Color(0xFF880E4F)],
                    icon: Icons.favorite_rounded,
                    onTap: () => catalogue.search('Bollywood Romantic Hits'),
                    isDark: isDark,
                  ),
                  _curatedCard(
                    context,
                    title: 'Punjabi Pop Energy',
                    subtitle: 'Diljit, AP Dhillon & Sidhu Beats',
                    colors: [const Color(0xFFFF9800), const Color(0xFFE65100)],
                    icon: Icons.bolt_rounded,
                    onTap: () => catalogue.search('Punjabi Hits 2024'),
                    isDark: isDark,
                  ),
                  _curatedCard(
                    context,
                    title: 'Midnight Lo-Fi Chill',
                    subtitle: 'Slowed & Reverbed Aesthetics',
                    colors: [const Color(0xFF3F51B5), const Color(0xFF1A237E)],
                    icon: Icons.nightlight_round,
                    onTap: () => catalogue.search('Lofi Hindi Chill'),
                    isDark: isDark,
                  ),
                  _curatedCard(
                    context,
                    title: 'Acoustic & Sufi',
                    subtitle: 'Soulful Spiritual Rhythms',
                    colors: [const Color(0xFF009688), const Color(0xFF004D40)],
                    icon: Icons.self_improvement_rounded,
                    onTap: () => catalogue.search('Sufi Classics Indian'),
                    isDark: isDark,
                  ),
                  _curatedCard(
                    context,
                    title: 'India Top 50 Chart',
                    subtitle: 'Most streamed tracks nationwide',
                    colors: [const Color(0xFF9C27B0), const Color(0xFF4A148C)],
                    icon: Icons.trending_up_rounded,
                    onTap: () => catalogue.search('Top 50 India'),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          // 7. Top Charts in India (Unified with Obsidian TrackTiles)
          if (trendingTracks.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top Charts • India',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '${trendingTracks.length} Songs',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, index) {
                  final track = trendingTracks[index];
                  return TrackTile(
                    track: track,
                    playlistContext: trendingTracks,
                    indexInPlaylist: index,
                  );
                },
                childCount: trendingTracks.length,
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _moodChip(BuildContext context, String label, VoidCallback onTap, bool isDark, Color primary) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F151B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              width: 0.8,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _curatedCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<Color> colors,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: isDark ? 0.35 : 0.2),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _languageCard(BuildContext context, MusicLanguage lang, bool isDark) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OnlineLanguageScreen(language: lang),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: lang.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: lang.gradient.first.withValues(alpha: isDark ? 0.35 : 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(
                  lang.icon,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            lang.nativeName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lang.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
