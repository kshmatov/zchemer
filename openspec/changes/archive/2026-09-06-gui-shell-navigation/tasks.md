## 1. Validate and Reconcile

- [x] 1.1 Run `openspec validate gui-shell-navigation --strict` and fix any structural issues in proposal/design
- [x] 1.2 Confirm a display connection is available in this environment (`racket -e '(require racket/gui/base)'` and a throwaway `frame%` show/close) before writing any GUI code

## 2. Shared Styling

- [x] 2.1 `gui/lcars-style.rkt`: palette constants and `status->color`

## 3. Panels

- [x] 3.1 `gui/journal-panel.rkt`: `make-journal-panel`, listing `progress-state`'s `completed-modules` in stored order
- [x] 3.2 `gui/skill-tree-panel.rkt`: `make-skill-tree-panel`, listing every `curriculum.rkt` `MODULE-TABLE` entry with its computed status/color

## 4. Application Shell

- [x] 4.1 `gui/app.rkt`: `make-app-frame`, a frame with a two-tab `tab-panel%` (Journal, Skill Tree)
- [x] 4.2 `gui/main.rkt`: runnable entry point — `load-progress`, build the frame, show it

## 5. Automated Tests

- [x] 5.1 `gui/journal-panel.rkt` tests: an empty completed-set produces an empty list; a non-empty one lists exactly those modules in stored order
- [x] 5.2 `gui/skill-tree-panel.rkt` tests: every `MODULE-TABLE` entry appears exactly once; a locked/available/completed module each gets the color `status->color` says it should
- [x] 5.3 `gui/app.rkt` test: `make-app-frame` produces a frame containing a `tab-panel%` with exactly two tabs, labeled for Journal and Skill Tree
- [x] 5.4 Run `raco test -x gui/main.rkt gui/` and confirm every test passes without a window ever becoming visible (bare `raco test gui/` also tries to run `main.rkt`'s body directly, which blocks — see this change's design.md)

## 6. Manual Smoke Test

- [x] 6.1 Actually run the app shell against a fresh progress state, confirm the window opens (`is-shown?` reports `#t`) with both tabs constructed, then close it — reported as a functional smoke test, not a visual/aesthetic verification (no screenshot tool available in this environment)

## 7. Adopt as Code Baseline

- [x] 7.1 Archive this change so `gui/` becomes the reference GUI shell
- [x] 7.2 Note in the future editor-wiring change that it should add a third tab/view rather than restructuring `gui/app.rkt`'s existing two tabs (recorded in this change's design.md)
