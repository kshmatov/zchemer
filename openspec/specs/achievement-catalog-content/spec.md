# achievement-catalog-content Specification

## Purpose

Defines the concrete starter catalog of achievement conditions — which module, what condition, what label — that `game-progression`'s Achievements for Notable Actions requirement assumes exists, demonstrating the generic mechanism against real lessons without attempting to be an exhaustive catalog for every module.

## Requirements

### Requirement: Achievement Catalog Coverage
The catalog SHALL define at least one achievement condition for at least three distinct modules, using distinct condition styles (not three copies of the same check parameterized differently), to demonstrate the mechanism is general rather than a single hard-coded special case.

#### Scenario: At least three modules have an achievement condition
- **WHEN** the achievement catalog is assembled
- **THEN** at least three distinct module ids each have at least one achievement condition defined for them

### Requirement: Achievement Conditions Are Independent of, but Subsequent to, Correctness Grading
An achievement condition SHALL only be evaluated for a submission that has already passed the exercise's own correctness tests; a submission that fails its exercise's tests SHALL NOT earn an achievement for that exercise, regardless of what the achievement's condition checks.

#### Scenario: An incorrect solution never earns an achievement
- **WHEN** a submission fails its exercise's automated tests
- **THEN** no achievement for that exercise is granted, even if the submission's source would otherwise satisfy an achievement condition

#### Scenario: A correct solution meeting a condition earns its achievement
- **WHEN** a submission passes its exercise's automated tests and its source satisfies one of that module's achievement conditions
- **THEN** the corresponding achievement is granted

### Requirement: Idempotent Achievement Granting
Granting an achievement the player has already earned SHALL be a no-op: it SHALL NOT appear twice in the player's earned-achievements record.

#### Scenario: Re-earning an already-granted achievement does not duplicate it
- **WHEN** a submission that would grant an achievement is made after that same achievement was already granted previously
- **THEN** the player's earned-achievements record still lists that achievement exactly once
