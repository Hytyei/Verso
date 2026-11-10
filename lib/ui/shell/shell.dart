import '../common/update_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import '../board/board_view.dart';
import '../glass/glass_surface.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';
import '../timeline/timeline_view.dart';
import 'background.dart';
import 'sidebar.dart';
import 'title_bar.dart';
import 'toolbar.dart';

/// Window layout: title bar, glass sidebar, floating toolbar over the
/// board or timeline.
class Shell extends ConsumerWidget {
  const Shell({
    super.key,
    this.toolbarLeading = const [],
    this.toolbarTrailing = const [],
    this.onOpenSettings,
    this.onProjectMenu,
    this.sidebarFooter,
  });

  final List<Widget> toolbarLeading;
  final List<Widget> toolbarTrailing;
  final VoidCallback? onOpenSettings;
  final void Function(BuildContext context, Project project, String environmentId, Offset globalPos)? onProjectMenu;

  /// Account area at the bottom of the sidebar.
  final Widget? sidebarFooter;

  /// Space the content leaves at the top for the floating toolbar.
  static const contentTopInset = Toolbar.height + 14;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider).value ?? const <Project>[];
    final selectedId = ref.watch(selectedProjectIdProvider);
    final project = projects.where((p) => p.id == selectedId).firstOrNull;
    final mode = ref.watch(viewModeProvider);
    return VersoBackground(
      child: Column(
        children: [
          const TitleBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Sidebar(onOpenSettings: onOpenSettings, onProjectMenu: onProjectMenu, footer: sidebarFooter),
                  const SizedBox(width: 10),
                  Expanded(
                    child: project == null
                        ? const _EmptyState()
                        : Stack(
                            children: [
                              Positioned.fill(
                                child: AnimatedSwitcher(
                                  duration: Motion.dur(context),
                                  // Fill the area: the default centred, loose Stack let the
                                  // board's scroll view shrink to its columns and drift right.
                                  layoutBuilder: (current, previous) =>
                                      Stack(fit: StackFit.expand, children: [...previous, ?current]),
                                  switchInCurve: Motion.curve(context),
                                  transitionBuilder: (child, a) => FadeTransition(
                                    opacity: a,
                                    child: ScaleTransition(
                                      scale: Tween(begin: .985, end: 1.0).animate(a),
                                      child: child,
                                    ),
                                  ),
                                  child: mode == ViewMode.board
                                      ? BoardView(
                                          key: ValueKey('board-${project.id}'),
                                          project: project,
                                          topInset: contentTopInset,
                                        )
                                      : TimelineView(
                                          key: ValueKey('timeline-${project.id}'),
                                          project: project,
                                          topInset: contentTopInset,
                                        ),
                                ),
                              ),
                              Positioned(
                                top: contentTopInset + 6,
                                left: 0,
                                right: 0,
                                child: const Center(child: UpdateBanner()),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Toolbar(
                                  title: project.name,
                                  paused: project.paused,
                                  leading: toolbarLeading,
                                  trailing: toolbarTrailing,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = VersoPalette.of(context);
    return Center(
      child: GlassSurface(
        radius: 28,
        padding: const EdgeInsets.fromLTRB(36, 32, 36, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 34, color: p.primary),
            const SizedBox(height: 14),
            Text(
              'Track your first app',
              style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700, color: p.text),
            ),
            const SizedBox(height: 6),
            Text(
              'Start with ideas in Concept, then plan them into versions.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, color: p.textSecondary),
            ),
            const SizedBox(height: 20),
            GlassSurface(
              interactive: true,
              radius: 999,
              tint: p.primary.withValues(alpha: .9),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              onTap: () async {
                final id = await ref.read(projectRepoProvider).create('My app', const VColor.slot(0));
                ref.read(selectedProjectIdProvider.notifier).select(id);
              },
              child: Text(
                'Create project',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: p.isDark ? Colors.black : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
