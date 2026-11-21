import 'online_album_model.dart';
import 'track_model.dart';

class OnlineArtistModel {
  final String id;
  final String name;
  final String? image;
  final String? role;
  final int? followerCount;
  final List<TrackModel> topSongs;
  final List<OnlineAlbumModel> topAlbums;

  const OnlineArtistModel({
    required this.id,
    required this.name,
    this.image,
    this.role,
    this.followerCount,
    this.topSongs = const [],
    this.topAlbums = const [],
  });

  factory OnlineArtistModel.fromJioSaavnJson(Map<String, dynamic> json) {
    final rawName = json['name']?.toString() ?? 'Unknown Artist';
    String? art = json['image']?.toString();
    if (art != null && art.contains('150x150')) {
      art = art.replaceAll('150x150', '500x500');
    } else if (art != null && art.contains('50x50')) {
      art = art.replaceAll('50x50', '500x500');
    }

    final rawId = json['artistId']?.toString() ?? json['id']?.toString() ?? '';
    final artistId = rawId.startsWith('saavn_artist_') ? rawId : 'saavn_artist_$rawId';

    List<TrackModel> songs = [];
    final rawSongs = json['topSongs'] is Map
        ? (json['topSongs'] as Map)['songs']
        : json['topSongs'];
    if (rawSongs is List) {
      songs = rawSongs
          .whereType<Map<String, dynamic>>()
          .map((s) => TrackModel.fromJioSaavnJson(s))
          .toList();
    }

    List<OnlineAlbumModel> albums = [];
    final rawAlbums = json['topAlbums'] is Map
        ? (json['topAlbums'] as Map)['albums']
        : json['topAlbums'];
    if (rawAlbums is List) {
      albums = rawAlbums
          .whereType<Map<String, dynamic>>()
          .map((a) => OnlineAlbumModel.fromJioSaavnJson(a))
          .toList();
    }

    final followers = int.tryParse(json['follower_count']?.toString() ?? json['fan_count']?.toString() ?? '0');

    return OnlineArtistModel(
      id: artistId,
      name: _decodeHtmlEntities(rawName),
      image: art,
      role: json['role']?.toString(),
      followerCount: followers,
      topSongs: songs,
      topAlbums: albums,
    );
  }

  static String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  OnlineArtistModel copyWith({
    String? id,
    String? name,
    String? image,
    String? role,
    int? followerCount,
    List<TrackModel>? topSongs,
    List<OnlineAlbumModel>? topAlbums,
  }) {
    return OnlineArtistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      role: role ?? this.role,
      followerCount: followerCount ?? this.followerCount,
      topSongs: topSongs ?? this.topSongs,
      topAlbums: topAlbums ?? this.topAlbums,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'role': role,
      'followerCount': followerCount,
      'topSongs': topSongs.map((s) => s.toJson()).toList(),
      'topAlbums': topAlbums.map((a) => a.toJson()).toList(),
    };
  }

  factory OnlineArtistModel.fromJson(Map<String, dynamic> json) {
    return OnlineArtistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String?,
      role: json['role'] as String?,
      followerCount: json['followerCount'] as int?,
      topSongs: (json['topSongs'] as List<dynamic>?)
              ?.map((s) => TrackModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      topAlbums: (json['topAlbums'] as List<dynamic>?)
              ?.map((a) => OnlineAlbumModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
