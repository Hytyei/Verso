import 'dart:async';

import 'package:flutter/material.dart';

import '../glass/glass_surface.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';

OverlayEntry? _current;
Timer? _timer;

/// Closes the current toast, if any.
void hideToast() {
  _timer?.cancel();
  _current?.remove();
  _current = null;
}

/// Glass toast at the bottom centre for 5 s, optionally with Undo.
void showToast(
  BuildContext context,
  String text, {
  VoidCallback? onUndo,
  Duration duration = const Duration(seconds: 5),
}) => showToastOn(Overlay.of(context, rootOverlay: true), text, onUndo: onUndo, duration: duration);

/// [showToast] on a captured overlay (for callers whose context is about to
/// go away, like a closing popover).
void showToastOn(
  OverlayState overlay,
  String text, {
  VoidCallback? onUndo,
  Duration duration = const Duration(seconds: 5),
}) {
  _timer?.cancel();
  _current?.remove();
  late final OverlayEntry entry;
  void close() {
    if (_current == entry) {
      _timer?.cancel();
      entry.remove();
      _current = null;
    }
  }

  entry = OverlayEntry(
    builder: (context) => Positioned(
      left: 0,
      right: 0,
      bottom: 26,
      child: Center(
        child: _Toast(
          text: text,
          onUndo: onUndo == null
              ? null
              : () {
                  close();
                  onUndo();
                },
        ),
      ),
    ),
  );
  _current = entry;
  overlay.insert(entry);
  _timer = Timer(duration, close);
}

class _Toast extends StatelessWidget {
  const _Toast({required this.text, this.onUndo});
  final String text;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Motion.dur(context),
      curve: Motion.curve(context),
      builder: (context, v, child) => Opacity(
        opacity: v.clamp(0, 1),
        child: Transform.translate(offset: Offset(0, (1 - v) * 24), child: child),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: GlassSurface(
          radius: 999,
          tint: p.isDark ? const Color(0xE61E1A16) : const Color(0xE6FFFFFF),
          padding: const EdgeInsets.fromLTRB(18, 10, 10, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, fontWeight: FontWeight.w500, color: p.text),
              ),
              const SizedBox(width: 12),
              if (onUndo != null)
                GestureDetector(
                  onTap: onUndo,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: p.primary.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Undo',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: p.primary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
