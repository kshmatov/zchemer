## ADDED Requirements

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
