## Context

See `proposal.md` for motivation. Reuses infrastructure from `track-workspaces` (`openspec/changes/archive/2026-09-06-track-workspaces/`): `engine/sandbox.rkt`'s sandboxed execution and `engine/static-check.rkt`'s disallowed-symbol scan. The lesson content format itself (`lesson.md` + `tests.rktd` + optional `checks.rktd`) was fixed by `base-course-content` (`openspec/changes/archive/2026-09-06-base-course-content/design.md`) and extended unchanged by `track-intro-content`; this change is the first thing that actually reads and grades that data.

## Goals / Non-Goals

**Goals:**
- Grade any of the 13 existing lessons' `tests.rktd` (both its `call` and `expr` entry shapes) against a player submission.
- Reuse `sandbox.rkt`/`static-check.rkt` unchanged in spirit, extending `sandbox.rkt` only additively (a new returned value, not a changed contract for existing callers).

**Non-Goals:**
- Learner-facing error-message translation (plain-language, LCARS-styled hints) — `code-evaluation`'s Learner-Facing Error Translation requirement needs presentation-layer work that belongs with the future GUI change, not this engine-only change.
- Curriculum sequencing/gating (which lesson unlocks next, base-course-vs-track gating) — `curriculum`'s job, a future change.
- Achievement-condition evaluation ("elegant solution" detection per `game-progression`) — out of scope, same as every prior content/engine change.

## Decisions

### `sandbox.rkt` gains a `value` field on `sandbox-result`
The two existing workspaces only ever compared captured stdout, so `sandbox-result` had no way to report the Scheme value a call actually returned. Lesson tests grade by return value (`(call (convert-to-cochranes 1) 100)` means "calling this returns 100," not "this prints 100"), so `run-in-sandbox` now also captures whatever `use-evaluator` returns and reports it as `sandbox-result-value` (meaningful only when `status` is `'ok`; `#f` otherwise). This is purely additive — `interpreter-workspace.rkt` and `multitasking-workspace.rkt` keep working unchanged, since they only ever read `status`/`output`.

### Two entry-format lessons: `call` and `expr`, unified around "load program, then evaluate one expression"
Every lesson reduces to the same two-step shape:
1. Load a program into the sandbox (the submission's definitions).
2. Evaluate one expression, capture its value, compare to `expected`.

For `call` entries (every lesson except `01-s-expr-basics`), the loaded program is the *entire* submission source, and the evaluated expression is the entry's own `<expression>` datum. For `expr` entries (`01-s-expr-basics` only), there is no separate test expression — the submission's own final top-level form *is* the expression to evaluate, so the loaded program is every form except the last, and the evaluated expression is that last form. `engine/lesson-grader.rkt` computes this uniformly by reading the submission with `static-check.rkt`'s existing `read-all-forms`, then re-serializing whichever forms belong in "the loaded program" back to source text with `write` (valid, since Racket data that represents code prints back as valid re-readable source).

### Fresh sandbox load per test entry, not shared across a lesson's entries
Matches the pattern already established and tested in `interpreter-workspace.rkt`: each of a lesson's test entries gets its own fresh `run-in-sandbox` call (the full load-program reloaded from scratch), rather than one evaluator shared across all of a lesson's test cases. This guarantees the `mutable-state` lesson's "independent counters" test entries can't accidentally leak state into each other through the grading harness itself, and keeps this module's isolation story identical to the already-shipped workspace harnesses rather than introducing a second isolation policy.

### `checks.rktd` support, reserved but currently unused
`base-course-content`'s design reserved an optional `checks.rktd` per lesson for `code-evaluation`'s Static Checks requirement. No lesson currently has one, but `lesson-grader.rkt` still checks for its presence and runs `static-check.rkt`'s `find-disallowed-symbols` when it exists, returning a `'blocked` report exactly like `interpreter-workspace.rkt` does for its own static check — so a future lesson that needs one (unlikely for the base course, plausible for a later track) works without touching this module again.

## Risks / Trade-offs

- [Re-serializing forms with `write` to reconstruct "the loaded program minus its last form" assumes every base-course/track-intro submission is plain data with no reader-macro syntax (`#(...)` literals aside, which `write` handles fine) — true for everything the base course teaches, but would need revisiting if a later lesson used something `write` can't round-trip (e.g., a literal procedure value, which can't appear in source anyway)] → Acceptable: submissions are always source text the player wrote, so this is a non-issue in practice.

## Open Questions

(none)
