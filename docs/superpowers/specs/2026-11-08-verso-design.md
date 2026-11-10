# Verso — design spec

Date: 2026-11-08 · Status: approved in chat, pending written review

## 1. Purpose

Verso is a personal tracker for building apps. It records what each version of an app contains and how far along it is. It is like Todoist or Notion, but organised around **versions and milestones** and shown visually. There is one user (the owner), and the projects are the owner's own apps (Tandem, Kobel, Leestn…).

Success means:
- The owner can lay out a project as version columns from left to right and fill each with feature items of any length.
- Ticking off work feels instant and satisfying.
- A timeline shows the dated plan and can be zoomed from days to years.
- It looks like a modern iOS app with Liquid Glass, in light and dark, and stays smooth (120 Hz) with hundreds of items.

Platform: **Windows first** (Flutter desktop). Android follows later from the same Flutter codebase. Cloudflare Worker sync comes later. This build only makes the data ready for sync.

## 2. Out of scope (v1.0.0)

- Cloud sync, the Cloudflare Worker, and the Android build.
- Multiple users, sharing, comments, notifications and reminders.

## 3. Tech stack

- Flutter 3.44 (installed at `%USERPROFILE%\Develop\flutter`), Windows desktop target.
- **Drift** (SQLite) for storage. Reactive queries drive the UI.
- **Riverpod** for app state and dependency wiring.
- `window_manager` for a frameless window with a custom glass title bar.
- `liquid_glass_renderer` (or an in-house fragment shader) for Liquid Glass. Feasibility depends on Impeller backdrop shaders on Windows; see §7.
- Bundled Inter font as the SF Pro stand-in.

Location: `D:\RandD\Windows Apps\Verso\v1.0.0\` (git repo, branch `main`). Later versions go into new sibling version folders.

## 4. Data model (SQLite via Drift)

Every table has `id TEXT` (UUID v4, primary key), `createdAt`, `updatedAt` (UTC epoch ms) and `deleted BOOL`. Rows are soft-deleted and filtered out of every query. Undo restores a row by clearing the flag. A later sync sends rows whose `updatedAt` is newer than the last sync, with last-write-wins per row.

Ordering uses a `sortKey TEXT`, a fractional index string (in the style of `fractional_indexing`). Moving an item rewrites only that item's key.

| Table | Fields beyond the common ones |
|---|---|
| `projects` | name, color (ARGB int), icon (optional symbol name), sortKey, archived |
| `versions` | projectId, name (e.g. "v1.2"), status (`planned`/`active`/`released`), color, startDate?, targetDate?, releasedDate?, description?, sortKey |
| `features` | versionId, title (unbounded text), done, doneAt?, priority (0 none, 1 low, 2 med, 3 high), color?, notes? (unbounded text), startDate?, endDate?, sortKey |
| `subitems` | featureId, title, done, sortKey |
| `milestones` | projectId, title, date, kind (`release`/`launch`/`deadline`/`other`), color? |
| `tags` | projectId, name, color, sortKey |
| `feature_tags` | featureId, tagId (composite key, but it still carries the common columns so it can sync) |
| `attachments` | featureId, fileName (stored name), originalName, width, height, sortKey |

- Image files are copied into `%APPDATA%\Verso\attachments\<uuid>.<ext>`, with a 512 px thumbnail cached beside each one (`<uuid>.thumb.png`).
- A new project starts with default tags: Feature, Fix, UI, Backend, Polish.
- Version progress = done features ÷ live features. Project progress = done ÷ live across all versions.

## 5. Screens

### 5.1 Shell
- **Custom title bar (glass):** app mark, then window buttons on the right. The whole bar can be dragged to move the window.
- **Sidebar (glass, ~240 px, collapsible):** project list (color dot, name, small progress ring), "+ New project", and Settings at the bottom. Drag to reorder projects.
- **Toolbar (glass):** project title (large, bold, iOS style), a **Board | Timeline** segmented control (the glass pill morphs and slides between segments), a search field (filters features by text), a filter menu (tag, priority, done/undone), and a theme toggle (System / Light / Dark).

### 5.2 Board view
- Columns scroll sideways, one per version, ordered by sortKey, with a final "+ Version" column. Shift+wheel or trackpad scrolls horizontally, with momentum.
- **Column header:** version name, status pill, date range, a progress bar in the version color, and a "⋯" menu (rename, color, dates, status, delete).
- **Feature card:** a left accent bar in the item color (or the first tag's color), a checkbox, a title that wraps freely, then a meta row with tag chips, a priority flag, a sub-items counter "2/5", and paperclip/notes indicators. Clicking a card expands it in place to show notes, the sub-item checklist and attachment thumbnails. Double-click on the title or press F2 to edit inline.
- **Adding:** an "+ Add feature" row at the bottom of each column. Enter adds and starts the next item, Esc stops.
- **Done items:** a checked item animates out of the unchecked group into a collapsible "Done (n)" group at the bottom of the column.
- **Drag and drop:** drag a card within a column or to another column. Neighbors slide aside with a spring animation and the dragged card lifts with a shadow. Columns can be reordered by dragging their header.
- **Images:** drop image files onto a card, or press Ctrl+V while it is expanded. Clicking a thumbnail opens a lightbox with zoom.

### 5.3 Timeline view
- One custom-painted canvas that draws only the visible range. The date axis runs along the top with labels that adapt to zoom (days → weeks → months → quarters → years).
- **Rows:** a milestone row at the top (diamonds with labels), then one lane per version. Each lane holds the version bar (start → target, filled in proportion to its progress) and the version's dated features as thinner sub-bars below it.
- **Zoom:** Ctrl+wheel or pinch, anchored at the cursor, smoothly animated. Buttons: zoom in/out, "Today", and "Fit project".
- **Pan:** drag the empty background, or use the wheel / Shift+wheel.
- **Editing:** drag a bar to move it, or drag its ends to change the dates. Double-click empty space in a lane to create a dated feature there. Click a bar for an info popover. A dashed vertical line marks today.
- Versions without dates are listed in a muted "Undated" tray at the bottom with a hint to set dates.

### 5.4 Editors
- Version, milestone, project and tag editors open as glass popovers or sheets. A color picker offers the palette swatches and a custom HSV picker, and every colorable thing uses it.
- Settings: theme, reduce motion (also follows the Windows setting), and data folder location (read-only display plus an "Open folder" button).

## 6. Visual language

iOS design language: generous spacing, continuous rounded corners (squircle-like, radius 12–20), large bold titles, SF-style hierarchy, quiet separators.

### 6.1 Light palette (from the reference "theme-based view" image)
| Role | Value |
|---|---|
| Background | gradient `#EEF2F8` → `#E9EBF7` |
| Card surface | white @ 72% with a 1 px `#FFFFFF` inner rim, soft shadow |
| Text / secondary | `#1E2A3B` / `#6B7A90` |
| Separators | `#C9D3E1` |
| Blue (primary accent) | `#3B82D6` on `#D7E6F6` |
| Amber | `#E3AE36` on `#FAEFD0` |
| Coral | `#E5675A` on `#F9DCDA` |
| Slate | `#3E4C68` on `#DDE3EC` |

### 6.2 Dark palette (black with warm accents)
| Role | Value |
|---|---|
| Background | `#000000` with a very faint warm vignette (`#0E0B08` at the edges) |
| Card surface | `#15120F` with a 1 px warm rim `#FFFFFF` @ 8% |
| Raised surface | `#1E1A16` |
| Text / secondary | `#F4EEE6` / `#A39886` |
| Separators | `#2A251F` |
| Amber (primary accent) | `#F5A524` on `#3A2A0E` |
| Coral | `#FF7A59` on `#3D1C14` |
| Rose | `#F2668B` on `#3B1621` |
| Sand | `#E2C08D` on `#2F271B` |

User colors (projects, versions, tags, items) are stored once. Each theme maps the four palette slots to its own colors (light Blue/Amber/Coral/Slate ↔ dark Amber/Coral/Rose/Sand). Custom colors are used as-is in both themes.

### 6.3 Liquid Glass
Liquid Glass, not frosted glass: mostly clear, refracting and magnifying the content behind it near the edges, with a bright rim highlight, only a light softening, and a subtle tint. It is used on **chrome and controls only**: title bar, sidebar, toolbar, the segmented control, floating buttons, popovers, sheets and the drag ghost. Feature cards are plain, light surfaces with no backdrop sampling, which keeps scrolling cheap.

- Neighbouring glass controls (toolbar buttons, the segmented pill) merge like droplets when close together. That uses the renderer's blending if available.
- **Fallback** if backdrop shaders are unavailable on Windows: a stack of an inner lens gradient, a specular rim stroke, a light tint and at most a σ≈2 blur on large surfaces only.

### 6.4 Motion
- Springs everywhere (iOS-like: response ~0.35 s, damping ~0.85). Add = grow + fade from 0.96 scale. Delete = collapse height + slide/fade out. Reorder = neighbours glide. Check = checkbox pop (scale 0.8 → 1.1 → 1) with a stroke-drawn tick, then the item slides into the Done group.
- Zoom and pan on the timeline are interpolated per frame, never in jumps.
- Only transforms and opacity animate. List items are keyed and wrapped in RepaintBoundary, and there are no layout-thrashing animations.
- Reduce motion turns springs into short crossfades.

## 7. Feasibility test (first build step) — result: lens glass, see `docs/glass-spike.md`

Before the UI is built, a throwaway test checks whether `liquid_glass_renderer` / `ImageFilter.shader` on a backdrop renders on this PC (Windows, Intel UHD + RTX 3060) with Impeller enabled, and at what frame cost.
- **Pass:** real refraction glass.
- **Fail:** the fallback in §6.3.

The result is recorded in this spec's folder as `docs/glass-spike.md`.

## 8. Undo and safety
- Undo stack (Ctrl+Z / Ctrl+Shift+Z) for create, delete, move, check, edit and date changes, held in memory for the session.
- Deleting shows a toast with Undo for 5 s. Deleting a version or project asks for confirmation and shows how many features it contains.

## 9. Keyboard
Ctrl+N new feature in the focused column · Ctrl+Shift+N new version · Space toggle the focused item · F2 rename · Del delete · Ctrl+F search · Ctrl+1 / Ctrl+2 Board / Timeline · Ctrl+wheel zoom the timeline.

## 10. Testing and verification
- Unit tests: fractional sort keys, move between versions, soft delete and undo, progress math, timeline date ↔ x mapping at each zoom level.
- Widget tests: adding, checking and reordering a feature on the board.
- Manual run on Windows: screenshots of the board and timeline in light and dark, plus a scroll/zoom smoothness check with a seeded project of ~300 features (Flutter performance overlay).

## 11. Amendment (2026-11-09): Concept stage and delaying features

Requested by the owner during the build.

### 11.1 Concept stage
- Every project has exactly one **Concept** stage, the first step of the project, where ideas are listed as concept features before they're assigned to a build.
- Storage: it is a row in `versions` with a new column `kind` (`concept` | `release`, default `release`), name "Concept", created together with the project. It always sorts first: it can't be moved or deleted, and other versions can't be placed before it.
- **Board:** the Concept column is always leftmost. It has a lightbulb glyph, a dashed glass outline instead of a solid header, and no status pill. Concept cards have every feature capability (tags, notes, sub-items, images, color). A concept card's menu has "Move to build →" (choose a version or "New version").
- **Timeline:** the Concept stage is the first lane. Like any version it can have a date range (the concept design period), drawn as a bar with a hatched fill. Concept features with their own dates show as sub-bars.
- **Progress:** concept features are excluded from project progress and from version progress counts. The Concept column header shows a count ("12 ideas") instead of a progress bar.

### 11.2 Delaying a feature to a later build
- Each unfinished feature in a release version has a **Delay** action (card menu, or Ctrl+D):
  - "Next version" (default) moves it to the top of the next release version by sortKey.
  - "Choose version…" lists later release versions only.
  - "New version" creates a version after the last one, auto-named by bumping the last numeric part (`v1.2` → `v1.3`, `v2` → `v3`, otherwise "`<name>` next"), then moves the feature there.
  - Delaying from the last version offers only "New version" and "Choose…" (when none exist).
- New `features` columns: `delayedFromVersionId TEXT?` (the version it was in before its **first** delay; this keeps the original commitment) and `delayCount INT` (default 0, +1 per delay).
- The card shows a coral chip "Delayed from v1.1" (or "Delayed ×3 · from v1.1" when the count is above 1). When the feature is checked done the chip stays as history, muted.
- Moving a feature backwards by drag (to an earlier version) is a plain move: it doesn't count as a delay and doesn't clear the history. Dragging forwards is also a plain move; only the Delay action records a delay.
- Delay is undoable, like any move.
- Timeline: a delayed feature's sub-bar has a small coral notch at its start, and its info popover shows the delay history.
- The version column header shows "n delayed in" when it has features delayed into it.

## 12. Amendment (2026-11-10): copy, environments, Google sign-in

Requested by the owner after the v1 build.

### 12.1 Copy a version
Each column header has a copy button. It puts the version's features on the clipboard as a Markdown checklist:
the heading "name (dates) — done/total done", open features first, then done ones, with steps indented. (Built.)

### 12.2 Environments (folders)
- An **environment** is where development happens (Claude Code, ChatGPT, Astra…). It has a name, an icon and a
  color. New table `environments` (common columns + name, icon, color, colorCustom, sortKey). `icon` is a built-in glyph key (e.g.
  `terminal`, `sparkle`, `robot`, `code`, `bolt`, `chat`, `cloud`, `rocket`) or `file:<name>` for a custom image copied into
  `%APPDATA%\Verso\icons\`.
- Every version (Concept included) gets `environmentId`. A project appears in each environment folder that holds
  any of its versions; in that folder it shows only the versions of that environment (a **segment**).
- **Breaking:** changing a version's environment moves that version **and every later version** to the new environment
  ("break from that point and continue"). It is undoable. Earlier versions stay where they were.
- **Sidebar:** environment folders (icon, name, project count, collapsible) containing projects. A project selection is
  (project, environment). Right-click a folder: Rename, Icon & color, Delete (only when empty). "+ New environment". New
  projects are created in the folder they are added from; their Concept stage and first versions use that environment.
- **Board / timeline:** they show the selected segment's versions. Edge stubs link to the neighbouring segments:
  "← v1.0–v1.1 in ChatGPT", "Continues in Claude Code →". New versions are created in the segment's environment.
  Delay/Move menus still list all versions of the project (the menu shows each version's environment icon).
- **Migration:** schema v2 creates the table, makes a default environment "My apps" and assigns every existing version to it.

### 12.3 Google sign-in
- Desktop OAuth with the system browser: loopback redirect on `http://127.0.0.1:<random port>`, PKCE (S256), state check,
  scopes `openid email profile`. The token exchange goes to `https://oauth2.googleapis.com/token`. The account (name, email, picture)
  is read from the ID token.
- The client ID and secret come from a "Desktop app" OAuth client in the owner's Google Cloud Console. They are set in Settings, or baked in at build
  time with `--dart-define=GOOGLE_CLIENT_ID=… --dart-define=GOOGLE_CLIENT_SECRET=…`. A desktop client secret is not confidential by
  Google's own definition.
- The refresh token is stored with the OS secure store (Windows Credential Manager via `flutter_secure_storage`). On launch the
  session is restored silently. Sign out revokes the token (`https://oauth2.googleapis.com/revoke`) and clears it.
- **Sidebar footer:** "Sign in with Google" when signed out (it opens Settings with a hint if no client ID is set). When signed in, an avatar
  and name, with a menu holding the email and Sign out.
- Sign-in identifies the owner for the later Cloudflare sync (the Worker will verify the Google ID token). Nothing is uploaded in this round.

## 13. Amendment (2026-11-10): Cloudflare sync (`verso-api`)

The owner asked for this ("use my same Cloudflare account, create a new worker for it and work things out").

### 13.1 Server
- A new Worker, **`verso-api`**, in `D:\RandD\Windows Apps\Verso\v1.0.0\backend\`. It uses TypeScript and wrangler, like tandem-api, kobel-api and leestn-api,
  on the owner's account. It has a D1 database, `verso`. R2 is not enabled on the account, so images are stored in D1 in 1 MB chunks.
- **Auth:** every request carries `Authorization: Bearer <Google ID token>`. The Worker verifies the RS256 signature against
  Google's JWKS, the `iss`, `exp`, and that `aud` is in `GOOGLE_CLIENT_ID` (a comma list, which will hold the Verso Desktop client ID). The user key is `sub`.
  It is a **single-owner server**: the first `sub` that syncs is recorded as the owner, and every other account gets 403.
- **Storage:** one generic table holds every row: `rows(tbl, id, updated_at, deleted, data TEXT(JSON), seq)`, primary key `(tbl, id)`.
  `seq` comes from a server counter that increases on every accepted write. Blobs live in `blobs(name, chunk, bytes)` plus `blob_meta(name, size, chunks)`.
- **Endpoints:**
  - `POST /v1/sync {cursor, rows:[{t,id,u,d,data}]}`.
    - Push: each row replaces the stored one only if its `u` (updatedAt) is greater (**last write wins**; on a tie the stored row stays). Each accepted row gets a new `seq`.
    - Pull: it returns up to 500 rows with `seq > cursor`, plus the new `cursor` and `more`.
  - `PUT /v1/blobs/:name` (raw bytes, up to 40 MB) and `GET /v1/blobs/:name`. `HEAD` tells whether a blob exists.
  - `GET /v1/health`.
- **Tables synced:** projects, environments, versions, features, subitems, milestones, tags, feature_tags and attachments
  (rows; the image bytes go through the blob endpoints). Soft deletes travel as ordinary rows with `deleted = true`.

### 13.2 Client
- **`SyncService`** (`lib/sync/`) runs only while signed in and a server URL is set. The default URL is the deployed `verso-api` URL; it can be changed in Settings.
- **Push:** every row whose `updatedAt` is later than `lastPushedAt` (kept in `settings.json`). **Pull:** pages from `cursor` until `more` is false.
  Each pulled row is applied only if its `updatedAt` is newer than the local copy. It is written raw, keeping its `updatedAt`.
- **Images:** before pushing an attachment row, upload its file if the server lacks it. Download missing files after a pull.
- **When it syncs:** after sign-in, at launch, 3 s after any local change (debounced on drift table updates), every 2 minutes while open, and from a "Sync now" button.
- **UI:** the account area shows "Synced · 2 min ago", "Syncing…" or "Sync failed: …" (tap to retry). Settings shows the server URL.
- **Offline:** everything keeps working locally, and a failed sync just retries later.
- **Note:** clock skew between devices only affects which concurrent edit wins; pulls are ordered by the server's `seq`, not by clocks.

### 13.3 Owner action needed
For sign-in and sync to work, the owner creates a Google OAuth client of type **Desktop app** (in any Google Cloud project, for example the one
Tandem uses), pastes its ID and secret into Verso's Settings, and gives the client ID to be added to the Worker's `GOOGLE_CLIENT_ID`.
Android (later) will add its own client ID to the same list.
