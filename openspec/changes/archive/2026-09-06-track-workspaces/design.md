## Context

See `proposal.md` for motivation. No source code exists anywhere in the project yet — `content/` (from `base-course-content` and `track-intro-content`) holds only Markdown/`.rktd` lesson data, no Racket module. This change writes the first `.rkt` files. Per `AGENTS.md`, the stack is Racket (`racket/sandbox` for safe execution), targeting an R6RS subset as the taught language; the grading engine itself is ordinary Racket, since it is host tooling, not player-facing curriculum content.

## Goals / Non-Goals

**Goals:**
- Implement the sandboxed execution, static-check, and both workspaces' grading harnesses exactly as `scheme-runtime`/`code-evaluation`/`advanced-project-sandboxes` already specify.
- Write one concrete reference-program suite (Interpreter) and one concrete workspace exercise (Multitasking), each satisfying this change's new content capabilities.
- Prove both harnesses work with `rackunit` tests against both a correct and a deliberately broken reference solution.

**Non-Goals:**
- GUI, persistence, achievement/rank wiring, or curriculum sequencing — separate future changes.
- A general-purpose plugin system for arbitrary future exercises — this change hard-codes exactly the one reference suite and one exercise its specs require; a later change can generalize if a third workspace needs it.
- Implementing the player-facing Scheme reader/evaluator itself — that's the player's job; this change only grades what they submit.

## Decisions

### Directory layout: `engine/` for code, `content/<track>/workspace/` for data
Mirrors the project's existing content/code split:
- `engine/info.rkt` — Racket collection metadata (`racket` dependency, `rackunit` for tests).
- `engine/sandbox.rkt` — shared sandboxed-execution wrapper.
- `engine/static-check.rkt` — shared static-check module.
- `engine/interpreter-workspace.rkt` — Interpreter grading harness; reads reference-suite data from `content/interpreter-track/workspace/reference-suite.rktd`.
- `engine/multitasking-workspace.rkt` — Multitasking grading harness; reads exercise parameters from `content/multitasking-track/workspace/exercise.rktd`.
- Tests as `(module+ test ...)` submodules in each `engine/*.rkt` file, run via `raco test engine/`.

Alternative considered: putting the reference-suite/exercise data inside `engine/` alongside the code that reads it — rejected, since every other piece of exercise content in this project lives under `content/`, and keeping data there means a future content-only change can revise the reference suite without touching Racket source.

### Interpreter submission contract: a `run-program` procedure
A player's Interpreter-track submission SHALL define a procedure `(run-program forms)`, where `forms` is a list of already-parsed top-level Scheme forms (definitions, expressions). `run-program` must evaluate them in order using the player's own `eval`/`apply` for the MVP subset (`define`, `lambda`, `if`/`cond` as the base course already taught, procedure application, `quote`), producing output via calls to host primitives like `display`/`newline` — delegating primitive operations (`+`, `car`, `display`, ...) to the host is fine and expected (same convention as every base-course exercise); only delegating the interpretation of the MVP special forms themselves to Racket's own `eval` is disallowed.

Alternative considered: requiring the player to expose separate `my-eval`/`my-apply` procedures with a fixed signature — rejected as more rigid for no real benefit; `run-program` is simpler to grade (call it once per reference program) and closer to "here's a program, run it" than "call these two functions in the right pattern."

### Static check: disallow the symbol `eval` (and `dynamic-require`) anywhere in the submission's read forms
`static-check.rkt` exports `(find-disallowed-symbols forms disallowed)`, which recursively walks the submission's already-`read` top-level forms (before any evaluation) and returns any disallowed symbol it finds referenced anywhere (not just in operator position, since a submission could alias `eval` to another name and still be delegating). For the Interpreter workspace, `disallowed = '(eval dynamic-require)`. `code-evaluation`'s Static Checks requirement already specifies blocking execution with an explanation when this check fails; this module supplies the generic mechanism, callable with a different disallow-list by any future exercise.

### Output capture and comparison
`sandbox.rkt` exposes `(run-in-sandbox thunk-src)`, which creates a fresh `racket/sandbox` evaluator per call (satisfying `scheme-runtime`'s Fresh Evaluation Isolation), configured with `sandbox-eval-limits` for time and memory (Isolated, Resource-Bounded Execution), evaluates the submission's source inside it, and returns the captured stdout as a string alongside the evaluator's captured errors/timeout status. The Interpreter harness calls `run-in-sandbox` once per reference program (loading the submission, then invoking `(run-program '<program-forms>)`), comparing the captured string to the program's expected output.

### Multitasking exercise: a semaphore-and-channel-guarded shared ledger
The concrete exercise (`content/multitasking-track/workspace/exercise.rktd`) asks the player to define `(run-ledger num-workers ops-per-worker)`: spawn `num-workers` threads, each performing `ops-per-worker` increments of a shared balance guarded by a semaphore, each worker signaling completion over a shared channel; the main thread waits for all completion signals before **displaying** the final balance. The invariant: the printed balance always equals `(* num-workers ops-per-worker)`.

**Refinement discovered during implementation:** the exercise prints the balance (via `display`) rather than returning it, so the harness can reuse `sandbox.rkt`'s existing captured-stdout mechanism unchanged instead of adding a second value-returning code path — keeping both workspaces graded the same way (compare captured output to an expected value).

**Tuned parameters (empirically verified):** `num-workers = 4`, `ops-per-worker = 5000`. At these counts, a correctly semaphore-guarded solution never mis-reports the balance (0/10 trials wrong in tuning), while a solution that reads-then-writes the shared balance without synchronization is wrong on effectively every run (10/10 trials wrong in tuning, once a real scheduling point — a zero-duration `sleep`/blocking op — sits between the read and the write). Racket's threads are cooperatively scheduled, so a race only manifests where the racy code actually yields between reading and writing shared state; the reference "buggy" fixture used for this change's own tests introduces exactly that yield point to make the race observable, since a tight `set!` loop with no yielding call inside the read-modify-write step never actually interleaves.

This differs from the track-intro lesson's `synchronized-sum`/`ping-pong` (which only demonstrate the primitives individually) by combining `thread` + `semaphore` + `channel` in one task and scaling worker/op counts up enough that an unsynchronized (racy) submission can actually lose updates under Racket's real thread scheduler — giving the repeated-execution grading something genuine to catch, rather than a race that's merely theoretical at tiny scale.

Alternative considered: a producer/consumer queue exercise — rejected for this MVP as needlessly more complex to specify and grade than a shared-ledger race, while exercising the same three primitives.

### Repeated-execution grading: fixed run count, fail-fast
`multitasking-workspace.rkt`'s harness runs the submission a fixed number of times (a module constant, not exposed to the player), checking the invariant after each run, and returns failure as soon as one run violates it — matching `advanced-project-sandboxes`' "Grading repeats execution to surface non-deterministic failures" scenario exactly (fail-fast, not an averaged/statistical pass).

## Risks / Trade-offs

- [A race in the shared-ledger exercise might not reliably manifest on every underlying machine/scheduler, making the "buggy solution fails" test flaky] → Mitigate by using a worker/op count high enough to make lost updates observable in practice (tuned and verified empirically during implementation, not just assumed), and by running the buggy reference solution across the harness's full repeated-run count rather than a single run.
- [Hard-coding one reference suite and one exercise means adding a second Interpreter/Multitasking exercise later requires new code, not just new content] → Acceptable for this MVP; `Non-Goals` already defers generalizing the harness until a second exercise is actually needed.

## Open Questions

(none — contract, layout, and grading approach are all fixed by this design)
