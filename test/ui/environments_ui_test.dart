import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/environment_repo.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/repos/version_repo.dart';
import 'package:verso/state/providers.dart';

import 'harness.dart';

void main() {
  late String gpt, claude, p, v1, v2;

  Future<Harness> open(WidgetTester t) => Harness.pump(
    t,
    seed: (db) async {
      final envs = EnvironmentRepo(db);
      gpt = await envs.defaultId();
      await envs.update(gpt, name: 'ChatGPT', icon: 'chat');
      claude = await envs.create('Claude Code', 'terminal', const VColor.slot(2));
      p = await ProjectRepo(db).create('Tandem', const VColor.slot(0), environmentId: gpt);
      v1 = await VersionRepo(db).create(p, 'v1.0');
      v2 = await VersionRepo(db).create(p, 'v1.1');
      await ProjectRepo(db).create('Kobel', const VColor.slot(1), environmentId: claude);
    },
  );

  testWidgets('sidebar groups projects by environment', (t) async {
    final h = await open(t);
    expect(find.text('ChatGPT'), findsOneWidget);
    expect(find.text('Claude Code'), findsOneWidget);
    expect(find.byKey(ValueKey('$gpt-$p')), findsOneWidget);
    expect(find.byKey(ValueKey('$claude-$p')), findsNothing);
    expect(find.text('Kobel'), findsOneWidget);
    await h.dispose(t);
  });

  testWidgets('changing v1.1 environment splits the project into two folders', (t) async {
    final h = await open(t);
    await t.tap(find.byKey(ValueKey('$gpt-$p')));
    await Harness.settle(t);
    await t.tap(find.byKey(Key('version-menu-$v2')));
    await Harness.settle(t);
    await t.tap(find.byKey(Key('pick-env-$claude')));
    await Harness.settle(t);
    expect(find.byKey(ValueKey('$gpt-$p')), findsOneWidget);
    expect(find.byKey(ValueKey('$claude-$p')), findsOneWidget);
    // Now viewing the Claude Code segment: v1.1 only, with a link back.
    expect(h.container.read(selectedEnvironmentIdProvider), claude);
    expect(find.byKey(ValueKey('col-$v2')), findsOneWidget);
    expect(find.byKey(ValueKey('col-$v1')), findsNothing);
    expect(find.byKey(const Key('stub-before')), findsOneWidget);
    await h.dispose(t);
  });

  testWidgets('edge stub switches to the neighbouring segment', (t) async {
    final h = await open(t);
    await t.runAsync(() => VersionRepo(h.db).setEnvironmentFrom(v2, claude));
    await Harness.settle(t);
    await t.tap(find.byKey(ValueKey('$gpt-$p')));
    await Harness.settle(t);
    expect(find.byKey(ValueKey('col-$v1')), findsOneWidget);
    expect(find.text('Continues in Claude Code'), findsOneWidget);
    await t.tap(find.byKey(const Key('stub-after')));
    await Harness.settle(t);
    expect(h.container.read(selectedEnvironmentIdProvider), claude);
    expect(find.byKey(ValueKey('col-$v2')), findsOneWidget);
    await h.dispose(t);
  });

  testWidgets('a paused project moves into the On Pause subfolder and looks faded', (t) async {
    final h = await open(t);
    expect(find.text('On Pause · 1'), findsNothing);
    await t.tap(find.byKey(ValueKey('$gpt-$p')), buttons: kSecondaryButton);
    await Harness.settle(t);
    await t.tap(find.text('Move to On Pause'));
    await Harness.settle(t);
    expect(find.text('On Pause · 1'), findsOneWidget);
    final tile = find.byKey(ValueKey('$gpt-$p'));
    expect(tile, findsOneWidget);
    final opacity = t.widget<Opacity>(find.ancestor(of: tile, matching: find.byType(Opacity)).first);
    expect(opacity.opacity, lessThan(.6));
    // The paused tile sits below the subfolder header.
    expect(t.getTopLeft(tile).dy, greaterThan(t.getTopLeft(find.text('On Pause · 1')).dy));
    // Resume brings it back.
    await t.tap(tile, buttons: kSecondaryButton);
    await Harness.settle(t);
    await t.tap(find.text('Move back from On Pause'));
    await Harness.settle(t);
    expect(find.text('On Pause · 1'), findsNothing);
    await h.dispose(t);
  });

  testWidgets('right-click Move to environment moves the project to that folder', (t) async {
    final h = await open(t);
    await t.tap(find.byKey(ValueKey('$gpt-$p')), buttons: kSecondaryButton);
    await Harness.settle(t);
    await t.tap(find.text('Move to environment'));
    await Harness.settle(t);
    await t.tap(find.text('Claude Code').last);
    await Harness.settle(t);
    expect(find.byKey(ValueKey('$gpt-$p')), findsNothing);
    expect(find.byKey(ValueKey('$claude-$p')), findsOneWidget);
    expect(h.container.read(selectedEnvironmentIdProvider), claude);
    await h.dispose(t);
  });

  testWidgets('On Pause is also offered in the Move to environment list', (t) async {
    final h = await open(t);
    await t.tap(find.byKey(ValueKey('$gpt-$p')), buttons: kSecondaryButton);
    await Harness.settle(t);
    await t.tap(find.text('Move to environment'));
    await Harness.settle(t);
    await t.tap(find.text('On Pause').last);
    await Harness.settle(t);
    expect(find.text('On Pause · 1'), findsOneWidget);
    // Still in the same environment folder, just inside its On Pause subfolder.
    expect(find.byKey(ValueKey('$gpt-$p')), findsOneWidget);
    await h.dispose(t);
  });
}
