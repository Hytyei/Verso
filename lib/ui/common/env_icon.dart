import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import '../theme/palette.dart';

/// Built-in environment glyphs (keys are stored in the database).
const envGlyphs = <String, IconData>{
  'folder': Icons.folder_rounded,
  'terminal': Icons.terminal_rounded,
  'sparkle': Icons.auto_awesome_rounded,
  'robot': Icons.smart_toy_rounded,
  'chat': Icons.chat_bubble_rounded,
  'brain': Icons.psychology_rounded,
  'code': Icons.code_rounded,
  'bolt': Icons.bolt_rounded,
  'rocket': Icons.rocket_launch_rounded,
  'cloud': Icons.cloud_rounded,
  'science': Icons.science_rounded,
  'web': Icons.public_rounded,
  'phone': Icons.phone_iphone_rounded,
  'desktop': Icons.desktop_windows_rounded,
  'palette': Icons.palette_rounded,
  'star': Icons.star_rounded,
};

/// Folder holding custom environment images.
Directory envIconsDir(Directory dataDir) => Directory('${dataDir.path}${Platform.pathSeparator}icons');

/// An environment's icon: a glyph tile in its color, or its custom image.
class EnvIcon extends ConsumerWidget {
  const EnvIcon({super.key, required this.env, this.size = 18});
  final Environment env;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = VersoPalette.of(context);
    final color = p.resolve(VColor(env.color, custom: env.colorCustom));
    if (env.icon.startsWith('file:')) {
      Directory? dir;
      try {
        dir = ref.read(dataDirProvider);
      } catch (_) {}
      if (dir != null) {
        final f = File('${envIconsDir(dir).path}${Platform.pathSeparator}${env.icon.substring(5)}');
        return ClipRRect(
          borderRadius: BorderRadius.circular(size * .28),
          child: Image.file(
            f,
            width: size,
            height: size,
            fit: BoxFit.cover,
            cacheWidth: (size * 3).round(),
            errorBuilder: (_, _, _) => _glyph(Icons.folder_rounded, color),
          ),
        );
      }
    }
    return _glyph(envGlyphs[env.icon] ?? Icons.folder_rounded, color);
  }

  Widget _glyph(IconData icon, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color.withValues(alpha: .18), borderRadius: BorderRadius.circular(size * .28)),
    child: Icon(icon, size: size * .68, color: color),
  );
}
