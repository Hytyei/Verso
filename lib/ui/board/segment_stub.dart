import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../state/providers.dart';
import '../common/env_icon.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';

/// The versions of [all] in [envId] (all versions when [envId] is null).
List<Version> segmentOf(List<Version> all, String? envId) => envId == null
    ? all
    : [
        for (final v in all)
          if (v.environmentId == envId) v,
      ];

/// The contiguous run of other-environment versions right before (or after)
/// the selected segment, or null.
({String envId, List<Version> versions})? neighbourRun(List<Version> all, String? envId, {required bool before}) {
  if (envId == null) return null;
  final idx = [
    for (var i = 0; i < all.length; i++)
      if (all[i].environmentId == envId) i,
  ];
  if (idx.isEmpty) return null;
  var i = before ? idx.first - 1 : idx.last + 1;
  if (i < 0 || i >= all.length) return null;
  final other = all[i].environmentId;
  if (other == null) return null;
  final run = <Version>[];
  while (i >= 0 && i < all.length && all[i].environmentId == other) {
    before ? run.insert(0, all[i]) : run.add(all[i]);
    i += before ? -1 : 1;
  }
  return (envId: other, versions: run);
}

/// A link card to the previous / next environment segment of a project.
class SegmentStub extends ConsumerStatefulWidget {
  const SegmentStub({super.key, required this.projectId, required this.run, required this.before});
  final String projectId;
  final ({String envId, List<Version> versions}) run;
  final bool before;

  @override
  ConsumerState<SegmentStub> createState() => _SegmentStubState();
}

class _SegmentStubState extends ConsumerState<SegmentStub> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final env = (ref.watch(environmentsProvider).value ?? const <Environment>[])
        .where((e) => e.id == widget.run.envId)
        .firstOrNull;
    if (env == null) return const SizedBox.shrink();
    final vs = widget.run.versions;
    final range = vs.length == 1 ? vs.first.name : '${vs.first.name}–${vs.last.name}';
    final text = widget.before ? '$range in ${env.name}' : 'Continues in ${env.name}';
    return Align(
      alignment: Alignment.topLeft,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          key: Key(widget.before ? 'stub-before' : 'stub-after'),
          onTap: () => openSegment(ref, widget.projectId, env.id),
          child: AnimatedContainer(
            duration: Motion.smoothDur(context),
            width: 170,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _hover ? p.text.withValues(alpha: .06) : p.text.withValues(alpha: .03),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.separator),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (widget.before) Icon(Icons.arrow_back_rounded, size: 16, color: p.textSecondary),
                    if (widget.before) const SizedBox(width: 6),
                    EnvIcon(env: env, size: 22),
                    if (!widget.before) const Spacer(),
                    if (!widget.before) Icon(Icons.arrow_forward_rounded, size: 16, color: p.textSecondary),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  text,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: p.text),
                ),
                if (!widget.before) ...[
                  const SizedBox(height: 2),
                  Text(
                    'from $range',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: p.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
