import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/models.dart';
import '../../data/repos/feature_repo.dart';
import '../../state/providers.dart';
import '../common/chips.dart';
import '../common/glass_menu.dart';
import '../glass/glass_surface.dart';
import '../theme/palette.dart';
import 'glass_segmented.dart';

/// Whether [v] passes the search [query] (title, notes, sub-items; case-
/// insensitive) and the tag / priority / done [filter].
bool featureMatches(FeatureView v, String query, FeatureFilter filter) {
  final q = query.trim().toLowerCase();
  if (q.isNotEmpty) {
    final hay = [v.f.title, v.f.notes ?? '', ...v.subTitles].join('\n').toLowerCase();
    if (!hay.contains(q)) return false;
  }
  if (filter.tagIds.isNotEmpty && !v.tags.any((t) => filter.tagIds.contains(t.id))) return false;
  if (filter.minPriority != null && v.f.priority < filter.minPriority!) return false;
  switch (filter.done) {
    case DoneFilter.open:
      if (v.f.done) return false;
    case DoneFilter.done:
      if (!v.f.done) return false;
    case DoneFilter.all:
      break;
  }
  return true;
}

/// Focus node for the toolbar search (Ctrl+F).
final searchFocusProvider = Provider<FocusNode>((ref) {
  final n = FocusNode(debugLabel: 'search');
  ref.onDispose(n.dispose);
  return n;
});

/// Glass search field for the toolbar.
class SearchField extends ConsumerStatefulWidget {
  const SearchField({super.key});

  @override
  ConsumerState<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<SearchField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final q = ref.watch(searchQueryProvider);
    return GlassSurface(
      radius: 999,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        width: 210,
        height: 34,
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 17, color: p.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                key: const Key('search-field'),
                controller: _ctrl,
                focusNode: ref.watch(searchFocusProvider),
                onChanged: (s) => ref.read(searchQueryProvider.notifier).set(s),
                style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, color: p.text),
                decoration: InputDecoration.collapsed(
                  hintText: 'Search  Ctrl+F',
                  hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 13.5, color: p.textSecondary),
                ),
              ),
            ),
            if (q.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _ctrl.clear();
                  ref.read(searchQueryProvider.notifier).set('');
                },
                child: Icon(Icons.close_rounded, size: 15, color: p.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}

/// Filter button with a popover: tags, minimum priority, done state.
class FilterButton extends ConsumerWidget {
  const FilterButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = VersoPalette.of(context);
    final active = ref.watch(filterProvider).isActive;
    return Builder(
      builder: (ctx) => GlassSurface(
        key: const Key('filter-button'),
        interactive: true,
        radius: 999,
        tint: active ? p.primary.withValues(alpha: .22) : null,
        padding: const EdgeInsets.all(8),
        onTap: () {
          final box = ctx.findRenderObject() as RenderBox;
          showGlassPopover(
            ctx,
            anchor: box.localToGlobal(Offset.zero) & box.size,
            width: 300,
            builder: (c, close) => const _FilterPanel(),
          );
        },
        child: Icon(Icons.filter_list_rounded, size: 18, color: active ? p.primary : p.textSecondary),
      ),
    );
  }
}

class _FilterPanel extends ConsumerWidget {
  const _FilterPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = VersoPalette.of(context);
    final f = ref.watch(filterProvider);
    final set = ref.read(filterProvider.notifier).set;
    final projectId = ref.watch(selectedProjectIdProvider);
    final tags = projectId == null ? const <Tag>[] : (ref.watch(tagsProvider(projectId)).value ?? const <Tag>[]);
    final label = TextStyle(fontFamily: 'Inter', fontSize: 11.5, fontWeight: FontWeight.w600, color: p.textSecondary);
    return GlassSurface(
      radius: 16,
      tint: p.isDark ? const Color(0xF51E1A16) : const Color(0xF5FFFFFF),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Show', style: label),
          const SizedBox(height: 6),
          GlassSegmented<DoneFilter>(
            segmentWidth: 84,
            height: 28,
            items: const [(DoneFilter.all, 'All'), (DoneFilter.open, 'Open'), (DoneFilter.done, 'Done')],
            value: f.done,
            onChanged: (d) => set(f.copyWith(done: d)),
          ),
          const SizedBox(height: 12),
          Text('Tags', style: label),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in tags)
                GestureDetector(
                  onTap: () {
                    final next = {...f.tagIds};
                    next.contains(t.id) ? next.remove(t.id) : next.add(t.id);
                    set(f.copyWith(tagIds: next));
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Opacity(
                      opacity: f.tagIds.isEmpty || f.tagIds.contains(t.id) ? 1 : .4,
                      child: TintChip(
                        label: t.name,
                        color: p.resolve(VColor(t.color, custom: t.colorCustom)),
                        tint: p.resolveTint(VColor(t.color, custom: t.colorCustom)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Minimum priority', style: label),
          const SizedBox(height: 6),
          GlassSegmented<int>(
            segmentWidth: 64,
            height: 28,
            items: const [(0, 'Any'), (1, 'Low'), (2, 'Med'), (3, 'High')],
            value: f.minPriority ?? 0,
            onChanged: (v) => set(f.copyWith(minPriority: () => v == 0 ? null : v)),
          ),
          if (f.isActive) ...[
            const SizedBox(height: 10),
            TextButton(onPressed: () => set(const FeatureFilter()), child: const Text('Clear filters')),
          ],
        ],
      ),
    );
  }
}
