# Verso — Instructions for anyone continuing this project

This file is the hand-over document. It explains what Verso is, how it is built, how to run, test and release it,
where every piece lives, the decisions behind it, and what comes next. Read it fully before changing anything.
Keep it up to date in the same commit as any change to features, structure or plans.

---

## 1. What Verso is

Verso is a personal app for **Windows and Android** for **tracking app development by version**. It sits
between Todoist and Notion, but is organised around versions and milestones, and shown visually. Both platforms are
built from the same Flutter code and share data through the owner's Cloudflare Worker (§8a).

- **Board view:** columns from left to right. The **Concept** stage (ideas) comes first, then versions (v1.0 → v1.1 → …), then
  "Add version". Each column holds **feature** cards: text of any length, a round checkbox, tags, priority, steps
  (sub-items), notes, image attachments, a color, and dates.
- **Timeline view:** version bars and dated features on a date axis that zooms from days to years with Ctrl+wheel or pinch.
  It shows milestones (diamonds) and a today line. Drag bars or their ends to reschedule.
- **Environments:** sidebar folders such as "Claude Code", "ChatGPT" or "Firefox", each with a name, an icon and a color. A project
  appears in every environment that holds any of its versions. **Changing a version's environment moves that version
  and every later version** ("break from here and continue in the new environment").
- **Delay:** a feature can be delayed to the next or a chosen later version. It then shows "Delayed from v1.1"
  (or "Delayed ×3 · from v1.1"), and the receiving column header shows "n delayed in".
- **On Pause:** right-click a project → **Move to On Pause** (first menu item; also listed as "On Pause" at the bottom of **Move to environment**). In every environment folder it then moves into an
  "On Pause · n" subfolder, drawn at low opacity, and the toolbar shows an "On Pause" pill. **Move back from On Pause** brings it back. Undoable.
- **Copy:** each column header copies its version as a Markdown checklist (open features first, then done ones, with steps indented).
- **Undo for everything** (Ctrl+Z / Ctrl+Shift+Z / Ctrl+Y), toasts with Undo, search (Ctrl+F), filters (tags, priority, open/done).
- **Google sign-in:** OAuth in the browser with PKCE (Windows and Android). It identifies the owner for the Cloudflare sync.
- **Sync indicator:** a small cloud in the Windows toolbar and the phone header: ✓ synced, spinning while syncing,
  a dot for changes waiting to upload, ! when the last sync failed, slashed when signed out. Tap it for the state in words and "Sync now".
- **Updates from GitHub:** at launch (and from Settings → Check for updates) the app reads the latest release of the
  public repo. Android downloads the APK and opens the installer; Windows opens the release page (§8c).
- **Android (§8b):** one version per screen: swipe left/right between versions, scroll up/down through its tasks. A glass
  header shows the environment and project (tap → folders sheet, the Windows sidebar) plus version pills. Two home-screen
  widgets (§8d).

The owner is a single user (Hytyei). The look follows the iOS design language with **Liquid Glass** chrome:
- **Light theme:** a pastel blue-lavender palette taken from a "theme-based roadmap" reference.
- **Dark theme:** pure black with warm accents (amber, coral, rose, sand).

## 0. Folder layout (read first)

```
D:\RandD\Windows Apps\Verso\
  v1.0.0\            first release (frozen)
  v1.1.0\            previous version
  v1.2.0\            previous version
  v1.3.0\            CURRENT version: source + git repo + the runner
    verso.exe         ← run this (with the DLLs and data\ beside it; put there by tool\release.ps1)
    lib\ test\ backend\ docs\ tool\ …
  releases\          zipped builds: Verso-<version>-windows-x64.zip
%APPDATA%\Verso\     THE database and files, shared by every version (see §5)
```

- **One folder per version:** every round of changes starts by copying the latest version folder to a new
  `vX.Y.Z` (without `build\`, `.dart_tool\`, `windows\flutter\ephemeral\`, `backend\node_modules\`). Then bump
  `version:` in `pubspec.yaml`, run `flutter pub get` and `python tool\junctions.py .`, and work there.
- **The database is NOT inside a version folder.** All versions read and write `%APPDATA%\Verso`, so a new version
  sees all existing data. Upgrades must be **idempotent** (`onUpgrade` checks for each table and column before adding it), because an older
  build that opens the file stamps `user_version` back down. Back up `verso.sqlite` before trying a new version.
- **Don't run old builds on purpose:** they can't show newer data such as nested steps.

## 2. Status (2026-11-10)

- **v1.0.0 is built and verified.**
  - 159 automated tests pass (plus 18 Worker smoke tests).
  - The release exe runs.
  - A whole-branch code review was done and all its Critical and Important findings were fixed.
- **The owner's data is imported** from the Todoist project "Claude Projects Map": 3 environments, 24 projects, 6 versions and 69 features.
- **Repository:** private GitHub `Hytyei/Verso`, branch `main` (work happened on `v1`, fast-forwarded into `main`).
  Releases are built locally and attached to GitHub releases (§9).
- **v1.1.0 adds:**
  - Cloudflare sync (§8a);
  - nested steps (sub-steps to any depth, drag to reorder);
  - right-click **Move to environment** for projects;
  - pause projects;
  - new versions named `v0.0.0`, then bumping the second number (`v1.6.0` → `v1.7.0`);
  - idempotent schema upgrades.
- **v1.2.0:** "Move to On Pause" is the first project menu item.
- **v1.3.0:** completed Todoist tasks imported. That brought in 4 more environments (Comet, Google Chrome, Brave, Nightfox), 9 finished
  projects, 10 released versions and 153 done features. The importer gained a **merge mode** (see `lib/data/import_tree.dart`):
  - projects are matched by name anywhere;
  - only missing features and steps are added;
  - new versions are placed in version-number order;
  - `status` and `notes` are supported.
  Converter: `tool/todoist/completed_to_tree.py <completed.json> <out.json> [map.json]` (input: a Todoist completed-tasks
  JSON export). The git-ignored `tool/todoist/map.json` names the open Todoist parents as they are called in Verso now;
  it is the owner's data and stays off GitHub. Run with `VERSO_IMPORT=<tree.json>` (the tree has `"merge": true`).
- **v1.4.0 (2026-11-10): Android.** The phone app (§8b), GitHub updates (§8c), home-screen widgets (§8d), the sync
  indicator, pinch-to-zoom on the timeline, "Rename…" in the project menu, and the Verso icon on both platforms.
  The repository was recreated as **public** with a fresh history (§9).
- **Not verified yet:** live sync between the phone and the PC. It needs the owner to sign in on both; the Worker
  already accepts the Desktop client the phone uses.

## 3. Requirements and toolchain

| Thing | Version / location |
|---|---|
| Flutter | 3.44.2 (stable) at `%USERPROFILE%\Develop\flutter`; Dart 3.12.2 |
| Windows build tools | Visual Studio 2026 (Desktop C++), Windows 10 SDK 10.0.26100 |
| OS | Windows 10/11 x64 (target); dev PC is Windows 11 with a 1080p laptop panel at 125% |
| Packages | see `pubspec.yaml`: drift + drift_flutter (SQLite), flutter_riverpod 3, window_manager, screen_retriever, uuid, path_provider, image, desktop_drop, pasteboard, crypto, ffi; dev: drift_dev, build_runner, flutter_lints |
| Font | Inter 4.1 (bundled in `assets/fonts/`, OFL licence file alongside) |
| Android | SDK at `%LOCALAPPDATA%\Android\Sdk` (platform 36), **JDK 21** at `%USERPROFILE%\.jdks\jbr-21.0.11` (Gradle fails on Android Studio's Java 25), AGP 9 / Gradle 9.1 (from the Flutter template), minSdk 26 |
| Android packages | `home_widget` (widgets), `image_picker` (photos); everything else Android-only is in `MainActivity.kt` (channel `verso/platform`) |

**Windows Developer Mode is OFF on the owner's PC.** Flutter needs symlinks for plugins, so:
1. Run `flutter pub get` once after changing dependencies. It resolves packages, then complains about symlinks.
2. Create **directory junctions** (no admin needed) in `windows\flutter\ephemeral\.plugin_symlinks\` for every Windows
   plugin listed in `.flutter-plugins-dependencies`:
   `mklink /J <name> %LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\<name>-<version>`.
   Current list: desktop_drop, jni, pasteboard, path_provider_windows, screen_retriever_windows, window_manager.
3. Build with `--no-pub`.

With Developer Mode on, a plain `flutter build windows` works.

**Android build quirk:** `android/gradle.properties` sets `kotlin.incremental=false`. The plugin sources (pub cache on
C:) and the project (D:) sit on different drives, and Kotlin's incremental caches fail across drives
("Could not close incremental caches").

## 4. How to run, test and build

```
flutter test                                    # all tests (~20 s)
powershell -ExecutionPolicy Bypass -File tool\release.ps1
                                                # junctions → release build with the Google client baked in →
                                                # runner copied to the version root (verso.exe) → zip in ..\releases
powershell -ExecutionPolicy Bypass -File tool\release_android.ps1
                                                # signed release APK → ..\releases\Verso-<v>-android.apk
powershell -ExecutionPolicy Bypass -File tool\release_android.ps1 -Debug
                                                # debug APK (package design.hadi.verso.debug, installs beside the release)
cd backend && npm test                          # Worker smoke tests (node:sqlite stands in for D1)
```

**Android emulator:** `emulator -avd Medium_Phone_API_35 -gpu angle_indirect -no-snapshot` (other GPU modes crash it on this
PC), then `adb install -r <apk>`. Capture it with `adb exec-out screencap -p > shot.png` (the emulator's own screen, not the desktop).
`tool\google_client.env` (git-ignored) holds `GOOGLE_CLIENT_ID=` / `GOOGLE_CLIENT_SECRET=` for the "Desktop app"
OAuth client. Ask the owner for it, or copy it from the previous version folder.

Environment variables (runtime):
- `VERSO_DATA_DIR=<folder>`: use another data folder (sandbox). Default `%APPDATA%\Verso`.
- `VERSO_SEED=1`: if the database has no projects, fill it with 3 sample projects (~300 features).
- `VERSO_PERF=1`: the board or timeline drives its own scrolling or zooming, and frame timings are written to `<data>\perf.txt`.
- `VERSO_IMPORT=<file.json>`: import a JSON tree at startup (see `lib/data/import_tree.dart` for the format). The import is
  idempotent by name, and each run appends a line to `<data>\import.log`. This is how the Todoist map was imported.

Build-time defines: `--dart-define=GOOGLE_CLIENT_ID=… --dart-define=GOOGLE_CLIENT_SECRET=…` (otherwise set them in Settings).

**Testing on the owner's PC without disturbing them:**
- Run against a sandbox `VERSO_DATA_DIR`.
- Capture the window with `PrintWindow(hwnd, hdc, 2)` from a DPI-aware process.
- **Never** use screen grabs (`CopyFromScreen`) or synthetic mouse or keyboard input: the owner uses the PC at the same time.

## 5. Data and files

| Path (in `%APPDATA%\Verso`) | What |
|---|---|
| `verso.sqlite` | the database (Drift/SQLite) |
| `attachments\<uuid>.<ext>` + `<uuid>.thumb.png` | feature images and their 512 px thumbnails |
| `icons\<uuid>.<ext>` | custom environment icons |
| `settings.json` | theme, reduce motion, last project/view, Google client ID and secret |
| `auth.bin` | Google session (refresh token + account), encrypted with Windows DPAPI (current user) |
| `import.log` | results of `VERSO_IMPORT` runs |
| `verso.sqlite.bak-before-todoist-import` | backup made before the first Todoist import |

### Schema (Drift, `lib/data/db/tables.dart`, schema version 4)
Every table has `id` (UUID v4), `createdAt` and `updatedAt` (UTC epoch ms), and `deleted` (soft delete). Queries never return
deleted rows. Every write stamps `updatedAt`. Together these make the rows ready for last-write-wins sync.

- `projects`: name, color/colorCustom, icon, sortKey, archived, paused
- `environments`: name, icon (glyph key or `file:<name>`), color/colorCustom, sortKey
- `versions`: projectId, environmentId, kind (`concept`/`release`), name, status (`planned`/`active`/`released`),
  color, startDate, targetDate, releasedDate, description, sortKey
- `features`: versionId, title, done, doneAt, priority 0–3, color?, notes?, startDate?, endDate?, sortKey,
  delayedFromVersionId?, delayCount
- `subitems` (steps; `parentId` for nesting), `milestones`, `tags`, `feature_tags` (id = `featureId:tagId`), `attachments`

**Ordering:** `sortKey` is a fractional index (`lib/data/sort_key.dart`, after Greenspan). A move rewrites only the moved
row. `placeKey` always lands strictly after its anchor and before the next greater key. Columns with duplicate
keys are renumbered automatically. Create and move run in transactions.

**Migrations:** `onUpgrade` in `lib/data/db/database.dart`. v1→v2 added environments, and v2→v3 added `projects.paused`. Each step runs atomically in a transaction.
After editing tables, run `dart run build_runner build --delete-conflicting-outputs` and bump `schemaVersion` with a migration.

Dates are calendar days stored at UTC midnight. Drift returns them as **local** `DateTime`, so always format and compare
via `toUtc()` (see `lib/ui/common/format.dart`).

## 6. Architecture and file map

```
lib/
  main.dart              startup: data dir, DB, env-var hooks, window, ProviderScope overrides; mainAndroid() for phones
  app.dart               MaterialApp, themes; Shell (Windows) or PhoneHost (touch mode); launch update check
  version.dart           appVersionName (a test keeps it equal to pubspec's version)
  auth/                  Google OAuth (google_oauth.dart), DPAPI token store (token_store.dart), AuthController
  platform/              window.dart (Windows window), android_platform.dart (channel to MainActivity.kt + KeystoreTokenStore)
  update/                updater.dart (GitHub latest release, version compare, download), update_controller.dart
  widgets/               widget_snapshot.dart (JSON the Android widgets read), widget_bridge.dart (publisher + background tick)
  ui/phone/              PhoneHost, PhoneShell (version pager), PhoneHeader (pills, ⋯ menu), folders sheet, phone timeline
  data/
    db/                  Drift tables + database (+ generated database.g.dart)
    repos/               ProjectRepo, EnvironmentRepo, VersionRepo, FeatureRepo, TagRepo, MilestoneRepo, ordering.dart
    undo.dart            UndoStack + every undoable action (create/delete/move/check/edit/delay/env change…)
    attachment_store.dart images: validation, size caps (40 MB / 60 MP), isolate thumbnailing
    export.dart          version → Markdown checklist
    import_tree.dart     JSON tree importer
    sort_key.dart, models.dart
  dev/                   seed.dart (sample data), perf_probe.dart (frame timings + perfMode)
  platform/window.dart   frameless window, size clamped to the screen, WindowApi interface
  state/                 providers.dart (all Riverpod providers, selection of project + environment), settings.dart
  ui/
    shell/               Shell layout, Sidebar (environment folders), Toolbar, TitleBar, GlassSegmented,
                         filter.dart (search/filter + featureMatches), account_area.dart
    board/               BoardView, VersionColumn, ColumnHeader, FeatureCard, FeatureExpanded, AddFeatureRow,
                         drag_controller.dart (card drag), segment_stub.dart (environment segments), feature_actions.dart
    timeline/            TimelineScale (date↔x, zoom, ticks), TimelineLayout (lanes), TimelinePainter, TimelineView
    editors/             version/milestone/tag/environment editors, color picker, date chip, settings sheet,
                         project menu, confirm dialog, wiring.dart (plugs editors into the board via boardHooksProvider)
    common/              toast, glass menu/popover, check pop, chips, FLIP + animated entry list, smooth wheel, lightbox…
    glass/glass_surface.dart   the Liquid Glass material
    theme/               palette (light/dark tokens), motion (springs), ThemeData
    shortcuts.dart       global keyboard shortcuts
test/                    data/, ui/, auth/ (harness.dart pumps the full app over an in-memory DB)
docs/                    spec, plan, glass spike, verification notes, screenshots
```

**State:** Riverpod 3. The repositories return Drift streams, and `StreamProvider.family`s expose them. Selection is
`selectedProjectIdProvider` + `selectedEnvironmentIdProvider` (a project is viewed "from" an environment folder).
The editors and filters plug into the board through `boardHooksProvider` (overridden in `main.dart` and in the tests), so the
board does not import the editors.

**Liquid Glass (important decision):** Flutter on Windows renders with Skia. `liquid_glass_renderer` and any
`ImageFilter.shader` backdrop need Impeller, so they cannot be used. `GlassSurface` fakes refraction instead:
- `BackdropFilter` with `ImageFilter.matrix` magnifies the backdrop 1.03× inside the shape;
- three rim bands magnify it 1.06/1.11/1.17×;
- a tint, a sheen and a specular rim go on top.

Rules:
- Glass goes on chrome and controls only, never on feature cards.
- Glass inside glass never refracts (an inherited marker turns it off).
- Use `refract: false` over static backgrounds.

See `docs/glass-spike.md`.

**Motion:** springs (`Motion.spring`, response 0.35 s, damping 0.85) only for transforms, sizes and positions.
Colors and shadows use `Motion.smooth` (springs overshoot and broke shadows). Reduce motion (setting or OS) switches to crossfades.
Lists use `AnimatedEntryList` (enter/exit) plus `Flip` (FLIP moves).

**Test gotchas:**
- Never await a Drift stream `cancel()` or `db.close()` inside `tester.runAsync` (deadlock). The harness handles teardown.
- The test font (Ahem) is wider than Inter, so every text in a `Row` needs `Flexible` or `Expanded`.

## 7. Features in detail (current)

- **Projects:** create (in the selected environment), rename (double-click in the sidebar), and from right-click: color, tags, **Move to environment** (moves the project's versions in that folder), pause/resume, delete. All undoable. Progress ring.
- **Concept stage:** always the first column. It cannot be moved or deleted. Its features are "ideas" and don't count toward progress.
- **Versions:** new ones are named `v0.0.0` first, then the second number bumps (`bumpVersionName` in `lib/data/models.dart`).
  - name, status, dates (start/target), color, description and environment are set via ⋯ on the column header;
  - drag a header to reorder;
  - delete with a confirmation and undo.
- **Features:**
  - **steps** nest to any depth (`subitems.parentId`): "+" on a step adds a sub-step, the drag handle reorders siblings, collapsing shows a count, and deleting removes the subtree (undoable);
  - add (Enter adds the next one, Shift+Enter makes a newline, Esc cancels), rename inline (double-click or F2), check (pop animation, moves to "Done · n");
  - drag between columns, delay or move via the right-click menu, priority, color, tags, steps, notes, dates, images (drop or Ctrl+V, lightbox).
- **Timeline:**
  - lanes per version (Concept hatched), feature sub-bars, milestones;
  - drag a bar or its ends to reschedule;
  - double-click a lane to add a dated feature, double-click the milestone row to add a milestone;
  - Today / Fit / zoom buttons, and an undated tray.
- **Environments:** folders, editor (16 glyphs or a custom image, plus color), break-from-here, edge stubs between segments.
- **Search and filters**, settings (theme, reduce motion, Google client, data folder), and shortcuts:

| Key | Action |
|---|---|
| Ctrl+N / Ctrl+Shift+N | new feature / new version |
| Space | check the focused feature |
| F2 | rename the focused feature |
| Del | delete the focused feature |
| Ctrl+D | delay the focused feature |
| Ctrl+F | search |
| Ctrl+1 / Ctrl+2 | Board / Timeline |
| Esc | clear focus |

## 8. Google sign-in

- **Setup:** Google Cloud Console → APIs & Services → Credentials → OAuth client ID → **Desktop app**. Put the ID and
  secret in Settings (or pass them as dart-defines). A desktop client secret is not confidential by Google's own definition.
- **Flow (`lib/auth/google_oauth.dart`):**
  1. Open the system browser with a PKCE S256 challenge, a state value, and the scopes `openid email profile` (offline access).
  2. Receive the redirect on a loopback server at `http://127.0.0.1:<random port>`.
  3. Exchange the code at `oauth2.googleapis.com/token`.
  4. Decode the account from the ID token.
  5. Store the refresh token with DPAPI.
- **Cancel and sign-out:** cancel closes the loopback port, and a cancelled or superseded attempt never stores anything.
  Sign-out revokes the token and deletes `auth.bin`.
- **Not verified in the app:** the ID token signature. The future sync Worker must verify it, including `aud` = client ID.

- **Android:** the same flow. The phone's browser opens through `MainActivity` (`openUrl`). The loopback server runs
  inside the app, and its success page links to `verso://signed-in` (an intent filter in the manifest), which brings
  Verso back to the front. The refresh token is stored in `auth.bin`, encrypted with AES-GCM under a non-exportable
  Android Keystore key (`TokenCipher` in `MainActivity.kt`). The Desktop client's ID is the `aud`, so the Worker
  needs no change.
  - **If Google ever refuses loopback from a phone:** create an *Android* OAuth client (package `design.hadi.verso`, SHA-1
    `86:B5:2E:33:5B:78:6C:05:40:F5:11:CB:CD:B7:D3:17:D8:B2:C9:DE`), then add its ID to `GOOGLE_CLIENT_ID` in `backend/wrangler.toml`.

## 8a. Cloudflare sync (verso-api)

- **Worker:** `backend\` (TypeScript), deployed as **verso-api** at `https://verso-api.thehdv7.workers.dev` on the owner's
  Cloudflare account. D1 database `verso` (id `4733215d-66e1-4a32-89c4-643e29861374`).
  R2 is not enabled, so images are stored in D1 as 1 MB chunks.
- **Deploy:** `cd backend && npm install && npx wrangler deploy` (wrangler is logged in on the owner's PC). Apply schema changes with
  `npx wrangler d1 execute verso --remote --file=schema.sql` (statements use IF NOT EXISTS).
- **Auth:** the app sends `Authorization: Bearer <Google ID token>`. The Worker checks the signature against Google's JWKS, plus
  `iss`, `exp`, and `aud` ∈ `GOOGLE_CLIENT_ID` (in `wrangler.toml` `[vars]`; add the Android client ID there later).
  The first Google account to sync becomes the owner (`meta.owner_sub`); every other account gets 403.
- **API:**
  - `POST /v1/sync {cursor, rows}`:
    - pushes at most 40 rows, because of the free-plan D1 queries-per-request limit;
    - last write by `updated_at` wins, and a tie keeps the stored row;
    - returns up to 500 rows with `seq > cursor`, plus `cursor` and `more`.
  - `PUT|GET|HEAD /v1/blobs/<uuid>.<ext>` for images (up to 40 MB).
  - `GET /v1/health`.
- **App side (`lib/sync/`):**
  - `SyncApi` (HTTP);
  - `SyncCodec` (every table ↔ wire rows, using Drift's own JSON);
  - `SyncEngine`:
    1. upload missing images;
    2. push rows with `updatedAt >= lastPushedAt` in batches of 40;
    3. pull until `more` is false, applying only rows newer than the local copy;
    4. download images that arrived;
  - `SyncController`: runs after sign-in, at launch, 3 s after local changes, every 2 min, and from "Sync now" in the account menu.
  - State lives in `%APPDATA%\Verso\sync_state.json`. The server URL is in Settings (empty turns sync off).
- **Default folder id:** the built-in default folder has the fixed id `env-default`, so devices share it. It is hidden when empty and other
  folders exist.

## 8b. Android app

- **Layout (`lib/ui/phone/`):** `PhoneHost` → `PhoneShell`.
  - **Header** (`PhoneHeader`, glass): the environment of the version on screen, the project name (tap → **folders
    sheet**, which is the Windows `Sidebar` in a drop-down sheet; long-press a project or folder for its menu), the sync
    indicator, and the ⋯ menu (Search & filter, Timeline, New version, Undo/Redo, Theme, Settings). **Version pills**
    follow the pager and jump on tap; "+" adds a version.
  - **Pages:** one `VersionColumn` per page, the same widget as a Windows column. Concept comes first; the app opens
    on the active version. A version that starts a new environment shows "Continues in <env>".
  - **Add bar:** "Add a task to vX" floats at the bottom and opens the page's add row.
- **Touch mode** (`touchModeProvider`, set in `mainAndroid`):
  - Cards: tap to expand; tap the title of an open card to edit it. Long-press lifts a card: move to drag it, or
    let go in place for its menu (Delay to, Move to, Priority, Color, Delete).
  - Version headers don't drag (they would fight the swipe). No double-tap anywhere.
- **Timeline:** full screen from ⋯ → Timeline; pinch zooms (a pointer listener in `timeline_view.dart`; one finger still pans and drags bars).
- **Data:** the app's private storage (`getApplicationSupportDirectory()`), the same schema and sync as Windows.
  When the app comes back to the foreground, it re-reads all tables (a widget may have ticked a task) and syncs.
- **Package:** `design.hadi.verso` (debug: `design.hadi.verso.debug`). minSdk 26.
- **Signing:** `android/app/build.gradle.kts` reads `D:\RandD\Android Apps\AndroidKeys\versoapp.properties`
  (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`). The key `versoapp` (alias `versoapp`, RSA 4096, valid 100 years) sits beside it.
  **Neither file is in the repo. Back both up:** losing the key means no more in-place updates.
  - Signer SHA-1 `86:B5:2E:33:5B:78:6C:05:40:F5:11:CB:CD:B7:D3:17:D8:B2:C9:DE`.

## 8c. Updates from GitHub

- `lib/update/updater.dart` reads `https://api.github.com/repos/Hytyei/Verso/releases/latest` (the repo is public, so
  no token is needed). A release counts when its tag is newer than `appVersionName` and it has the platform's file:
  `*.apk` on Android, `*windows-x64.zip` on Windows.
- `UpdateController`: check, then update.
  - **Android:** asks for "Install unknown apps" if needed, downloads into the cache (`updates/`, shared through a
    FileProvider), then opens the package installer.
  - **Windows:** opens the release page.
- **When it checks:** 4 s after launch (`launchUpdateCheckProvider`, off in tests), and from Settings → Check for updates.
  A glass banner offers "Update" and "Later".
- **Releasing an update:** bump `version:` in pubspec **and** `lib/version.dart`, build both platforms, and create the
  GitHub release `v<version>` with `Verso-<v>-android.apk` and `Verso-<v>-windows-x64.zip`. Phones see it at their next
  launch. **Every APK must be signed with the versoapp key**, or Android refuses the update.

## 8d. Home-screen widgets (Android)

- **Current version** (resizable): project, version, ring, and as many open tasks as fit. The checkbox ticks the task
  right there: a `home_widget` background callback (`widgetBackgroundCallback`) opens the database in a background
  isolate, marks it done, and refreshes the widgets. Tapping elsewhere opens that version in the app.
- **Progress glance** (2×1): project, version, ring and percentage.
- **Choosing the project:** both widgets ask when they are placed (`WidgetConfigActivity`); they can follow "the last
  project I opened". Long-press → reconfigure changes it.
- **Data flow:** the app writes `buildWidgetSnapshot()` JSON to the widget prefs 1 s after any change (`WidgetPublisher`),
  and the Kotlin providers (`android/app/src/main/kotlin/design/hadi/verso/widget/`) render it with RemoteViews.
  The ring is a bitmap. Colors follow light/dark from `values(-night)/widget_colors.xml`.

## 9. Releases and repository

- Repo: `https://github.com/Hytyei/Verso`, **public** since 2026-11-10 (the in-app updater reads its releases). It was
  recreated then with a fresh history, after a scan for secrets: the Google client secret
  (`tool/google_client.env`), the Todoist map, keys and databases are all git-ignored. **Never commit secrets or the
  owner's personal data.** Commit messages end with
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Version folders: the owner keeps one folder per version (`D:\RandD\Windows Apps\Verso\v1.0.0\`). For a new
  version, copy the folder to `v1.x.y` (including `.git`) and work there.
- Release:
  1. Run `tool\release.ps1` and `tool\release_android.ps1`.
  2. Run `gh release create v<version> ..\releases\Verso-<version>-windows-x64.zip ..\releases\Verso-<version>-android.apk --repo Hytyei/Verso`.
- **Repo history:** the repo history lives in the newest version folder's `.git` (copied forward). Keep `build/` and `.dart_tool/` ignored;
  an early mistake once bloated the history to 293 MB, and it had to be rewritten.
- The exe is not code-signed, so Windows SmartScreen shows "More info → Run anyway".

## 10. Known limitations and deferred items (from the final review)

- **Timeline:**
  - no edge stubs to other environment segments (the board has them);
  - an A, B, A environment pattern shows no hint of the middle segment;
  - text cache not disposed, and lane labels laid out again on every paint.
- **Timeline end dates are drawn as exclusive** (a version running Jan 1–10 ends at the start of Jan 10). Decide whether to
  make them inclusive.
- **Performance:**
  - board p99 ≈ 13 ms, and 3–4% of frames go over 8.3 ms, mostly warm-up;
  - every column re-queries on any feature write (Drift `readsFrom` is table-level); a project-level query would fix it.
- **Small fixes left:**
  - `settings.json` is written synchronously and not atomically;
  - the project delete confirmation doesn't show the feature count;
  - the OAuth success page appears before the token exchange finishes;
  - HttpClient has no timeouts;
  - raw HTTP errors appear in a toast;
  - the DPAPI plaintext buffer is not zeroed before it is freed.
- **Design gaps:**
  - no auto-scroll when dragging near the board edge;
  - "break from here" also pulls in later versions that already sit in a third environment (spec wording; product question);
  - `data/export.dart` imports `ui/common/format.dart` (a layering nit).
- The full list with reasons is in the git history of `.superpowers/sdd/...` (a gitignored ledger) and in `docs/verification.md`.

## 11. Planned next

1. **Cloudflare sync: built in v1.1.0 (§8a).** Remaining: Android client ID in the Worker's `GOOGLE_CLIENT_ID`, and a conflict view if ever needed.
1. *(Old plan text, kept for context.)* **Cloudflare sync.** A Worker + D1 on the owner's Cloudflare account, following the same pattern as Tandem, Kobel and Leestn
   (TypeScript, `wrangler`). Planned shape:
   - auth: the Google ID token, verified by the Worker; the owner's account only;
   - `/sync`: push rows whose `updatedAt` is newer than the last sync, pull everything newer than the client's cursor,
     last-write-wins per row (soft deletes propagate);
   - attachments uploaded to R2 or stored as blobs.
   Not built yet; see the owner's decision on which Worker to use.
2. **Android app: built in v1.4.0 (§8b–8d).** Next for it: dragging a card to the neighbouring version, by holding it
   at the screen edge; widget previews in the picker (Android 15 generated previews).
3. The §10 items, in this order: timeline stubs, inclusive end dates, settings write safety, the project-level query.
4. Optional: Todoist two-way sync, which would build on the importer.

## 12. Design references

- Spec: `docs/superpowers/specs/2026-11-08-verso-design.md`. Amendments: §11 Concept/Delay, §12 copy/environments/sign-in.
- Android spec: `docs/superpowers/specs/2026-11-10-verso-android-design.md`.
- Plan: `docs/superpowers/plans/2026-11-08-verso-v1.md` (Amendments A, B).
- Glass test: `docs/glass-spike.md`. Verification and timings: `docs/verification.md`. Screenshots: `docs/images/`.
