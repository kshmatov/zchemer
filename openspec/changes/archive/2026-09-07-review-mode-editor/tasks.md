## 1. Validate and Reconcile

- [x] 1.1 Run `openspec validate review-mode-editor --strict` and fix any structural issues in proposal/design

## 2. Preload and Clear

- [x] 2.1 `gui/editor-panel.rkt`: `load-selected!` preloads the retained `last-submissions` entry when the selected lesson's module id is in `completed-modules`
- [x] 2.2 Add the "Очистить" button, unconditionally erasing the code editor

## 3. Automated Tests

- [x] 3.1 Selecting a completed lesson with a retained submission preloads exactly that source into the code editor
- [x] 3.2 Selecting a not-yet-completed lesson still starts blank (no regression from `inline-code-editor`)
- [x] 3.3 Clicking "Очистить" empties the code editor for a lesson that was preloaded
- [x] 3.4 End-to-end: reviewing a completed lesson, clearing, submitting a different correct solution, and checking replaces the retained submission in the progress box/save file with the new one
- [x] 3.5 Run `raco test -x gui/main.rkt gui/` and confirm every test (old and new) passes

## 4. Adopt as Code Baseline

- [x] 4.1 Archive this change so review-mode preload/clear becomes part of the reference editor
