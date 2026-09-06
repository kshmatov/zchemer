## 1. Validate and Reconcile

- [x] 1.1 Run `openspec validate track-workspaces --strict` and fix any structural issues in proposal/specs/design

## 2. Project Skeleton

- [x] 2.1 Create `engine/info.rkt` declaring the collection and its dependencies (`racket`, `rackunit`)
- [x] 2.2 Confirm `raco test engine/` runs (even with zero tests) before adding harness code, so later failures are attributable to the harnesses themselves

## 3. Shared Infrastructure

- [x] 3.1 `engine/sandbox.rkt`: implement `run-in-sandbox`, wrapping `racket/sandbox` with time/memory limits, fresh evaluator per call, and captured stdout
- [x] 3.2 `engine/static-check.rkt`: implement `find-disallowed-symbols`, recursively scanning read forms for any of a given disallow-list of symbols
- [x] 3.3 `rackunit` tests for both modules: a timeout case and a memory-limit case for `sandbox.rkt`; a found-and-not-found case for `static-check.rkt`

## 4. Interpreter Workspace

- [x] 4.1 Write `content/interpreter-track/workspace/reference-suite.rktd`: pre-parsed reference programs with expected printed output, covering every MVP construct and the three required error categories (unbound variable, arity mismatch, non-procedure application)
- [x] 4.2 `engine/interpreter-workspace.rkt`: implement the harness — static-check the submission (disallow `eval`, `dynamic-require`), then run each reference program through the submission's `run-program` inside the sandbox, comparing captured output to expected
- [x] 4.3 Write a hand-written correct reference `run-program` evaluator (test fixture, not player-facing) covering the MVP subset plus all three error detections
- [x] 4.4 Write at least one deliberately incorrect evaluator fixture (e.g., missing arity checking) and confirm the harness fails it specifically on the arity-mismatch program
- [x] 4.5 Write a fixture that delegates to Racket's own `eval` and confirm the static check blocks it before any reference program runs

## 5. Multitasking Workspace

- [x] 5.1 Write `content/multitasking-track/workspace/exercise.rktd`: the `run-ledger` task description and its invariant parameters (worker count, ops per worker)
- [x] 5.2 `engine/multitasking-workspace.rkt`: implement the harness — run the submission's `run-ledger` a fixed number of times inside the sandbox, checking the invariant after each run, failing fast on the first violation
- [x] 5.3 Write a correct `run-ledger` fixture (semaphore-guarded) and confirm it passes the full run count
- [x] 5.4 Write an unsynchronized `run-ledger` fixture (no semaphore around the shared balance) and empirically tune worker/op counts until the harness reliably catches its race within the fixed run count; record the tuned counts in `design.md` if they differ from the draft

## 6. Cross-Check Against Specs

- [x] 6.1 Confirm the reference suite satisfies `interpreter-workspace-content`'s Reference Program Suite Coverage and Reference Programs Supplied as Pre-Parsed Data requirements
- [x] 6.2 Confirm the Multitasking exercise satisfies `multitasking-workspace-content`'s Workspace Exercise Defines a Verifiable Invariant and Harness Repeats Execution requirements
- [x] 6.3 Confirm both harnesses satisfy `code-evaluation`'s Static Checks, Automated Test-Based Grading, and Unlimited Retry requirements, and `scheme-runtime`'s Isolated Resource-Bounded Execution and Fresh Evaluation Isolation requirements
- [x] 6.4 Run `raco test engine/` and confirm every test passes

## 7. Adopt as Content/Code Baseline

- [x] 7.1 Archive this change so the engine and its two workspace exercises become the reference implementation for both MVP tracks
- [ ] 7.2 Note in the future GUI/curriculum-engine change that it should call into `engine/interpreter-workspace.rkt` and `engine/multitasking-workspace.rkt` rather than reimplementing grading
