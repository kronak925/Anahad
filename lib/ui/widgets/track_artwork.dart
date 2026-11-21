import 'dart:io';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class TrackArtwork extends StatelessWidget {
  final String id;
  final String? artUri;
  final double size;
  final double borderRadius;
  final IconData fallbackIcon;

  const TrackArtwork({
    super.key,
    required this.id,
    this.artUri,
    this.size = 48,
    this.borderRadius = 8,
    this.fallbackIcon = Icons.music_note_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: _buildArtworkContent(context, theme),
      ),
    );
  }

  Widget _buildArtworkContent(BuildContext context, ThemeData theme) {
    // 1. Online network image
    if (artUri != null && artUri!.isNotEmpty && artUri!.startsWith('http')) {
      return Image.network(
        artUri!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (ctx, err, stack) => _buildFallback(theme),
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return Container(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Center(
              child: SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          );
        },
      );
    }

    // 2. Local file image
    if (artUri != null && artUri!.isNotEmpty && (artUri!.startsWith('file://') || File(artUri!).existsSync())) {
      final path = artUri!.replaceFirst('file://', '');
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (ctx, err, stack) => _buildFallback(theme),
      );
    }

    // 3. Local Android MediaStore audio artwork
    final numericId = int.tryParse(id);
    if (numericId != null) {
      return QueryArtworkWidget(
        id: numericId,
        type: ArtworkType.AUDIO,
        artworkWidth: size,
        artworkHeight: size,
        artworkBorder: BorderRadius.zero,
        nullArtworkWidget: _buildFallback(theme),
        errorBuilder: (ctx, err, stack) => _buildFallback(theme),
      );
    }

    // 4. Fallback placeholder
    return _buildFallback(theme);
  }

  Widget _buildFallback(ThemeData theme) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.2),
            theme.colorScheme.surfaceContainerHighest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          fallbackIcon,
          size: size * 0.48,
          color: theme.colorScheme.primary.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
