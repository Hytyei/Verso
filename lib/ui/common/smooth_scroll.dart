import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/motion.dart';

/// Turns notchy mouse-wheel steps into eased scrolling on [controller].
/// Place it *inside* the scroll view (around its content) so it claims the
/// wheel event before the Scrollable does.
class SmoothWheel extends StatefulWidget {
  const SmoothWheel({super.key, required this.controller, required this.axis, required this.child, this.accept});
  final ScrollController controller;
  final Axis axis;
  final Widget child;

  /// Which wheel events this scroller claims; defaults by axis:
  /// vertical claims plain vertical wheel; horizontal claims everything.
  final bool Function(PointerScrollEvent e)? accept;

  @override
  State<SmoothWheel> createState() => _SmoothWheelState();
}

class _SmoothWheelState extends State<SmoothWheel> {
  double? _target;

  bool _accepts(PointerScrollEvent e) {
    if (widget.accept != null) return widget.accept!(e);
    final shift = HardwareKeyboard.instance.isShiftPressed;
    if (widget.axis == Axis.vertical)
      return !shift && e.scrollDelta.dy != 0 && e.scrollDelta.dx.abs() < e.scrollDelta.dy.abs();
    return true;
  }

  void _scroll(PointerScrollEvent e) {
    final c = widget.controller;
    if (!c.hasClients) return;
    final pos = c.position;
    final d = widget.axis == Axis.vertical
        ? e.scrollDelta.dy
        : (e.scrollDelta.dx != 0 ? e.scrollDelta.dx : e.scrollDelta.dy);
    final base = (_target == null || (pos.pixels - _target!).abs() > 600) ? pos.pixels : _target!;
    final t = (base + d * 1.15).clamp(pos.minScrollExtent, pos.maxScrollExtent);
    _target = t;
    if (Motion.reduced(context)) {
      c.jumpTo(t);
      _target = null;
      return;
    }
    c.animateTo(t, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic).whenComplete(() {
      if (_target == t) _target = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (e) {
        if (e is PointerScrollEvent && _accepts(e)) {
          GestureBinding.instance.pointerSignalResolver.register(e, (ev) => _scroll(ev as PointerScrollEvent));
        }
      },
      child: widget.child,
    );
  }
}
