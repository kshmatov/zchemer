## ADDED Requirements

### Requirement: Idempotent Review Grading
Re-submitting a solution for an already-completed module while reviewing it SHALL be graded for feedback, but SHALL NOT re-grant rank/level progress or re-trigger module completion.

#### Scenario: Passing a review submission does not add rank twice
- **WHEN** a player resubmits a solution for a module already marked completed and the submission passes
- **THEN** the pass/fail result is shown to the player, but rank/level and completion status remain unchanged from their prior value

### Requirement: Retroactive Achievement Recognition During Review
The system SHALL still evaluate achievement conditions against submissions made while reviewing an already-completed module, and SHALL grant an achievement the player has not yet earned even though the module itself was completed earlier.

#### Scenario: A newly elegant solution found during review earns an achievement
- **WHEN** a player, while reviewing a completed module, submits a solution that meets an achievement condition they had not previously met
- **THEN** the achievement is granted and shown to the player, independent of the module's already-completed status
