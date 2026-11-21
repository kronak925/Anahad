import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnahadBrandIcon extends StatefulWidget {
  final double size;
  final bool isPlaying;
  final VoidCallback? onTap;

  const AnahadBrandIcon({
    super.key,
    this.size = 40,
    this.isPlaying = false,
    this.onTap,
  });

  @override
  State<AnahadBrandIcon> createState() => _AnahadBrandIconState();
}

class _AnahadBrandIconState extends State<AnahadBrandIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AnahadBrandIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.animateTo(0, duration: const Duration(milliseconds: 300));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _AnahadLogoPainter(
              animationValue: _controller.value,
              isPlaying: widget.isPlaying,
            ),
          );
        },
      ),
    );
  }
}

class _AnahadLogoPainter extends CustomPainter {
  final double animationValue;
  final bool isPlaying;

  _AnahadLogoPainter({
    required this.animationValue,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Background Rounded Squircle with Dark Radial Gradient
    final rect = Rect.fromLTWH(0, 0, w, h);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(w * 0.28));

    final bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -0.1),
        radius: 0.9,
        colors: [
          Color(0xFF131D2E),
          Color(0xFF090D15),
          Color(0xFF04060A),
        ],
      ).createShader(rect);

    canvas.drawRRect(rrect, bgPaint);

    // Squircle border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.8);
    canvas.drawRRect(rrect, borderPaint);

    // Dynamic wave oscillation offset
    final wavePhase = animationValue * 2 * math.pi;
    final glowPulse = isPlaying ? (math.sin(wavePhase) * 0.25 + 0.75) : 0.6;

    // 2. Headphone Arch Parameters
    final archCenter = Offset(w / 2, h * 0.44);
    final outerRadius = w * 0.24;
    final innerRadius = w * 0.18;

    // Outer Headphone Band Neon Glow
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.08 * glowPulse)
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF00E676),
          Color(0xFF00E5FF),
          Color(0xFF00B0FF),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromCircle(center: archCenter, radius: outerRadius));

    final archPath = Path()
      ..addArc(
        Rect.fromCircle(center: archCenter, radius: outerRadius),
        math.pi,
        math.pi,
      );

    canvas.drawPath(archPath, glowPaint);

    // Crisp Outer Headphone Arch
    final bandPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF00E676),
          Color(0xFF1DE9B6),
          Color(0xFF00E5FF),
          Color(0xFF2979FF),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromCircle(center: archCenter, radius: outerRadius));

    canvas.drawPath(archPath, bandPaint);

    // Inner Concentric Arc (Slate Gray)
    final innerArchPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.022
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF64748B).withValues(alpha: 0.85);

    final innerPath = Path()
      ..addArc(
        Rect.fromCircle(center: archCenter, radius: innerRadius),
        math.pi * 0.95,
        math.pi * 1.1,
      );
    canvas.drawPath(innerPath, innerArchPaint);

    // Earcups (Rounded vertical capsules on left and right)
    final earcupWidth = w * 0.055;
    final earcupHeight = w * 0.16;
    final leftEarcupRect = Rect.fromCenter(
      center: Offset(archCenter.dx - outerRadius, archCenter.dy + earcupHeight * 0.25),
      width: earcupWidth,
      height: earcupHeight,
    );
    final rightEarcupRect = Rect.fromCenter(
      center: Offset(archCenter.dx + outerRadius, archCenter.dy + earcupHeight * 0.25),
      width: earcupWidth,
      height: earcupHeight,
    );

    // Left Earcup (Emerald Green)
    final leftEarcupPaint = Paint()
      ..color = const Color(0xFF00E676)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(leftEarcupRect, Radius.circular(earcupWidth / 2)), leftEarcupPaint);

    // Right Earcup (Cyan / Blue)
    final rightEarcupPaint = Paint()
      ..color = const Color(0xFF00B0FF)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(rightEarcupRect, Radius.circular(earcupWidth / 2)), rightEarcupPaint);

    // 3. Center Triple Dots
    final dotY = archCenter.dy;
    // Left Dot (Green)
    final leftDotPaint = Paint()..color = const Color(0xFF00E676).withValues(alpha: 0.9);
    canvas.drawCircle(Offset(archCenter.dx - w * 0.12, dotY), w * 0.016, leftDotPaint);

    // Right Dot (Cyan)
    final rightDotPaint = Paint()..color = const Color(0xFF00B0FF).withValues(alpha: 0.9);
    canvas.drawCircle(Offset(archCenter.dx + w * 0.12, dotY), w * 0.016, rightDotPaint);

    // Center Dot (Glowing White Pulse)
    final centerGlow = Paint()
      ..color = Colors.white.withValues(alpha: isPlaying ? (0.6 * glowPulse) : 0.4)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.04);
    canvas.drawCircle(Offset(archCenter.dx, dotY), w * 0.035, centerGlow);

    final centerDotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(archCenter.dx, dotY), w * 0.024, centerDotPaint);

    // 4. Oscillating Sound Waves Underneath
    final wave1Y = h * 0.69;
    final wave2Y = h * 0.77;
    final waveWidth = w * 0.54;
    final waveStartX = (w - waveWidth) / 2;

    // Primary Neon Cyan Sound Wave
    final wave1Glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.06 * glowPulse)
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.75);

    final wave1Stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.042
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF00E676),
          Color(0xFF00E5FF),
          Color(0xFF00B0FF),
        ],
      ).createShader(Rect.fromLTWH(waveStartX, wave1Y - 10, waveWidth, 20));

    final wave1Path = Path();
    const points = 32;
    for (int i = 0; i <= points; i++) {
      final t = i / points;
      final x = waveStartX + t * waveWidth;
      // Multi-frequency sinusoidal oscillation
      final amp = isPlaying ? (w * 0.042) : (w * 0.018);
      final freq = 2.5;
      final y = wave1Y + math.sin(t * freq * 2 * math.pi + (isPlaying ? wavePhase : 0)) * amp;
      if (i == 0) {
        wave1Path.moveTo(x, y);
      } else {
        wave1Path.lineTo(x, y);
      }
    }

    canvas.drawPath(wave1Path, wave1Glow);
    canvas.drawPath(wave1Path, wave1Stroke);

    // Secondary Subtle Cyan/Blue Wave Underneath
    final wave2Stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.026
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF00B0FF).withValues(alpha: isPlaying ? 0.8 : 0.4);

    final wave2Path = Path();
    for (int i = 0; i <= points; i++) {
      final t = i / points;
      final x = waveStartX + w * 0.06 + t * (waveWidth * 0.8);
      final amp = isPlaying ? (w * 0.024) : (w * 0.012);
      final freq = 2.2;
      final y = wave2Y + math.sin(t * freq * 2 * math.pi - (isPlaying ? wavePhase * 1.2 : 0) + 1.2) * amp;
      if (i == 0) {
        wave2Path.moveTo(x, y);
      } else {
        wave2Path.lineTo(x, y);
      }
    }

    canvas.drawPath(wave2Path, wave2Stroke);
  }

  @override
  bool shouldRepaint(covariant _AnahadLogoPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.isPlaying != isPlaying;
  }
}
