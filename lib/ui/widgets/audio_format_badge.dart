import 'package:flutter/material.dart';

class AudioFormatBadge extends StatelessWidget {
  final String format;
  final bool isLossless;
  final int? sampleRate;
  final int? bitDepth;
  final bool compact;

  const AudioFormatBadge({
    super.key,
    required this.format,
    required this.isLossless,
    this.sampleRate,
    this.bitDepth,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isHiRes = isLossless && ((bitDepth != null && bitDepth! > 16) || (sampleRate != null && sampleRate! > 48000));

    final badgeColor = isHiRes
        ? const Color(0xFF06B6D4) // Cyan for Hi-Res Lossless
        : isLossless
            ? const Color(0xFFEAB308) // Gold for CD Lossless
            : const Color(0xFF64748B); // Slate for Lossy

    String label = format.toUpperCase();
    if (!compact) {
      if (isHiRes) {
        label = 'HI-RES LOSSLESS';
        if (bitDepth != null && sampleRate != null) {
          label += ' • ${bitDepth}B/${(sampleRate! / 1000).toStringAsFixed(1)}kHz';
        }
      } else if (isLossless) {
        label = 'LOSSLESS FLAC';
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: compact ? 2 : 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(compact ? 4 : 6),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: badgeColor,
          fontSize: compact ? 9 : 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
