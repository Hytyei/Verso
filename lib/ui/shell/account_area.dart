import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/auth_controller.dart';
import '../../sync/sync_controller.dart';
import '../common/glass_menu.dart';
import '../common/toast.dart';
import '../theme/motion.dart';
import '../theme/palette.dart';

/// Sidebar footer: "Sign in with Google", progress, or the signed-in account.
class AccountArea extends ConsumerWidget {
  const AccountArea({super.key, required this.onNeedsSetup});

  /// Called when no Google client ID is configured yet (opens Settings).
  final VoidCallback onNeedsSetup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = VersoPalette.of(context);
    final auth = ref.watch(authProvider);
    ref.listen(authProvider, (prev, next) {
      if (next.error != null && prev?.error != next.error) showToast(context, 'Sign-in failed: ${next.error}');
    });
    final text = TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: p.text);
    final small = TextStyle(fontFamily: 'Inter', fontSize: 11.5, color: p.textSecondary);

    Widget row({
      required Key key,
      required Widget leading,
      required Widget body,
      VoidCallback? onTap,
      void Function(Offset)? onTapUp,
    }) => MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        key: key,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onTapUp: onTapUp == null ? null : (d) => onTapUp(d.globalPosition),
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(color: p.text.withValues(alpha: .04), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 10),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );

    return AnimatedSwitcher(
      duration: Motion.smoothDur(context),
      child: switch (auth.status) {
        AuthStatus.signedIn => row(
          key: const Key('account-signed-in'),
          leading: _Avatar(url: auth.account?.pictureUrl, name: auth.account?.name ?? '?'),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(auth.account?.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: text),
              _SyncLine(style: small),
            ],
          ),
          onTapUp: (pos) => showGlassMenu(context, pos, [
            MenuItemSpec(auth.account?.email ?? '', icon: Icons.mail_outline_rounded, enabled: false),
            MenuItemSpec('Sync now', icon: Icons.sync_rounded, onTap: () => ref.read(syncProvider.notifier).syncNow()),
            const MenuItemSpec.divider(),
            MenuItemSpec(
              'Sign out',
              icon: Icons.logout_rounded,
              onTap: () => ref.read(authProvider.notifier).signOut(),
            ),
          ]),
        ),
        AuthStatus.signingIn => row(
          key: const Key('account-signing-in'),
          leading: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: p.primary),
          ),
          body: Row(
            children: [
              Expanded(
                child: Text('Finish in your browser…', maxLines: 1, overflow: TextOverflow.ellipsis, style: small),
              ),
              GestureDetector(
                onTap: () => ref.read(authProvider.notifier).cancel(),
                child: Text(
                  'Cancel',
                  style: small.copyWith(color: p.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        AuthStatus.signedOut => row(
          key: const Key('sign-in-google'),
          leading: Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.surfaceRaised,
              shape: BoxShape.circle,
              border: Border.all(color: p.separator),
            ),
            child: Text(
              'G',
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w800, color: p.primary),
            ),
          ),
          body: Text('Sign in with Google', maxLines: 1, overflow: TextOverflow.ellipsis, style: text),
          onTap: () {
            final c = ref.read(authProvider.notifier);
            if (!c.configured) {
              showToast(context, 'Add your Google client ID in Settings first');
              onNeedsSetup();
              return;
            }
            c.signIn();
          },
        ),
      },
    );
  }
}

/// "Synced · 2 min ago", "Syncing…", or the last error (in coral).
class _SyncLine extends ConsumerWidget {
  const _SyncLine({required this.style});
  final TextStyle style;

  static String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 45) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    if (d.inHours < 24) return '${d.inHours} h ago';
    return '${d.inDays} d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = VersoPalette.of(context);
    final s = ref.watch(syncProvider);
    final (text, color) = switch (s.phase) {
      SyncPhase.off => ('Sync off', p.textSecondary),
      SyncPhase.syncing => ('Syncing…', p.textSecondary),
      SyncPhase.idle => (s.lastSynced == null ? 'Ready to sync' : 'Synced · ${_ago(s.lastSynced!)}', p.textSecondary),
      SyncPhase.failed => ('Sync failed: ${s.error ?? ''}', p.coral),
    };
    return Text(
      text,
      key: const Key('sync-status'),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style.copyWith(color: color),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.name});
  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    final fallback = Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: p.primary, shape: BoxShape.circle),
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: p.isDark ? Colors.black : Colors.white,
        ),
      ),
    );
    if (url == null) return fallback;
    return ClipOval(
      child: Image.network(url!, width: 26, height: 26, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback),
    );
  }
}
