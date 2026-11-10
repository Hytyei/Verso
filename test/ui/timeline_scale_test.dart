import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/db/database.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/repos/version_repo.dart';
import 'package:verso/ui/timeline/timeline_layout.dart';
import 'package:verso/ui/timeline/timeline_scale.dart';

void main() {
  final origin = DateTime.utc(2026, 1, 1);

  group('TimelineScale', () {
    test('xOf/dateAt round trip', () {
      final s = TimelineScale(origin: origin, pxPerDay: 12);
      final d = DateTime.utc(2026, 3, 15, 6);
      expect(s.dateAt(s.xOf(d)).difference(d).inSeconds.abs(), lessThan(2));
      expect(s.xOf(origin), 0);
      expect(s.xOf(DateTime.utc(2026, 1, 11)), closeTo(120, 1e-9));
    });

    test('zoomAt keeps anchor date under cursor', () {
      final s = TimelineScale(origin: origin, pxPerDay: 6);
      final before = s.dateAt(333);
      final z = s.zoomAt(1.8, 333);
      expect(z.dateAt(333).difference(before).inMinutes.abs(), lessThanOrEqualTo(1));
      expect(z.pxPerDay, closeTo(10.8, 1e-9));
    });

    test('pxPerDay clamps', () {
      expect(TimelineScale(origin: origin, pxPerDay: 6).zoomAt(1e6, 0).pxPerDay, TimelineScale.maxPxPerDay);
      expect(TimelineScale(origin: origin, pxPerDay: 6).zoomAt(1e-6, 0).pxPerDay, TimelineScale.minPxPerDay);
    });

    test('panBy moves the origin', () {
      final s = TimelineScale(origin: origin, pxPerDay: 10).panBy(-100);
      expect(s.origin, DateTime.utc(2026, 1, 11));
    });

    test('level is day at 120 px/day, month at 4 px/day, year at 0.1 px/day', () {
      expect(TimelineScale(origin: origin, pxPerDay: 120).level, TickLevel.day);
      expect(TimelineScale(origin: origin, pxPerDay: 20).level, TickLevel.week);
      expect(TimelineScale(origin: origin, pxPerDay: 4).level, TickLevel.month);
      expect(TimelineScale(origin: origin, pxPerDay: 1).level, TickLevel.quarter);
      expect(TimelineScale(origin: origin, pxPerDay: .1).level, TickLevel.year);
    });

    test('month ticks labelled Jan..Dec', () {
      final s = TimelineScale(origin: origin, pxPerDay: 4);
      final ticks = s.ticks(365 * 4.0 - 1);
      expect(ticks.map((t) => t.label).take(12), [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ]);
      expect(ticks.first.major, isTrue);
      expect(ticks[1].major, isFalse);
    });

    test('ticks are at least 64 px apart', () {
      for (final px in <double>[400, 120, 30, 9.5, 4, 2.2, 1, .5, .1, .05]) {
        final ticks = TimelineScale(origin: origin, pxPerDay: px).ticks(3000);
        final xs = [for (final t in ticks) TimelineScale(origin: origin, pxPerDay: px).xOf(t.at)];
        for (var i = 1; i < xs.length; i++) {
          expect(xs[i] - xs[i - 1], greaterThanOrEqualTo(40), reason: 'px/day $px');
        }
      }
    });
  });

  group('TimelineLayout', () {
    late VersoDb db;
    late String p;
    setUp(() async {
      db = VersoDb(NativeDatabase.memory());
      p = await ProjectRepo(db).create('P', const VColor.slot(0));
    });
    tearDown(() => db.close());

    Future<TimelineLayoutResult> layout() async => TimelineLayout.build(
      await VersionRepo(db).listForProject(p),
      await FeatureRepo(db).watchDatedForProject(p).first,
      const [],
    );

    test('version with no dates goes to undated', () async {
      final v = await VersionRepo(db).create(p, 'v1');
      final r = await layout();
      expect(r.undated.map((x) => x.id), contains(v));
      expect(r.lanes.where((l) => l.version.id == v), isEmpty);
    });

    test('inverted range is swapped', () async {
      final v = await VersionRepo(db).create(p, 'v1');
      await VersionRepo(
        db,
      ).update(v, startDate: Value(DateTime.utc(2026, 5, 10)), targetDate: Value(DateTime.utc(2026, 5, 1)));
      final lane = (await layout()).lanes.single;
      expect(lane.range!.start, DateTime.utc(2026, 5, 1));
      expect(lane.range!.end, DateTime.utc(2026, 5, 10));
    });

    test('only targetDate gives 1-day bar', () async {
      final v = await VersionRepo(db).create(p, 'v1');
      await VersionRepo(db).update(v, targetDate: Value(DateTime.utc(2026, 6, 1)));
      final lane = (await layout()).lanes.single;
      expect(lane.range!.start, DateTime.utc(2026, 6, 1));
      expect(lane.range!.end, DateTime.utc(2026, 6, 2));
    });

    test('undated version with dated features still gets a lane', () async {
      final v = await VersionRepo(db).create(p, 'v1');
      await FeatureRepo(db).create(v, 'A', startDate: DateTime.utc(2026, 2, 1), endDate: DateTime.utc(2026, 2, 5));
      final r = await layout();
      final lane = r.lanes.single;
      expect(lane.range, isNull);
      expect(lane.features.single.range.start, DateTime.utc(2026, 2, 1));
      expect(r.undated.map((x) => x.id), contains(v));
    });

    test('concept lane is first', () async {
      final v = await VersionRepo(db).create(p, 'v1');
      final concept = (await VersionRepo(db).listForProject(p)).first.id;
      await VersionRepo(
        db,
      ).update(v, startDate: Value(DateTime.utc(2026, 1, 1)), targetDate: Value(DateTime.utc(2026, 2, 1)));
      await VersionRepo(
        db,
      ).update(concept, startDate: Value(DateTime.utc(2026, 3, 1)), targetDate: Value(DateTime.utc(2026, 3, 9)));
      final lanes = (await layout()).lanes;
      expect(lanes.first.isConcept, isTrue);
      expect(lanes.first.version.id, concept);
    });

    test('extent spans every bar and milestone', () async {
      final v = await VersionRepo(db).create(p, 'v1');
      await VersionRepo(
        db,
      ).update(v, startDate: Value(DateTime.utc(2026, 4, 1)), targetDate: Value(DateTime.utc(2026, 4, 20)));
      final r = TimelineLayout.build(await VersionRepo(db).listForProject(p), const [], [
        Milestone(
          id: 'm',
          createdAt: 0,
          updatedAt: 0,
          deleted: false,
          projectId: p,
          title: 'Launch',
          date: DateTime.utc(2026, 5, 3),
          kind: 'launch',
          colorCustom: false,
        ),
      ]);
      expect(r.extent!.start, DateTime.utc(2026, 4, 1));
      expect(r.extent!.end.isAfter(DateTime.utc(2026, 5, 3)), isTrue);
    });
  });
}
