## Purpose

Defines the concrete lesson content — instructional text, exercise, and automated tests — for each MVP advanced track's intro node(s), the bridge between full base-course completion and that track's main project workspace.

## ADDED Requirements

### Requirement: Complete Track-Intro Lesson Coverage
The content SHALL define exactly one lesson for each track-intro node — `symbolic-data` and `environment-model` for the Interpreter track (in that order), and `concurrency-primitives` for the Multitasking track — and SHALL NOT include a lesson for any base-course node or any content belonging to a track's main project workspace.

#### Scenario: Both tracks' intro nodes have a lesson
- **WHEN** the track-intro content set is assembled
- **THEN** `symbolic-data`, `environment-model`, and `concurrency-primitives` each have exactly one corresponding lesson, and no intro node is missing or duplicated

#### Scenario: Base-course and main-workspace content are not duplicated here
- **WHEN** the track-intro content set is assembled
- **THEN** no lesson for a base-course node (per `base-course-content`) is present, and no player-facing `eval`/`apply` grading harness or concurrency-workspace grading harness is included

### Requirement: Lesson Content Package
Each track-intro lesson SHALL consist of first-person log-entry instructional text introducing the node's concept, an exercise prompt describing a task the player writes Scheme code to solve, and a set of automated test cases sufficient to grade a submission against that prompt.

#### Scenario: Lesson package has all three parts
- **WHEN** a track-intro lesson is authored
- **THEN** it includes instructional text, an exercise prompt, and at least one automated test case, and none of the three is left as a placeholder

### Requirement: Prerequisite Ordering Relative to the Base Course and Within a Track
A track-intro lesson's exercise SHALL only require constructs already taught by the completed base course, plus (for `environment-model` only) constructs taught by `symbolic-data`, and SHALL NOT require any construct or capability that is only introduced by the track's own main project workspace.

#### Scenario: symbolic-data requires only base-course constructs
- **WHEN** the `symbolic-data` lesson's exercise is written
- **THEN** it requires only constructs already taught across the base course, plus `quote`/`quasiquote` itself, and does not require anything from `environment-model` or the Interpreter workspace

#### Scenario: environment-model may build on symbolic-data
- **WHEN** the `environment-model` lesson's exercise is written
- **THEN** it may use `symbolic-data`'s constructs in addition to base-course constructs, but does not require the player to have already implemented `eval`/`apply`

#### Scenario: concurrency-primitives does not require the Multitasking workspace's grading style
- **WHEN** the `concurrency-primitives` lesson's exercise is written
- **THEN** it requires only base-course constructs plus `thread`, `semaphore`, and `channel`, and does not assume the invariant-based, repeated-execution grading defined for the Multitasking track's main workspace

### Requirement: Deterministic Grading for the Concurrency-Primitives Lesson
The `concurrency-primitives` lesson's automated tests SHALL check a deterministic, observable outcome of the exercise (for example, a final accumulated value after synchronized access) rather than relying on the repeated-execution, non-determinism-tolerant grading approach defined for the Multitasking track's main workspace, since this intro exercise is scoped small enough to admit a deterministic expected result.

#### Scenario: Concurrency intro lesson test does not require multiple grading runs
- **WHEN** the `concurrency-primitives` lesson's test cases are defined
- **THEN** each test case specifies one deterministic expected outcome, and grading it does not depend on running the submission multiple times to average over non-deterministic thread interleaving
