import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import '../../state/settings.dart';
import '../common/glass_menu.dart';
import '../glass/glass_surface.dart';
import '../theme/palette.dart';

/// Filter for the all-projects timeline: which environments and projects
/// show, and whether released versions and paused projects do. Saved in Settings.
Future<void> showOverviewFilter(BuildContext context, Rect anchor) => showGlassPopover(
  context,
  anchor: anchor,
  width: 300,
  builder: (ctx, close) => const _OverviewFilterPanel(),
);

class _OverviewFilterPanel extends ConsumerWidget {
  const _OverviewFilterPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = VersoPalette.of(context);
    final f = ref.watch(settingsProvider.select((s) => s.overview));
    void set(OverviewFilter n) => ref.read(settingsProvider.notifier).update((s) => s.copyWith(overview: n));
    final envs = ref.watch(environmentsProvider).value ?? const <Environment>[];
    final projects = [
      for (final pr in ref.watch(projectsProvider).value ?? const <Project>[])
        if (!pr.archived) pr,
    ];
    final label = TextStyle(fontFamily: 'Inter', fontSize: 11.5, fontWeight: FontWeight.w600, color: p.textSecondary);

    Widget check({
      required Key key,
      required String text,
      required bool value,
      required ValueChanged<bool> onChanged,
      Color? dot,
      bool dim = false,
    }) => InkWell(
      key: key,
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              size: 19,
              color: value ? p.primary : p.textSecondary,
            ),
            const SizedBox(width: 8),
            if (dot != null) ...[
              Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
              const SizedBox(width: 7),
            ],
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, color: dim ? p.textSecondary : p.text),
              ),
            ),
          ],
        ),
      ),
    );

    Set<String> toggled(Set<String> hidden, String id, bool show) => show ? ({...hidden}..remove(id)) : {...hidden, id};

    return GlassSurface(
      radius: 16,
      tint: p.isDark ? const Color(0xF51E1A16) : const Color(0xF5FFFFFF),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .7),
        child: SingleChildScrollView(
          child: Column(
            key: const Key('overview-filter'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Show', style: label)),
                  if (f.isActive)
                    TextButton(
                      key: const Key('overview-reset'),
                      onPressed: () => set(const OverviewFilter()),
                      child: const Text('Reset'),
                    ),
                ],
              ),
              check(
                key: const Key('overview-released'),
                text: 'Released versions',
                value: !f.hideReleased,
                onChanged: (v) => set(f.copyWith(hideReleased: !v)),
              ),
              check(
                key: const Key('overview-paused'),
                text: 'Projects on pause',
                value: !f.hidePaused,
                onChanged: (v) => set(f.copyWith(hidePaused: !v)),
              ),
              const SizedBox(height: 10),
              Text('Environments', style: label),
              for (final e in envs)
                check(
                  key: Key('overview-env-${e.id}'),
                  text: e.name,
                  value: !f.hiddenEnvironments.contains(e.id),
                  dot: p.resolve(VColor(e.color, custom: e.colorCustom)),
                  onChanged: (v) => set(f.copyWith(hiddenEnvironments: toggled(f.hiddenEnvironments, e.id, v))),
                ),
              const SizedBox(height: 10),
              Text('Projects', style: label),
              for (final pr in projects)
                check(
                  key: Key('overview-project-${pr.id}'),
                  text: pr.name,
                  value: !f.hiddenProjects.contains(pr.id),
                  dot: p.resolve(VColor(pr.color, custom: pr.colorCustom)),
                  dim: pr.paused,
                  onChanged: (v) => set(f.copyWith(hiddenProjects: toggled(f.hiddenProjects, pr.id, v))),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
