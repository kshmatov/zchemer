## 1. Validate and Reconcile

- [x] 1.1 Run `openspec validate review-mode-project-view --strict` and fix any structural issues in proposal/design

## 2. Auto-Reopen on Selection

- [x] 2.1 `gui/project-panel.rkt`: workspace-picker callback checks `progress-state-project-refs` for the selected workspace
- [x] 2.2 Auto-load the retained folder + explicitly set the retained entry point (overriding `load-folder!`'s alphabetical default) when a ref exists and its folder still resolves
- [x] 2.3 Report a missing/moved folder via the results area without crashing or changing completion status, when a ref exists but its folder no longer resolves
- [x] 2.4 No change in behavior when the selected workspace has no retained ref

## 3. Automated Tests

- [x] 3.1 Selecting an already-completed workspace with a retained ref auto-populates the file list and sets the entry point to the retained filename (even when it isn't alphabetically first)
- [x] 3.2 Selecting a workspace whose retained folder no longer exists reports it in the results area and leaves completion status unchanged
- [x] 3.3 Selecting a not-yet-completed workspace (no ref) still leaves the file list empty, unchanged from `project-view`
- [x] 3.4 Run `raco test -x gui/main.rkt gui/` and confirm every test (old and new) passes

## 4. Adopt as Code Baseline

- [x] 4.1 Archive this change so review-mode-for-projects becomes part of the reference GUI
