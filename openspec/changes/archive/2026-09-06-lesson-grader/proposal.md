## Why

Thirteen lessons already exist with `tests.rktd` grading data (10 base-course lessons plus 3 track-intro lessons), but nothing runs them: the engine built so far only grades the two MVP tracks' main workspaces (`interpreter-workspace.rkt`, `multitasking-workspace.rkt`), which use a different, workspace-specific contract (`run-program`/`run-ledger`). Every lesson's exercise is inert until something can load its `tests.rktd` and grade a submission against it. This change adds that generic lesson grader, implementing `code-evaluation`'s already-specified Automated Test-Based Grading and Static Checks requirements — no new externally observable behavior beyond what those specs already require, so this change carries no spec delta (`skip_specs: true`).

## What Changes

- Extend `engine/sandbox.rkt`'s `run-in-sandbox` to also return the evaluated *value* of the caller's expression (not only captured stdout), needed because lesson tests grade by comparing a returned value, unlike the two workspaces' printed-output comparison.
- Add `engine/lesson-grader.rkt`: reads a lesson directory's `tests.rktd` (`base-course-content`/`track-intro-content`'s established format: `(call <expression> expected)` entries, or, for the one `01-s-expr-basics` lesson, `(expr expected)`), runs each entry against a submission inside the sandbox, and reports a pass/fail per entry.
- Support the optional `checks.rktd` static-check file per lesson (none of the 13 existing lessons has one, but the format was reserved for this from the start) by reusing `engine/static-check.rkt`'s existing `find-disallowed-symbols`.
- Automated `rackunit` tests grading a hand-written correct submission (must pass) and an incorrect submission (must fail with detail) for a representative sample of lessons across both entry formats.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
(none — `code-evaluation` and `scheme-runtime` already specify all the behavior this change implements; `skip_specs: true` is set in this change's `.openspec.yaml`)

## Impact

- Modifies `engine/sandbox.rkt` (additive: new `value` field on `sandbox-result`, existing fields and behavior unchanged).
- Adds `engine/lesson-grader.rkt`.
- No content changes — grades the 13 lessons already written by `base-course-content` and `track-intro-content`.
- Out of scope: learner-facing error-message translation (`code-evaluation`'s Learner-Facing Error Translation requirement — needs LCARS-styled presentation, which belongs to a future GUI change), and any curriculum-sequencing/gating logic (`curriculum` spec) that would decide which lesson to grade next.
