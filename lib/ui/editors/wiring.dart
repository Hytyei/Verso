import '../../state/providers.dart';
import '../board/board_view.dart';
import '../board/feature_expanded.dart';
import '../shell/filter.dart';
import 'version_editor.dart';

/// The real editors and filters plugged into the board.
final appBoardHooks = BoardHooks(
  onVersionMenu: (context, ref, v, pos) => showVersionEditor(context, ref, v, pos),
  expandedBuilder: (context, v) => FeatureExpanded(v: v),
  filter: (ref) {
    final q = ref.watch(searchQueryProvider);
    final f = ref.watch(filterProvider);
    if (q.trim().isEmpty && !f.isActive) return (views) => views;
    return (views) => [
      for (final v in views)
        if (featureMatches(v, q, f)) v,
    ];
  },
);
