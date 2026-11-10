# Verso

Track the apps you build, version by version. Verso shows a project's ideas and versions left to right
(Concept → v1.0 → v1.1 …) with feature checklists, plus a zoomable timeline of the same plan.
It uses an iOS look with Liquid-Glass chrome, and has light and black-warm dark themes.

Windows desktop (Flutter). An Android build and Cloudflare Worker sync are planned.

## Features
- **Board:** a Concept column for ideas, then a column per version. Feature cards hold text of any length, a round checkbox,
  tags, priority, steps, notes, image attachments (drop or paste) and colors. Drag to reorder or move between versions.
  You can delay a feature to a later build (it is marked "Delayed from v1.1"), and copy a version as a Markdown checklist.
- **Timeline:** version bars and dated features on a date axis that zooms from days to years with Ctrl+wheel or pinch.
  It shows milestones and a today line, and you drag bars or their ends to reschedule.
- **Environments:** folders such as "Claude Code" or "ChatGPT", each with its own name, icon and color. Switching a version's
  environment moves that version and every later one into the new folder; earlier versions stay behind.
- **Undo everywhere** (Ctrl+Z / Ctrl+Shift+Z), search (Ctrl+F), filters, and keyboard shortcuts:
  Space checks a feature, F2 renames, Del deletes, Ctrl+D delays, Ctrl+N adds, Ctrl+1/2 switch views.
- **Google sign-in:** desktop OAuth (browser + PKCE). The session is stored encrypted with Windows DPAPI.

## Google sign-in setup
1. Google Cloud Console → APIs & Services → Credentials → **Create OAuth client ID** → **Desktop app**.
2. In Verso, open **Settings** and paste the client ID and secret. To bake them into a build instead, use
   `--dart-define=GOOGLE_CLIENT_ID=… --dart-define=GOOGLE_CLIENT_SECRET=…`.

## Data
Data lives in `%APPDATA%\Verso`: `verso.db` (SQLite), `attachments\`, `icons\`, `settings.json` and `auth.bin`.
Setting `VERSO_DATA_DIR` points the app at another folder.

## Development
```
flutter test
flutter build windows --release
```
Plugins need Windows Developer Mode for symlinks. Without it, create directory junctions in
`windows\flutter\ephemeral\.plugin_symlinks` and build with `--no-pub` (see `docs/verification.md`).
Dev switches: `VERSO_SEED=1` fills an empty database with sample projects; `VERSO_PERF=1` records frame timings.

Design and plan: `docs/superpowers/specs/2026-11-08-verso-design.md`, `docs/superpowers/plans/2026-11-08-verso-v1.md`.
