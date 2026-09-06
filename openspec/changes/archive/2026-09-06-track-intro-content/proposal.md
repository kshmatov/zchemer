## Why

The base course now has full lesson content (`openspec/specs/base-course-content/spec.md`, archived as `2026-09-06-base-course-content`), but both MVP advanced tracks still have no content at all — not even their intro lessons. The skill graph (`openspec/changes/archive/2026-09-06-define-base-course-skill-graph/design.md`) fixes `symbolic-data` → `environment-model` as the Interpreter track's intro and `concurrency-primitives` as the Multitasking track's intro, each required before a player can start that track's main workspace (`advanced-project-sandboxes`). This change writes that content, closing tasks 3.2 and 3.3 of the archived skill-graph change.

## What Changes

- Author one lesson for each of the three track-intro nodes, reusing the exact content format `base-course-content` established (per-node directory with `lesson.md` and `tests.rktd`), extended to two new track-scoped content roots: `content/interpreter-track/` and `content/multitasking-track/`.
- `01-symbolic-data`: `quote`/`quasiquote`, code as data.
- `02-environment-model`: representing a chain of lexical scopes as frames, composing `closures` + `data-structures` (both already taught in the base course) into an environment-chain model.
- `01-concurrency-primitives` (Multitasking): Racket's `thread`, `semaphore`, and `channel` API, scoped per `advanced-project-sandboxes`' Multitasking MVP boundary (no `sync`, no place/future-based parallelism).
- Each lesson assumes full base-course completion as its prerequisite (per `curriculum`'s Base Course Scope) and may freely use any base-course construct.

## Capabilities

### New Capabilities
- `track-intro-content`: The concrete lesson content (instructional text, exercise, tests) for each MVP advanced track's intro node(s), preceding that track's main project workspace.

### Modified Capabilities
(none — no existing spec's requirements change; this adds content governed by already-specified rules in `curriculum`, `game-progression`, `code-evaluation`, `scheme-runtime`, and `advanced-project-sandboxes`)

## Impact

- New `openspec/specs/track-intro-content/spec.md` capability.
- New content directories `content/interpreter-track/` and `content/multitasking-track/`, following the same file format as `content/base-course/`.
- No source code changes (still no engine to consume this content).
- Unblocks: the Interpreter track's main "write your own eval/apply" workspace and the Multitasking track's main concurrent-exercise workspace, both of which assume their track's intro concepts have already been taught.
