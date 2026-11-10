import '../../auth/auth_controller.dart';
import 'sync_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import '../glass/glass_surface.dart';
import '../theme/palette.dart';
import 'glass_segmented.dart';

/// Floating glass toolbar: project title, extra controls, Board|Timeline,
/// theme toggle. Content scrolls underneath it, so its lens shows.
class Toolbar extends ConsumerWidget {
  const Toolbar({
    super.key,
    required this.title,
    this.leading = const [],
    this.trailing = const [],
    this.paused = false,
  });
  final String title;

  /// Shows an "On Pause" pill after the title.
  final bool paused;

  /// Controls placed after the title (search, filter).
  final List<Widget> leading;

  /// Controls placed before the view switch.
  final List<Widget> trailing;

  static const height = 58.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = VersoPalette.of(context);
    final mode = ref.watch(viewModeProvider);
    final theme = ref.watch(settingsProvider).themeMode;
    return GlassSurface(
      large: true,
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: p.text,
                ),
              ),
            ),
            if (paused) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: p.text.withValues(alpha: .07),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pause_rounded, size: 13, color: p.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'On Pause',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: p.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(width: 16),
            ...leading,
            const Spacer(),
            ...trailing,
            GlassSurface(
              radius: 999,
              padding: const EdgeInsets.all(4),
              child: SyncIndicator(size: 26, onSignIn: () => ref.read(authProvider.notifier).signIn()),
            ),
            const SizedBox(width: 10),
            GlassSegmented<ViewMode>(
              items: const [(ViewMode.board, 'Board'), (ViewMode.timeline, 'Timeline')],
              value: mode,
              onChanged: (m) => ref.read(viewModeProvider.notifier).set(m),
            ),
            const SizedBox(width: 10),
            Tooltip(
              message: 'Theme: ${theme.name}',
              child: GlassSurface(
                key: const Key('theme-toggle'),
                interactive: true,
                radius: 999,
                padding: const EdgeInsets.all(8),
                onTap: () => ref
                    .read(settingsProvider.notifier)
                    .update(
                      (s) => s.copyWith(
                        themeMode:
                            ThemeMode.values[(ThemeMode.values.indexOf(s.themeMode) + 1) % ThemeMode.values.length],
                      ),
                    ),
                child: Icon(
                  switch (theme) {
                    ThemeMode.system => Icons.brightness_auto_rounded,
                    ThemeMode.light => Icons.light_mode_rounded,
                    ThemeMode.dark => Icons.dark_mode_rounded,
                  },
                  size: 18,
                  color: p.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
