import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/auth_controller.dart';
import '../../sync/sync_controller.dart';
import '../common/glass_menu.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';

String _ago(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inSeconds < 45) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours} h ago';
  return '${d.inDays} d ago';
}

/// One line for the sync state, shared by the account panel and the indicator.
String syncLabel(SyncStatus s) => switch (s.phase) {
  SyncPhase.off => 'Not syncing (signed out)',
  SyncPhase.syncing => 'Syncing…',
  SyncPhase.failed => 'Sync failed: ${s.error ?? 'offline?'}',
  SyncPhase.idle when s.pending => 'Changes waiting to upload',
  SyncPhase.idle => s.lastSynced == null ? 'Ready to sync' : 'Synced with the server · ${_ago(s.lastSynced!)}',
};

/// A small cloud that says whether local data has reached the server:
/// ✓ synced, spinning while syncing, a dot for changes waiting to upload,
/// ! when the last sync failed, slashed when signed out.
/// Tap: the state in words, plus Sync now.
class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key, this.size = 30, this.onSignIn});
  final double size;

  /// Shown as a menu item while signed out.
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = VersoPalette.of(context);
    final s = ref.watch(syncProvider);
    final (IconData icon, Color color, Color? badge) = switch (s.phase) {
      SyncPhase.off => (Icons.cloud_off_rounded, p.textSecondary.withValues(alpha: .7), null),
      SyncPhase.syncing => (Icons.sync_rounded, p.primary, null),
      SyncPhase.failed => (Icons.cloud_rounded, p.coral, p.coral),
      SyncPhase.idle when s.pending => (Icons.cloud_upload_rounded, p.textSecondary, p.accents[1]),
      SyncPhase.idle => (s.lastSynced == null ? Icons.cloud_queue_rounded : Icons.cloud_done_rounded, p.primary, null),
    };
    final label = syncLabel(s);
    Widget glyph = Icon(icon, size: size * .62, color: color, key: ValueKey(icon));
    if (s.phase == SyncPhase.syncing && !Motion.reduced(context)) glyph = _Spin(child: glyph);
    return Semantics(
      label: label,
      button: true,
      child: Tooltip(
        message: label,
        child: GestureDetector(
          key: const Key('sync-indicator'),
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => showGlassMenu(context, d.globalPosition, [
            MenuItemSpec(label, icon: Icons.info_outline_rounded, enabled: false),
            if (s.phase == SyncPhase.off) ...[
              if (onSignIn != null) MenuItemSpec('Sign in with Google', icon: Icons.login_rounded, onTap: onSignIn!),
            ] else
              MenuItemSpec(
                'Sync now',
                icon: Icons.sync_rounded,
                onTap: () => ref.read(syncProvider.notifier).syncNow(),
              ),
            if (ref.read(authProvider).account?.email case final email?)
              MenuItemSpec(email, icon: Icons.mail_outline_rounded, enabled: false),
          ]),
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedSwitcher(duration: Motion.smoothDur(context), child: glyph),
                if (badge != null)
                  Positioned(
                    right: size * .12,
                    top: size * .16,
                    child: Container(
                      width: size * .26,
                      height: size * .26,
                      decoration: BoxDecoration(
                        color: badge,
                        shape: BoxShape.circle,
                        border: Border.all(color: p.surfaceRaised, width: 1.5),
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

class _Spin extends StatefulWidget {
  const _Spin({required this.child});
  final Widget child;
  @override
  State<_Spin> createState() => _SpinState();
}

class _SpinState extends State<_Spin> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
    ..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(turns: _c, child: widget.child);
}
