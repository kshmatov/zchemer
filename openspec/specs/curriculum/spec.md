# curriculum Specification

## Purpose

Defines the structure of the learning path: a mandatory base language course followed by a free choice of advanced tracks, with an explicit prerequisite graph governing when topics unlock.

## Requirements

### Requirement: Base Course Scope
The system SHALL provide a base Scheme course covering syntax, recursion, and closures, and SHALL require its completion before any advanced track becomes available.

#### Scenario: Advanced track blocked before base course completion
- **WHEN** a player has not completed the base course
- **THEN** advanced tracks are shown as locked and the player is directed to the remaining base course modules

### Requirement: Free Advanced Track Selection
Once the base course is complete, the system SHALL let the player choose freely among the advanced tracks that are enabled in the current version, in any order.

#### Scenario: Player picks tracks in any order
- **WHEN** the base course is complete and multiple tracks are enabled
- **THEN** the player can start any enabled track first and switch between enabled tracks at will, with progress on each preserved independently

### Requirement: Explicit Prerequisite Graph
The system SHALL maintain an explicit graph of prerequisite skills between the base course and each advanced track, and SHALL use it to determine what a given module requires and what it grants.

#### Scenario: Shared prerequisite skill recognized across tracks
- **WHEN** a skill required by a module has already been granted by a previously completed module (in the base course or another track)
- **THEN** the system marks that prerequisite as satisfied and does not require the player to repeat equivalent introductory material

### Requirement: Track Availability Boundary
The system SHALL distinguish tracks that are enabled for play from tracks that are defined but not yet enabled, and SHALL present unavailable tracks as visibly planned rather than hiding or omitting them.

#### Scenario: Unavailable track shown as planned
- **WHEN** the player views the list of advanced tracks
- **THEN** tracks not enabled in the current version are visible but marked as unavailable, and cannot be started
