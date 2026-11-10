import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../update/update_controller.dart';
import '../glass/glass_surface.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';

/// "Verso 1.5.0 is ready · Update": a glass pill that appears when GitHub has
/// a newer release, with a progress bar while the APK downloads.
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(updateProvider);
    final show =
        s.info != null &&
        !s.dismissed &&
        const {
          UpdatePhase.available,
          UpdatePhase.downloading,
          UpdatePhase.installing,
          UpdatePhase.needsPermission,
          UpdatePhase.failed,
        }.contains(s.phase);
    return AnimatedSwitcher(
      duration: Motion.dur(context),
      switchInCurve: Motion.curve(context),
      transitionBuilder: (child, a) => FadeTransition(
        opacity: a,
        child: SlideTransition(position: Tween(begin: const Offset(0, -.4), end: Offset.zero).animate(a), child: child),
      ),
      child: show ? _Pill(key: ValueKey(s.info!.version), state: s) : const SizedBox.shrink(),
    );
  }
}

class _Pill extends ConsumerWidget {
  const _Pill({super.key, required this.state});
  final UpdateState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = VersoPalette.of(context);
    final c = ref.read(updateProvider.notifier);
    final busy = state.phase == UpdatePhase.downloading || state.phase == UpdatePhase.installing;
    final title = switch (state.phase) {
      UpdatePhase.downloading => 'Downloading Verso ${state.info!.version}… ${(state.progress * 100).round()}%',
      UpdatePhase.installing => 'Opening the installer…',
      UpdatePhase.needsPermission => 'Allow "Install unknown apps" for Verso, then tap Update',
      UpdatePhase.failed => state.error ?? 'Update failed',
      _ => 'Verso ${state.info!.version} is ready',
    };
    final text = TextStyle(fontFamily: 'Inter', fontSize: 13.5, fontWeight: FontWeight.w600, color: p.text);
    return ConstrainedBox(
      key: const Key('update-banner'),
      constraints: const BoxConstraints(maxWidth: 460),
      child: GlassSurface(
        radius: 20,
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.arrow_circle_down_rounded, size: 20, color: p.primary),
                const SizedBox(width: 10),
                Expanded(child: Text(title, style: text, maxLines: 2, overflow: TextOverflow.ellipsis)),
                if (!busy) ...[
                  TextButton(
                    key: const Key('update-now'),
                    onPressed: c.update,
                    style: TextButton.styleFrom(
                      foregroundColor: p.isDark ? Colors.black : Colors.white,
                      backgroundColor: p.primary,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text(
                      state.phase == UpdatePhase.failed ? 'Retry' : 'Update',
                      style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Later',
                    onPressed: c.dismiss,
                    icon: Icon(Icons.close_rounded, size: 18, color: p.textSecondary),
                  ),
                ],
              ],
            ),
            if (busy)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 6, 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: state.progress),
                    duration: Motion.smoothDuration,
                    curve: Motion.smooth,
                    builder: (_, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 4,
                      color: p.primary,
                      backgroundColor: p.separator.withValues(alpha: .5),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
