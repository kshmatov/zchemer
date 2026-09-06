## Why

The Interpreter and Multitasking tracks' main workspaces have been fully implemented and tested since `track-workspaces` (`engine/interpreter-workspace.rkt`, `engine/multitasking-workspace.rkt`), and their track-intro lessons are playable via the inline editor since `inline-code-editor`/`review-mode-editor` — but nothing in the GUI can reach the workspaces themselves. A player who finishes both tracks' intro lessons has no way to actually attempt either track's main exercise: `advanced-project-sandboxes`' Loadable Multi-File Projects requirement and `gui-lcars`'s Dedicated Loaded-Project View requirement are both still unimplemented. This change closes that gap: load a project folder, edit its files, run/grade the entry point against the selected workspace, and persist the result. No new externally observable behavior beyond what `advanced-project-sandboxes`/`gui-lcars`/`progress-persistence` already specify, so `skip_specs: true`.

## What Changes

- Add `gui/project-panel.rkt`: the fourth app tab. A workspace picker (Interpreter / Multitasking), a "Загрузить папку" button (native folder picker) that scans the chosen folder for `.scm` files, a file list letting the player pick which file to view/edit (auto-saving edits back to disk on switching files), an entry-point selector (defaults to the alphabetically-first `.scm` file, overridable), a "Запустить" button that grades the entry-point file's current content through the selected workspace's existing grader, and a results area.
- On a passing grade: `mark-completed` + `record-project-ref` (folder path, entry-point file, pass) + `save-progress`, then refresh the Journal/Skill Tree tabs — mirroring `inline-code-editor`'s pattern.
- On a failing grade for an *already-completed* workspace (a review re-check): update the retained project reference's pass/fail status via `record-project-ref` without re-triggering completion, matching `progress-persistence`'s "pass/fail status of the player's most recent grading" wording and `game-progression`'s Idempotent Review Grading requirement.
- On a failing grade for a *not-yet-completed* workspace: show the result, but retain nothing yet (per `progress-persistence`'s "for each **completed** project-based exercise" wording — there's nothing to retain before a first pass).
- Extend `gui/app.rkt` with the project view as a fourth tab, alongside the existing three.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
(none — `advanced-project-sandboxes`, `gui-lcars`, and `progress-persistence` already specify this behavior; `skip_specs: true` is set in this change's `.openspec.yaml`)

## Impact

- Adds `gui/project-panel.rkt`. Modifies `gui/app.rkt` only (adds the fourth tab; existing tabs unchanged).
- No changes to `engine/` — this only calls `engine/interpreter-workspace.rkt`'s `grade-interpreter-submission`, `engine/multitasking-workspace.rkt`'s `grade-multitasking-submission`, and `engine/progress.rkt`'s existing `mark-completed`/`record-project-ref`/`save-progress`, all unchanged.
- Scoping decision (see `design.md`): grading only ever reads the designated entry-point file's own content — real cross-file `require`s between project files are not executed inside the sandbox in this change. Every exercise this change's two workspaces actually grade (the reference-suite programs, the shared-ledger exercise) already fits in one file, so this doesn't block playing either MVP track; true multi-file `require` support is deferred to a later change if a future exercise actually needs it.
- Out of scope: `game-progression`'s rank/achievement logic (no achievement engine exists yet); Review Mode for Loaded Projects' full reopening flow beyond what's naturally implied by this change already storing/reusing the retained project reference (a small, separate follow-on, per the plan agreed with the user).
