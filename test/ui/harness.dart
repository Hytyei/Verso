import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/app.dart';
import 'package:verso/data/db/database.dart';
import 'package:verso/state/providers.dart';
import 'package:verso/state/settings.dart';
import 'package:verso/sync/sync_controller.dart';
import 'package:verso/ui/board/board_view.dart';
import 'package:verso/ui/editors/wiring.dart';

/// Pumps the full app over an in-memory database.
class Harness {
  Harness(this.db, this.container);
  final VersoDb db;
  final ProviderContainer container;

  static Future<Harness> pump(
    WidgetTester t, {
    Size size = const Size(1360, 860),
    Settings settings = const Settings(),
    Future<void> Function(VersoDb db)? seed,
    List<dynamic> overrides = const [],
  }) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final db = VersoDb(NativeDatabase.memory());
    if (seed != null) await t.runAsync(() => seed(db));
    final container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
        dataDirProvider.overrideWithValue(Directory.systemTemp),
        settingsStoreProvider.overrideWithValue(MemorySettingsStore(settings)),
        boardHooksProvider.overrideWithValue(appBoardHooks),
        syncAutoProvider.overrideWithValue(false),
        ...overrides.cast(),
      ],
    );
    await t.pumpWidget(UncontrolledProviderScope(container: container, child: const VersoApp()));
    await settle(t);
    return Harness(db, container);
  }

  /// Lets drift queries resolve, then finishes animations.
  static Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 6; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
      await t.pump(const Duration(milliseconds: 50));
    }
    await t.pumpAndSettle(
      const Duration(milliseconds: 50),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );
  }

  Future<void> dispose(WidgetTester t) async {
    // Never await drift stream cancels or close() inside runAsync here:
    // their cleanup timers live in the fake zone and would deadlock.
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 1));
    container.dispose();
    unawaited(db.close());
    // Let toast timers (5 s) run out.
    await t.pump(const Duration(seconds: 6));
  }
}
