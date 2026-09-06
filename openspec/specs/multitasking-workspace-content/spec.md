# multitasking-workspace-content Specification

## Purpose

Defines the concrete workspace exercise — task and invariant — that grades a player's submitted concurrent solution in the Multitasking track's main workspace, the exercise `advanced-project-sandboxes`' Multitasking Track Uses Real Concurrency requirement assumes exists.

## Requirements

### Requirement: Workspace Exercise Defines a Verifiable Invariant
The workspace SHALL define a single concrete exercise built on `thread`, `semaphore`, and/or `channel`, with an invariant that is checkable after each run and that a correctly synchronized solution satisfies regardless of legitimate scheduling variation, but that an unsynchronized (racy) solution can violate.

#### Scenario: Invariant tolerates any legitimate interleaving
- **WHEN** a correctly synchronized solution is run repeatedly
- **THEN** the invariant holds after every run, regardless of the actual thread interleaving observed

#### Scenario: Invariant is violated by an unsynchronized solution
- **WHEN** a solution that omits proper synchronization (for example, updates shared state without a semaphore) is run repeatedly
- **THEN** the invariant is violated on at least one of the runs

### Requirement: Harness Repeats Execution Until a Violation or a Fixed Run Count
Per `advanced-project-sandboxes`' "Grading repeats execution to surface non-deterministic failures" scenario, the harness SHALL run a submission a fixed number of times, checking the invariant after each run, and SHALL fail the exercise as soon as any run violates the invariant rather than averaging across runs.

#### Scenario: Correct solution passes the full run count
- **WHEN** a correctly synchronized solution is graded
- **THEN** it is run the harness's fixed number of times and the invariant holds after every run, and the exercise passes

#### Scenario: Buggy solution fails within the run count
- **WHEN** an unsynchronized solution is graded
- **THEN** grading stops and reports failure as soon as a run violates the invariant, without requiring all runs to complete first
