## Why

`advanced-project-sandboxes` requires the Multitasking track to use real concurrency and grade by invariant rather than fixed interleaving, but left the concurrency primitive set, what "invariant grading" concretely means, and the exercise progression undefined. Explore-mode discussion (2026-09-06) resolved all three; content authoring for the track's intro module and exercises cannot start without them fixed.

## What Changes

- `advanced-project-sandboxes`'s Multitasking Track Uses Real Concurrency requirement is scoped to a concrete MVP primitive set (`thread`, `semaphore`, `channel`) and gains an explicit grading mechanic: a solution is executed multiple times, with the exercise's invariant checked after every run, so a single failing run fails the exercise.
- `sync`, place-based, and future-based parallelism are excluded from this MVP (places isolate memory and cannot demonstrate the shared-state races the track is built around; futures target pure data-parallel performance, not general multitasking) — deferred to a speculative future "Advanced Concurrency" track, the same pattern already used for the Interpreter track's deferred `call/cc`/mutation.
- Records the exercise progression for `concurrency-primitives`: the intro module's own practice is a "fix the race" exercise on a given unsafe solution, followed by the track's main "design from scratch" exercises (producer/consumer, bounded buffer, worker pool, etc.) — a design decision, not a spec requirement change.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `advanced-project-sandboxes`: scopes the Multitasking track's concurrency primitives for this MVP and adds the repeated-execution grading mechanic to the Multitasking Track Uses Real Concurrency requirement.

## Impact

- Fixes the reference sequence for the future Multitasking track content change (the `concurrency-primitives` intro module and its reference exercise suite).
- No existing code is touched.
