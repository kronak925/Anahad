import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/track_model.dart';
import '../../providers/library_notifier.dart';
import '../../services/download_service.dart';
import '../theme/app_theme.dart';
import '../widgets/air_shuffle_button.dart';
import '../widgets/track_tile.dart';
import 'album_artist_detail_screen.dart';
import 'playlist_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryNotifier>();
    final downloadService = context.watch<DownloadService>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkObsidianBackground : null,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkObsidianBackground.withValues(alpha: 0.85) : null,
        elevation: 0,
        title: Text(
          'Your Library',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          AirShuffleButton(
            contextLabel: 'Offline Music',
            tracksProvider: () => downloadService.downloadedTracks.isNotEmpty
                ? downloadService.downloadedTracks
                : library.allTracks,
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(
              Icons.sort_rounded,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
            tooltip: 'Sort Options',
            onPressed: () => _showSortSheet(context, library, isDark, primary),
          ),
          IconButton(
            icon: Icon(
              Icons.add_rounded,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
            tooltip: 'Create Playlist',
            onPressed: () => _showCreatePlaylistDialog(context, library, isDark, primary),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              physics: const BouncingScrollPhysics(),
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: primary.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primary.withValues(alpha: 0.4), width: 1),
              ),
              labelColor: primary,
              unselectedLabelColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              dividerColor: Colors.transparent,
              padding: EdgeInsets.zero,
              tabs: [
                Tab(text: 'Tracks (${library.allTracks.length})'),
                Tab(text: 'Downloaded (${downloadService.downloadedTracks.length})'),
                Tab(text: 'Lossless (${library.losslessTracks.length})'),
                Tab(text: 'Albums (${library.albums.length})'),
                Tab(text: 'Artists (${library.artists.length})'),
                Tab(text: 'Playlists (${library.playlists.length})'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildTracksTab(context, library, library.allTracks, isDark, primary),
          _buildTracksTab(
            context,
            library,
            downloadService.downloadedTracks,
            isDark,
            primary,
            emptyMsg: 'No offline downloads yet.\nTap download on any song to save it for offline listening.',
          ),
          _buildTracksTab(
            context,
            library,
            library.losslessTracks,
            isDark,
            primary,
            emptyMsg: 'No FLAC lossless tracks found on device.',
          ),
          _buildAlbumsTab(context, library, isDark, primary),
          _buildArtistsTab(context, library, isDark, primary),
          _buildPlaylistsTab(context, library, isDark, primary),
        ],
      ),
    );
  }

  Widget _buildTracksTab(
    BuildContext context,
    LibraryNotifier library,
    List<TrackModel> tracks,
    bool isDark,
    Color primary, {
    String emptyMsg = 'No tracks in library',
  }) {
    if (library.isLoading) {
      return Center(child: CircularProgressIndicator(color: primary));
    }

    if (tracks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
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
                child: Icon(Icons.music_off_rounded, size: 36, color: primary),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMsg,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              InkWell(
                onTap: () => library.refreshLibrary(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: isDark ? 0.16 : 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primary.withValues(alpha: 0.35), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, size: 18, color: primary),
                      const SizedBox(width: 8),
                      Text(
                        'Rescan Device',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 120),
      itemCount: tracks.length,
      itemBuilder: (ctx, index) {
        final track = tracks[index];
        return TrackTile(
          track: track,
          playlistContext: tracks,
          indexInPlaylist: index,
        );
      },
    );
  }

  Widget _buildAlbumsTab(BuildContext context, LibraryNotifier library, bool isDark, Color primary) {
    final albums = library.albums;

    if (albums.isEmpty) {
      return Center(
        child: Text(
          'No albums found',
          style: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: albums.length,
      itemBuilder: (ctx, index) {
        final album = albums[index];
        final albumTracks = library.getTracksByAlbum(album);

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => AlbumArtistDetailScreen(
                  title: album,
                  isArtist: false,
                  tracks: albumTracks,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F151B) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(Icons.album_rounded, size: 54, color: primary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                album,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                '${albumTracks.length} tracks',
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

  Widget _buildArtistsTab(BuildContext context, LibraryNotifier library, bool isDark, Color primary) {
    final artists = library.artists;

    if (artists.isEmpty) {
      return Center(
        child: Text(
          'No artists found',
          style: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      itemCount: artists.length,
      itemBuilder: (ctx, index) {
        final artist = artists[index];
        final artistTracks = library.getTracksByArtist(artist);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => AlbumArtistDetailScreen(
                    title: artist,
                    isArtist: true,
                    tracks: artistTracks,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F151B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary.withValues(alpha: 0.15),
                      border: Border.all(color: primary.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Center(
                      child: Icon(Icons.person_rounded, color: primary, size: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artist,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '${artistTracks.length} tracks',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaylistsTab(BuildContext context, LibraryNotifier library, bool isDark, Color primary) {
    final playlists = library.playlists;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        // Favorites Special Glass Card
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => PlaylistDetailScreen(
                  title: 'Favorite Tracks',
                  tracks: library.favoriteTracks,
                  isFavorites: true,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E1020), const Color(0xFF0F151B)]
                    : [const Color(0xFFFDE8E8), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE91E63).withValues(alpha: 0.35),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE91E63).withValues(alpha: isDark ? 0.2 : 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE91E63),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.favorite_rounded, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Favorite Tracks',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${library.favoriteTracks.length} tracks',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // User Playlists
        ...playlists.map((pl) {
          final Map<String, TrackModel> trackMap = {for (var t in library.allTracks) t.id: t};
          final plTracks = pl.trackIds.map((id) => trackMap[id]).whereType<TrackModel>().toList();

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => PlaylistDetailScreen(
                      title: pl.name,
                      tracks: plTracks,
                      playlistId: pl.id,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F151B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(Icons.queue_music_rounded, color: primary, size: 24),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pl.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            '${pl.trackIds.length} tracks',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      color: isDark ? const Color(0xFF0F151B) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      icon: Icon(
                        Icons.more_vert_rounded,
                        size: 20,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                      onSelected: (val) {
                        if (val == 'delete') {
                          library.deletePlaylist(pl.id);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                              SizedBox(width: 8),
                              Text('Delete Playlist', style: TextStyle(color: Colors.redAccent, fontSize: 13.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showSortSheet(BuildContext context, LibraryNotifier library, bool isDark, Color primary) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0C1218) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sort Library',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Done', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              _sortTile(context, library, 'Track Title', SortOption.title, Icons.sort_by_alpha_rounded, isDark, primary),
              _sortTile(context, library, 'Artist Name', SortOption.artist, Icons.person_rounded, isDark, primary),
              _sortTile(context, library, 'Duration', SortOption.duration, Icons.timer_outlined, isDark, primary),
              _sortTile(context, library, 'Date Added', SortOption.dateAdded, Icons.calendar_today_outlined, isDark, primary),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sortTile(
    BuildContext context,
    LibraryNotifier library,
    String label,
    SortOption option,
    IconData icon,
    bool isDark,
    Color primary,
  ) {
    final isSelected = library.sortOption == option;

    return ListTile(
      leading: Icon(icon, color: isSelected ? primary : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? primary : (isDark ? Colors.white : Colors.black87),
        ),
      ),
      trailing: isSelected
          ? Icon(library.sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: primary)
          : null,
      onTap: () {
        library.setSortOption(option);
        Navigator.pop(context);
      },
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, LibraryNotifier library, bool isDark, Color primary) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0F151B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        title: Text(
          'New Playlist',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'Playlist name',
            hintStyle: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            filled: true,
            fillColor: isDark ? const Color(0xFF070B0E) : Colors.black.withValues(alpha: 0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                library.createPlaylist(name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
