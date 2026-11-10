# Liquid Glass feasibility test — 2026-11-09

Machine: owner's laptop (Windows 11, Intel UHD + RTX 3060, 1080p 120 Hz), Flutter 3.44.2.

## 1. `liquid_glass_renderer` 0.2.0-dev.4 — FAIL
The Windows build fails: its fragment shaders don't compile for SkSL ("initializers are not permitted on arrays", "loop index initializer must be a constant expression"). Flutter on Windows renders with Skia, and the package (like `ImageFilter.shader` backdrops in general) needs Impeller. Its README also lists Windows as unsupported.

## 2. Skia-safe "lens glass" — PASS (chosen)
The probe source is kept in `docs/images/lens-probe.dart.txt`. It stacks:
1. a `BackdropFilter` with `ImageFilter.matrix` scaling the backdrop by 1.03 around the shape centre (gentle magnification inside);
2. a second `BackdropFilter`, clipped to a 7 px ring along the edge, scaling by 1.16, so content bends at the rim (edge lensing);
3. a tint, a vertical sheen gradient and a specular rim stroke (a bright gradient from top-left to bottom-right).

Both filters are composed with a 0.6σ blur only to anti-alias the resampling. It is not frosted.

Result: visible refraction at the rims (`docs/images/glass-spike-lens.png`). Scrolling 60 coloured cards under 2 glass shapes gave **raster p50 1.24 ms, p90 1.63 ms**, build p50 0.15 ms (release build, 208 frames).

Production tuning: replace the single hard ring with 3 graded rings (scale 1.06 / 1.11 / 1.17, widths 3 / 3 / 3 px) so the bend ramps up toward the edge.

Decision: `GlassMode.fallback` in plan terms = the lens glass above. There is no Impeller dependency, so it should also work on Android later. Revisit real shader refraction when Flutter ships Impeller on Windows.
