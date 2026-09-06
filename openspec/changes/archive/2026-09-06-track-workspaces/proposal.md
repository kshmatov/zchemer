## Why

`advanced-project-sandboxes`, `code-evaluation`, and `scheme-runtime` already fully specify how the Interpreter track's player-`eval` workspace and the Multitasking track's concurrent-exercise workspace must behave — sandboxed, resource-bounded execution, static checks before running code, printed-output comparison for the Interpreter track, invariant checks across repeated runs for the Multitasking track, and the three interpreter error categories a correct evaluator must detect. None of it exists in code: this is the first executable source in the project. This change builds both workspaces' grading engines and the concrete exercise content those specs assume exists (a reference program suite for the Interpreter track, a task-plus-invariant exercise for the Multitasking track) but that no prior change has written.

## What Changes

- Add the project's first Racket source tree, `engine/`, with its own `info.rkt`.
- `engine/sandbox.rkt`: a shared sandboxed-execution module (wraps `racket/sandbox` with time/memory limits and fresh-per-evaluation isolation), used by both workspaces.
- `engine/static-check.rkt`: a static-check module expressing a per-exercise disallow-list, with a first concrete rule blocking a submitted Interpreter evaluator from delegating to Racket's own `eval`.
- Interpreter workspace (`engine/interpreter-workspace.rkt` + reference-suite data): a concrete reference-program suite — pre-parsed sample programs with expected printed output, including at least one program each designed to surface an unbound-variable error, an arity-mismatch error, and a non-procedure-application error in a correct player evaluator — plus the harness that runs each program through a submitted `eval`/`apply` inside the sandbox and compares printed output.
- Multitasking workspace (`engine/multitasking-workspace.rkt` + exercise data): one concrete workspace exercise (task description plus invariant check, built on `thread`/`semaphore`/`channel`) plus the harness that runs a submission multiple times and checks the invariant after each run, failing on the first violation.
- Automated `rackunit` tests for both harnesses, each exercised against a hand-written correct reference solution (must pass) and at least one deliberately incorrect solution (must fail with the spec-required detail).

## Capabilities

### New Capabilities
- `interpreter-workspace-content`: The concrete reference-program suite (source programs, expected printed output, and the three error-triggering programs) that grades a player's submitted evaluator, analogous to how `base-course-content` fixed concrete lesson data under already-specified structural rules.
- `multitasking-workspace-content`: The concrete workspace exercise (task and invariant) that grades a player's submitted concurrent solution.

### Modified Capabilities
(none — the grading-harness mechanics are pure implementation of already-specified behavior in `advanced-project-sandboxes`, `code-evaluation`, and `scheme-runtime`; no requirement changes)

## Impact

- New `engine/` Racket source tree — the project's first executable code.
- New `openspec/specs/interpreter-workspace-content/spec.md` and `openspec/specs/multitasking-workspace-content/spec.md` capabilities.
- Out of scope: the GUI (`gui-lcars`), progress persistence wiring, achievement/rank logic (`game-progression`), and the curriculum engine sequencing lessons/tracks for a player — all separate future changes that will eventually call into this engine.
