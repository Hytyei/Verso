import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Pastel chip like the reference image's column labels.
class TintChip extends StatelessWidget {
  const TintChip({
    super.key,
    required this.label,
    required this.color,
    required this.tint,
    this.icon,
    this.muted = false,
  });
  final String label;
  final Color color;
  final Color tint;
  final IconData? icon;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: muted ? .55 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(6)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 11, color: color), const SizedBox(width: 3)],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Priority marker: 1 low, 2 medium, 3 high.
class PriorityFlag extends StatelessWidget {
  const PriorityFlag({super.key, required this.priority});
  final int priority;

  static String label(int p) => const ['None', 'Low', 'Medium', 'High'][p.clamp(0, 3)];

  @override
  Widget build(BuildContext context) {
    if (priority <= 0) return const SizedBox.shrink();
    final p = VersoPalette.of(context);
    final color = switch (priority) {
      3 => p.coral,
      2 => p.accents[1],
      _ => p.textSecondary,
    };
    return Tooltip(
      message: '${label(priority)} priority',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < priority; i++)
            Container(
              width: 3,
              height: 6.0 + i * 3,
              margin: const EdgeInsets.only(right: 1.5),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1.5)),
            ),
        ],
      ),
    );
  }
}

/// Small icon + count used in a card's meta row.
class MetaCount extends StatelessWidget {
  const MetaCount({super.key, required this.icon, this.text});
  final IconData icon;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: p.textSecondary),
        if (text != null) ...[
          const SizedBox(width: 3),
          Text(
            text!,
            style: TextStyle(fontFamily: 'Inter', fontSize: 11.5, color: p.textSecondary),
          ),
        ],
      ],
    );
  }
}
