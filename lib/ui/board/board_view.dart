import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/undo.dart';
import '../../dev/perf_probe.dart';
import '../../data/repos/feature_repo.dart';
import '../../state/providers.dart';
import '../common/smooth_scroll.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';
import 'drag_controller.dart';
import 'feature_card.dart';
import 'segment_stub.dart';
import 'version_column.dart';

/// Hooks the editors (Task 8) and filters (Task 11) plug into the board.
class BoardHooks {
  const BoardHooks({this.onVersionMenu, this.expandedBuilder, this.filter});
  final void Function(BuildContext context, WidgetRef ref, Version v, Offset globalPos)? onVersionMenu;
  final ExpandedBuilder? expandedBuilder;
  final FeatureFilterFn Function(WidgetRef ref)? filter;
}

/// Editors and filters wire themselves in by overriding this provider.
final boardHooksProvider = Provider<BoardHooks>((ref) => const BoardHooks());

/// Version columns left to right: Concept, releases, "+ Version".
class BoardView extends ConsumerStatefulWidget {
  const BoardView({super.key, required this.project, required this.topInset});
  final Project project;
  final double topInset;

  @override
  ConsumerState<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends ConsumerState<BoardView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    if (perfMode) _perfDrive();
  }

  /// Dev-only: sweeps the board sideways for the perf probe.
  Future<void> _perfDrive() async {
    await Future<void>.delayed(const Duration(seconds: 3));
    for (var i = 0; i < 3 && mounted; i++) {
      if (!_scroll.hasClients) return;
      await _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 1600),
        curve: Curves.easeInOut,
      );
      await _scroll.animateTo(0, duration: const Duration(milliseconds: 1600), curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(versionsProvider(widget.project.id)).value ?? const <Version>[];
    final env = ref.watch(selectedEnvironmentIdProvider);
    final versions = segmentOf(all, env);
    final prev = neighbourRun(all, env, before: true);
    final next = neighbourRun(all, env, before: false);
    final names = {for (final v in all) v.id: v.name};
    final hooks = ref.watch(boardHooksProvider);
    final filter = hooks.filter?.call(ref);
    return BoardDragHost(
      versions: all,
      child: Padding(
        padding: EdgeInsets.only(top: widget.topInset),
        child: Scrollbar(
          controller: _scroll,
          child: SingleChildScrollView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 20),
            child: SmoothWheel(
              controller: _scroll,
              axis: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (prev != null) SegmentStub(projectId: widget.project.id, run: prev, before: true),
                  for (final v in versions)
                    VersionColumn(
                      key: ValueKey('col-${v.id}'),
                      version: v,
                      versionNames: names,
                      filter: filter,
                      expandedBuilder: hooks.expandedBuilder,
                      onVersionMenu: hooks.onVersionMenu == null
                          ? null
                          : (v, pos) => hooks.onVersionMenu!(context, ref, v, pos),
                    ),
                  if (next != null)
                    SegmentStub(projectId: widget.project.id, run: next, before: false)
                  else
                    _AddVersionColumn(projectId: widget.project.id),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Provides card dragging to the version columns below it, and shows the
/// lifted card in the root overlay while a drag runs.
class BoardDragHost extends StatefulWidget {
  const BoardDragHost({super.key, required this.versions, required this.child});
  final List<Version> versions;
  final Widget child;

  @override
  State<BoardDragHost> createState() => _BoardDragHostState();
}

class _BoardDragHostState extends State<BoardDragHost> {
  final _drag = BoardDragController();
  OverlayEntry? _ghost;

  @override
  void initState() {
    super.initState();
    _drag.addListener(_syncGhost);
  }

  void _syncGhost() {
    if (_drag.active && _ghost == null) {
      final v = _drag.dragging!;
      final version = widget.versions.where((x) => x.id == _drag.fromVersionId).firstOrNull;
      if (version == null) return;
      final names = {for (final x in widget.versions) x.id: x.name};
      _ghost = OverlayEntry(
        builder: (_) => _Ghost(controller: _drag, v: v, version: version, names: names),
      );
      Overlay.of(context, rootOverlay: true).insert(_ghost!);
    } else if (!_drag.active && _ghost != null) {
      _ghost!.remove();
      _ghost = null;
    }
  }

  @override
  void dispose() {
    _ghost?.remove();
    _drag.removeListener(_syncGhost);
    _drag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BoardDrag(controller: _drag, child: widget.child);
}

/// The lifted card following the pointer while dragging.
class _Ghost extends StatelessWidget {
  const _Ghost({required this.controller, required this.v, required this.version, required this.names});
  final BoardDragController controller;
  final FeatureView v;
  final Version version;
  final Map<String, String> names;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ListenableBuilder(
        listenable: controller.ghost,
        builder: (context, child) {
          final pos = controller.pointer - controller.grab;
          return Stack(
            children: [Positioned(left: pos.dx, top: pos.dy, width: controller.cardSize.width, child: child!)],
          );
        },
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Motion.dur(context),
          curve: Motion.curve(context),
          builder: (context, t, child) => Transform.rotate(
            angle: .025 * t,
            child: Transform.scale(scale: 1 + .035 * t, child: child),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: VersoPalette.of(context).shadow.withValues(alpha: .35),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: FeatureCard(v: v, version: version, versionNames: names),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddVersionColumn extends ConsumerStatefulWidget {
  const _AddVersionColumn({required this.projectId});
  final String projectId;

  @override
  ConsumerState<_AddVersionColumn> createState() => _AddVersionColumnState();
}

class _AddVersionColumnState extends ConsumerState<_AddVersionColumn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return Align(
      alignment: Alignment.topLeft,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          key: const Key('add-version'),
          onTap: () => ref
              .read(undoProvider)
              .run(
                createVersionAction(
                  ref.read(versionRepoProvider),
                  widget.projectId,
                  environmentId: ref.read(selectedEnvironmentIdProvider),
                ),
              ),
          child: AnimatedContainer(
            duration: Motion.smoothDur(context),
            width: 200,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: _hover ? p.text.withValues(alpha: .05) : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.separator),
            ),
            child: Row(
              children: [
                Icon(Icons.add_rounded, size: 18, color: p.textSecondary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Add version',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
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
    );
  }
}
