import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verso/data/db/database.dart';
import 'package:verso/data/export.dart';
import 'package:verso/data/models.dart';
import 'package:verso/data/repos/feature_repo.dart';
import 'package:verso/data/repos/project_repo.dart';
import 'package:verso/data/repos/version_repo.dart';

void main() {
  test('versionAsText lists open then done features with steps as a checklist', () async {
    final db = VersoDb(NativeDatabase.memory());
    final p = await ProjectRepo(db).create('Tandem', const VColor.slot(0));
    final v = await VersionRepo(db).create(p, 'v1.1');
    await VersionRepo(
      db,
    ).update(v, startDate: Value(DateTime.utc(2026, 11, 21)), targetDate: Value(DateTime.utc(2026, 12, 10)));
    final f = FeatureRepo(db);
    final a = await f.create(v, 'Sign in with Google');
    final b = await f.create(v, 'Dark mode');
    await f.create(v, 'Multi\nline title');
    await f.setDone(b, true);
    final s1 = await f.addSubitem(a, 'Design screen');
    await f.addSubitem(a, 'Wire API');
    await f.updateSubitem(s1, done: true);
    final text = await versionAsText(db, v, now: DateTime.utc(2026, 11, 10));
    expect(
      text,
      'v1.1 (Nov 21 → Dec 10) — 1/3 done\n'
      '- [ ] Sign in with Google\n'
      '  - [x] Design screen\n'
      '  - [ ] Wire API\n'
      '- [ ] Multi\n'
      '  line title\n'
      '- [x] Dark mode\n',
    );
    await db.close();
  });

  test('empty version copies just its heading', () async {
    final db = VersoDb(NativeDatabase.memory());
    final p = await ProjectRepo(db).create('Tandem', const VColor.slot(0));
    final v = await VersionRepo(db).create(p, 'v2');
    expect(await versionAsText(db, v), 'v2 — 0/0 done\n');
    await db.close();
  });
}
