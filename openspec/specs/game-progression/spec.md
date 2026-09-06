# game-progression Specification

## Purpose

Provides the game framing on top of the curriculum: rank/level progression and achievements that reward completing content, and a Starfleet-log style of presenting instructional text, without scripted narrative missions.

## Requirements

### Requirement: Rank and Level Progression
The system SHALL track a player rank/level that advances as curriculum modules (base course and advanced tracks) are completed, and SHALL display the current rank/level to the player.

#### Scenario: Completing a module advances rank
- **WHEN** a player completes a module that grants enough progress to cross a rank threshold
- **THEN** the displayed rank/level updates to reflect the new standing

### Requirement: Achievements for Notable Actions
The system SHALL grant discrete achievements for notable player actions or solutions (for example, an unusually elegant or optimized solution to an exercise), independent of rank/level progression.

#### Scenario: Elegant solution earns an achievement
- **WHEN** a player submits a solution that meets a defined achievement condition for that exercise
- **THEN** the corresponding achievement is granted and shown to the player

### Requirement: Log-Entry Instructional Delivery
Instructional text SHALL be presented in a first-person log/journal style (as if recorded by a single narrator), without dialogue exchanges between multiple characters.

#### Scenario: Lesson content shown as a log entry
- **WHEN** a player opens a lesson's instructional text
- **THEN** the text is presented as a first-person log entry, not as a back-and-forth dialogue between characters

### Requirement: No Scripted Narrative Missions
The system SHALL NOT gate learning content behind scripted story missions or cutscenes; the Star Trek framing is limited to visual styling and log-entry text.

#### Scenario: Completing a lesson triggers no story sequence
- **WHEN** a player completes a lesson or module
- **THEN** no mission briefing, cutscene, or multi-step scripted story sequence is triggered; only the LCARS visual chrome and log-entry text are shown

### Requirement: Idempotent Review Grading
Re-submitting a solution for an exercise within an already-completed module, while reviewing it, SHALL be graded for feedback, but SHALL NOT re-grant rank/level progress or re-trigger module completion.

#### Scenario: Passing a review submission does not add rank twice
- **WHEN** a player resubmits a solution for an exercise whose module is already marked completed, and the submission passes
- **THEN** the pass/fail result is shown to the player, but rank/level and completion status remain unchanged from their prior value

### Requirement: Retroactive Achievement Recognition During Review
The system SHALL still evaluate achievement conditions against submissions made while reviewing an exercise within an already-completed module, and SHALL grant an achievement the player has not yet earned even though the module itself was completed earlier.

#### Scenario: A newly elegant solution found during review earns an achievement
- **WHEN** a player, while reviewing an exercise within an already-completed module, submits a solution that meets an achievement condition they had not previously met
- **THEN** the achievement is granted and shown to the player, independent of the module's already-completed status
