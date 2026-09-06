## Purpose

Provides the R6RS-compliant Scheme execution engine embedded in the application, which runs player-submitted code in an isolated, resource-bounded context for both learning and checking purposes.

## ADDED Requirements

### Requirement: R6RS Code Execution
The system SHALL execute player-submitted code as R6RS Scheme, supporting at minimum the constructs covered by the base course (core syntax, recursion, closures) and any additional constructs required by enabled advanced tracks.

#### Scenario: Valid recursive program executes
- **WHEN** a player submits a syntactically valid R6RS program using recursion and closures
- **THEN** the runtime evaluates it and returns the resulting value or output

### Requirement: Isolated, Resource-Bounded Execution
Each execution of player code SHALL run in an isolated context with enforced time and memory limits, so that runaway or malicious code cannot hang, crash, or otherwise compromise the host application.

#### Scenario: Infinite loop is terminated
- **WHEN** a player submits code that does not terminate
- **THEN** execution is stopped after a bounded time limit and reported to the player as a timeout, and the application remains responsive

#### Scenario: Excessive memory use is contained
- **WHEN** a player's code attempts to allocate memory beyond the configured limit
- **THEN** execution is aborted and reported as a resource-limit error, without affecting the rest of the application

### Requirement: Fresh Evaluation Isolation
Unless a player is in an explicit continued session (such as an interactive REPL), each independent code evaluation SHALL start from a clean environment, with no state leaking between unrelated submissions.

#### Scenario: Unrelated snippets do not share state
- **WHEN** a player runs one snippet and then runs a second, unrelated snippet
- **THEN** definitions or side effects from the first snippet are not visible during evaluation of the second

### Requirement: Genuine Concurrency Semantics
For tracks that exercise concurrency, the runtime SHALL provide real concurrency primitives with genuine, non-simulated scheduling behavior, rather than a deterministic simulation.

#### Scenario: Concurrent program exhibits real non-determinism
- **WHEN** a player's code launches multiple concurrent tasks
- **THEN** the runtime schedules them using the underlying language's actual concurrency semantics, including legitimate run-to-run variation in ordering
