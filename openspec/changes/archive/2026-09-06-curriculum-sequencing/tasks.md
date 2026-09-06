## 1. Validate and Reconcile

- [x] 1.1 Run `openspec validate curriculum-sequencing --strict` and fix any structural issues in proposal/specs/design
- [x] 1.2 Cross-check the table in `design.md` node-by-node against `define-base-course-skill-graph`'s archived design.md and `base-course-content`'s design.md — confirm no edge drift

## 2. Graph Data and Core Queries

- [x] 2.1 `engine/curriculum.rkt`: encode the module table (10 base-course nodes + 3 track-intro nodes + 2 workspace nodes) exactly as fixed in this change's design.md
- [x] 2.2 Implement `module-status`, handling the virtual `'base-course` prerequisite token
- [x] 2.3 Implement `available-modules` (every module currently `'available` given a completed-set)
- [x] 2.4 Implement `ENABLED-TRACKS`/`PLANNED-TRACKS` accessors

## 3. Automated Tests

- [x] 3.1 Base-course edges: `mutable-state` and `data-structures` are `'available` immediately after `first-class-fn` completes, without needing `recursion-basic`/`tail-recursion`/`closures` done first
- [x] 3.2 Base Course Scope: `symbolic-data` is `'locked` when only 9 of the 10 base-course nodes are complete, and `'available` once all 10 are
- [x] 3.3 Free Advanced Track Selection: with the full base course complete and neither track started, both `symbolic-data` and `concurrency-primitives` are `'available` simultaneously; completing one does not change the other's status
- [x] 3.4 Completed Module Accessibility: a module already in the completed-set always reports `'completed`, even if its own prerequisites would otherwise be unmet by some other inconsistency in the input set
- [x] 3.5 Track internal chain and workspace gating: `environment-model` is `'locked` until `symbolic-data` is complete; `interpreter-eval-workspace` is `'locked` until `environment-model` is complete (same shape for the Multitasking chain)
- [x] 3.6 Enabled vs. planned tracks: `ENABLED-TRACKS` contains exactly `interpreter`/`multitasking`; `PLANNED-TRACKS` contains exactly `network`/`database`/`oop`
- [x] 3.7 Run `raco test engine/` and confirm every test (old and new) passes

## 4. Adopt as Code Baseline

- [x] 4.1 Archive this change so `engine/curriculum.rkt` becomes the reference sequencing engine
- [x] 4.2 Note in the future progress-persistence change that it should supply `engine/curriculum.rkt` with the completed-set read from the save file, rather than this module doing its own I/O (recorded in this change's design.md Non-Goals)
