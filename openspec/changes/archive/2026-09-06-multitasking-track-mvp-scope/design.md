## Context

See `proposal.md` for motivation. This builds on the MVP track scope fixed in the archived `define-project-scope` change and the skill graph fixed in `curriculum-review-and-navigation` / `define-base-course-skill-graph`, which already placed `concurrency-primitives` as the Multitasking track's own intro module (needed by only this track in the MVP). It resolves the track's remaining open questions: primitive scope, invariant-grading mechanics, and exercise progression.

## Goals / Non-Goals

**Goals:**
- Fix a concrete, minimal MVP concurrency primitive set and grading mechanic for the Multitasking track.
- Fix the exercise progression within the track's intro module and main exercises.

**Non-Goals:**
- Designing the speculative "Advanced Concurrency" track (`sync`, `place`, `future`) — noted as a future possibility only. If pursued, it needs its own placement-rule pass per `curriculum`'s Shared-Skill Base Course Placement requirement, like any new track.
- Writing the reference exercise suite itself or the `concurrency-primitives` intro lesson content — content authoring, follow-up work.
- Fixing the exact number of repeated grading runs or the stress-load shape (thread/iteration counts) of reference exercises — implementation/content-authoring detail, not an architectural decision.

## Decisions

### MVP primitive set: `thread`, `semaphore`, `channel`
These three cover both dominant synchronization paradigms — shared-memory-with-locks (`semaphore`) and message-passing (`channel`) — on top of the concurrency unit (`thread`) the track is fundamentally about. `sync` is deferred because it composes on top of these (waiting on multiple events/timeouts at once) rather than being needed for a first exercise in either paradigm.

`place` and `future` were considered and rejected for this MVP, not merely deferred for scope reasons: `place` isolates memory per place (communication only via place-channels), so the shared-state races the track's grading is built around (`advanced-project-sandboxes` — "final shared state or absence of race conditions") cannot occur between places at all — it teaches a genuinely different lesson (isolation-based parallelism), not a deeper version of this one. `future` targets data-parallel performance on side-effect-free code under restrictions on which operations actually parallelize — a narrow, performance-oriented tool, not general multitasking. Both remain plausible content for a speculative future "Advanced Concurrency" track, alongside `sync`.

### Grading: repeated execution, per-exercise invariant predicate
Since Racket's scheduler provides genuine non-simulated scheduling (already required by `scheme-runtime`), a single run cannot prove the absence of a race — the race may simply not have manifested that time. Grading therefore runs the player's solution multiple times, checking each exercise's own invariant predicate (author-defined per exercise — e.g., "final counter equals thread-count × iterations," "no item is dequeued twice") after every run; any single violating run fails the exercise. This is the same "automated test against expected results" mechanism `code-evaluation` already requires generically — the expected result is expressed as an invariant predicate evaluated across repeated runs, rather than a single exact-value match.

Reference exercises should be designed (thread/iteration counts high enough) to make a genuine race manifest with high probability within a bounded number of runs — a standard stress-testing technique for concurrent code, not a system-level mechanism, so it belongs to content authoring rather than this design.

### Exercise progression: fix-the-race, then design-from-scratch
The `concurrency-primitives` intro module's own practice exercise gives the player a working-but-unsafe solution (e.g., an unsynchronized shared counter) and asks them to locate and fix the race — this makes the failure mode tangible before asking the player to design synchronization from a blank page. The track's main exercises (producer/consumer, bounded buffer, worker pool) are then design-from-scratch, once the primitives and the shape of the failure are both already familiar. This mirrors the Interpreter track's progression (understand the model via `symbolic-data`/`environment-model` before building `eval` itself) and is a content-sequencing decision, not a spec-level requirement — no player-observable system behavior hinges on which exercise comes first, only what future content authoring should produce.

## Risks / Trade-offs

- [Repeated-run grading reduces but does not eliminate false negatives — a genuinely unsafe solution can still pass by chance if the race window is too narrow relative to the run count] → Mitigate through reference-exercise design (wide race windows via thread/iteration count), not by claiming the grading mechanism is a proof; this is an inherent limitation of testing concurrent code, not specific to this game.
- [Repeated execution makes Multitasking exercises take measurably longer to grade than single-shot exercises elsewhere in the game] → Acceptable trade-off; exact run count is an implementation detail that can be tuned once real exercises exist and their timing is known.

## Open Questions

(none — all decisions needed to write the reference exercise suite and intro content are fixed above)
