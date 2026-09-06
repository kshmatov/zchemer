## Context

See `proposal.md`. Builds on `engine/interpreter-workspace.rkt` (`grade-interpreter-submission`), `engine/multitasking-workspace.rkt` (`grade-multitasking-submission`), `engine/progress.rkt` (`mark-completed`, `record-project-ref`, `save-progress`), and `gui/code-editor.rkt` (`make-code-editor`) — all already archived and tested, none changed by this change. Also reuses `gui/app.rkt`'s existing shared `(box progress-state)` + `save-path` + `refresh!` pattern from `inline-code-editor`.

## Goals / Non-Goals

**Goals:**
- Load a real folder of `.scm` files, list them, edit them, designate an entry point.
- Grade the entry point against whichever of the two MVP workspaces the player selects, using the existing graders unchanged.
- Persist a passing result as a project reference (folder, entry point, pass/fail), and keep that reference's pass/fail status current on later review re-checks, per `progress-persistence`.

**Non-Goals:**
- Executing real cross-file `require`s between project files inside the sandbox — grading only ever reads the entry-point file's own content as a self-contained submission (see Decisions). Both workspaces' actual exercises fit in one file, so this isn't a real limitation for the current MVP content.
- Any achievement/rank logic.
- A full "reopen exactly where you left off" review flow beyond reusing the retained folder path/entry-point on... (deferred: this change stores the reference; a dedicated follow-on change decides how re-opening auto-populates the project view from it, kept separate per the user's agreed plan).

## Decisions

### Grading reads only the entry-point file's content, not a real multi-file sandbox
Building genuine sandboxed cross-file `require` support (a custom module-name resolver restricted to the project folder, `racket/sandbox`'s `make-module-evaluator`, etc.) is substantial additional engineering with no exercise in this project that actually needs it: the Interpreter reference suite grades a `run-program` procedure, and the Multitasking ledger exercise grades `run-ledger` — both single self-contained definitions. This change lets a player edit and view multiple files (satisfying "list the project's files and let them be edited"), but "run" always (re-)reads the current entry-point file's own text and passes it to the existing grader exactly as the inline editor already does for lessons. If a future exercise genuinely needs multi-file composition, that's a follow-up to `engine/sandbox.rkt`, not this change.

### File switching auto-saves the previously-open file
Since there's no separate persistent "editor state per file," switching the file-list selection writes the current editor buffer back to whatever file was open before loading the newly-selected one. This mirrors ordinary text-editor behavior and avoids a more complex per-file dirty-tracking/prompt-to-save system for this first slice.

### Entry point: defaults to the alphabetically-first `.scm` file, explicitly reassignable
`advanced-project-sandboxes`' own wording ("recognizes **or lets the player select** an entry point file") only requires one or the other; this change does both cheaply: auto-pick the first `.scm` file alphabetically as a sensible default, shown in a label, with a "Назначить точкой входа" button that reassigns it to whichever file is currently open in the editor.

### Project-reference persistence distinguishes "not yet completed" from "completed, this review-check failed"
- First pass → `mark-completed` + `record-project-ref` with `pass-fail? = #t` + `save-progress` + refresh Journal/Skill Tree (same shape as `inline-code-editor`'s lesson flow).
- A later failing re-check on an *already-completed* workspace → `record-project-ref` with `pass-fail? = #f` + `save-progress`, but no `mark-completed` (already completed; `mark-completed` is idempotent regardless) and no tab refresh (nothing the other tabs display changed).
- A failing check on a *not-yet-completed* workspace → show the result only; nothing persisted, since `progress-persistence`'s Project-Based Exercise Reference Retained requirement is scoped to "each **completed** project-based exercise" — there's nothing to retain before a first pass.

This distinction matters because `progress-persistence`'s spec explicitly wants the reference's pass/fail field to reflect "the player's most recent grading" (which can legitimately be a failure during review), unlike the lesson editor's `last-submissions`, which specifically retains only the last *successful* source. Reusing the lesson editor's "only ever act on success" logic verbatim here would be a silent under-implementation of this requirement.

### Workspace picker maps directly to the two existing graders
```racket
WORKSPACES : (list (list module-id label grade-fn report-lines-fn report-passed?-fn) ...)
```
One entry for `interpreter-eval-workspace` (wrapping `grade-interpreter-submission`) and one for `multitasking-ledger-workspace` (wrapping `grade-multitasking-submission`) — their report structs differ (`interpreter-grade-report` vs `multitasking-grade-report`), so each entry carries its own small "turn this report into result lines" and "did this report pass" functions rather than trying to unify the two report shapes into one.

## Risks / Trade-offs

- [No true multi-file `require` support means a hypothetical future exercise requiring genuine file-splitting can't be graded yet] → Acceptable now (documented as a Non-Goal); revisit `engine/sandbox.rkt` if and when such an exercise is actually designed.
- [Auto-save-on-switch means there's no "discard my edits to this file" option] → Acceptable for a first slice; the retained project reference (folder path) means the player's actual files on disk are the source of truth regardless, matching `progress-persistence`'s own reasoning for not copying project source into the save file.

## Open Questions

(none)
