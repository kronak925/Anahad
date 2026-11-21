import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/track_model.dart';
import '../../providers/playback_notifier.dart';

class AirShuffleButton extends StatefulWidget {
  final List<TrackModel> Function() tracksProvider;
  final String contextLabel;
  final bool compact;

  const AirShuffleButton({
    super.key,
    required this.tracksProvider,
    required this.contextLabel,
    this.compact = false,
  });

  @override
  State<AirShuffleButton> createState() => _AirShuffleButtonState();
}

class _AirShuffleButtonState extends State<AirShuffleButton> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _executeAirShuffle(BuildContext context) {
    _animController.forward(from: 0.0);

    final tracks = widget.tracksProvider();
    if (tracks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No tracks available to Air Shuffle in ${widget.contextLabel}'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final shuffled = List<TrackModel>.from(tracks)..shuffle(Random());
    final playback = context.read<PlaybackNotifier>();
    playback.playTrack(shuffled.first, playlist: shuffled, index: 0);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF00E5FF), width: 1),
        ),
        content: Row(
          children: [
            const Icon(Icons.shuffle_rounded, color: Color(0xFF00E5FF), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Air Shuffle: Playing ${shuffled.length} ${widget.contextLabel} tracks',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return IconButton(
        icon: RotationTransition(
          turns: _animController,
          child: const Icon(Icons.shuffle_rounded),
        ),
        color: const Color(0xFF00E5FF),
        tooltip: 'Air Shuffle (${widget.contextLabel})',
        onPressed: () => _executeAirShuffle(context),
      );
    }

    return InkWell(
      onTap: () => _executeAirShuffle(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(
              turns: _animController,
              child: const Icon(Icons.shuffle_rounded, size: 16, color: Colors.black),
            ),
            const SizedBox(width: 6),
            const Text(
              'Air Shuffle',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
