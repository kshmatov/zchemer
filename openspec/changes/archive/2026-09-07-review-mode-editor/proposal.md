## Why

`gui-lcars`'s Review Mode Editor requirement is `inline-code-editor`'s own noted follow-on: reopening a completed exercise should preload the player's last successful submission (with a way to clear it and start over), rather than always starting blank as the editor currently does. `engine/progress.rkt`'s `record-submission` already always replaces the retained source regardless of whether it's a first pass or a review resubmission — exactly matching `progress-persistence`'s "replaces during review" requirement — so no engine change is needed; this is purely GUI wiring. `skip_specs: true`, since no externally observable behavior beyond what `gui-lcars`/`progress-persistence` already specify is added.

## What Changes

- `gui/editor-panel.rkt`'s `load-selected!` now preloads the code editor with `progress-state`'s retained `last-submissions` entry for the selected lesson, when that lesson's module id is already completed and has one; otherwise it still starts blank (unchanged for a not-yet-completed lesson).
- Add a "Очистить" (clear) button next to "Проверить", which empties the code editor so the player can redo a reviewed exercise from scratch, per `gui-lcars`'s second Review Mode Editor scenario. The exercise prompt (the read-only instructional text) is untouched by clearing.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
(none — `gui-lcars`'s Review Mode Editor and `progress-persistence`'s submission-retention requirements already specify this; `skip_specs: true` is set in this change's `.openspec.yaml`)

## Impact

- Modifies `gui/editor-panel.rkt` only (additive: preload-on-select behavior and a new button; the existing "Проверить" check/grade/persist logic is unchanged, since `mark-completed`/`record-submission` were already idempotent-safe and always-replace respectively).
- No changes to `engine/`.
- Out of scope: `game-progression`'s Retroactive Achievement Recognition During Review (no achievement engine exists yet to retroactively recognize anything against); Review Mode for Loaded Projects (needs the project view, which doesn't exist yet).
