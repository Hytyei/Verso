import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../state/providers.dart';
import '../../sync/sync_controller.dart';
import 'phone_shell.dart';

/// Android glue around [PhoneShell]:
/// - coming back to the foreground re-reads the tables (a widget may have
///   ticked a task in the background) and syncs;
/// - a widget tap (`verso://open?project=…&version=…`) opens that version.
class PhoneHost extends ConsumerStatefulWidget {
  const PhoneHost({super.key, required this.onOpenSettings});
  final VoidCallback onOpenSettings;

  @override
  ConsumerState<PhoneHost> createState() => _PhoneHostState();
}

class _PhoneHostState extends ConsumerState<PhoneHost> {
  AppLifecycleListener? _life;
  StreamSubscription<Uri?>? _clicks;

  @override
  void initState() {
    super.initState();
    _life = AppLifecycleListener(onResume: _resumed);
    if (Platform.isAndroid) {
      HomeWidget.initiallyLaunchedFromHomeWidget().then(_open, onError: (_) {});
      _clicks = HomeWidget.widgetClicked.listen(_open, onError: (_) {});
    }
  }

  void _resumed() {
    final db = ref.read(dbProvider);
    db.markTablesUpdated(db.allTables);
    ref.read(syncProvider.notifier).syncNow();
  }

  void _open(Uri? uri) {
    if (!mounted || uri == null || uri.host != 'open') return;
    final project = uri.queryParameters['project'];
    final version = uri.queryParameters['version'];
    if (project == null) return;
    if (version != null) ref.read(phoneOpenVersionProvider.notifier).set(version);
    ref.read(selectedProjectIdProvider.notifier).select(project);
  }

  @override
  void dispose() {
    _life?.dispose();
    _clicks?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PhoneShell(onOpenSettings: widget.onOpenSettings);
}
