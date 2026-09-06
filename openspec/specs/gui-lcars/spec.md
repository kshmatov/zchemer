# gui-lcars Specification

## Purpose

Defines the native desktop interface, styled after LCARS, covering both the inline code editor used for simple examples and the dedicated view for loaded multi-file projects.

## Requirements

### Requirement: Native Desktop Application
The game SHALL run as a native desktop application that does not require a browser and does not rely on a bundled web-rendering runtime to display its interface.

#### Scenario: Application launches as a native window
- **WHEN** a player launches the installed application
- **THEN** it opens as a native window rendered without a browser or embedded web view

### Requirement: Inline Code Editor for Simple Examples
The system SHALL provide an in-app code editor with syntax highlighting where a player can write and run short Scheme snippets directly, without leaving the application.

#### Scenario: Player writes and runs a snippet inline
- **WHEN** a player opens a base-course lesson
- **THEN** an in-app editor is available for typing and executing Scheme code, with results shown in the same view

### Requirement: Dedicated Loaded-Project View
The system SHALL provide a view distinct from the inline single-snippet editor for working with a loaded multi-file project, showing the project's files and allowing them to be edited and run.

#### Scenario: Loading a project switches to project view
- **WHEN** a player loads a project folder
- **THEN** the interface switches to a project view that lists the project's files and lets the player edit and run them

### Requirement: Consistent LCARS Visual Styling
The interface SHALL apply LCARS-inspired visual conventions (panel shapes, color-coded regions, typography) consistently across the lesson, editor, and project views.

#### Scenario: Visual language is consistent across screens
- **WHEN** a player navigates between the lesson, inline editor, and project views
- **THEN** the panel shapes, color coding, and typography remain visually consistent

### Requirement: Review Mode Editor
When a player reopens a completed exercise's inline editor, the system SHALL preload the player's last successful submission for that exercise, and SHALL let the player clear it to restart the exercise from a blank state.

#### Scenario: Reopening a completed exercise preloads the prior solution
- **WHEN** a player reopens the editor for a completed exercise
- **THEN** the editor is preloaded with the player's last successful submission for that exercise

#### Scenario: Player clears the preloaded solution to redo the exercise
- **WHEN** a player chooses to clear the preloaded solution while reviewing a completed exercise
- **THEN** the editor is emptied and the player can write a new solution from scratch, with the original exercise prompt still available

### Requirement: Review Mode for Loaded Projects
When a player reopens a completed project-based exercise, the system SHALL open the Dedicated Loaded-Project View against the exercise's retained folder path and entry-point file, letting the player re-run the exercise's checks without affecting its completion status, rank, or previously earned achievements beyond what `game-progression`'s review-grading requirements already define.

#### Scenario: Reopening a completed project reopens its saved folder
- **WHEN** a player reopens a completed project-based exercise
- **THEN** the loaded-project view opens against the folder path and entry-point file retained for that exercise, with the player's existing project files as last left on disk

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
