import 'package:flutter/material.dart';

import '../glass/glass_surface.dart';
import '../theme/palette.dart';

/// Glass confirmation dialog. Resolves true on confirm.
Future<bool> confirmDanger(
  BuildContext context, {
  required String title,
  required String message,
  String action = 'Delete',
}) async {
  final r = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Cancel',
    barrierColor: const Color(0x33000000),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, a, b) {
      final p = VersoPalette.of(ctx);
      return Center(
        child: Material(
          type: MaterialType.transparency,
          child: SizedBox(
            width: 360,
            child: GlassSurface(
              radius: 22,
              tint: p.isDark ? const Color(0xF51E1A16) : const Color(0xF5FFFFFF),
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w700, color: p.text),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, height: 1.4, color: p.textSecondary),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('Cancel', style: TextStyle(color: p.textSecondary)),
                      ),
                      const SizedBox(width: 6),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: p.coral, foregroundColor: Colors.white),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(action),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, a, b, child) => FadeTransition(
      opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: Tween(begin: .96, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
  );
  return r ?? false;
}
