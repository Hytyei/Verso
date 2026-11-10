import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/export.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import '../common/chips.dart';
import '../common/format.dart';
import '../common/toast.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';

/// Version (or Concept) column header: name, status, dates, progress,
/// "n delayed in", and a ⋯ menu.
class ColumnHeader extends ConsumerWidget {
  const ColumnHeader({super.key, required this.version, this.onMenu});
  final Version version;
  final void Function(Offset globalPos)? onMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = VersoPalette.of(context);
    final v = version;
    final concept = v.kind == 'concept';
    final color = p.resolve(VColor(v.color, custom: v.colorCustom));
    final prog = ref.watch(versionProgressProvider(v.id)).value ?? (done: 0, total: 0);
    final delayedIn = ref.watch(delayedInProvider(v.id)).value ?? 0;
    final dates = dateRange(v.startDate, v.targetDate);
    final status = VersionStatus.values.firstWhere((s) => s.name == v.status, orElse: () => VersionStatus.planned);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (concept) ...[Icon(Icons.lightbulb_outline_rounded, size: 18, color: color), const SizedBox(width: 6)],
              Flexible(
                child: Text(
                  v.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: p.text,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!concept)
                _StatusPill(
                  status: status,
                  color: color,
                  tint: p.resolveTint(VColor(v.color, custom: v.colorCustom)),
                ),
              const Spacer(),
              Tooltip(
                message: 'Copy features as a checklist',
                child: _IconButton(
                  key: Key('copy-version-${v.id}'),
                  icon: Icons.copy_all_rounded,
                  onTapUp: (_) async {
                    final text = await versionAsText(ref.read(dbProvider), v.id);
                    await Clipboard.setData(ClipboardData(text: text));
                    final n = (ref.read(featureViewsProvider(v.id)).value ?? const []).length;
                    if (context.mounted)
                      showToast(context, 'Copied $n ${n == 1 ? 'feature' : 'features'} from ${v.name}');
                  },
                ),
              ),
              if (onMenu != null)
                _IconButton(
                  key: Key('version-menu-${v.id}'),
                  icon: Icons.more_horiz_rounded,
                  onTapUp: (pos) => onMenu!(pos),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (concept)
            Text(
              '${prog.total} ${prog.total == 1 ? 'idea' : 'ideas'}',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12.5, color: p.textSecondary),
            )
          else ...[
            Row(
              children: [
                if (dates.isNotEmpty)
                  Flexible(
                    child: Text(
                      dates,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12.5, color: p.textSecondary),
                    ),
                  ),
                if (dates.isNotEmpty) const SizedBox(width: 8),
                Text(
                  '${prog.done}/${prog.total}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: p.textSecondary,
                  ),
                ),
                if (delayedIn > 0) ...[
                  const SizedBox(width: 8),
                  TintChip(label: '$delayedIn delayed in', color: p.coral, tint: p.coralTint),
                ],
              ],
            ),
            const SizedBox(height: 8),
            _ProgressBar(value: prog.total == 0 ? 0 : prog.done / prog.total, color: color),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.color, required this.tint});
  final VersionStatus status;
  final Color color;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      VersionStatus.planned => 'Planned',
      VersionStatus.active => 'In progress',
      VersionStatus.released => 'Released',
    };
    return TintChip(
      label: label,
      color: color,
      tint: tint,
      icon: switch (status) {
        VersionStatus.planned => Icons.radio_button_unchecked_rounded,
        VersionStatus.active => Icons.timelapse_rounded,
        VersionStatus.released => Icons.rocket_launch_rounded,
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 5,
      child: LayoutBuilder(
        builder: (context, c) => Stack(
          children: [
            Container(
              decoration: BoxDecoration(color: color.withValues(alpha: .16), borderRadius: BorderRadius.circular(3)),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(end: value.clamp(0, 1)),
              duration: Motion.dur(context),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => Container(
                width: c.maxWidth * v,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatefulWidget {
  const _IconButton({super.key, required this.icon, required this.onTapUp});
  final IconData icon;
  final void Function(Offset globalPos) onTapUp;

  @override
  State<_IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapUp: (d) => widget.onTapUp(d.globalPosition),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: _hover ? p.text.withValues(alpha: .07) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(widget.icon, size: 18, color: p.textSecondary),
        ),
      ),
    );
  }
}
