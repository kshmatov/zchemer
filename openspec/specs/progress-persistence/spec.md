# progress-persistence Specification

## Purpose

Defines how a player's progress — curriculum completion, rank/achievements, and per-track state — is saved locally and restored between sessions on the same machine.

## Requirements

### Requirement: Local, Account-Free Persistence
The system SHALL save player progress to a local file alongside the application, without requiring network access or a user account.

#### Scenario: Progress persists across relaunches
- **WHEN** a player completes a module and later closes and reopens the application
- **THEN** the module is still shown as completed on relaunch

### Requirement: Human-Inspectable Save Format
Saved progress SHALL be stored in a human-readable structured format (such as JSON or S-expressions), not a binary or proprietary format.

#### Scenario: Save file is readable in a text editor
- **WHEN** a player opens their save file in a plain text editor
- **THEN** the recorded progress is legible without requiring specialized tools

### Requirement: Independent Per-Track State
Progress for the base course and for each advanced track SHALL be tracked independently in the saved data.

#### Scenario: Tracks reflect independent completion state
- **WHEN** a player has completed one advanced track but not started another
- **THEN** the save data records each track's state separately and accurately

### Requirement: Resilience to Missing or Corrupt Save Data
If no save file exists, or an existing save file cannot be parsed, the system SHALL start a new progress record rather than failing to launch.

#### Scenario: Corrupt save does not block launch
- **WHEN** the application starts and the save file is missing or unreadable
- **THEN** the application starts normally with a fresh progress record instead of crashing or refusing to launch
