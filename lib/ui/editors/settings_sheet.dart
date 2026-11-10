import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import '../glass/glass_surface.dart';
import '../shell/glass_segmented.dart';
import '../theme/palette.dart';

/// Settings: theme, reduce motion, data folder.
Future<void> showSettings(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x26000000),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, a, b) => const Center(
      child: Material(type: MaterialType.transparency, child: _Settings()),
    ),
    transitionBuilder: (ctx, a, b, child) => FadeTransition(
      opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: Tween(begin: .96, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
  );
}

class _Settings extends ConsumerWidget {
  const _Settings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = VersoPalette.of(context);
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    Directory? dir;
    try {
      dir = ref.read(dataDirProvider);
    } catch (_) {}
    final label = TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: p.textSecondary);
    return SizedBox(
      width: 420,

      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .88),
        child: SingleChildScrollView(
          child: GlassSurface(
            radius: 24,
            tint: p.isDark ? const Color(0xF51E1A16) : const Color(0xF5FFFFFF),
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Settings',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w800, color: p.text),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded, color: p.textSecondary, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text('Appearance', style: label),
                const SizedBox(height: 8),
                GlassSegmented<ThemeMode>(
                  segmentWidth: 110,
                  items: const [(ThemeMode.system, 'System'), (ThemeMode.light, 'Light'), (ThemeMode.dark, 'Dark')],
                  value: s.themeMode,
                  onChanged: (m) => notifier.update((x) => x.copyWith(themeMode: m)),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reduce motion',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: p.text,
                            ),
                          ),
                          Text(
                            'Crossfades instead of springs. Windows\' own setting is respected too.',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: p.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: s.reduceMotion,
                      activeTrackColor: p.primary,
                      onChanged: (v) => notifier.update((x) => x.copyWith(reduceMotion: v)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text('Google sign-in', style: label),
                const SizedBox(height: 4),
                Text(
                  'Google Cloud Console → APIs & Services → Credentials → Create OAuth client ID → Desktop app.',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: p.textSecondary),
                ),
                const SizedBox(height: 8),
                _SettingField(
                  key: const Key('google-client-id'),
                  hint: 'Client ID (…apps.googleusercontent.com)',
                  initial: s.googleClientId,
                  onSaved: (v) => notifier.update((x) => x.copyWith(googleClientId: v.trim())),
                ),
                const SizedBox(height: 6),
                _SettingField(
                  key: const Key('google-client-secret'),
                  hint: 'Client secret',
                  initial: s.googleClientSecret,
                  obscure: true,
                  onSaved: (v) => notifier.update((x) => x.copyWith(googleClientSecret: v.trim())),
                ),
                const SizedBox(height: 18),
                Text('Sync server', style: label),
                const SizedBox(height: 6),
                _SettingField(
                  key: const Key('sync-url'),
                  hint: 'https://… (empty = sync off)',
                  initial: s.syncUrl,
                  onSaved: (v) => notifier.update((x) => x.copyWith(syncUrl: v.trim())),
                ),
                if (dir != null) ...[
                  const SizedBox(height: 18),
                  Text('Data folder', style: label),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          dir.path,
                          style: TextStyle(fontFamily: 'Inter', fontSize: 12.5, color: p.text),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Process.run('explorer', [dir!.path]),
                        child: const Text('Open folder'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Verso 1.0.0 · data stays on this PC; Cloudflare sync comes later.',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11.5, color: p.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingField extends StatelessWidget {
  const _SettingField({
    super.key,
    required this.hint,
    required this.initial,
    required this.onSaved,
    this.obscure = false,
  });
  final String hint;
  final String initial;
  final ValueChanged<String> onSaved;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    final p = VersoPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(color: p.text.withValues(alpha: .05), borderRadius: BorderRadius.circular(10)),
      child: TextFormField(
        initialValue: initial,
        obscureText: obscure,
        style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: p.text),
        decoration: InputDecoration.collapsed(
          hintText: hint,
          hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 13, color: p.textSecondary),
        ),
        onChanged: onSaved,
      ),
    );
  }
}
