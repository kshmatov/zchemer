## 1. Validate and Reconcile

- [x] 1.1 Run `openspec validate base-course-content --strict` and fix any structural issues in proposal/specs/design
- [x] 1.2 Confirm the ten node names and fixed order in this change's design.md match `define-base-course-skill-graph`'s archived design.md exactly (no drift before authoring content against them)

## 2. Set Up Content Layout

- [x] 2.1 Create `content/base-course/` with one `NN-<node-id>/` subdirectory per node, numbered per the fixed order (`01-s-expr-basics` through `10-higher-order-fn`)

## 3. Author Lessons — Linear Opening (s-expr-basics through first-class-fn)

- [x] 3.1 `01-s-expr-basics`: `lesson.md` (log entry + exercise) and `tests.rktd` covering atoms, pairs/lists, prefix notation, and inline `display`/`newline` use
- [x] 3.2 `02-binding`: `lesson.md` and `tests.rktd` covering `define` and `let`, using only `s-expr-basics` constructs otherwise
- [x] 3.3 `03-conditionals`: `lesson.md` and `tests.rktd` covering `if`, `cond`, booleans
- [x] 3.4 `04-first-class-fn`: `lesson.md` and `tests.rktd` covering `lambda` as a value and passing/returning functions

## 4. Author Lessons — Recursion Branch (recursion-basic through higher-order-fn)

- [x] 4.1 `05-recursion-basic`: `lesson.md` and `tests.rktd` covering structural recursion
- [x] 4.2 `06-tail-recursion`: `lesson.md` and `tests.rktd` covering the accumulator/iterative-process pattern, distinguishing it from `recursion-basic` in the log entry
- [x] 4.3 `07-closures`: `lesson.md` and `tests.rktd` covering closures, noting in the log entry why this concept matters for later tracks without naming unreleased tracks as a narrative hook
- [x] 4.4 `08-higher-order-fn`: `lesson.md` and `tests.rktd` covering `map`/`filter`/`fold`

## 5. Author Lessons — Parallel Branches (mutable-state, data-structures)

- [x] 5.1 `09-mutable-state`: `lesson.md` and `tests.rktd` covering `set!`, `begin`, and side effects; exercise must only require `first-class-fn` and earlier constructs otherwise
- [x] 5.2 `10-data-structures`: `lesson.md` and `tests.rktd` covering vectors, hash tables, and assoc lists; exercise must only require `first-class-fn` and earlier constructs otherwise

## 6. Cross-Check Against Specs

- [x] 6.1 For each lesson, confirm its exercise requires no construct introduced by a later-order node (`base-course-content`'s Lesson Scope Matches Its Skill Node requirement)
- [x] 6.2 For each lesson, confirm the log entry is written in first-person log style with no character dialogue and no mission/cutscene framing (`game-progression`'s Log-Entry Instructional Delivery and No Scripted Narrative Missions requirements)
- [x] 6.3 Confirm every lesson directory has a non-placeholder `lesson.md` and `tests.rktd`, and that `checks.rktd` is present only where a lesson genuinely disallows a construct

## 7. Adopt as Content Baseline

- [x] 7.1 Archive this change so the ten lessons become the reference content for the base course
- [x] 7.2 Note in the future Interpreter/Multitasking track-intro content changes that they should pick up immediately after `10-higher-order-fn` in the same `content/` layout (recorded in this change's design.md Context section, which becomes the archived reference)
