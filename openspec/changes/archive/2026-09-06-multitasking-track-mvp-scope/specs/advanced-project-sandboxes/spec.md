## MODIFIED Requirements

### Requirement: Multitasking Track Uses Real Concurrency
The Multitasking track's sandbox SHALL use the runtime's real concurrency primitives (per the `scheme-runtime` capability), scoped for this MVP to `thread`, `semaphore`, and `channel` (`sync`, and any place-based or future-based parallelism, are excluded from this MVP), and its automated checks SHALL account for legitimate non-deterministic ordering rather than requiring an exact interleaving.

#### Scenario: Concurrent solution graded despite non-determinism
- **WHEN** a player's concurrent solution is graded
- **THEN** the checks validate outcome invariants (for example, final shared state or absence of race conditions) rather than a single fixed execution order

#### Scenario: Grading repeats execution to surface non-deterministic failures
- **WHEN** a player's concurrent solution is graded
- **THEN** the system runs the solution multiple times and checks the exercise's invariant after each run, and a single run that violates the invariant fails the exercise
