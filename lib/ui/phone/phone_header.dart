import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/auth_controller.dart';
import '../../data/db/database.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import '../common/env_icon.dart';
import '../common/glass_menu.dart';
import '../common/toast.dart';
import '../glass/glass_surface.dart';
import '../shell/filter.dart';
import '../shell/sync_indicator.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';
import 'phone_timeline.dart';

/// Whether the search row under the header is open.
final phoneSearchOpenProvider = NotifierProvider<ValueNotifierOf<bool>, bool>(() => ValueNotifierOf(false));

/// Glass header: environment, project (tap → folders), sync state, ⋯ menu,
/// and the version pills that follow the pager.
class PhoneHeader extends ConsumerWidget {
  const PhoneHeader({
    super.key,
    required this.project,
    required this.versions,
    required this.index,
    required this.environment,
    required this.onPill,
    required this.onAddVersion,
    required this.onFolders,
    required this.onOpenSettings,
  });

  final Project project;
  final List<Version> versions;
  final int index;
  final Environment? environment;
  final ValueChanged<int> onPill;
  final VoidCallback onAddVersion;
  final VoidCallback onFolders;
  final VoidCallback onOpenSettings;

  static const _body = 116.0;
  static const _searchRow = 50.0;

  /// The header's height, status bar included.
  static double heightFor(BuildContext context, {bool search = false}) =>
      MediaQuery.paddingOf(context).top + _body + (search ? _searchRow : 0);

  void _menu(BuildContext context, WidgetRef ref, Offset pos) {
    final undo = ref.read(undoProvider);
    final theme = ref.read(settingsProvider).themeMode;
    final search = ref.read(phoneSearchOpenProvider);
    showGlassMenu(context, pos, [
      MenuItemSpec(
        search ? 'Hide search' : 'Search & filter',
        icon: Icons.search_rounded,
        onTap: () {
          ref.read(phoneSearchOpenProvider.notifier).set(!search);
          if (search) ref.read(searchQueryProvider.notifier).set('');
        },
      ),
      MenuItemSpec('Timeline', icon: Icons.view_timeline_outlined, onTap: () => openPhoneTimeline(context, project)),
      MenuItemSpec('New version', icon: Icons.add_rounded, onTap: onAddVersion),
      const MenuItemSpec.divider(),
      MenuItemSpec(
        'Undo',
        icon: Icons.undo_rounded,
        onTap: () async {
          if (!await undo.undo() && context.mounted) showToast(context, 'Nothing to undo');
        },
      ),
      MenuItemSpec('Redo', icon: Icons.redo_rounded, onTap: () => undo.redo()),
      const MenuItemSpec.divider(),
      MenuItemSpec(
        'Theme: ${theme.name}',
        icon: switch (theme) {
          ThemeMode.system => Icons.brightness_auto_rounded,
          ThemeMode.light => Icons.light_mode_rounded,
          ThemeMode.dark => Icons.dark_mode_rounded,
        },
        onTap: () => ref
            .read(settingsProvider.notifier)
            .update(
              (s) => s.copyWith(themeMode: ThemeMode.values[(ThemeMode.values.indexOf(s.themeMode) + 1) % ThemeMode.values.length]),
            ),
      ),
      MenuItemSpec('Settings', icon: Icons.settings_outlined, onTap: onOpenSettings),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = VersoPalette.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final search = ref.watch(phoneSearchOpenProvider);
    final color = p.resolve(VColor(project.color, custom: project.colorCustom));
    return GlassSurface(
      key: const Key('phone-header'),
      large: true,
      refract: false,
      radius: 0,
      padding: EdgeInsets.fromLTRB(16, top + 8, 8, 8),
      child: AnimatedSize(
        duration: Motion.smoothDur(context),
        curve: Motion.smooth,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    key: const Key('phone-folders'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onFolders();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 18,
                          child: Row(
                            children: [
                              if (environment != null) ...[
                                EnvIcon(env: environment!, size: 14),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child: AnimatedSwitcher(
                                  duration: Motion.smoothDur(context),
                                  child: Text(
                                    environment?.name ?? 'Verso',
                                    key: ValueKey(environment?.id),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: p.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                project.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -.3,
                                  color: p.text,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.expand_more_rounded, size: 22, color: p.textSecondary),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SyncIndicator(size: 40, onSignIn: () => ref.read(authProvider.notifier).signIn()),
                Builder(
                  builder: (bc) => IconButton(
                    key: const Key('phone-more'),
                    tooltip: 'More',
                    onPressed: () {
                      final box = bc.findRenderObject() as RenderBox;
                      _menu(context, ref, box.localToGlobal(box.size.bottomCenter(Offset.zero)));
                    },
                    icon: Icon(Icons.more_horiz_rounded, color: p.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: _VersionPills(versions: versions, index: index, onPill: onPill, onAdd: onAddVersion),
            ),
            if (search)
              const Padding(
                padding: EdgeInsets.only(top: 10, right: 8),
                child: SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      Expanded(child: SearchField()),
                      SizedBox(width: 8),
                      FilterButton(),
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

class _VersionPills extends StatefulWidget {
  const _VersionPills({required this.versions, required this.index, required this.onPill, required this.onAdd});
  final List<Version> versions;
  final int index;
  final ValueChanged<int> onPill;
  final VoidCallback onAdd;

  @override
  State<_VersionPills> createState() => _VersionPillsState();
}

class _VersionPillsState extends State<_VersionPills> {
  final _scroll = ScrollController();
  final _keys = <String, GlobalKey>{};

  @override
  void didUpdateWidget(_VersionPills old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(animate: false));
  }

  /// Keeps the selected pill in view (centred when it can be).
  void _reveal({bool animate = true}) {
    if (!mounted || widget.index >= widget.versions.length) return;
    final ctx = _keys[widget.versions[widget.index].id]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: .5,
      duration: animate ? Motion.smoothDur(context) : Duration.zero,
      curve: Motion.smooth,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return ListView(
      key: const Key('version-pills'),
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(right: 8),
      children: [
        for (final (i, v) in widget.versions.indexed)
          Padding(
            key: _keys.putIfAbsent(v.id, GlobalKey.new),
            padding: const EdgeInsets.only(right: 6),
            child: _Pill(
              label: v.name,
              selected: i == widget.index,
              released: v.status == 'released',
              concept: v.kind == 'concept',
              onTap: () => widget.onPill(i),
            ),
          ),
        Semantics(
          button: true,
          label: 'New version',
          child: GestureDetector(
            key: const Key('pill-add'),
            onTap: widget.onAdd,
            child: Container(
              width: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.separator)),
              child: Icon(Icons.add_rounded, size: 18, color: p.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.selected, required this.released, required this.concept, required this.onTap});
  final String label;
  final bool selected;
  final bool released;
  final bool concept;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final fg = selected ? (p.isDark ? Colors.black : Colors.white) : p.text;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        key: Key('pill-$label'),
        onTap: onTap,
        child: AnimatedContainer(
          duration: Motion.smoothDur(context),
          curve: Motion.smooth,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? p.primary : p.text.withValues(alpha: .06),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (concept) ...[Icon(Icons.lightbulb_outline_rounded, size: 14, color: fg), const SizedBox(width: 5)],
              if (released && !concept) ...[Icon(Icons.check_rounded, size: 14, color: fg), const SizedBox(width: 4)],
              Text(
                label,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, fontWeight: FontWeight.w600, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
