import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../theme/motion.dart';

/// Marks the coordinate space [Flip] children measure their moves in
/// (put it inside the scroll view so scrolling is not a "move").
class FlipScope extends SingleChildRenderObjectWidget {
  const FlipScope({super.key, super.child});
  @override
  RenderFlipScope createRenderObject(BuildContext context) => RenderFlipScope();
}

class RenderFlipScope extends RenderProxyBox {}

/// FLIP move animation: when the child's position inside the nearest
/// [FlipScope] jumps by more than [threshold] (a reorder), it is painted at
/// the old place and glides to the new one. Small per-frame drifts (a
/// neighbour growing) are followed directly.
class Flip extends StatefulWidget {
  const Flip({super.key, required this.child, this.threshold = 20});
  final Widget child;
  final double threshold;

  @override
  State<Flip> createState() => _FlipState();
}

class _FlipState extends State<Flip> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: Motion.springDuration);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FlipBox(controller: _c, threshold: widget.threshold, reduced: Motion.reduced(context), child: widget.child);
  }
}

class _FlipBox extends SingleChildRenderObjectWidget {
  const _FlipBox({required this.controller, required this.threshold, required this.reduced, super.child});
  final AnimationController controller;
  final double threshold;
  final bool reduced;

  @override
  _RenderFlip createRenderObject(BuildContext context) => _RenderFlip(controller, threshold, reduced);

  @override
  void updateRenderObject(BuildContext context, _RenderFlip r) => r
    ..threshold = threshold
    ..reduced = reduced;
}

class _RenderFlip extends RenderProxyBox {
  _RenderFlip(this.controller, this.threshold, this.reduced) {
    controller.addListener(markNeedsPaint);
  }
  final AnimationController controller;
  double threshold;
  bool reduced;
  Offset? _last;
  Offset _from = Offset.zero;
  bool _pending = false;

  Offset get _shift {
    if (_pending) return _from;
    if (!controller.isAnimating) return Offset.zero;
    return _from * (1 - Motion.springCurve.transform(controller.value));
  }

  RenderFlipScope? _scope() {
    RenderObject? n = parent;
    while (n != null) {
      if (n is RenderFlipScope) return n;
      n = n.parent;
    }
    return null;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final scope = _scope();
    if (scope != null && attached && hasSize) {
      final pos = localToGlobal(Offset.zero, ancestor: scope);
      final last = _last;
      if (last != null && !reduced) {
        final delta = last - pos;
        if (delta.distance > threshold) {
          // Start from where it visually was (including an in-flight shift).
          _from = delta + _shift;
          _pending = true;
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (!attached) return;
            _pending = false;
            controller.forward(from: 0);
          });
        }
      }
      _last = pos;
    }
    final s = _shift;
    if (s == Offset.zero) {
      super.paint(context, offset);
    } else {
      context.pushTransform(needsCompositing, offset, Matrix4.translationValues(s.dx, s.dy, 0), super.paint);
    }
  }

  @override
  void detach() {
    _last = null;
    super.detach();
  }

  @override
  void dispose() {
    controller.removeListener(markNeedsPaint);
    super.dispose();
  }
}
