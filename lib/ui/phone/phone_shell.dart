import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/models.dart';
import '../../data/undo.dart';
import '../../state/providers.dart';
import '../../widgets/widget_snapshot.dart';
import '../board/board_view.dart';
import '../board/version_column.dart';
import '../common/update_banner.dart';
import '../glass/glass_surface.dart';
import '../shell/background.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';
import 'folders_sheet.dart';
import 'phone_header.dart';

/// Version to show next (a widget tap, a new version). Cleared once handled.
final phoneOpenVersionProvider = NotifierProvider<ValueNotifierOf<String?>, String?>(() => ValueNotifierOf(null));

/// The phone layout: a glass header (project, environment, version pills),
/// one version per page (swipe left/right), its tasks scrolling up/down,
/// and a floating "Add a task" bar.
class PhoneShell extends ConsumerWidget {
  const PhoneShell({super.key, required this.onOpenSettings});
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider).value;
    final selectedId = ref.watch(selectedProjectIdProvider);
    final project = projects?.where((p) => p.id == selectedId).firstOrNull;
    return VersoBackground(
      child: projects == null
          ? const SizedBox.expand()
          : project == null
          ? _Empty(onFolders: () => showFoldersSheet(context, onOpenSettings: onOpenSettings))
          : _ProjectPager(key: ValueKey('pager-${project.id}'), project: project, onOpenSettings: onOpenSettings),
    );
  }
}

class _ProjectPager extends ConsumerStatefulWidget {
  const _ProjectPager({super.key, required this.project, required this.onOpenSettings});
  final Project project;
  final VoidCallback onOpenSettings;

  @override
  ConsumerState<_ProjectPager> createState() => _ProjectPagerState();
}

class _ProjectPagerState extends ConsumerState<_ProjectPager> {
  PageController? _pages;
  int _index = 0;
  List<Version> _versions = const [];

  /// A version to show once it is in the list (new versions arrive a frame later).
  String? _pendingJump;

  @override
  void dispose() {
    _pages?.dispose();
    super.dispose();
  }

  /// First open: the version a widget would show (the active one).
  void _ensureController(List<Version> versions) {
    if (_pages != null || versions.isEmpty) return;
    final want = ref.read(phoneOpenVersionProvider);
    final start = want != null ? versions.indexWhere((v) => v.id == want) : -1;
    _index = start >= 0 ? start : versions.indexOf(widgetVersionOf(versions) ?? versions.first).clamp(0, versions.length - 1);
    if (start >= 0) ref.read(phoneOpenVersionProvider.notifier).set(null);
    _pages = PageController(initialPage: _index);
    WidgetsBinding.instance.addPostFrameCallback((_) => _followEnvironment(versions[_index]));
  }

  void _followEnvironment(Version v) {
    if (!mounted || v.environmentId == null) return;
    if (ref.read(selectedEnvironmentIdProvider) != v.environmentId) {
      ref.read(selectedEnvironmentIdProvider.notifier).set(v.environmentId);
    }
  }

  void _onPage(int i) {
    if (i == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = i);
    if (i < _versions.length) _followEnvironment(_versions[i]);
  }

  void jumpTo(String versionId) {
    final i = _versions.indexWhere((v) => v.id == versionId);
    if (i < 0 || _pages == null || !_pages!.hasClients) return;
    _pages!.animateToPage(i, duration: Motion.dur(context), curve: Motion.curve(context));
  }

  Future<void> _addVersion() async {
    final before = _versions.map((v) => v.id).toSet();
    await ref
        .read(undoProvider)
        .run(createVersionAction(ref.read(versionRepoProvider), widget.project.id, environmentId: ref.read(selectedEnvironmentIdProvider)));
    final after = await ref.read(versionRepoProvider).listForProject(widget.project.id);
    final added = after.where((v) => !before.contains(v.id)).firstOrNull;
    if (added != null) ref.read(phoneOpenVersionProvider.notifier).set(added.id);
  }

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final versions = ref.watch(versionsProvider(widget.project.id)).value;
    if (versions == null) return const SizedBox.expand();
    _versions = versions;
    _ensureController(versions);
    if (_index >= versions.length) _index = versions.length - 1;
    ref.listen(phoneOpenVersionProvider, (_, id) {
      if (id == null) return;
      _pendingJump = id;
      ref.read(phoneOpenVersionProvider.notifier).set(null);
      setState(() {});
    });
    final pending = _pendingJump;
    if (pending != null && versions.any((v) => v.id == pending)) {
      _pendingJump = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => jumpTo(pending));
    }
    final names = {for (final v in versions) v.id: v.name};
    final envs = {for (final e in ref.watch(environmentsProvider).value ?? const <Environment>[]) e.id: e};
    final hooks = ref.watch(boardHooksProvider);
    final filter = hooks.filter?.call(ref);
    final media = MediaQuery.of(context);
    final headerH = PhoneHeader.heightFor(context, search: ref.watch(phoneSearchOpenProvider));
    final keyboard = media.viewInsets.bottom > 0;
    final barSpace = 76 + media.padding.bottom;
    final current = versions.isEmpty ? null : versions[_index.clamp(0, versions.length - 1)];

    return Stack(
      children: [
        Positioned.fill(
          child: BoardDragHost(
            versions: versions,
            child: PageView.builder(
              key: const Key('version-pager'),
              controller: _pages,
              itemCount: versions.length,
              onPageChanged: _onPage,
              itemBuilder: (context, i) {
                final v = versions[i];
                final prevEnv = i > 0 ? versions[i - 1].environmentId : null;
                final breaks = i > 0 && v.environmentId != null && prevEnv != null && v.environmentId != prevEnv;
                return Padding(
                  padding: EdgeInsets.fromLTRB(12, headerH + 8, 0, keyboard ? 8 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (breaks)
                        Padding(
                          padding: const EdgeInsets.only(right: 12, bottom: 8),
                          child: _EnvBreak(name: envs[v.environmentId]?.name ?? 'another environment'),
                        ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, c) => VersionColumn(
                            key: ValueKey('page-${v.id}'),
                            version: v,
                            versionNames: names,
                            width: c.maxWidth - 12,
                            filter: filter,
                            expandedBuilder: hooks.expandedBuilder,
                            bottomInset: keyboard ? 14 : barSpace + 10,
                            onVersionMenu: hooks.onVersionMenu == null
                                ? null
                                : (v, pos) => hooks.onVersionMenu!(context, ref, v, pos),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: PhoneHeader(
            project: widget.project,
            versions: versions,
            index: _index,
            environment: envs[current?.environmentId],
            onPill: (i) => _pages?.animateToPage(i, duration: Motion.dur(context), curve: Motion.curve(context)),
            onAddVersion: _addVersion,
            onFolders: () => showFoldersSheet(context, onOpenSettings: widget.onOpenSettings),
            onOpenSettings: widget.onOpenSettings,
          ),
        ),
        Positioned(
          top: headerH + 6,
          left: 12,
          right: 12,
          child: const Center(child: UpdateBanner()),
        ),
        if (!keyboard && current != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: media.padding.bottom + 14,
            child: Center(
              child: GlassSurface(
                key: const Key('phone-add'),
                interactive: true,
                radius: 999,
                // Denser than the header: it floats over cards, and its label must stay readable.
                tint: p.surfaceRaised.withValues(alpha: p.isDark ? .9 : .86),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(addFeatureRequestProvider.notifier).set(current.id);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 20, color: p.primary),
                    const SizedBox(width: 8),
                    Text(
                      current.kind == 'concept' ? 'Add an idea' : 'Add a task to ${current.name}',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: p.text),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// "Continues in Astra": this version starts a new environment.
class _EnvBreak extends StatelessWidget {
  const _EnvBreak({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: p.accentTints[1], borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.subdirectory_arrow_right_rounded, size: 15, color: p.accents[1]),
            const SizedBox(width: 6),
            Text(
              'Continues in $name',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12.5, fontWeight: FontWeight.w600, color: p.text),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends ConsumerWidget {
  const _Empty({required this.onFolders});
  final VoidCallback onFolders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = VersoPalette.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassSurface(
          radius: 28,
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
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
                'Sign in to sync your projects from Windows, or start a new one.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, color: p.textSecondary),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  GlassSurface(
                    interactive: true,
                    radius: 999,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    onTap: onFolders,
                    child: Text(
                      'Sign in & folders',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: p.text),
                    ),
                  ),
                  GlassSurface(
                    key: const Key('phone-create-project'),
                    interactive: true,
                    radius: 999,
                    tint: p.primary.withValues(alpha: .9),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
            ],
          ),
        ),
      ),
    );
  }
}
