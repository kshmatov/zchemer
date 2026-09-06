## Context

See `proposal.md` for motivation. This reuses, rather than re-decides, the content format fixed by `base-course-content` (`openspec/changes/archive/2026-09-06-base-course-content/design.md`): one directory per lesson, `lesson.md` (front matter + `## Log Entry` + `## Exercise`) and `tests.rktd` (a list of `(call <expression> expected)` cases), with an optional `checks.rktd`. That change's design.md remains the reference for the base course's own ten nodes; this change only extends the same format to two new track-scoped content roots.

## Goals / Non-Goals

**Goals:**
- Write the three track-intro lessons (`symbolic-data`, `environment-model`, `concurrency-primitives`) using the existing content format, unchanged.
- Keep each track-intro lesson gradable without depending on the (not-yet-built) main-workspace grading harness for its track.

**Non-Goals:**
- Redeciding the content file format — already fixed by `base-course-content`.
- Building the Interpreter track's `eval`/`apply` grading harness or the Multitasking track's concurrency-workspace grading harness (`advanced-project-sandboxes`) — both are separate, larger future changes.
- Achievement-condition logic — out of scope, same as `base-course-content`.

## Decisions

### Content roots: `content/interpreter-track/` and `content/multitasking-track/`
Mirrors `content/base-course/`'s `NN-<node-id>/` numbering, scoped per track since these nodes are track-local (unlike the base course's shared nodes): `content/interpreter-track/01-symbolic-data/`, `content/interpreter-track/02-environment-model/`, `content/multitasking-track/01-concurrency-primitives/`.

### concurrency-primitives lesson is graded deterministically, unlike the future Multitasking workspace
The Multitasking track's main workspace (per `advanced-project-sandboxes`) must tolerate genuine non-deterministic thread interleaving and grade by repeated execution against an invariant. This lesson's exercise is deliberately scoped smaller: it asks the player to use a `semaphore` to force a specific, fully-synchronized final outcome (e.g., two threads incrementing a shared counter a fixed number of times each, guarded so the final total is always the same regardless of interleaving), so its `tests.rktd` can use the same single-expected-value `call` format as every other lesson, with no repeated-run grading logic. This keeps the lesson content-only (no new test-execution mechanics) while still giving the player their first real exposure to `thread`/`semaphore`/`channel` before the workspace's harder, order-independent grading.

Alternative considered: writing the lesson's test to already tolerate non-determinism (matching the eventual workspace's grading style) — rejected, since that grading mechanism doesn't exist yet and building it here would smuggle main-workspace scope into an intro-content change.

### environment-model builds directly on closures + data-structures, not on symbolic-data's data representation
The lesson explains representing an environment as a chain of frames (each frame a data structure mapping names to values, chained via a parent-frame reference) built from `data-structures` (hash tables or assoc lists) and closures (a returned lookup procedure capturing its frame) — both already taught in the base course. It uses `symbolic-data` only incidentally (frames are themselves just data), not as a hard dependency beyond what the base course already provides.

## Risks / Trade-offs

- [Forcing the `concurrency-primitives` lesson into a deterministic shape trims how much of "real" concurrent non-determinism the player sees before the main workspace] → Acceptable: the lesson's job is to introduce the primitives' API, not to teach non-deterministic reasoning — that remains the main workspace's job per `advanced-project-sandboxes`.

## Open Questions

(none — the format, scope, and grading approach are all fixed by this design)
