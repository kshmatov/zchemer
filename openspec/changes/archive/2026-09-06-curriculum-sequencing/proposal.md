## Why

`curriculum` already specifies, in detail, how the base course and advanced tracks must gate and unlock (Base Course Scope, Free Advanced Track Selection, Explicit Prerequisite Graph, Track Availability Boundary, Completed Module Accessibility), and the base-course skill graph's exact nodes and edges have been fixed in prose/diagram form since `define-base-course-skill-graph` — but none of it exists as data or code a program can query. Right now, nothing in the repo can answer "given what this player has completed, which module should they see as available next?" This change encodes the graph as data and builds the query logic `curriculum` already specifies.

## What Changes

- Encode the full module graph as data: the 10 base-course nodes and their edges (from `define-base-course-skill-graph`'s design.md, also carried in `base-course-content`'s design.md), the two enabled tracks' intro chains (Interpreter: `symbolic-data` → `environment-model`; Multitasking: `concurrency-primitives`) gated on full base-course completion, and each track's main workspace gated on its intro chain's completion.
- Add `engine/curriculum.rkt`: given a set of completed module ids, reports every module's status (`'completed` / `'available` / `'locked`), and reports which tracks are enabled vs. planned-but-not-yet-built.
- Automated `rackunit` tests covering: a track's intro locked before full base-course completion, all enabled tracks' first modules simultaneously available (and independently progressable) once the base course is done, and a completed module's status never reverting.

## Capabilities

### New Capabilities
- `curriculum-graph-content`: The concrete module graph — node ids, edges, and track groupings — that `curriculum`'s structural requirements assume exists as queryable data.

### Modified Capabilities
(none — the gating/query logic is pure implementation of `curriculum`'s already-specified requirements; no requirement changes)

## Impact

- Adds `engine/curriculum.rkt` and its capability's fixed graph data.
- No content changes — this only encodes the graph that content changes (`base-course-content`, `track-intro-content`) and the workspace changes (`track-workspaces`) already assume.
- Out of scope: progress persistence (reading/writing the actual completed-set from a save file — `progress-persistence`'s job), the GUI's skill-tree/journal views (`gui-lcars`), and rank/achievement logic (`game-progression`) — this change only answers "what's available given a completed-set," not where that set comes from or how it's displayed.
