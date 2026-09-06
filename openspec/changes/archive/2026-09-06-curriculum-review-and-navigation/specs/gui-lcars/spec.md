## ADDED Requirements

### Requirement: Review Mode Editor
When a player reopens a completed module's inline editor, the system SHALL preload the player's last successful submission for that module, and SHALL let the player clear it to restart the exercise from a blank state.

#### Scenario: Reopening a completed exercise preloads the prior solution
- **WHEN** a player reopens the editor for a completed exercise
- **THEN** the editor is preloaded with the player's last successful submission for that exercise

#### Scenario: Player clears the preloaded solution to redo the exercise
- **WHEN** a player chooses to clear the preloaded solution while reviewing a completed exercise
- **THEN** the editor is emptied and the player can write a new solution from scratch, with the original exercise prompt still available

### Requirement: Journal as Primary Navigation
The system SHALL present a chronological log/journal of completed entries as the application's primary navigation screen, and SHALL let the player open any entry from it to review the corresponding module.

#### Scenario: Player browses the journal to find a past entry
- **WHEN** a player opens the journal screen
- **THEN** completed entries are listed in chronological order, and selecting an entry reopens the corresponding module in review mode

### Requirement: Skill Tree as Secondary Navigation
The system SHALL provide a curriculum/skill-tree view, distinct from the journal, showing the base course and advanced tracks with their completion and lock state, accessible as a secondary tab from the journal.

#### Scenario: Player checks track progress in the skill tree view
- **WHEN** a player switches to the skill-tree tab
- **THEN** the base course and each advanced track are shown with their current completed/available/locked state
