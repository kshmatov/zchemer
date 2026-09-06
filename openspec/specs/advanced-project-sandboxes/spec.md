# advanced-project-sandboxes Specification

## Purpose

Defines the environments in which advanced-track projects run — starting with the Scheme Interpreter and Multitasking tracks — and how a player loads a more complex, multi-file project into the game.

## Requirements

### Requirement: Loadable Multi-File Projects
The system SHALL let a player load a more complex project consisting of multiple Scheme source files from a local folder, distinct from the single-snippet inline editor.

#### Scenario: Player loads a project folder
- **WHEN** a player selects a local folder containing one or more `.scm` files
- **THEN** the game loads it as a project and recognizes or lets the player select an entry point file

### Requirement: Interpreter Track Evaluation Workspace
The Scheme Interpreter track SHALL let a player implement their own evaluator (for example, `eval`/`apply`) in Scheme, and SHALL exercise that evaluator against the game's reference suite of sample programs to check its behavior.

#### Scenario: Custom evaluator is checked against sample programs
- **WHEN** a player submits their evaluator implementation for grading
- **THEN** the system runs the reference sample programs through the player's evaluator inside the sandbox and compares the results to the expected output for each

### Requirement: Multitasking Track Uses Real Concurrency
The Multitasking track's sandbox SHALL use the runtime's real concurrency primitives (per the `scheme-runtime` capability), and its automated checks SHALL account for legitimate non-deterministic ordering rather than requiring an exact interleaving.

#### Scenario: Concurrent solution graded despite non-determinism
- **WHEN** a player's concurrent solution is graded
- **THEN** the checks validate outcome invariants (for example, final shared state or absence of race conditions) rather than a single fixed execution order

### Requirement: Unavailable Tracks Are Visible but Disabled
Tracks not enabled in the current version (Network, Database, Object-Oriented Programming, and any others not yet built) SHALL be visible in track selection as planned, but SHALL NOT be startable.

#### Scenario: Player views a not-yet-enabled track
- **WHEN** a player opens the advanced track selection screen
- **THEN** tracks not enabled in this version are listed and labeled as not yet available, and attempting to start one has no effect beyond that indication
