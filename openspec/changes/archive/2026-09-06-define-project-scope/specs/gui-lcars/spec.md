## Purpose

Defines the native desktop interface, styled after LCARS, covering both the inline code editor used for simple examples and the dedicated view for loaded multi-file projects.

## ADDED Requirements

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
