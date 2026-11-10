import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/providers.dart';
import 'ui/editors/project_menu.dart';
import 'ui/editors/settings_sheet.dart';
import 'ui/phone/phone_host.dart';
import 'ui/shell/account_area.dart';
import 'ui/shell/filter.dart';
import 'ui/shell/shell.dart';
import 'ui/shortcuts.dart';
import 'ui/theme/verso_theme.dart';
import 'update/update_controller.dart';

/// Whether the app checks GitHub for a newer release at launch (main sets it;
/// tests leave it off so they never touch the network).
final launchUpdateCheckProvider = Provider<bool>((ref) => false);

class VersoApp extends ConsumerStatefulWidget {
  const VersoApp({super.key});

  @override
  ConsumerState<VersoApp> createState() => _VersoAppState();
}

class _VersoAppState extends ConsumerState<VersoApp> {
  @override
  void initState() {
    super.initState();
    if (ref.read(launchUpdateCheckProvider)) {
      // A few seconds in, so it never competes with the first frames or the first sync.
      Future<void>.delayed(const Duration(seconds: 4), () {
        if (mounted) ref.read(updateProvider.notifier).check();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(settingsProvider.select((s) => s.themeMode));
    final touch = ref.watch(touchModeProvider);
    return MaterialApp(
      title: 'Verso',
      debugShowCheckedModeBanner: false,
      theme: versoTheme(Brightness.light),
      darkTheme: versoTheme(Brightness.dark),
      themeMode: mode,
      themeAnimationDuration: const Duration(milliseconds: 280),
      home: touch
          ? Builder(
              builder: (context) => Material(
                type: MaterialType.transparency,
                child: PhoneHost(onOpenSettings: () => showSettings(context)),
              ),
            )
          : ShortcutsHost(
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
