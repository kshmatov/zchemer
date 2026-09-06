## Purpose

Defines the concrete lesson content — instructional text, exercise, and automated tests — that fills each node of the base-course skill graph, as distinct from `curriculum`'s structural rules about ordering and gating.

## ADDED Requirements

### Requirement: Complete Base-Course Lesson Coverage
The content SHALL define exactly one lesson for each node of the base-course skill graph (`s-expr-basics`, `binding`, `conditionals`, `first-class-fn`, `recursion-basic`, `tail-recursion`, `mutable-state`, `data-structures`, `closures`, `higher-order-fn`), in that fixed order, and SHALL NOT bundle a lesson for any node outside this graph (advanced-track intro nodes are out of scope for this content set).

#### Scenario: All ten base nodes have a lesson
- **WHEN** the base-course content set is assembled
- **THEN** each of the ten named nodes has exactly one corresponding lesson, and no node is missing or duplicated

#### Scenario: Advanced-track intro node is not included
- **WHEN** the base-course content set is assembled
- **THEN** no lesson for `symbolic-data`, `environment-model`, or `concurrency-primitives` is present in it

### Requirement: Lesson Content Package
Each base-course lesson SHALL consist of first-person log-entry instructional text introducing the node's concept, an exercise prompt describing a task the player writes Scheme code to solve, and a set of automated test cases sufficient to grade a submission against that prompt.

#### Scenario: Lesson package has all three parts
- **WHEN** a base-course lesson is authored
- **THEN** it includes instructional text, an exercise prompt, and at least one automated test case, and none of the three is left as a placeholder

### Requirement: Lesson Scope Matches Its Skill Node
A lesson's instructional text and exercise SHALL only require constructs already introduced by its own node or an earlier node in the fixed order, and SHALL NOT require a construct first introduced by a later node.

#### Scenario: Early lesson does not require a later construct
- **WHEN** the `binding` lesson's exercise is written
- **THEN** it requires only `define` and `let` (and constructs from `s-expr-basics`), and does not require `lambda`, `set!`, or any construct first introduced by a later node

#### Scenario: A lesson may reuse any earlier node's constructs freely
- **WHEN** the `closures` lesson's exercise is written
- **THEN** it may freely use constructs from `s-expr-basics`, `binding`, `conditionals`, `first-class-fn`, `recursion-basic`, and `tail-recursion`, since those precede it in the fixed order
