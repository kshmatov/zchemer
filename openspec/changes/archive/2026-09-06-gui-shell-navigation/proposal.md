## Why

`gui-lcars` already specifies the whole interface in detail, but no GUI code exists at all yet — every prior change built the engine (`engine/curriculum.rkt`, `engine/progress.rkt`, the two workspaces, the lesson grader) with no way for a player to see any of it. This change is the first slice of the GUI: a native application shell with the two navigation views `gui-lcars` specifies as primary/secondary (Journal, Skill Tree), wiring `curriculum.rkt`'s module statuses and `progress.rkt`'s saved completed-set together for the first time. It does not yet implement the inline editor, the loaded-project view, or review mode — those are larger, separate slices. No new externally observable behavior beyond what `gui-lcars` already specifies, so `skip_specs: true`.

## What Changes

- Add `gui/lcars-style.rkt`: a small shared LCARS color palette and a `status->color` mapping (locked/available/completed), used consistently by both views, per `gui-lcars`'s Consistent LCARS Visual Styling requirement.
- Add `gui/journal-panel.rkt`: builds the Journal panel — a chronological list of completed modules, styled per the palette — per `gui-lcars`'s Journal as Primary Navigation requirement (selecting an entry to reopen it in review mode is out of scope here; nothing to reopen into yet).
- Add `gui/skill-tree-panel.rkt`: builds the Skill Tree panel — every module from `engine/curriculum.rkt`'s `MODULE-TABLE`, color-coded by its computed status (locked/available/completed) — per `gui-lcars`'s Skill Tree as Secondary Navigation requirement.
- Add `gui/app.rkt`: the native application shell (`racket/gui`, no browser/webview) — a frame with a two-tab `tab-panel%` (Journal primary, Skill Tree secondary), loading `progress.rkt`'s saved state at startup via `load-progress`.
- Add `gui/main.rkt`: the runnable entry point.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
(none — `gui-lcars` already specifies all of this; `skip_specs: true` is set in this change's `.openspec.yaml`)

## Impact

- Adds `gui/` (the project's first GUI code) alongside the existing `engine/`.
- No changes to `engine/` — this change only reads `curriculum.rkt`'s `MODULE-TABLE`/`module-status` and `progress.rkt`'s `load-progress`/`progress-state`, it doesn't modify either.
- Out of scope, left for future changes: the inline code editor (`gui-lcars`'s Inline Code Editor requirement, needs wiring to `engine/lesson-grader.rkt`), the loaded-project view (needs `advanced-project-sandboxes`' Loadable Multi-File Projects, not yet built), and both Review Mode requirements (need the editor/project view to exist first).
- Testing note: `racket/gui` widget construction needs a display connection. This environment has one (verified: `(require racket/gui/base)` loads and a test frame shows without error), but there is no screenshot utility available in this environment, so visual/aesthetic verification of the LCARS styling is not possible here beyond structural checks (correct widgets, correct computed colors/labels) and a manual open-and-close smoke test — this will be reported honestly rather than claimed as visually verified.
