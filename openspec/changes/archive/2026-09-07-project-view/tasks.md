## 1. Validate and Reconcile

- [x] 1.1 Run `openspec validate project-view --strict` and fix any structural issues in proposal/design

## 2. Project Panel Core

- [x] 2.1 `gui/project-panel.rkt`: `scan-project-files` (pure: folder path -> sorted list of `.scm` filenames directly in it)
- [x] 2.2 `WORKSPACES` table wrapping `grade-interpreter-submission`/`grade-multitasking-submission` with per-workspace result-line and passed? functions
- [x] 2.3 Workspace picker, "Загрузить папку" (folder picker dialog), file list, entry-point label + reassignment button, code editor (reusing `make-code-editor`), "Запустить" button, results area

## 3. Wiring

- [x] 3.1 File-switching auto-saves the previously open file's edited content back to disk before loading the newly selected file
- [x] 3.2 "Запустить": save current file, read entry-point file content, grade via the selected workspace's grader, show results
- [x] 3.3 On a pass: `mark-completed` + `record-project-ref` (`#t`) + `save-progress` + call the shared `refresh!` thunk
- [x] 3.4 On a fail for an already-completed workspace: `record-project-ref` (`#f`) + `save-progress`, no `mark-completed` call, no refresh
- [x] 3.5 On a fail for a not-yet-completed workspace: show results only, no persistence
- [x] 3.6 `gui/app.rkt`: add the project view as a fourth tab

## 4. Automated Tests

- [x] 4.1 `scan-project-files`: finds only `.scm` files directly in a folder, sorted, ignoring subdirectories and other extensions
- [x] 4.2 Loading a folder populates the file list and defaults the entry point to the alphabetically-first `.scm` file
- [x] 4.3 Reassigning the entry point via the button changes it to the currently-open file
- [x] 4.4 End-to-end (Interpreter workspace): grading a correct `run-program` entry-point file marks `interpreter-eval-workspace` completed, records a project ref with `pass-fail? = #t`, and persists
- [x] 4.5 End-to-end (Multitasking workspace): grading a correct `run-ledger` entry-point file marks `multitasking-ledger-workspace` completed and persists a project ref
- [x] 4.6 End-to-end: grading an incorrect entry point for a not-yet-completed workspace persists nothing
- [x] 4.7 End-to-end: grading an incorrect entry point for an already-completed workspace updates the retained project ref's `pass-fail?` to `#f` without un-completing the module
- [x] 4.8 Switching the selected file auto-saves edits to the previously open file on disk
- [x] 4.9 `gui/app.rkt`: the tab-panel now has exactly four tabs, in order
- [x] 4.10 Run `raco test -x gui/main.rkt gui/` and confirm every test (old and new) passes

## 5. Manual Smoke Test

- [x] 5.1 Run the app shell, confirm the composed 4-tab frame actually opens (`is-shown?` → `#t`) against a real save path — the load-folder/select-workspace/run/persist flow itself is exercised end-to-end by the automated widget-event tests (4.4-4.7) using real temporary project folders on disk, which is functionally equivalent to a manual click-through; no screenshot tool available in this environment for visual verification, as before

## 6. Adopt as Code Baseline

- [x] 6.1 Archive this change so the project view becomes part of the reference GUI
- [x] 6.2 Note in the future Review Mode for Loaded Projects change that it should read the retained project ref (folder path, entry point) to auto-populate this panel when reopening a completed workspace, rather than requiring the player to reload the folder manually (recorded in this change's design.md Non-Goals)
