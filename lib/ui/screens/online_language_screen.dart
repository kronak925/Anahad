import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/music_language.dart';
import '../../models/online_album_model.dart';
import '../../models/track_model.dart';
import '../../providers/online_catalogue_notifier.dart';
import '../../providers/playback_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/track_artwork.dart';
import '../widgets/track_tile.dart';
import '../widgets/air_shuffle_button.dart';
import 'online_album_screen.dart';

class OnlineLanguageScreen extends StatefulWidget {
  final MusicLanguage language;

  const OnlineLanguageScreen({super.key, required this.language});

  @override
  State<OnlineLanguageScreen> createState() => _OnlineLanguageScreenState();
}

class _OnlineLanguageScreenState extends State<OnlineLanguageScreen> {
  List<TrackModel> _songs = [];
  List<OnlineAlbumModel> _albums = [];
  bool _isLoading = true;
  String? _selectedSubgenre;

  @override
  void initState() {
    super.initState();
    _loadLanguageContent();
  }

  Future<void> _loadLanguageContent({String? subgenre}) async {
    setState(() {
      _isLoading = true;
      _selectedSubgenre = subgenre;
    });

    final catalogue = context.read<OnlineCatalogueNotifier>();
    final query = subgenre != null
        ? '${widget.language.name} $subgenre'
        : widget.language.searchQuery;

    try {
      final songsFuture = catalogue.searchSongsDirect(query, limit: 30);
      final albumsFuture = catalogue.searchAlbumsDirect(widget.language.albumQuery, limit: 12);

      final results = await Future.wait([songsFuture, albumsFuture]);

      if (mounted) {
        setState(() {
          _songs = results[0] as List<TrackModel>;
          _albums = results[1] as List<OnlineAlbumModel>;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[LanguageScreen] Error loading ${widget.language.name} music: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _playAll({bool shuffle = false}) {
    if (_songs.isEmpty) return;
    final playback = context.read<PlaybackNotifier>();
    final list = List<TrackModel>.from(_songs);
    if (shuffle) {
      list.shuffle(Random());
    }
    playback.playTrack(list.first, playlist: list, index: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = widget.language;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkObsidianBackground : null,
      body: CustomScrollView(
        slivers: [
          // Dynamic Gradient Hero App Bar with Native Script Typography
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              AirShuffleButton(
                tracksProvider: () => _songs,
                contextLabel: lang.name,
                compact: true,
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
                onPressed: () => _loadLanguageContent(subgenre: _selectedSubgenre),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      lang.gradient.first,
                      lang.gradient.last,
                      theme.scaffoldBackgroundColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.65, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      // Watermark Native Script in background
                      Positioned(
                        right: -10,
                        bottom: 20,
                        child: Text(
                          lang.nativeName,
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withValues(alpha: 0.12),
                            letterSpacing: -2,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Native script pill badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(lang.icon, size: 14, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    lang.nativeName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Language English Title
                            Text(
                              '${lang.name} Music Hub',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Subtitle description
                            Text(
                              lang.subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Play All & Shuffle Buttons
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _songs.isEmpty ? null : () => _playAll(shuffle: false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                    elevation: 4,
                                  ),
                                  icon: const Icon(Icons.play_arrow_rounded, size: 22),
                                  label: const Text('Play All', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                AirShuffleButton(
                                  tracksProvider: () => _songs,
                                  contextLabel: '${lang.name} Music',
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
            ),
          ),

          // Subgenres / Mood Filter Chips
          if (lang.subgenres.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: lang.subgenres.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSelected = _selectedSubgenre == null;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('All Hits'),
                            selected: isSelected,
                            onSelected: (_) => _loadLanguageContent(subgenre: null),
                            selectedColor: lang.gradient.first.withValues(alpha: 0.3),
                            checkmarkColor: Colors.white,
                          ),
                        );
                      }

                      final sub = lang.subgenres[index - 1];
                      final isSelected = _selectedSubgenre == sub;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(sub),
                          selected: isSelected,
                          onSelected: (_) => _loadLanguageContent(subgenre: sub),
                          selectedColor: lang.gradient.first.withValues(alpha: 0.3),
                          checkmarkColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],

          // Featured Albums Section
          if (_albums.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Text(
                  'Featured ${lang.name} Albums',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 185,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _albums.length,
                  itemBuilder: (ctx, index) {
                    final album = _albums[index];
                    return Container(
                      width: 125,
                      margin: const EdgeInsets.only(right: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
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
                            TrackArtwork(
                              id: album.id,
                              artUri: album.image,
                              size: 125,
                              borderRadius: 14,
                              fallbackIcon: Icons.album_rounded,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              album.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              album.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
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

          // Top Songs Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedSubgenre != null
                          ? '$_selectedSubgenre Songs'
                          : 'Top ${lang.name} Songs',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_songs.isNotEmpty)
                    Text(
                      '${_songs.length} Tracks',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Loading Indicator or List
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_songs.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.music_off_rounded, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    Text('No ${lang.name} songs found.', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _loadLanguageContent(),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final track = _songs[index];
                  return TrackTile(
                    track: track,
                    playlistContext: _songs,
                    indexInPlaylist: index,
                  );
                },
                childCount: _songs.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
