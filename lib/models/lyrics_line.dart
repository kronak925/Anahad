class LyricsLine {
  final Duration timestamp;
  final String text;

  const LyricsLine({
    required this.timestamp,
    required this.text,
  });

  @override
  String toString() => '[${timestamp.inMinutes}:${(timestamp.inSeconds % 60).toString().padLeft(2, '0')}] $text';
}
