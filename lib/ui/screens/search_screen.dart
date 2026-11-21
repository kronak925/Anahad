import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/online_album_model.dart';
import '../../models/online_artist_model.dart';
import '../../models/track_model.dart';
import '../../providers/library_notifier.dart';
import '../../providers/online_catalogue_notifier.dart';
import '../../providers/playback_notifier.dart';
import '../../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/air_shuffle_button.dart';
import '../widgets/track_artwork.dart';
import '../widgets/track_tile.dart';
import 'online_album_screen.dart';
import 'online_artist_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val, OnlineCatalogueNotifier catalogue) {
    setState(() {});
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (val.trim().isNotEmpty) {
        StorageService.addSearchHistory(val.trim());
      }
      catalogue.search(val);
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalogue = context.watch<OnlineCatalogueNotifier>();
    final library = context.watch<LibraryNotifier>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final query = _searchController.text.trim();

    final localMatches = query.isNotEmpty ? library.searchTracks(query) : <TrackModel>[];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkObsidianBackground : null,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkObsidianBackground.withValues(alpha: 0.85) : null,
        elevation: 0,
        title: Text(
          'Search',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          AirShuffleButton(
            contextLabel: query.isNotEmpty ? 'Search Results' : 'Trending Hits',
            tracksProvider: () {
              if (query.isNotEmpty && catalogue.songResults.isNotEmpty) {
                return catalogue.songResults;
              }
              return catalogue.trendingTracks;
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Obsidian Glass Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F151B) : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => _onSearchChanged(val, catalogue),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        StorageService.addSearchHistory(val.trim());
                        setState(() {});
                      }
                      catalogue.search(val);
                    },
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Songs, artists, albums, or FLAC...',
                      hintStyle: TextStyle(
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        fontSize: 14.5,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: primary,
                        size: 22,
                      ),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.cancel_rounded,
                                size: 20,
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                                catalogue.search('');
                              },
                            )
                          : null,
                      filled: false,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Filter Segment Bar with Glowing Active Pill State
          if (query.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _filterChip(context, catalogue, SearchTab.all, 'All', isDark, primary),
                  const SizedBox(width: 8),
                  _filterChip(context, catalogue, SearchTab.songs, 'Songs (${catalogue.songResults.length})', isDark, primary),
                  const SizedBox(width: 8),
                  _filterChip(context, catalogue, SearchTab.albums, 'Albums (${catalogue.albumResults.length})', isDark, primary),
                  const SizedBox(width: 8),
                  _filterChip(context, catalogue, SearchTab.artists, 'Artists (${catalogue.artistResults.length})', isDark, primary),
                  const SizedBox(width: 8),
                  _filterChip(context, catalogue, SearchTab.local, 'Device (${localMatches.length})', isDark, primary),
                ],
              ),
            ),

          const SizedBox(height: 4),

          // Search Content Body
          Expanded(
            child: query.isEmpty
                ? _buildSearchHistoryAndTrending(context, catalogue, isDark, primary)
                : catalogue.isLoading
                    ? Center(child: CircularProgressIndicator(color: primary))
                    : _buildSearchResults(context, catalogue, localMatches, isDark, primary),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    BuildContext context,
    OnlineCatalogueNotifier catalogue,
    SearchTab tab,
    String label,
    bool isDark,
    Color primary,
  ) {
    final isSelected = catalogue.currentTab == tab;

    return InkWell(
      onTap: () => catalogue.setTab(tab),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: isDark ? 0.2 : 0.15)
              : (isDark ? const Color(0xFF0F151B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? primary
                : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
            width: isSelected ? 1.0 : 0.8,
          ),
          boxShadow: isSelected && isDark
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? primary : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHistoryAndTrending(
    BuildContext context,
    OnlineCatalogueNotifier catalogue,
    bool isDark,
    Color primary,
  ) {
    final searchHistory = StorageService.getSearchHistory();
    final trendingSongs = catalogue.trendingTracks;
    final playback = context.watch<PlaybackNotifier>();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        // 1. Search History Section (Obsidian Glass Chips)
        if (searchHistory.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await StorageService.clearSearchHistory();
                    setState(() {});
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: searchHistory.map((historyQuery) {
              return InkWell(
                onTap: () {
                  _searchController.text = historyQuery;
                  StorageService.addSearchHistory(historyQuery);
                  catalogue.search(historyQuery);
                  setState(() {});
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                        Icons.history_rounded,
                        size: 15,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        historyQuery,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () async {
                          await StorageService.removeSearchHistory(historyQuery);
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // 2. Most Searched & Trending Songs
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Trending & Most Searched',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (trendingSongs.isNotEmpty)
                InkWell(
                  onTap: () {
                    playback.playTrack(trendingSongs.first, playlist: trendingSongs, index: 0);
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

        if (trendingSongs.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: CircularProgressIndicator(color: primary),
            ),
          )
        else
          ...trendingSongs.map((track) {
            return TrackTile(
              track: track,
              playlistContext: trendingSongs,
              indexInPlaylist: trendingSongs.indexOf(track),
            );
          }),
      ],
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    OnlineCatalogueNotifier catalogue,
    List<TrackModel> localMatches,
    bool isDark,
    Color primary,
  ) {
    if (catalogue.error != null && catalogue.songResults.isEmpty && localMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(catalogue.error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => catalogue.search(catalogue.query),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Search'),
            ),
          ],
        ),
      );
    }

    final hasAny = catalogue.songResults.isNotEmpty ||
        catalogue.albumResults.isNotEmpty ||
        catalogue.artistResults.isNotEmpty ||
        localMatches.isNotEmpty;

    if (!hasAny) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 52, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              'No results found for "${catalogue.query}"',
              style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    switch (catalogue.currentTab) {
      case SearchTab.songs:
        return _buildSongsTab(catalogue.songResults);
      case SearchTab.albums:
        return _buildAlbumsTab(catalogue.albumResults, isDark, primary);
      case SearchTab.artists:
        return _buildArtistsTab(catalogue.artistResults, isDark, primary);
      case SearchTab.local:
        return _buildLocalTab(localMatches);
      case SearchTab.all:
        return _buildAllUnifiedTab(context, catalogue, localMatches, isDark, primary);
    }
  }

  Widget _buildAllUnifiedTab(
    BuildContext context,
    OnlineCatalogueNotifier catalogue,
    List<TrackModel> localMatches,
    bool isDark,
    Color primary,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        // 1. Online Songs Section
        if (catalogue.songResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Songs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => catalogue.setTab(SearchTab.songs),
                  child: Text('See All', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          ...catalogue.songResults.take(5).map((track) {
            return TrackTile(
              track: track,
              playlistContext: catalogue.songResults,
              indexInPlaylist: catalogue.songResults.indexOf(track),
            );
          }),
        ],

        // 2. Online Albums Section
        if (catalogue.albumResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Albums',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => catalogue.setTab(SearchTab.albums),
                  child: Text('See All', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 185,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: catalogue.albumResults.length,
              itemBuilder: (ctx, idx) {
                final album = catalogue.albumResults[idx];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OnlineAlbumScreen(album: album),
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
                            id: album.id,
                            artUri: album.image,
                            size: 130,
                            borderRadius: 16,
                            fallbackIcon: Icons.album_rounded,
                          ),
                        ),
                        const SizedBox(height: 6),
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
                        Text(
                          album.artist,
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
        ],

        // 3. Online Artists Section
        if (catalogue.artistResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Artists',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => catalogue.setTab(SearchTab.artists),
                  child: Text('See All', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: catalogue.artistResults.length,
              itemBuilder: (ctx, idx) {
                final artist = catalogue.artistResults[idx];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OnlineArtistScreen(artist: artist),
                      ),
                    );
                  },
                  child: Container(
                    width: 96,
                    margin: const EdgeInsets.only(right: 14),
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
                        const SizedBox(height: 6),
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
        ],

        // 4. Device Local Tracks
        if (localMatches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Device Tracks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () => catalogue.setTab(SearchTab.local),
                  child: Text('See All', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          ...localMatches.take(5).map((track) {
            return TrackTile(
              track: track,
              playlistContext: localMatches,
              indexInPlaylist: localMatches.indexOf(track),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildSongsTab(List<TrackModel> songs) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120, top: 4),
      itemCount: songs.length,
      itemBuilder: (ctx, idx) {
        return TrackTile(
          track: songs[idx],
          playlistContext: songs,
          indexInPlaylist: idx,
        );
      },
    );
  }

  Widget _buildAlbumsTab(List<OnlineAlbumModel> albums, bool isDark, Color primary) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      itemCount: albums.length,
      itemBuilder: (ctx, idx) {
        final album = albums[idx];
        return GestureDetector(
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
              Expanded(
                child: Container(
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
                    size: double.infinity,
                    borderRadius: 18,
                    fallbackIcon: Icons.album_rounded,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                album.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                '${album.artist}${album.year != null && album.year!.isNotEmpty ? " • ${album.year}" : ""}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArtistsTab(List<OnlineArtistModel> artists, bool isDark, Color primary) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: artists.length,
      itemBuilder: (ctx, idx) {
        final artist = artists[idx];
        return GestureDetector(
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
                ),
                child: ClipOval(
                  child: TrackArtwork(
                    id: artist.id,
                    artUri: artist.image,
                    size: 88,
                    borderRadius: 44,
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
                  fontSize: 12.5,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              if (artist.followerCount != null)
                Text(
                  '${artist.followerCount} Fans',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocalTab(List<TrackModel> localTracks) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120, top: 4),
      itemCount: localTracks.length,
      itemBuilder: (ctx, idx) {
        return TrackTile(
          track: localTracks[idx],
          playlistContext: localTracks,
          indexInPlaylist: idx,
        );
      },
    );
  }
}
