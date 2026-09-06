## Why

The base course is currently defined only as an ordered skill graph (`openspec/changes/archive/2026-09-06-define-base-course-skill-graph/design.md`) — a list of node names and why each is placed where it is. No lesson content exists for any node, so the mandatory base course that gates every advanced track (`curriculum` — Base Course Scope) cannot actually be built or played yet. This change fixes the content itself: one lesson per base-course node, in the graph's fixed order, each satisfying the log-entry delivery and code-evaluation grading rules already specified elsewhere.

## What Changes

- Define a lesson content structure (log-entry instructional text, exercise prompt, automated test cases, and any static-check rule) that a future engine can parse, without building that engine here.
- Author one lesson per base-course node, in the skill graph's fixed order: `s-expr-basics`, `binding`, `conditionals`, `first-class-fn`, `recursion-basic`, `tail-recursion`, `mutable-state`, `data-structures`, `closures`, `higher-order-fn`.
- Record the finalized skill graph's ordering and per-node scope inside this change's `design.md` (carrying forward the still-open task from `define-base-course-skill-graph`'s tasks.md item 2.2), so track-intro content authors (Interpreter, Multitasking) have a live reference instead of only the archived change.
- Each lesson's instructional text follows `game-progression`'s Log-Entry Instructional Delivery requirement (first-person log/journal style, no character dialogue) and its No Scripted Narrative Missions requirement (LCARS visual chrome and log text only, no mission/cutscene framing).
- Each lesson's exercise and tests follow `code-evaluation`'s requirements: automated test-based grading, unlimited retry, and a static check only where the lesson actually disallows a construct (most base lessons will have none).

## Capabilities

### New Capabilities
- `base-course-content`: The concrete lesson content (instructional text, exercise, tests) for each base-course skill node, and the content structure used to write it down consistently.

### Modified Capabilities
(none — no existing spec's requirements change; this adds content governed by already-specified rules in `curriculum`, `game-progression`, and `code-evaluation`)

## Impact

- New `openspec/specs/base-course-content/spec.md` capability.
- No source code changes (no engine exists yet to consume this content); `design.md` fixes the content format so a future GUI/curriculum engine change can parse it without re-deciding structure.
- Unblocks: Interpreter track's `symbolic-data`/`environment-model` intro content and Multitasking track's `concurrency-primitives` intro content (tasks 3.2/3.3 of `define-base-course-skill-graph`), which assume the base course's lesson format and completion semantics already exist.
