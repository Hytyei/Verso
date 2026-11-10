import 'package:flutter/material.dart';

import '../../data/db/database.dart';
import '../glass/glass_surface.dart';
import '../shell/background.dart';
import '../theme/palette.dart';
import '../timeline/timeline_view.dart';

/// The shared timeline on a full screen (pinch to zoom, drag bars to move them).
Future<void> openPhoneTimeline(BuildContext context, Project project) {
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (ctx, _, _) => _PhoneTimeline(project: project),
      transitionsBuilder: (ctx, a, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween(begin: .97, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    ),
  );
}

class _PhoneTimeline extends StatelessWidget {
  const _PhoneTimeline({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final top = MediaQuery.paddingOf(context).top;
    return Material(
      type: MaterialType.transparency,
      child: VersoBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
                child: TimelineView(project: project, topInset: top + 64),
              ),
            ),
            Positioned(
              top: top + 8,
              left: 10,
              child: GlassSurface(
                key: const Key('timeline-back'),
                interactive: true,
                radius: 999,
                padding: const EdgeInsets.fromLTRB(10, 8, 16, 8),
                onTap: () => Navigator.of(context).pop(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 20, color: p.text),
                    const SizedBox(width: 6),
                    Text(
                      '${project.name} · Timeline',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: p.text),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
