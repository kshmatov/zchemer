## ADDED Requirements

### Requirement: Last Successful Submission Retained
For each completed inline exercise, the system SHALL retain the source of the player's most recent successful submission alongside its completion state, updating it whenever a later successful submission is made — including during review — so it can be reloaded when the player revisits the exercise.

#### Scenario: Last successful submission survives a relaunch
- **WHEN** a player completes an exercise and later closes and reopens the application
- **THEN** the source of their most recent successful submission for that exercise is still available, unchanged, on relaunch

#### Scenario: A later successful resubmission during review replaces the retained source
- **WHEN** a player, while reviewing a completed exercise, resubmits a different solution that also passes
- **THEN** the newly passing solution replaces the previously retained source as the exercise's most recent successful submission

### Requirement: Project-Based Exercise Reference Retained
For each completed project-based exercise (a loaded multi-file project per `advanced-project-sandboxes`), the system SHALL retain the local folder path, the selected entry-point file, and the pass/fail status of the player's most recent grading, rather than a copy of the project's source files, since those already persist on the player's local filesystem.

#### Scenario: Project reference survives a relaunch
- **WHEN** a player completes a project-based exercise and later closes and reopens the application
- **THEN** the recorded folder path, entry-point file, and pass/fail status for that exercise are still available on relaunch

#### Scenario: Referenced project folder is missing on review
- **WHEN** a player reopens a completed project-based exercise and the recorded folder path no longer resolves to an existing project
- **THEN** the system reports that the project folder could not be found rather than crashing, and lets the player re-select a folder without losing the exercise's completed status
