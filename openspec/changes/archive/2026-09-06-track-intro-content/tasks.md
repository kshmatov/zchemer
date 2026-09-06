## 1. Validate and Reconcile

- [x] 1.1 Run `openspec validate track-intro-content --strict` and fix any structural issues in proposal/specs/design
- [x] 1.2 Confirm the two Interpreter intro nodes and their order, and the single Multitasking intro node, match `define-base-course-skill-graph`'s archived design.md's Track intro sequences section exactly

## 2. Set Up Content Layout

- [x] 2.1 Create `content/interpreter-track/01-symbolic-data/` and `content/interpreter-track/02-environment-model/`
- [x] 2.2 Create `content/multitasking-track/01-concurrency-primitives/`

## 3. Author Interpreter Track Intro

- [x] 3.1 `01-symbolic-data`: `lesson.md` and `tests.rktd` covering `quote`/`quasiquote` and code-as-data, using only base-course constructs otherwise
- [x] 3.2 `02-environment-model`: `lesson.md` and `tests.rktd` covering representing a chain of lexical scopes as frames (built from `data-structures` + `closures`), using only base-course constructs plus `symbolic-data` otherwise

## 4. Author Multitasking Track Intro

- [x] 4.1 `01-concurrency-primitives`: `lesson.md` and `tests.rktd` covering `thread`, `semaphore`, and `channel`; exercise and test must be deterministically gradable per this change's design.md (no repeated-run/non-determinism-tolerant grading)

## 5. Cross-Check Against Specs

- [x] 5.1 For each lesson, confirm its exercise requires no construct beyond the base course (plus, for `environment-model`, `symbolic-data`) and no main-workspace grading mechanism (`track-intro-content`'s Prerequisite Ordering requirement)
- [x] 5.2 For each lesson, confirm the log entry is written in first-person log style with no character dialogue and no mission/cutscene framing
- [x] 5.3 Confirm `concurrency-primitives`' test cases each specify a single deterministic expected outcome (`track-intro-content`'s Deterministic Grading requirement)
- [x] 5.4 Confirm every lesson directory has a non-placeholder `lesson.md` and `tests.rktd`, and that `checks.rktd` is present only where a lesson genuinely disallows a construct

## 6. Adopt as Content Baseline

- [x] 6.1 Archive this change so the three lessons become the reference intro content for both MVP tracks
- [x] 6.2 Note in the future Interpreter and Multitasking main-workspace changes that they should assume these intro lessons are already completed prerequisites (recorded in this change's design.md, which becomes the archived reference)
