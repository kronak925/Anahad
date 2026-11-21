// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:dart_des/dart_des.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() {
  test('JioSaavn search and DES stream decryption test', () async {
    final url = Uri.parse(
      'https://www.jiosaavn.com/api.php?__call=search.getResults&_format=json&_marker=0&cc=in&p=1&n=5&q=Kesariya',
    );

    final res = await http.get(url, headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
    });

    expect(res.statusCode, equals(200));
    final data = json.decode(res.body.trim()) as Map<String, dynamic>;
    expect(data.containsKey('results'), isTrue);

    final results = data['results'] as List;
    expect(results.isNotEmpty, isTrue);

    final first = results.first as Map<String, dynamic>;
    final songTitle = first['song']?.toString() ?? '';
    final encryptedUrl = first['encrypted_media_url']?.toString() ?? '';
    print('JioSaavn Track: $songTitle');
    print('Encrypted URL: $encryptedUrl');

    expect(songTitle.isNotEmpty, isTrue);
    expect(encryptedUrl.isNotEmpty, isTrue);

    // Decrypt using DES ECB with key '38346591'
    final key = utf8.encode('38346591');
    final desECB = DES(key: key, mode: DESMode.ECB, paddingType: DESPaddingType.PKCS7);
    final encryptedBytes = base64.decode(encryptedUrl);
    final decryptedBytes = desECB.decrypt(encryptedBytes);
    final decryptedUrl = utf8.decode(decryptedBytes);
    print('Decrypted direct URL: $decryptedUrl');
    expect(decryptedUrl.startsWith('http'), isTrue);
    expect(decryptedUrl.contains('.mp4'), isTrue);
  });

  test('LRCLIB lyrics retrieval test', () async {
    final url = Uri.parse(
      'https://lrclib.net/api/get?track_name=Kesariya&artist_name=Arijit%20Singh',
    );
    try {
      final res = await http.get(url, headers: {'User-Agent': 'ANAHAD/2.2 (Linux; Android)'});
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        print('LRCLIB synced lyrics: ${data['syncedLyrics'] != null ? "Found" : "None"}');
      } else {
        print('LRCLIB status: ${res.statusCode}');
      }
    } catch (e) {
      print('LRCLIB exception: $e');
    }
  });

  test('YouTube Explode audio stream resolution test', () async {
    final yt = YoutubeExplode();
    try {
      final searchResults = await yt.search.search('Kesariya Audio');
      expect(searchResults.isNotEmpty, isTrue);

      final video = searchResults.first;
      print('YouTube Video Title: ${video.title}');
      print('YouTube Video ID: ${video.id.value}');

      final manifest = await yt.videos.streamsClient.getManifest(video.id);
      final audioStreams = manifest.audioOnly.sortByBitrate();
      expect(audioStreams.isNotEmpty, isTrue);

      final highestAudio = audioStreams.last;
      print('YouTube Audio Stream URL: ${highestAudio.url}');
      print('YouTube Audio Bitrate: ${highestAudio.bitrate}');
      print('YouTube Audio Codec: ${highestAudio.audioCodec}');

      expect(highestAudio.url.toString().startsWith('http'), isTrue);
    } finally {
      yt.close();
    }
  });
}
