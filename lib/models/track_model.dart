import 'package:audio_service/audio_service.dart';
import 'package:on_audio_query/on_audio_query.dart';

enum AudioSourceType { local, sample, universal, deezer, dab, saavn, youtube }

class TrackModel {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String uri;
  final String? path;
  final String? artUri;
  final String format; // "FLAC", "MP3", "AAC", "M4A", "WAV", "OGG", "OPUS"
  final int? sampleRate; // e.g. 44100, 96000
  final int? bitDepth; // e.g. 16, 24
  final int? bitrate; // e.g. 320000, 1411200
  final bool isLossless;
  final bool isFavorite;
  final AudioSourceType sourceType;
  final int? size;
  final DateTime? dateAdded;
  final String? encryptedMediaUrl;
  final String? year;
  final bool isDownloaded;

  const TrackModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.uri,
    this.path,
    this.artUri,
    this.format = 'MP3',
    this.sampleRate,
    this.bitDepth,
    this.bitrate,
    this.isLossless = false,
    this.isFavorite = false,
    this.sourceType = AudioSourceType.local,
    this.size,
    this.dateAdded,
    this.encryptedMediaUrl,
    this.year,
    this.isDownloaded = false,
  });

  TrackModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    Duration? duration,
    String? uri,
    String? path,
    String? artUri,
    String? format,
    int? sampleRate,
    int? bitDepth,
    int? bitrate,
    bool? isLossless,
    bool? isFavorite,
    AudioSourceType? sourceType,
    int? size,
    DateTime? dateAdded,
    String? encryptedMediaUrl,
    String? year,
    bool? isDownloaded,
  }) {
    return TrackModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      uri: uri ?? this.uri,
      path: path ?? this.path,
      artUri: artUri ?? this.artUri,
      format: format ?? this.format,
      sampleRate: sampleRate ?? this.sampleRate,
      bitDepth: bitDepth ?? this.bitDepth,
      bitrate: bitrate ?? this.bitrate,
      isLossless: isLossless ?? this.isLossless,
      isFavorite: isFavorite ?? this.isFavorite,
      sourceType: sourceType ?? this.sourceType,
      size: size ?? this.size,
      dateAdded: dateAdded ?? this.dateAdded,
      encryptedMediaUrl: encryptedMediaUrl ?? this.encryptedMediaUrl,
      year: year ?? this.year,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }

  MediaItem toMediaItem() {
    return MediaItem(
      id: id,
      title: title,
      artist: artist,
      album: album,
      duration: duration,
      artUri: artUri != null ? Uri.tryParse(artUri!) : null,
      extras: {
        'uri': uri,
        'path': path,
        'format': format,
        'sampleRate': sampleRate,
        'bitDepth': bitDepth,
        'bitrate': bitrate,
        'isLossless': isLossless,
        'sourceType': sourceType.name,
      },
    );
  }

  factory TrackModel.fromSongModel(SongModel song) {
    final title = song.title.isNotEmpty ? song.title : 'Unknown Title';
    final artist = song.artist != null && song.artist != '<unknown>' ? song.artist! : 'Unknown Artist';
    final album = song.album != null && song.album != '<unknown>' ? song.album! : 'Unknown Album';
    final duration = Duration(milliseconds: song.duration ?? 0);
    final ext = (song.fileExtension.isNotEmpty ? song.fileExtension.toUpperCase() : 'MP3');
    final isLossless = ext == 'FLAC' || ext == 'WAV' || ext == 'ALAC';

    return TrackModel(
      id: song.id.toString(),
      title: title,
      artist: artist,
      album: album,
      duration: duration,
      uri: song.uri ?? song.data,
      path: song.data,
      artUri: null, // OnAudioQuery provides ArtworkWidget directly by id
      format: ext,
      sampleRate: isLossless ? 44100 : 44100,
      bitDepth: isLossless ? 16 : null,
      bitrate: isLossless ? 1411 : 320,
      isLossless: isLossless,
      isFavorite: false,
      sourceType: AudioSourceType.local,
      size: song.size,
      dateAdded: song.dateAdded != null ? DateTime.fromMillisecondsSinceEpoch(song.dateAdded! * 1000) : null,
    );
  }

  factory TrackModel.fromJioSaavnJson(Map<String, dynamic> json, {String? directStreamUrl}) {
    final rawTitle = json['song']?.toString() ?? json['title']?.toString() ?? 'Unknown Song';
    final rawArtist = json['primary_artists']?.toString() ??
        json['singers']?.toString() ??
        json['artist']?.toString() ??
        'Unknown Artist';
    final rawAlbum = json['album']?.toString() ?? 'Single';
    final durationSec = int.tryParse(json['duration']?.toString() ?? '0') ?? 0;

    String? art = json['image']?.toString();
    if (art != null && art.contains('150x150')) {
      art = art.replaceAll('150x150', '500x500');
    } else if (art != null && art.contains('50x50')) {
      art = art.replaceAll('50x50', '500x500');
    }

    final rawId = json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    final encryptedUrl = json['encrypted_media_url']?.toString();
    final mediaPreviewUrl = json['media_preview_url']?.toString();

    return TrackModel(
      id: rawId.startsWith('saavn_') ? rawId : 'saavn_$rawId',
      title: _decodeHtmlEntities(rawTitle),
      artist: _decodeHtmlEntities(rawArtist),
      album: _decodeHtmlEntities(rawAlbum),
      duration: Duration(seconds: durationSec),
      uri: directStreamUrl ?? mediaPreviewUrl ?? '',
      artUri: art,
      format: 'AAC 320k',
      sampleRate: 44100,
      bitDepth: 16,
      bitrate: 320,
      isLossless: false,
      isFavorite: false,
      sourceType: AudioSourceType.saavn,
      encryptedMediaUrl: encryptedUrl,
      year: json['year']?.toString(),
      isDownloaded: false,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'durationMs': duration.inMilliseconds,
      'uri': uri,
      'path': path,
      'artUri': artUri,
      'format': format,
      'sampleRate': sampleRate,
      'bitDepth': bitDepth,
      'bitrate': bitrate,
      'isLossless': isLossless,
      'isFavorite': isFavorite,
      'sourceType': sourceType.name,
      'size': size,
      'dateAdded': dateAdded?.toIso8601String(),
      'encryptedMediaUrl': encryptedMediaUrl,
      'year': year,
      'isDownloaded': isDownloaded,
    };
  }

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String,
      duration: Duration(milliseconds: json['durationMs'] as int? ?? 0),
      uri: json['uri'] as String,
      path: json['path'] as String?,
      artUri: json['artUri'] as String?,
      format: json['format'] as String? ?? 'MP3',
      sampleRate: json['sampleRate'] as int?,
      bitDepth: json['bitDepth'] as int?,
      bitrate: json['bitrate'] as int?,
      isLossless: json['isLossless'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      sourceType: AudioSourceType.values.firstWhere(
        (e) => e.name == json['sourceType'],
        orElse: () => AudioSourceType.local,
      ),
      size: json['size'] as int?,
      dateAdded: json['dateAdded'] != null ? DateTime.tryParse(json['dateAdded'] as String) : null,
      encryptedMediaUrl: json['encryptedMediaUrl'] as String?,
      year: json['year'] as String?,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
    );
  }
}
