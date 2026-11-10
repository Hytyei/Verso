import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/providers.dart';
import 'ui/editors/project_menu.dart';
import 'ui/editors/settings_sheet.dart';
import 'ui/shell/account_area.dart';
import 'ui/shell/filter.dart';
import 'ui/shell/shell.dart';
import 'ui/shortcuts.dart';
import 'ui/theme/verso_theme.dart';

class VersoApp extends ConsumerWidget {
  const VersoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(settingsProvider.select((s) => s.themeMode));
    return MaterialApp(
      title: 'Verso',
      debugShowCheckedModeBanner: false,
      theme: versoTheme(Brightness.light),
      darkTheme: versoTheme(Brightness.dark),
      themeMode: mode,
      themeAnimationDuration: const Duration(milliseconds: 280),
      home: ShortcutsHost(
        child: Builder(
          builder: (context) => Material(
            type: MaterialType.transparency,
            child: Shell(
              onProjectMenu: (context, project, envId, pos) => showProjectMenu(context, ref, project, envId, pos),
              onOpenSettings: () => showSettings(context),
              toolbarLeading: const [SearchField(), SizedBox(width: 8), FilterButton()],
              sidebarFooter: AccountArea(onNeedsSetup: () => showSettings(context)),
            ),
          ),
        ),
      ),
    );
  }
}
