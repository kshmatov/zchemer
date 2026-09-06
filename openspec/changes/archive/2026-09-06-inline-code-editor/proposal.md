## Why

`gui-lcars`'s Inline Code Editor requirement is the one piece of the GUI `gui-shell-navigation` explicitly deferred: a player can currently see the Journal and Skill Tree, but there is still no way to actually write, run, or pass any of the 13 existing lessons from inside the app — `engine/lesson-grader.rkt` and `engine/progress.rkt` both exist and are tested, but nothing in the GUI calls them yet. This change adds that editor and wires it end to end: pick a lesson, write code, check it, and see the result persisted and reflected back in the Journal/Skill Tree. No new externally observable behavior beyond what `gui-lcars`/`code-evaluation`/`progress-persistence` already specify, so `skip_specs: true`.

## What Changes

- Add `gui/code-editor.rkt`: a syntax-highlighting code editor built directly on `text%`/`editor-canvas%` (per `AGENTS.md`), highlighting the base-course's taught keywords. The highlighting logic itself is a pure function (text → colored spans) separated from the widget, so it's testable without rendering.
- Add `gui/editor-panel.rkt`: the third tab — a lesson picker (the 13 lessons `base-course-content`/`track-intro-content` wrote), read-only instructional text for the selected lesson, the code editor, a "Проверить" (check) button, and a results area. Checking calls `engine/lesson-grader.rkt`'s `grade-lesson-submission`; on a full pass, it calls `engine/progress.rkt`'s `mark-completed`/`record-submission` and persists via `save-progress`.
- Extend `gui/journal-panel.rkt` and `gui/skill-tree-panel.rkt` with an in-place `refresh!` each, so completing a lesson in the editor tab updates the already-built Journal/Skill Tree panels without reconstructing the whole frame.
- Extend `gui/app.rkt` to add the editor as a third tab (per `gui-shell-navigation`'s own forward note) and wire a shared, mutable current-progress state so the editor's completions flow back into the other two tabs' `refresh!`.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
(none — `gui-lcars`'s Inline Code Editor, `code-evaluation`'s Automated Test-Based Grading, and `progress-persistence`'s retention requirements already specify this behavior; `skip_specs: true` is set in this change's `.openspec.yaml`)

## Impact

- Adds `gui/code-editor.rkt`, `gui/editor-panel.rkt`.
- Modifies `gui/journal-panel.rkt`, `gui/skill-tree-panel.rkt` (additive: a new `refresh!` export each, existing `make-*-panel` unchanged), and `gui/app.rkt` (adds the third tab and shared state).
- No changes to `engine/` — this only calls `lesson-grader.rkt`/`progress.rkt`'s existing public functions.
- Out of scope: syntax highlighting for the Interpreter/Multitasking track's advanced constructs beyond the base-course keyword set (not needed — those tracks' workspaces use the future project view, not this inline editor); Review Mode Editor (preloading a completed exercise's last submission — needs this editor to exist first, a natural immediate follow-on but still a separate change to keep this one reviewable); the loaded-project view and its own review mode.
