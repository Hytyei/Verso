import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/motion.dart';

/// A small circular progress ring that animates between values.
class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.value, required this.color, this.size = 18, this.track});
  final double value;
  final Color color;
  final Color? track;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.isNaN ? 0 : value.clamp(0, 1)),
      duration: Motion.dur(context),
      curve: Motion.curve(context),
      builder: (context, v, _) =>
          CustomPaint(size: Size.square(size), painter: _RingPainter(v, color, track ?? color.withValues(alpha: .18))),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.v, this.color, this.track);
  final double v;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size s) {
    final stroke = s.width * .16;
    final rect = (Offset.zero & s).deflate(stroke / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );
    if (v > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * v,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.v != v || o.color != color || o.track != track;
}
