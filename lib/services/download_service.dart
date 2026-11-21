import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/track_model.dart';
import 'media_library_service.dart';
import 'storage_service.dart';
import 'stream_resolver.dart';

enum DownloadStatus { pending, downloading, completed, failed, paused, cancelled }

class DownloadTask {
  final String id;
  final TrackModel track;
  double progress;
  int bytesReceived;
  int totalBytes;
  DownloadStatus status;
  String? error;
  String? localFilePath;
  String? localLyricsPath;
  http.Client? client;

  DownloadTask({
    required this.id,
    required this.track,
    this.progress = 0.0,
    this.bytesReceived = 0,
    this.totalBytes = 0,
    this.status = DownloadStatus.pending,
    this.error,
    this.localFilePath,
    this.localLyricsPath,
  });
}

class DownloadService extends ChangeNotifier {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Map<String, DownloadTask> _tasks = {};
  final List<TrackModel> _downloadedTracks = [];
  final StreamResolver _resolver = StreamResolver();
  MediaLibraryService? _mediaLibraryService;

  Map<String, DownloadTask> get tasks => Map.unmodifiable(_tasks);
  List<TrackModel> get downloadedTracks => List.unmodifiable(_downloadedTracks);

  void setMediaLibraryService(MediaLibraryService service) {
    _mediaLibraryService = service;
  }

  /// Initialize and load previously downloaded tracks from persistent storage
  Future<void> initialize() async {
    try {
      final savedJson = StorageService.getString('downloaded_tracks_list');
      if (savedJson != null && savedJson.isNotEmpty) {
        final List<dynamic> list = json.decode(savedJson);
        _downloadedTracks.clear();
        for (var item in list) {
          if (item is Map<String, dynamic>) {
            final track = TrackModel.fromJson(item);
            // Verify file still exists on disk
            if (track.path != null && File(track.path!).existsSync()) {
              _downloadedTracks.add(track);
            }
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[DownloadService] Initialize error: $e');
    }
  }

  Future<Directory> getDownloadDirectory() async {
    final type = StorageService.getDownloadLocationType();
    Directory targetDir;

    switch (type) {
      case 'music_dir':
        final musicDir = Directory('/storage/emulated/0/Music/ANAHAD');
        if (await testDirectoryWritable(musicDir)) {
          targetDir = musicDir;
        } else {
          final extDir = await getExternalStorageDirectory();
          targetDir = Directory('${extDir?.path ?? (await getApplicationDocumentsDirectory()).path}/Music');
        }
        break;

      case 'downloads_dir':
        final downloadDir = Directory('/storage/emulated/0/Download/ANAHAD');
        if (await testDirectoryWritable(downloadDir)) {
          targetDir = downloadDir;
        } else {
          final extDir = await getExternalStorageDirectory();
          targetDir = Directory('${extDir?.path ?? (await getApplicationDocumentsDirectory()).path}/Download');
        }
        break;

      case 'custom':
        final customPath = StorageService.getCustomDownloadDirectory();
        if (customPath != null && customPath.trim().isNotEmpty) {
          final customDir = Directory(customPath.trim());
          if (await testDirectoryWritable(customDir)) {
            targetDir = customDir;
            break;
          }
        }
        final appDir = await getApplicationDocumentsDirectory();
        targetDir = Directory('${appDir.path}/downloads');
        break;

      case 'app_storage':
      default:
        final appDir = await getApplicationDocumentsDirectory();
        targetDir = Directory('${appDir.path}/downloads');
        break;
    }

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    return targetDir;
  }

  static Future<bool> testDirectoryWritable(Directory dir) async {
    try {
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final testFile = File('${dir.path}/.test_write_${DateTime.now().millisecondsSinceEpoch}');
      await testFile.writeAsString('test');
      await testFile.delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  bool isDownloaded(String trackId) {
    return _downloadedTracks.any((t) => t.id == trackId) ||
        (_tasks[trackId]?.status == DownloadStatus.completed);
  }

  bool isDownloading(String trackId) {
    final task = _tasks[trackId];
    return task != null &&
        (task.status == DownloadStatus.downloading || task.status == DownloadStatus.pending);
  }

  double getProgress(String trackId) => _tasks[trackId]?.progress ?? 0.0;

  DownloadTask? getTask(String trackId) => _tasks[trackId];

  Future<bool> downloadTrack(TrackModel track) async {
    await startDownload(track);
    return true;
  }

  /// Start downloading an online track to local device storage
  Future<void> startDownload(TrackModel track) async {
    if (isDownloaded(track.id)) {
      debugPrint('[DownloadService] Track "${track.title}" is already downloaded.');
      return;
    }

    if (isDownloading(track.id)) {
      debugPrint('[DownloadService] Track "${track.title}" is already downloading.');
      return;
    }

    final task = DownloadTask(
      id: track.id,
      track: track,
      status: DownloadStatus.pending,
    );
    _tasks[track.id] = task;
    notifyListeners();

    _executeDownload(task);
  }

  Future<void> _executeDownload(DownloadTask task) async {
    final track = task.track;
    task.status = DownloadStatus.downloading;
    notifyListeners();

    try {
      // 1. Resolve direct playable audio stream URL
      final resolved = await _resolver.resolveStream(track);
      if (resolved == null || resolved.url.isEmpty) {
        throw Exception('Download resolver error: could not resolve stream URL');
      }

      final streamUrl = resolved.url;
      debugPrint('[DownloadService] Resolved stream: $streamUrl');

      // 2. Prepare destination directory and file path
      final downloadsDir = await getDownloadDirectory();

      final ext = resolved.format.toLowerCase().contains('opus')
          ? 'opus'
          : resolved.format.toLowerCase().contains('mp3')
              ? 'mp3'
              : 'm4a';

      final sanitizedName = track.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final fileName = '${track.id}_$sanitizedName.$ext';
      final file = File('${downloadsDir.path}/$fileName');
      task.localFilePath = file.path;

      // 3. Resumable chunked download
      int startByte = 0;
      if (await file.exists()) {
        startByte = await file.length();
      }

      final client = http.Client();
      task.client = client;

      final request = http.Request('GET', Uri.parse(streamUrl));
      if (startByte > 0) {
        request.headers['Range'] = 'bytes=$startByte-';
      }
      request.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)';

      final response = await client.send(request);

      if (response.statusCode != 200 && response.statusCode != 206) {
        throw Exception('HTTP error ${response.statusCode} during download');
      }

      final contentLength = response.contentLength ?? 0;
      task.totalBytes = startByte + contentLength;
      task.bytesReceived = startByte;

      final sink = file.openWrite(mode: startByte > 0 ? FileMode.append : FileMode.write);

      await response.stream.listen(
        (chunk) {
          if (task.status == DownloadStatus.cancelled) {
            sink.close();
            client.close();
            return;
          }
          sink.add(chunk);
          task.bytesReceived += chunk.length;
          if (task.totalBytes > 0) {
            task.progress = (task.bytesReceived / task.totalBytes).clamp(0.0, 1.0);
          }
          notifyListeners();
        },
        cancelOnError: true,
      ).asFuture();

      await sink.flush();
      await sink.close();
      client.close();

      if (task.status == DownloadStatus.cancelled) {
        if (await file.exists()) await file.delete();
        notifyListeners();
        return;
      }

      // 4. File validation
      final downloadedSize = await file.length();
      if (downloadedSize < 50 * 1024) {
        // Less than 50KB is likely an error or corrupt response
        if (await file.exists()) await file.delete();
        throw Exception('Downloaded file validation failed: size too small ($downloadedSize bytes)');
      }

      // 5. Fetch and save offline lyrics from LRCLIB
      await _saveOfflineLyrics(track, downloadsDir.path);

      // 6. Register completed track
      final localTrack = track.copyWith(
        path: file.path,
        uri: file.path,
        sourceType: AudioSourceType.local,
        isDownloaded: true,
        size: downloadedSize,
        dateAdded: DateTime.now(),
      );

      _downloadedTracks.removeWhere((t) => t.id == localTrack.id);
      _downloadedTracks.insert(0, localTrack);
      await _persistDownloadedTracks();

      // Add to media library so it is instantly available in player and library
      _mediaLibraryService?.addLocalTrack(localTrack);

      task.status = DownloadStatus.completed;
      task.progress = 1.0;
      debugPrint('[DownloadService] Successfully downloaded: "${track.title}" to ${file.path}');
      notifyListeners();
    } catch (e) {
      debugPrint('[DownloadService] Resumable download error: $e');
      task.status = DownloadStatus.failed;
      task.error = e.toString();
      notifyListeners();
    }
  }

  /// Fetches and saves synchronized lyrics from LRCLIB alongside the audio file
  Future<void> _saveOfflineLyrics(TrackModel track, String downloadsPath) async {
    try {
      final uri = Uri.parse(
        'https://lrclib.net/api/get?track_name=${Uri.encodeComponent(track.title)}&artist_name=${Uri.encodeComponent(track.artist)}',
      );

      final res = await http.get(uri, headers: {'User-Agent': 'ANAHAD/2.2'});
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final syncedLyrics = data['syncedLyrics']?.toString();
        final plainLyrics = data['plainLyrics']?.toString();

        final lyricsContent = syncedLyrics ?? plainLyrics;
        if (lyricsContent != null && lyricsContent.isNotEmpty) {
          final lrcFile = File('$downloadsPath/${track.id}.lrc');
          await lrcFile.writeAsString(lyricsContent);
          debugPrint('[DownloadService] Auto-saved lyrics offline for "${track.title}"');
          return;
        }
      }
      debugPrint('[DownloadService] Auto-download lyrics skipped for "${track.title}" (not found on LRCLIB)');
    } catch (e) {
      debugPrint('[DownloadService] Auto-download lyrics skipped for "${track.title}": $e');
    }
  }

  Future<void> cancelDownload(String trackId) async {
    final task = _tasks[trackId];
    if (task != null) {
      task.status = DownloadStatus.cancelled;
      task.client?.close();
      if (task.localFilePath != null) {
        final f = File(task.localFilePath!);
        if (await f.exists()) await f.delete();
      }
      _tasks.remove(trackId);
      notifyListeners();
    }
  }

  Future<void> retryDownload(String trackId) async {
    final task = _tasks[trackId];
    if (task != null) {
      task.status = DownloadStatus.pending;
      task.error = null;
      notifyListeners();
      _executeDownload(task);
    }
  }

  Future<void> removeDownloadedTrack(String trackId) async {
    try {
      final index = _downloadedTracks.indexWhere((t) => t.id == trackId);
      if (index != -1) {
        final track = _downloadedTracks[index];
        if (track.path != null) {
          final f = File(track.path!);
          if (await f.exists()) await f.delete();
          final lrc = File(track.path!.replaceAll(RegExp(r'\.[^.]+$'), '.lrc'));
          if (await lrc.exists()) await lrc.delete();
        }
        _downloadedTracks.removeAt(index);
        _tasks.remove(trackId);
        await _persistDownloadedTracks();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[DownloadService] Remove downloaded track error: $e');
    }
  }

  Future<void> _persistDownloadedTracks() async {
    try {
      final list = _downloadedTracks.map((t) => t.toJson()).toList();
      await StorageService.setString('downloaded_tracks_list', json.encode(list));
    } catch (e) {
      debugPrint('[DownloadService] Persist downloaded tracks error: $e');
    }
  }
}
