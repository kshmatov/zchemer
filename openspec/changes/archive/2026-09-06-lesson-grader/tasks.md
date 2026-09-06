## 1. Validate and Reconcile

- [x] 1.1 Run `openspec validate lesson-grader --strict` and fix any structural issues in proposal/design

## 2. Extend Shared Infrastructure

- [x] 2.1 `engine/sandbox.rkt`: add a `value` field to `sandbox-result`, populated with `use-evaluator`'s return value on success
- [x] 2.2 Re-run `raco test engine/sandbox.rkt` and confirm all existing tests still pass unchanged, then add a new test asserting `value` is reported for a simple expression

## 3. Lesson Grader

- [x] 3.1 `engine/lesson-grader.rkt`: implement `grade-lesson-submission`, reading a lesson directory's `tests.rktd` and (if present) `checks.rktd`
- [x] 3.2 Implement the `call`-entry path: load the full submission, evaluate each entry's expression, compare returned value to expected
- [x] 3.3 Implement the `expr`-entry path (only `01-s-expr-basics` uses it): load all but the submission's last form, evaluate the last form, compare to expected
- [x] 3.4 Implement the optional static-check path: block grading and report which disallowed symbols were found, without running any test entry, when a lesson's `checks.rktd` exists and the submission trips it

## 4. Automated Tests

- [x] 4.1 Test `01-s-expr-basics` (the `expr` format): a correct submission passes; an incorrect one fails
- [x] 4.2 Test at least one `call`-format lesson with multiple entries covering distinct behavior (e.g. `03-conditionals`): correct submission passes every entry; a submission wrong on one branch fails specifically that entry while others still pass
- [x] 4.3 Test `09-mutable-state`: confirm its independent-counter test entries each get a fresh sandbox load (a submission that (incorrectly) shares counter state across `make-counter` calls fails the independent-counters entry)
- [x] 4.4 Run `raco test engine/` and confirm every test (old and new) passes — additionally verified all 13 existing lessons (10 base-course + 3 track-intro) grade correctly against hand-written reference solutions, beyond the representative sample in the committed test suite

## 5. Adopt as Code Baseline

- [x] 5.1 Archive this change so `lesson-grader.rkt` becomes the reference implementation for grading base-course and track-intro lessons
- [x] 5.2 Note in the future GUI/curriculum-engine change that per-lesson grading should call `engine/lesson-grader.rkt` rather than reimplementing it, the same way a future change should call the two workspace modules (recorded in this change's design.md)
