## Why

`gui-lcars`'s Review Mode for Loaded Projects requirement is `project-view`'s own noted follow-on: reopening a completed workspace should reopen its retained folder/entry-point automatically, rather than always requiring the player to click "Загрузить папку" and re-pick the same folder every time. `engine/progress.rkt`'s `record-project-ref` already retains exactly what's needed (folder path, entry-point file, pass/fail) since `project-view`; no engine change is needed. `skip_specs: true`, since no externally observable behavior beyond what `gui-lcars`/`progress-persistence` already specify is added.

## What Changes

- `gui/project-panel.rkt`'s workspace picker gains a callback: selecting a workspace that is already completed and has a retained project ref auto-loads that folder (scanning its files, selecting the retained entry point) instead of leaving the file list empty until the player clicks "Загрузить папку" — per `gui-lcars`'s "reopens against the exercise's retained folder path and entry-point file" wording.
- If the retained folder path no longer resolves to an existing directory, the panel reports this in the results area rather than crashing, and leaves the player able to load a different folder manually — per `progress-persistence`'s "Referenced project folder is missing on review" scenario. Nothing about the exercise's completion status changes.
- Selecting a workspace with no retained project ref (not yet completed) behaves exactly as before (empty file list, waiting for "Загрузить папку").

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
(none — `gui-lcars` and `progress-persistence` already specify this; `skip_specs: true` is set in this change's `.openspec.yaml`)

## Impact

- Modifies `gui/project-panel.rkt` only (additive: a workspace-picker callback; the existing "Загрузить папку"/file-list/entry-point/run flow is unchanged and still used for a workspace with no retained ref, or when the player wants a different folder).
- No changes to `engine/`.
