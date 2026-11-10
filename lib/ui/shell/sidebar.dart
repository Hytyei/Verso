import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/models.dart';
import '../../data/repos/environment_repo.dart';
import '../../state/providers.dart';
import '../common/env_icon.dart';
import '../common/glass_menu.dart';
import '../common/progress_ring.dart';
import '../editors/environment_editor.dart';
import '../glass/glass_surface.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';

/// Glass sidebar: environment folders holding projects (a project shows in
/// every environment it has versions in), plus new-project / settings.
class Sidebar extends ConsumerStatefulWidget {
  const Sidebar({super.key, this.onOpenSettings, this.onProjectMenu, this.footer});
  final VoidCallback? onOpenSettings;

  /// Right-click on a project (color, delete…); provided by the editors.
  final void Function(BuildContext context, Project project, String environmentId, Offset globalPos)? onProjectMenu;

  /// Shown above the buttons (the account area).
  final Widget? footer;

  static const width = 236.0;

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  final _collapsed = <String>{};

  Future<void> _newProject(String? envId, int count) async {
    final id = await ref.read(projectRepoProvider).create('New project', VColor.slot(count % 4), environmentId: envId);
    final env = envId ?? await ref.read(environmentRepoProvider).defaultId();
    if (mounted) openSegment(ref, id, env);
  }

  void _envMenu(BuildContext context, Environment env, Offset pos, int projectCount) {
    showGlassMenu(context, pos, [
      MenuItemSpec(
        'Edit environment…',
        icon: Icons.edit_outlined,
        onTap: () => showEnvironmentEditor(context, pos, env: env),
      ),
      MenuItemSpec('New project here', icon: Icons.add_rounded, onTap: () => _newProject(env.id, projectCount)),
    ]);
  }

  List<Widget> _folder(
    BuildContext context,
    Environment env,
    List<Project> projects,
    List<Placement> placements,
    String? selected,
    String? selectedEnv,
    TextStyle label,
  ) {
    final here = [
      for (final pr in projects)
        if (placements.any((x) => x.projectId == pr.id && x.environmentId == env.id)) pr,
    ];
    final open = !_collapsed.contains(env.id);
    final active = [
      for (final pr in here)
        if (!pr.paused) pr,
    ];
    final paused = [
      for (final pr in here)
        if (pr.paused) pr,
    ];
    final pausedOpen = !_collapsed.contains('paused-${env.id}');
    Widget tile(Project pr) => _ProjectTile(
      key: ValueKey('${env.id}-${pr.id}'),
      project: pr,
      selected: pr.id == selected && env.id == selectedEnv,
      onTap: () => openSegment(ref, pr.id, env.id),
      onMenu: widget.onProjectMenu == null ? null : (pos) => widget.onProjectMenu!(context, pr, env.id, pos),
    );
    return [
      _FolderRow(
        key: ValueKey('env-${env.id}'),
        env: env,
        count: here.length,
        open: open,
        onTap: () => setState(() => open ? _collapsed.add(env.id) : _collapsed.remove(env.id)),
        onMenu: (pos) => _envMenu(context, env, pos, projects.length),
        children: [
          for (final pr in active) tile(pr),
          if (paused.isNotEmpty)
            _PausedGroup(
              key: ValueKey('paused-${env.id}'),
              count: paused.length,
              open: pausedOpen,
              onTap: () => setState(
                () => pausedOpen ? _collapsed.add('paused-${env.id}') : _collapsed.remove('paused-${env.id}'),
              ),
              children: [for (final pr in paused) Opacity(opacity: .45, child: tile(pr))],
            ),
          if (here.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(38, 2, 8, 8),
              child: Text('Empty', style: label.copyWith(fontWeight: FontWeight.w400)),
            ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final projects = ref.watch(projectsProvider).value ?? const <Project>[];
    final allEnvs = ref.watch(environmentsProvider).value ?? const <Environment>[];
    final placements = ref.watch(placementsProvider).value ?? const <Placement>[];
    // The built-in default folder stays out of sight once it is empty and others exist
    // (e.g. a second device whose data all came from sync).
    final envs = [
      for (final e in allEnvs)
        if (!(e.id == VersoDb.defaultEnvironmentId &&
            allEnvs.length > 1 &&
            !placements.any((x) => x.environmentId == e.id)))
          e,
    ];
    final selected = ref.watch(selectedProjectIdProvider);
    final selectedEnv = ref.watch(selectedEnvironmentIdProvider);
    final label = TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: p.textSecondary);
    return GlassSurface(
      large: true,
      refract: false,
      radius: 22,
      child: SizedBox(
        width: Sidebar.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 10, 6),
              child: Row(
                children: [
                  Expanded(child: Text('Environments', style: label)),
                  Builder(
                    builder: (c) => Tooltip(
                      message: 'New environment',
                      child: GestureDetector(
                        key: const Key('new-environment'),
                        onTapUp: (d) => showEnvironmentEditor(c, d.globalPosition),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.create_new_folder_outlined, size: 17, color: p.textSecondary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  for (final env in envs) ..._folder(context, env, projects, placements, selected, selectedEnv, label),
                ],
              ),
            ),
            ?widget.footer,
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: GlassSurface(
                      key: const Key('new-project'),
                      interactive: true,
                      radius: 12,
                      onTap: () => _newProject(selectedEnv, projects.length),
                      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                      child: Row(
                        children: [
                          Icon(Icons.add_rounded, size: 18, color: p.primary),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'New project',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: p.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GlassSurface(
                    key: const Key('open-settings'),
                    interactive: true,
                    radius: 12,
                    onTap: widget.onOpenSettings,
                    padding: const EdgeInsets.all(9),
                    child: Icon(Icons.tune_rounded, size: 18, color: p.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "On Pause · n" subfolder inside an environment folder.
class _PausedGroup extends StatelessWidget {
  const _PausedGroup({super.key, required this.count, required this.open, required this.onTap, required this.children});
  final int count;
  final bool open;
  final VoidCallback onTap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 6, 4),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: open ? .25 : 0,
                    duration: Motion.dur(context),
                    curve: Motion.curve(context),
                    child: Icon(Icons.chevron_right_rounded, size: 14, color: p.textSecondary),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.pause_circle_outline_rounded, size: 15, color: p.textSecondary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'On Pause · $count',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: p.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: Motion.dur(context),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: open
              ? Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _FolderRow extends StatefulWidget {
  const _FolderRow({
    super.key,
    required this.env,
    required this.count,
    required this.open,
    required this.onTap,
    required this.onMenu,
    required this.children,
  });
  final Environment env;
  final int count;
  final bool open;
  final VoidCallback onTap;
  final void Function(Offset globalPos) onMenu;
  final List<Widget> children;

  @override
  State<_FolderRow> createState() => _FolderRowState();
}

class _FolderRowState extends State<_FolderRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onSecondaryTapUp: (d) => widget.onMenu(d.globalPosition),
            child: AnimatedContainer(
              duration: Motion.smoothDur(context),
              padding: const EdgeInsets.fromLTRB(6, 7, 6, 7),
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: _hover ? p.text.withValues(alpha: .04) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: widget.open ? .25 : 0,
                    duration: Motion.dur(context),
                    curve: Motion.curve(context),
                    child: Icon(Icons.chevron_right_rounded, size: 16, color: p.textSecondary),
                  ),
                  const SizedBox(width: 4),
                  EnvIcon(env: widget.env, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.env.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, fontWeight: FontWeight.w700, color: p.text),
                    ),
                  ),
                  Text(
                    '${widget.count}',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: p.textSecondary),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: Motion.dur(context),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: widget.open
              ? Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: widget.children),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _ProjectTile extends ConsumerStatefulWidget {
  const _ProjectTile({super.key, required this.project, required this.selected, required this.onTap, this.onMenu});
  final Project project;
  final bool selected;
  final VoidCallback onTap;
  final void Function(Offset globalPos)? onMenu;

  @override
  ConsumerState<_ProjectTile> createState() => _ProjectTileState();
}

class _ProjectTileState extends ConsumerState<_ProjectTile> {
  bool _hover = false;
  bool _editing = false;
  late final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startEdit() {
    _ctrl.text = widget.project.name;
    _ctrl.selection = TextSelection(baseOffset: 0, extentOffset: _ctrl.text.length);
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  Future<void> _commit() async {
    final name = _ctrl.text.trim();
    setState(() => _editing = false);
    if (name.isNotEmpty && name != widget.project.name) {
      await ref.read(projectRepoProvider).update(widget.project.id, name: name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final pr = widget.project;
    final color = p.resolve(VColor(pr.color, custom: pr.colorCustom));
    final prog = ref.watch(projectProgressProvider(pr.id)).value;
    final bg = widget.selected
        ? (p.isDark ? p.accentTints[0] : Colors.white.withValues(alpha: .7))
        : _hover
        ? p.text.withValues(alpha: .05)
        : Colors.transparent;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: _startEdit,
        onSecondaryTapUp: widget.onMenu == null ? null : (d) => widget.onMenu!(d.globalPosition),
        child: AnimatedContainer(
          duration: Motion.smoothDur(context),
          curve: Motion.smooth,
          margin: const EdgeInsets.symmetric(vertical: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.selected && !p.isDark
                ? [BoxShadow(color: p.shadow, blurRadius: 8, offset: const Offset(0, 2))]
                : const [],
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _editing
                    ? TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: p.text),
                        decoration: const InputDecoration.collapsed(hintText: 'Project name'),
                        onSubmitted: (_) => _commit(),
                        onTapOutside: (_) => _commit(),
                      )
                    : Text(
                        pr.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w500,
                          color: p.text,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              ProgressRing(value: prog == null || prog.total == 0 ? 0 : prog.done / prog.total, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
