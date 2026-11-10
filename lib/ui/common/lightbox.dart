import 'dart:io';

import 'package:flutter/material.dart';

import '../glass/glass_surface.dart';

/// Full-window image viewer with pinch / wheel zoom. Click outside or Esc closes.
Future<void> showLightbox(BuildContext context, File file) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0xD9000000),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, a, b) => Stack(
      children: [
        Positioned.fill(
          child: InteractiveViewer(
            maxScale: 8,
            child: Center(child: Image.file(file, fit: BoxFit.contain)),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: GlassSurface(
            interactive: true,
            radius: 999,
            onTap: () => Navigator.pop(ctx),
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
          ),
        ),
      ],
    ),
    transitionBuilder: (ctx, a, b, child) => FadeTransition(
      opacity: a,
      child: ScaleTransition(
        scale: Tween(begin: .97, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
  );
}
