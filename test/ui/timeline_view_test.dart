import 'package:drift/drift.dart' show Value;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/data/repos/version_repo.dart';
import 'package:verso/state/providers.dart';
import 'package:verso/state/settings.dart';
import 'package:verso/ui/timeline/timeline_view.dart';

import 'board_test.dart' show Ids, seedBasic;
import 'harness.dart';

void main() {
  Future<(Harness, Ids)> open(WidgetTester t, {bool datedV2 = true}) async {
    late Ids ids;
    final h = await Harness.pump(
      t,
      settings: const Settings(lastView: 'timeline'),
      seed: (db) async {
        ids = await seedBasic(db);
        await VersionRepo(
          db,
        ).update(ids.v1, startDate: Value(DateTime.utc(2026, 11, 2)), targetDate: Value(DateTime.utc(2026, 11, 20)));
        if (datedV2) {
          await VersionRepo(
            db,
          ).update(ids.v2, startDate: Value(DateTime.utc(2026, 11, 21)), targetDate: Value(DateTime.utc(2026, 12, 10)));
        }
      },
    );
    expect(h.container.read(viewModeProvider), ViewMode.timeline);
    return (h, ids);
  }

  TimelineViewState state(WidgetTester t) => t.state<TimelineViewState>(find.byType(TimelineView));

  testWidgets('ctrl+scroll zooms in', (t) async {
    final (h, _) = await open(t);
    final before = state(t).scale.pxPerDay;
    final center = t.getCenter(find.byType(TimelineView));
    await t.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await t.sendEventToBinding(pointer.hover(center));
    await t.sendEventToBinding(pointer.scroll(const Offset(0, -240)));
    await t.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await Harness.settle(t);
    expect(state(t).scale.pxPerDay, greaterThan(before * 1.2));
    await h.dispose(t);
  });

  testWidgets('drag bar end changes targetDate by dragged days', (t) async {
    final (h, ids) = await open(t);
    final s = state(t);
    final origin = t.getTopLeft(find.byType(TimelineView));
    final end = origin + s.handleRect(ids.v1, start: false)!.center;
    final dx = s.scale.pxPerDay * 5;
    final g = await t.startGesture(end, kind: PointerDeviceKind.mouse);
    for (var i = 1; i <= 6; i++) {
      await g.moveTo(end + Offset(dx * i / 6, 0));
      await t.pump(const Duration(milliseconds: 16));
    }
    await g.up();
    await Harness.settle(t);
    final v = await t.runAsync(() => VersionRepo(h.db).get(ids.v1));
    expect(v!.targetDate!.toUtc(), DateTime.utc(2026, 11, 25));
    expect(v.startDate!.toUtc(), DateTime.utc(2026, 11, 2));
    await h.dispose(t);
  });

  testWidgets('double-click empty lane creates dated feature in that version', (t) async {
    final (h, ids) = await open(t);
    final s = state(t);
    final lane = s.laneRect(ids.v2)!;
    final x = s.scale.xOf(DateTime.utc(2026, 12, 1, 12));
    final at = t.getTopLeft(find.byType(TimelineView)) + Offset(x, lane.bottom - 6);
    await t.tapAt(at);
    await t.pump(const Duration(milliseconds: 60));
    await t.tapAt(at);
    await Harness.settle(t);
    final fs = await t.runAsync(() => FeatureRepo(h.db).watchForVersion(ids.v2).first);
    expect(fs!.single.startDate!.toUtc(), DateTime.utc(2026, 12, 1));
    await h.dispose(t);
  });

  testWidgets('Today button centres today', (t) async {
    final (h, _) = await open(t);
    await t.tap(find.byKey(const Key('timeline-today')));
    await Harness.settle(t);
    final s = state(t);
    final width = t.getSize(find.byType(TimelineView)).width;
    final now = DateTime.now().toUtc();
    expect(s.scale.xOf(DateTime.utc(now.year, now.month, now.day, 12)), closeTo(width / 2, s.scale.pxPerDay + 2));
    await h.dispose(t);
  });

  testWidgets('undated tray lists undated versions', (t) async {
    final (h, _) = await open(t, datedV2: false);
    expect(find.descendant(of: find.byKey(const Key('undated-tray')), matching: find.text('v1.1')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('undated-tray')), matching: find.text('Concept')), findsOneWidget);
    await h.dispose(t);
  });
}
