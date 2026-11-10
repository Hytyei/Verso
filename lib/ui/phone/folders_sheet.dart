import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../editors/project_menu.dart';
import '../shell/account_area.dart';
import '../shell/sidebar.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';

/// The Windows sidebar as a sheet that drops from the header: environment
/// folders, projects, the dimmed On Pause subfolder, and the account.
/// Tap a project to open it; long-press it (or a folder) for its menu.
Future<void> showFoldersSheet(BuildContext context, {required VoidCallback onOpenSettings}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x66000000),
    transitionDuration: Motion.reduced(context) ? Motion.fade : const Duration(milliseconds: 380),
    pageBuilder: (ctx, _, _) => _FoldersSheet(onOpenSettings: onOpenSettings),
    transitionBuilder: (ctx, a, _, child) {
      final curved = CurvedAnimation(parent: a, curve: Motion.curve(ctx), reverseCurve: Curves.easeInCubic);
      return FadeTransition(
        opacity: CurvedAnimation(parent: a, curve: const Interval(0, .5)),
        child: SlideTransition(
          position: Tween(begin: const Offset(0, -.12), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _FoldersSheet extends ConsumerWidget {
  const _FoldersSheet({required this.onOpenSettings});
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = MediaQuery.of(context);
    final p = VersoPalette.of(context);
    void close() => Navigator.of(context).maybePop();
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, media.padding.top + 8, 10, 0),
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            key: const Key('folders-sheet'),
            height: (media.size.height - media.padding.top) * .78,
            // The sidebar's glass is made for a calm window background; over the busy board the
            // sheet needs a dense backing to stay readable.
            decoration: BoxDecoration(
              color: p.isDark ? const Color(0xF2141210) : const Color(0xF2F4F6FB),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: p.shadow, blurRadius: 30, offset: const Offset(0, 12))],
            ),
            child: Sidebar(
              panelWidth: media.size.width - 20,
              onOpened: close,
              onOpenSettings: () {
                close();
                onOpenSettings();
              },
              onProjectMenu: (c, project, envId, pos) => showProjectMenu(c, ref, project, envId, pos),
              footer: AccountArea(
                onNeedsSetup: () {
                  close();
                  onOpenSettings();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
