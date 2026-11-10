import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../theme/motion.dart';
import '../theme/palette.dart';

/// Round iOS-style checkbox: pops (0.8 → 1.1 → 1) on a spring and draws its
/// tick stroke by stroke.
class CheckPop extends StatefulWidget {
  const CheckPop({super.key, required this.value, required this.onChanged, required this.color, this.size = 20});
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;
  final double size;

  @override
  State<CheckPop> createState() => _CheckPopState();
}

class _CheckPopState extends State<CheckPop> with TickerProviderStateMixin {
  late final AnimationController _tick = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    value: widget.value ? 1 : 0,
  );
  late final AnimationController _pop = AnimationController.unbounded(vsync: this, value: 1);
  bool _hover = false;

  @override
  void didUpdateWidget(CheckPop old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      final reduced = Motion.reduced(context);
      if (widget.value) {
        _tick.animateTo(1, curve: Curves.easeOutCubic, duration: reduced ? Motion.fade : null);
        if (!reduced) {
          _pop.value = .8;
          _pop.animateWith(SpringSimulation(Motion.snappy, .8, 1, 6));
        }
      } else {
        _tick.animateTo(0, duration: Motion.fade);
      }
    }
  }

  @override
  void dispose() {
    _tick.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onChanged(!widget.value),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: AnimatedBuilder(
            animation: Listenable.merge([_tick, _pop]),
            builder: (context, _) => Transform.scale(
              scale: _pop.value,
              child: CustomPaint(
                size: Size.square(widget.size),
                painter: _CheckPainter(
                  t: _tick.value,
                  color: widget.color,
                  ring: _hover ? widget.color : widget.color.withValues(alpha: .55),
                  tick: p.isDark ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.t, required this.color, required this.ring, required this.tick});
  final double t;
  final Color color;
  final Color ring;
  final Color tick;

  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero);
    final r = s.width / 2;
    canvas.drawCircle(
      c,
      r - .8,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = Color.lerp(ring, color, t)!,
    );
    if (t <= 0) return;
    canvas.drawCircle(c, (r - .2) * Curves.easeOut.transform(t.clamp(0, 1)), Paint()..color = color);
    final path = Path()
      ..moveTo(s.width * .28, s.height * .52)
      ..lineTo(s.width * .44, s.height * .67)
      ..lineTo(s.width * .73, s.height * .36);
    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * ((t - .25) / .75).clamp(0, 1));
    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s.width * .11
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = tick,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter o) => o.t != t || o.color != color || o.ring != ring || o.tick != tick;
}
