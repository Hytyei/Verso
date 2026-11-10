# Verso v1.0.0 — verification (2026-11-10)

## Tests
`flutter test` → 95 passing (data layer, sort keys, undo, attachments, export, palette/glass, shell, board, drag/drop, editors, timeline scale/layout/view, filters, shortcuts).

## Build
`flutter build windows --release --no-pub` → `build\windows\x64\runner\Release\verso.exe`.
Windows plugin builds need symlinks (Developer Mode). This PC has Developer Mode off, so the plugin links in
`windows\flutter\ephemeral\.plugin_symlinks` were created as **directory junctions** (`mklink /J`, no admin needed)
and builds use `--no-pub`. After changing dependencies, run `flutter pub get` once (it reports the symlink error
but resolves packages), recreate the junctions, then build with `--no-pub`.

## Sandbox runs
The app ran against a scratch data folder (`VERSO_DATA_DIR`) seeded with `VERSO_SEED=1` (3 projects, 15 versions,
~300 features, steps, tags, delays, milestones). The real `%APPDATA%\Verso` was never touched.
Screenshots: `images/verso_light_board.png`, `images/verso_light_timeline.png`, `images/verso_dark_board.png`,
`images/verso_dark_timeline.png` (captured with `PrintWindow`, no synthetic input).

## Frame timings (release, 1080p laptop panel, `VERSO_PERF=1` self-driven sweeps)
| View | Frames | Raster p50 | p90 | p99 | Over 8.3 ms |
|---|---|---|---|---|---|
| Board, horizontal sweeps over ~110 cards | 972 | 3.0 ms | 3.8 ms | 13.3 ms | 36 (3.7%) |
| Timeline, zoom in/out + pans | 1233 | 5.7 ms | 6.7 ms | 12.4 ms | 38 (3.1%) |

The slow frames cluster at the start of each run (first shader/raster cache warm-up, max ≈ 100 ms once).
Build (UI thread) p90 stays under 1 ms.

## Fixed during verification
- Default window was taller than a 1080p screen at 125% scaling → size now clamps to 94% of the work area.
- Glass nested inside glass (search field in the toolbar) sampled the toolbar and smeared → nested glass never refracts.
- Timeline bars drew under the glass lane-label panel → clipped at the panel edge; panel no longer refracts.
