## Purpose

Defines the concrete module graph — node ids, prerequisite edges, and track groupings — that `curriculum`'s structural requirements (Base Course Scope, Explicit Prerequisite Graph, Track Availability Boundary) assume exists as queryable data.

## ADDED Requirements

### Requirement: Graph Matches the Fixed Base-Course Skill Graph
The graph data SHALL encode all ten base-course nodes with exactly the edges fixed by `define-base-course-skill-graph`'s design: `s-expr-basics` → `binding` → `conditionals` → `first-class-fn`, then three independent branches (`recursion-basic` → `tail-recursion` → `closures` → `higher-order-fn`, `mutable-state`, `data-structures`), each requiring only `first-class-fn`.

#### Scenario: Base-course edges match the fixed graph
- **WHEN** the graph data is loaded
- **THEN** each of the ten base-course node ids is present with exactly its fixed direct prerequisites, and no base-course node has a prerequisite outside the base course

### Requirement: Track Intro Nodes Gate on Full Base-Course Completion, Not Individual Nodes
Each enabled track's first module SHALL depend on every base-course node being complete, not merely on the specific base-course nodes that track's content happens to build on, matching `curriculum`'s Base Course Scope requirement.

#### Scenario: Interpreter track's first node requires the whole base course
- **WHEN** the graph data is loaded
- **THEN** `symbolic-data`'s prerequisite is "the entire base course," and completing only the base-course nodes `closures` and `data-structures` (which `symbolic-data`/`environment-model` conceptually build on) does not by itself satisfy it

#### Scenario: Multitasking track's first node requires the whole base course
- **WHEN** the graph data is loaded
- **THEN** `concurrency-primitives`' prerequisite is likewise "the entire base course"

### Requirement: Track Internal Chains and Workspace Prerequisites
Within an enabled track, later nodes SHALL depend on that track's own earlier nodes (`environment-model` depends on `symbolic-data`), and each track's main workspace SHALL depend on that track's full intro chain being complete (the Interpreter workspace on `environment-model`; the Multitasking workspace on `concurrency-primitives`).

#### Scenario: environment-model requires symbolic-data
- **WHEN** the graph data is loaded
- **THEN** `environment-model`'s prerequisites include `symbolic-data`

#### Scenario: Each track's workspace requires its track's intro chain
- **WHEN** the graph data is loaded
- **THEN** the Interpreter workspace module's prerequisites include `environment-model`, and the Multitasking workspace module's prerequisites include `concurrency-primitives`

### Requirement: Enabled vs. Planned Tracks Are Distinguished in the Data
The data SHALL list `interpreter` and `multitasking` as enabled tracks, and SHALL separately list `network`, `database`, and `oop` as planned-but-not-yet-built tracks with no modules, matching `advanced-project-sandboxes`' "Unavailable Tracks Are Visible but Disabled" requirement.

#### Scenario: Enabled tracks are queryable
- **WHEN** the graph data is loaded
- **THEN** `interpreter` and `multitasking` are reported as enabled

#### Scenario: Planned tracks have no modules
- **WHEN** the graph data is loaded
- **THEN** `network`, `database`, and `oop` are reported as planned-but-not-enabled, and none of them contributes any module to the graph
