import 'track_model.dart';

class OnlineAlbumModel {
  final String id;
  final String title;
  final String artist;
  final String? year;
  final String? image;
  final int? songCount;
  final List<TrackModel> tracks;

  const OnlineAlbumModel({
    required this.id,
    required this.title,
    required this.artist,
    this.year,
    this.image,
    this.songCount,
    this.tracks = const [],
  });

  factory OnlineAlbumModel.fromJioSaavnJson(Map<String, dynamic> json) {
    final rawTitle = json['title']?.toString() ?? json['name']?.toString() ?? 'Unknown Album';
    final rawArtist = _cleanArtist(
      json['artist'] ??
      json['primary_artists'] ??
      json['more_info']?['music'] ??
      json['music'] ??
      'Various Artists',
    );

    String? art = json['image']?.toString();
    if (art != null && art.contains('150x150')) {
      art = art.replaceAll('150x150', '500x500');
    } else if (art != null && art.contains('50x50')) {
      art = art.replaceAll('50x50', '500x500');
    }

    final rawId = json['albumid']?.toString() ?? json['id']?.toString() ?? '';
    final albumId = rawId.startsWith('saavn_album_') ? rawId : 'saavn_album_$rawId';

    List<TrackModel> albumTracks = [];
    if (json['songs'] is List) {
      final songList = json['songs'] as List;
      albumTracks = songList
          .whereType<Map<String, dynamic>>()
          .map((s) => TrackModel.fromJioSaavnJson(s))
          .toList();
    }

    final count = albumTracks.isNotEmpty
        ? albumTracks.length
        : int.tryParse(json['song_count']?.toString() ?? '0');

    return OnlineAlbumModel(
      id: albumId,
      title: _decodeHtmlEntities(rawTitle),
      artist: _decodeHtmlEntities(rawArtist),
      year: json['year']?.toString(),
      image: art,
      songCount: count,
      tracks: albumTracks,
    );
  }

  static String _cleanArtist(dynamic raw) {
    if (raw == null) return 'Various Artists';
    final str = raw.toString();
    if (str.startsWith('{') || str.startsWith('[')) {
      final cleaned = str
          .replaceAll(RegExp(r'[\{\}\[\]]'), '')
          .replaceAll(RegExp(r'\b(music|name|id|role|type):\s*'), '')
          .replaceAll(RegExp(r',\s*,'), ',')
          .trim();
      return cleaned.isNotEmpty ? cleaned : 'Various Artists';
    }
    return str.trim().isNotEmpty ? str.trim() : 'Various Artists';
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'year': year,
      'image': image,
      'songCount': songCount,
      'tracks': tracks.map((t) => t.toJson()).toList(),
    };
  }

  factory OnlineAlbumModel.fromJson(Map<String, dynamic> json) {
    return OnlineAlbumModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      year: json['year'] as String?,
      image: json['image'] as String?,
      songCount: json['songCount'] as int?,
      tracks: (json['tracks'] as List<dynamic>?)
              ?.map((t) => TrackModel.fromJson(t as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
