## 1. Validate and Reconcile

- [x] 1.1 Run `openspec validate progress-persistence-engine --strict` and fix any structural issues in proposal/design

## 2. Core State and Updates

- [x] 2.1 `engine/progress.rkt`: define `progress-state` and `fresh-progress`
- [x] 2.2 Implement `mark-completed`, `record-submission`, `record-project-ref` as pure updates

## 3. Save/Load

- [x] 3.1 Implement `save-progress` (write the single-S-expression alist format from `design.md`)
- [x] 3.2 Implement `load-progress`, returning `(fresh-progress)` on a missing file
- [x] 3.3 Implement `load-progress`'s corrupt-file path, returning `(fresh-progress)` when `read` fails rather than raising

## 4. Automated Tests

- [x] 4.1 Full round-trip: mark modules completed, record a submission and a project ref, save, load, confirm the loaded state equals the original
- [x] 4.2 Missing-file resilience: `load-progress` on a nonexistent path returns `(fresh-progress)`
- [x] 4.3 Corrupt-file resilience: `load-progress` on a file containing unparseable text returns `(fresh-progress)` instead of raising
- [x] 4.4 Independent per-track state: complete some Interpreter-track modules without touching Multitasking; confirm each track's completion state (and, separately, retained submissions) reflects only that track
- [x] 4.5 Submission replacement: `record-submission` called twice for the same module id retains only the second (most recent) source
- [x] 4.6 Run `raco test engine/` and confirm every test (old and new) passes

## 5. Adopt as Code Baseline

- [x] 5.1 Archive this change so `engine/progress.rkt` becomes the reference persistence implementation
- [x] 5.2 Note in the future GUI/curriculum-wiring change that it should call `load-progress` at launch and `save-progress` after each `mark-completed`/`record-submission`/`record-project-ref`, and pass `progress-state-completed-modules` into `engine/curriculum.rkt`'s queries, rather than reimplementing any of this (recorded in this change's tasks.md and design.md Non-Goals)
