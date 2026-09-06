## 1. Validate and Reconcile

- [x] 1.1 Run `openspec validate inline-code-editor --strict` and fix any structural issues in proposal/design

## 2. Syntax-Highlighting Code Editor

- [x] 2.1 `gui/code-editor.rkt`: implement `keyword-positions` (pure) covering every base-course-taught keyword
- [x] 2.2 Implement the `text%` subclass applying `keyword-positions` via `change-style` on `after-insert`/`after-delete`
- [x] 2.3 Implement `make-code-editor` (parent -> `editor-canvas%` wrapping the subclass)

## 3. Editor Panel

- [x] 3.1 `gui/editor-panel.rkt`: `LESSON-DIRS` mapping all 13 lesson module ids to their `content/` directories
- [x] 3.2 Lesson picker (list-box), loading and displaying the selected lesson's `lesson.md` instructional text read-only
- [x] 3.3 Wire the "Проверить" button to `grade-lesson-submission`, showing per-entry pass/fail (or blocked-symbols) in a results area
- [x] 3.4 On a full pass: `mark-completed` + `record-submission` on the shared progress box, `save-progress`, then call the shared `refresh!` thunk

## 4. Refresh-in-Place for Journal and Skill Tree

- [x] 4.1 `gui/journal-panel.rkt`: extract row-building into a shared helper; add `refresh-journal-panel!`
- [x] 4.2 `gui/skill-tree-panel.rkt`: extract row-building into a shared helper; add `refresh-skill-tree-panel!`
- [x] 4.3 `gui/app.rkt`: hold a `(box progress-state)` + `save-path`, add the editor as a third tab, pass both other panels' handles and a combined `refresh!` thunk into the editor panel

## 5. Automated Tests

- [x] 5.1 `keyword-positions`: matches whole-word keyword occurrences only (not `defined-thing` for `define`), across multiple keywords in one buffer
- [x] 5.2 `refresh-journal-panel!`/`refresh-skill-tree-panel!`: after calling with a new completed-set, the panel's rows reflect exactly that set (no leftover rows from the previous call)
- [x] 5.3 End-to-end: grading a correct submission for a sample lesson through the editor panel's check action results in that lesson's module id appearing in the progress box's `completed-modules` and in a saved file readable by `load-progress`
- [x] 5.4 End-to-end: grading an incorrect submission does not call `mark-completed`/`save-progress` at all
- [x] 5.5 Run `raco test -x gui/main.rkt gui/` and confirm every test (old and new) passes without a window ever becoming visible

## 6. Manual Smoke Test

- [x] 6.1 Run the app shell, select a lesson in the editor tab, type a correct solution, click Проверить, confirm the result area shows a pass and the Skill Tree tab now shows that module as completed — report as a functional smoke test only (no screenshot tool in this environment, as before). Done via the automated end-to-end widget-event tests (5.3/5.4, which simulate the real click/select flow) plus a separate manual run confirming the composed 3-tab frame actually opens (`is-shown?` → `#t`).

## 7. Adopt as Code Baseline

- [x] 7.1 Archive this change so the editor tab becomes part of the reference GUI
- [x] 7.2 Note in the future Review Mode Editor change that it should preload `progress-state`'s `last-submissions` entry for the selected lesson into this editor rather than always starting blank (recorded here; `load-selected!` currently always starts the code editor blank, per this change's Non-Goals)
