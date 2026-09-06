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

### Requirement: Shared-Skill Base Course Placement
The system SHALL place a skill in the base course when two or more advanced tracks enabled in the current version require it, and SHALL otherwise teach that skill as an introductory module within the single track that requires it, while still recording the skill as a shared node in the prerequisite graph so that a track requiring it later does not re-teach it.

#### Scenario: Skill required by two tracks is taught once in the base course
- **WHEN** a skill is a prerequisite for two or more enabled advanced tracks
- **THEN** the base course teaches that skill, and no advanced track repeats its introduction

#### Scenario: Skill required by a single track is taught as that track's intro module
- **WHEN** a skill is a prerequisite for exactly one enabled advanced track
- **THEN** that track's own introductory module teaches the skill, and the skill is still recorded as a shared graph node

#### Scenario: A skill later required by a second track is not retaught
- **WHEN** a skill was originally taught only within one track's intro module, and a newly enabled track also requires it
- **THEN** the newly enabled track recognizes the skill as already granted for any player who has completed it, and does not require the player to learn it again

### Requirement: Completed Module Accessibility
The system SHALL let a player reopen any module they have already completed, at any time, without altering its completion status or losing previously earned rank or achievements.

#### Scenario: Reopening a completed module preserves progress
- **WHEN** a player selects a module marked completed
- **THEN** the module reopens for review, and neither the completion status nor previously earned rank/achievements change as a result of opening it
