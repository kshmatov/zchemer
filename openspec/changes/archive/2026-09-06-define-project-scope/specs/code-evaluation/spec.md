## Purpose

Defines how player-submitted solutions are checked for correctness and how the resulting feedback — including translated runtime errors — is presented to the learner.

## ADDED Requirements

### Requirement: Static Checks Before Execution
For exercises that define disallowed or required constructs (for example, forbidding a built-in `eval` in the interpreter track), the system SHALL run a static check on the submission before executing it, and SHALL block execution with an explanatory message if the check fails.

#### Scenario: Disallowed construct is caught statically
- **WHEN** a player submits code using a construct the exercise disallows
- **THEN** the system reports which construct is disallowed and why, without running the tests

### Requirement: Automated Test-Based Grading
After passing static checks, the system SHALL execute the submission against the exercise's automated tests and mark the exercise as passed only when the observed behavior matches the expected results.

#### Scenario: Correct solution passes
- **WHEN** a player's submission passes all static checks and produces the expected results for every test case of the exercise
- **THEN** the exercise is marked as completed

#### Scenario: Incorrect solution fails with detail
- **WHEN** a player's submission fails one or more test cases
- **THEN** the exercise is marked as not yet completed and the player is told which case(s) failed

### Requirement: Learner-Facing Error Translation
Raw runtime errors from the execution engine SHALL be translated into plain-language, LCARS-styled feedback that references the relevant part of the player's code, rather than surfacing the raw interpreter exception text alone.

#### Scenario: Runtime error is translated
- **WHEN** a player's submission raises a runtime error (for example, wrong number of arguments)
- **THEN** the feedback shown is a plain-language hint pointing to the relevant expression, styled consistently with the rest of the interface

### Requirement: Unlimited Retry Without Penalty
The system SHALL allow a player to resubmit a failed exercise an unlimited number of times without losing previously earned progress, rank, or achievements.

#### Scenario: Player retries after failure
- **WHEN** a player's submission fails and they resubmit a corrected version
- **THEN** the retry is graded independently and no previously earned progress is lost
