## Why

`progress-persistence` already fully specifies how a player's progress must be saved (local, account-free, human-readable, resilient to a missing/corrupt file, independent per track, retaining a lesson's last successful submission and a workspace's project reference) — but nothing implements it yet. `engine/curriculum.rkt` takes a completed-set as a plain input with no way to obtain one across a relaunch, and neither `lesson-grader.rkt` nor the two workspaces retain anything after grading a submission. This change implements the save/load module `progress-persistence` already specifies in full — no new externally observable behavior, so `skip_specs: true`.

## What Changes

- Add `engine/progress.rkt`: an immutable `progress-state` (completed module ids, per-lesson last-successful-submission source, per-workspace project reference) with pure update functions (`mark-completed`, `record-submission`, `record-project-ref`), plus `load-progress`/`save-progress` reading and writing a single human-readable S-expression file.
- `load-progress` returns a fresh, empty state — rather than raising — when the save file is missing or fails to parse, per the Resilience requirement.
- Automated `rackunit` tests covering a full save/relaunch round-trip, missing-file and corrupt-file resilience, independent per-track completion state, and a later successful resubmission replacing a lesson's retained submission.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
(none — `progress-persistence` already specifies all of this behavior; `skip_specs: true` is set in this change's `.openspec.yaml`)

## Impact

- Adds `engine/progress.rkt`.
- No content changes.
- Out of scope: wiring this module's `completed-set` into `engine/curriculum.rkt`'s queries, or into the GUI's journal/skill-tree views (`gui-lcars`) — this change only builds the save/load module itself; a future change connects it to the rest of the engine and to the GUI.
- Out of scope: the actual "load a project folder" mechanism (`advanced-project-sandboxes`' Loadable Multi-File Projects) that a project reference would eventually point at — this change only defines and persists the reference shape (folder path, entry-point file, pass/fail), not the loading itself.
