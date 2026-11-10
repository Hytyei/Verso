# Verso for Android — design (v1.4.0)

Approved by the owner on 2026-11-10 ("start the production"). It amends the v1 spec (`2026-11-08-verso-design.md`).

## 1. Goal

The same Verso on an Android phone, from the same Flutter code and talking to the same Cloudflare sync. It has
the same data and the same features, laid out for one hand:

- **every version is one screen**: swiping left/right moves between versions, and scrolling up/down shows that
  version's tasks;
- the Windows sidebar becomes a **glass header**, and tapping it opens a **folders sheet**;
- the app updates itself from **GitHub releases**;
- two **home-screen widgets**;
- a **sync indicator** (on Windows too) that says whether local data has reached the server.

## 2. Phone screen

```
┌ glass header ───────────────────┐
│ ◐ Claude Code                    │  environment of the visible version
│ Baladsho ▾              ⟳✓  ⋯   │  project (tap → folders sheet), sync dot, menu
│ Concept · v0.1.0 ·[v1.0.0]· v1.1 │  version pills; they follow the pager, tap = jump
└─────────────────────────────────┘
  PageView (one page per version, Concept first)
    page header: name, status chip, dates, progress ring, copy, edit
    "→ Astra" break chip when this version starts a new environment
    task list (scrolls vertically), drag to reorder (long-press)
  floating glass "Add a task" bar (adds to the visible version)
```

- **Folders sheet** (it slides down from the header): each environment is a folder of projects, and On Pause is a
  dimmed subfolder, as in the Windows sidebar. Tap a project to open it, long-press it for the project menu
  (On Pause, Move to environment, Color, Tags, Rename, Delete), use "+" to add a project or environment, and
  long-press an environment to edit it.
- **Task tile:** checkbox, title, priority/color/tag marks, and a count of steps and notes. Tap it to expand it
  inline into the shared `FeatureExpanded` editor (steps to any depth, notes, tags, priority, color, dates,
  images). Long-press it for the shared feature menu (Delay to, Move to, Priority, Color, Delete). A swipe would
  clash with the pager, so the menu replaces it.
- **The ⋯ menu:** Timeline (the shared timeline view in a full-screen page; pinch zooms it), Search & filter,
  Settings, Undo/Redo, New version, Copy all features.
- **Undo:** an undo toast after each destructive action, the same `UndoStack` as on Windows.
- **Images:** taken from the photo picker or the camera (`image_picker`) instead of drag-drop/paste.
- **Glass:** the same lens glass as Windows (one look on both platforms; it is cheap under Impeller).
  Haptics: a selection click on check/reorder, a light impact on page snap.

The layout is chosen at runtime: Android (or a window narrower than 600 dp) gets `PhoneShell`, and Windows keeps
`Shell`. Everything below the UI is shared.

## 3. Platform layer (`lib/platform/`)

A single Kotlin channel `verso/platform` in `MainActivity` provides:

| method | use |
|---|---|
| `protect(bytes)` / `unprotect(bytes)` | AES-GCM with a non-exportable Android Keystore key → `KeystoreTokenStore` (the counterpart of DPAPI) |
| `openUrl(url)` | browser for Google sign-in |
| `appVersion()` | versionName for the updater |
| `canInstall()` / `openInstallSettings()` / `installApk(path)` | the updater (FileProvider + package installer) |

- **Data dir:** the app support directory (`getApplicationSupportDirectory`).
- **Sign-in:** the existing Desktop OAuth client with the loopback redirect (127.0.0.1). The page served after
  login sends the browser to `verso://signed-in`, which brings the app back to the front. The Worker already
  trusts this client's `aud`, so nothing changes in Google Console. If Google ever refuses loopback from a
  phone, the fallback is an Android OAuth client (package `design.hadi.verso`, release SHA-1
  `86:B5:2E:33:5B:78:6C:05:40:F5:11:CB:CD:B7:D3:17:D8:B2:C9:DE`), with its client ID added to the Worker's
  `GOOGLE_CLIENT_ID`.

## 4. Updates

- **The check:** `GET https://api.github.com/repos/Hytyei/Verso/releases/latest` (the repo is public) runs at
  launch (at most once every 6 h) and from Settings → "Check for updates".
- **What counts:** a release counts when its tag (`vX.Y.Z`) is newer than `appVersion()` and it has a `.apk` asset.
  When one appears, a glass banner shows "Verso X.Y.Z is ready" with an Update button.
- **Installing:** Update downloads the file into the cache with a progress bar, then asks Android to install it.
  The first time, Android sends the owner to "install unknown apps".
- **Failures:** they show as a toast. The check stays quiet when offline.

## 5. Widgets (`home_widget` + Kotlin `AppWidgetProvider`s)

- **The snapshot:** the app writes a JSON snapshot to the widget prefs one second after any data change (local
  edits and pulled sync rows alike), then refreshes both widgets. For each project that isn't paused it holds:
  `{id, name, env, color, version: {id, name, done, total}, open: [{id, title}] (≤ 8)}`. The *active version* is
  the first one with status *active*. Failing that, it is the first unreleased release; failing that, the Concept
  stage.
- **Current version** (resizable, 3×2 and up): project, version and ring at the top, then as many open tasks as
  fit. Tapping a task's checkbox ticks it through a `home_widget` background callback, which opens the database
  in a background isolate, marks the feature done, and rebuilds the snapshot. Tapping anywhere else opens the
  app on that project and version.
- **Progress glance** (2×1 / 2×2): project, version and ring.
- **The project:** both widgets ask for a project when they are placed (a configuration activity listing the
  snapshot's projects). With no choice, they follow the last opened project.

## 6. Sync indicator

`SyncController` also reports **pending** (local rows changed since the last successful push). The rest are
the existing states: off (signed out / no URL), syncing, failed (offline or server error), synced at a time.
A small glyph shows the state:

| glyph | state |
|---|---|
| ✓ | synced |
| spinning arcs | syncing |
| dot | waiting to upload |
| ! | failed |
| slashed cloud | off |

It sits in the Windows toolbar and in the phone header. Tapping it opens the account panel (last sync time, the
error if any, Sync now).

## 7. Release

- **Versions:** the Android `versionName` equals the app version (1.4.0) and `versionCode` is the pubspec build
  number.
- **Signing:** the APK is signed with `AndroidKeys\versoapp`, its passwords read from
  `AndroidKeys\versoapp.properties` (outside the repo). Debug builds use the debug key and the package
  `design.hadi.verso.debug`, so a debug build never blocks the release one.
- **The release:** each GitHub release carries `Verso-<v>-android.apk` and `Verso-<v>-windows-x64.zip`.

## 8. Testing

- **Unit tests:**
  - version comparison and update decision;
  - the widget snapshot builder (active-version choice, open tasks);
  - the sync pending state;
  - the Keystore store's round trip (via a fake channel).
- **Widget tests:** `PhoneShell` (pager follows pills, swipe changes version, add bar adds to the visible version,
  folders sheet opens a project).
- **On the emulator:** `Medium_Phone_API_35`, `-gpu angle_indirect`. Screens are captured with `adb exec-out
  screencap` (that's the emulator's own screen, not the owner's desktop).
