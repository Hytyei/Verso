import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/undo.dart';
import '../../state/providers.dart';
import '../common/overflow_text.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';

/// Steps of one feature, live.
final cardStepsProvider = StreamProvider.family<List<Subitem>, String>(
  (ref, featureId) => ref.watch(featureRepoProvider).watchSubitems(featureId),
);

/// How many steps a collapsed card lists before "+N more".
const cardStepsLimit = 6;

/// Steps in tree order with their depth: each step is followed by its children.
List<(Subitem, int)> stepsInTreeOrder(List<Subitem> steps) {
  final children = <String?, List<Subitem>>{};
  for (final s in steps) {
    (children[s.parentId] ??= []).add(s);
  }
  final ids = {for (final s in steps) s.id};
  final out = <(Subitem, int)>[];
  void walk(String? parent, int depth) {
    for (final s in children[parent] ?? const <Subitem>[]) {
      out.add((s, depth));
      walk(s.id, depth + 1);
    }
  }

  walk(null, 0);
  // Steps whose parent is gone (deleted elsewhere) still show, at the top level.
  for (final s in steps) {
    if (s.parentId != null && !ids.contains(s.parentId)) {
      out.add((s, 0));
      walk(s.id, 1);
    }
  }
  return out;
}

/// The steps of a collapsed card (v1.5.0): indented to show nesting, tickable
/// in place, the first [cardStepsLimit] then "+N more" (tap the card for all).
class CardSteps extends ConsumerWidget {
  const CardSteps({super.key, required this.featureId, required this.color});
  final String featureId;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = VersoPalette.of(context);
    final steps = ref.watch(cardStepsProvider(featureId)).value;
    if (steps == null || steps.isEmpty) return const SizedBox.shrink();
    final rows = stepsInTreeOrder(steps);
    final shown = rows.take(cardStepsLimit).toList();
    final more = rows.length - shown.length;
    final repo = ref.read(featureRepoProvider);
    return Column(
      key: Key('card-steps-$featureId'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (s, depth) in shown)
          Padding(
            padding: EdgeInsets.only(left: 14.0 * depth, top: 3),
            child: Row(
              children: [
                GestureDetector(
                  key: Key('card-step-${s.id}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(undoProvider).run(toggleSubitemAction(repo, s.id, !s.done));
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 2, 7, 2),
                    child: AnimatedContainer(
                      duration: Motion.smoothDur(context),
                      curve: Motion.smooth,
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: s.done ? color : Colors.transparent,
                        border: Border.all(color: s.done ? color : color.withValues(alpha: .6), width: 1.5),
                      ),
                      child: s.done
                          ? Icon(Icons.check_rounded, size: 10, color: p.isDark ? Colors.black : Colors.white)
                          : null,
                    ),
                  ),
                ),
                Expanded(
                  child: OverflowText(
                    s.title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                      height: 1.3,
                      color: s.done ? p.textSecondary : p.text,
                      decoration: s.done ? TextDecoration.lineThrough : null,
                      decorationColor: p.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (more > 0)
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 21),
            child: Text(
              '+$more more',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: p.textSecondary),
            ),
          ),
      ],
    );
  }
}
