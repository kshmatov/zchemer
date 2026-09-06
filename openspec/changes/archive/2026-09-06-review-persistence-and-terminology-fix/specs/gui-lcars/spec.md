## MODIFIED Requirements

### Requirement: Review Mode Editor
When a player reopens a completed exercise's inline editor, the system SHALL preload the player's last successful submission for that exercise, and SHALL let the player clear it to restart the exercise from a blank state.

#### Scenario: Reopening a completed exercise preloads the prior solution
- **WHEN** a player reopens the editor for a completed exercise
- **THEN** the editor is preloaded with the player's last successful submission for that exercise

#### Scenario: Player clears the preloaded solution to redo the exercise
- **WHEN** a player chooses to clear the preloaded solution while reviewing a completed exercise
- **THEN** the editor is emptied and the player can write a new solution from scratch, with the original exercise prompt still available

## ADDED Requirements

### Requirement: Review Mode for Loaded Projects
When a player reopens a completed project-based exercise, the system SHALL open the Dedicated Loaded-Project View against the exercise's retained folder path and entry-point file, letting the player re-run the exercise's checks without affecting its completion status, rank, or previously earned achievements beyond what `game-progression`'s review-grading requirements already define.

#### Scenario: Reopening a completed project reopens its saved folder
- **WHEN** a player reopens a completed project-based exercise
- **THEN** the loaded-project view opens against the folder path and entry-point file retained for that exercise, with the player's existing project files as last left on disk
