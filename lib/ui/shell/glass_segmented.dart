import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../glass/glass_surface.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';

/// iOS-style segmented control on glass. The selected pill glides with a
/// spring and stretches mid-travel like a droplet.
class GlassSegmented<T> extends StatelessWidget {
  const GlassSegmented({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.segmentWidth = 96,
    this.height = 34,
  });

  final List<(T, String)> items;
  final T value;
  final ValueChanged<T> onChanged;
  final double segmentWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final index = math.max(0, items.indexWhere((e) => e.$1 == value)).toDouble();
    return GlassSurface(
      radius: 999,
      padding: const EdgeInsets.all(3),
      child: SizedBox(
        width: segmentWidth * items.length,
        height: height,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: index),
          duration: Motion.dur(context),
          curve: Motion.curve(context),
          builder: (context, pos, _) {
            final frac = (pos - pos.floorToDouble());
            final stretch = Motion.reduced(context) ? 0.0 : math.sin(frac * math.pi) * .22;
            final w = segmentWidth * (1 + stretch);
            return Stack(
              children: [
                Positioned(
                  left: pos * segmentWidth - (w - segmentWidth) / 2,
                  top: 0,
                  bottom: 0,
                  width: w,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: p.isDark ? p.surfaceRaised : Colors.white.withValues(alpha: .82),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: p.isDark ? const Color(0x22FFFFFF) : Colors.white, width: .8),
                      boxShadow: [BoxShadow(color: p.shadow, blurRadius: 10, offset: const Offset(0, 2))],
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      _Segment(
                        width: segmentWidth,
                        label: items[i].$2,
                        selected: (pos - i).abs() < .5,
                        onTap: () => onChanged(items[i].$1),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.width, required this.label, required this.selected, required this.onTap});
  final double width;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: Motion.fade,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? (p.isDark ? p.primary : p.text) : p.textSecondary,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
