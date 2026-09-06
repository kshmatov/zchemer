## Context

See `proposal.md` for motivation. This change builds on the stack and architecture already fixed in `openspec/changes/archive/2026-09-06-define-project-scope/design.md` (Racket, `racket/gui`, `racket/sandbox`, S-expression save format, DAG-based prerequisite graph). It does not revisit those decisions; it fills in two gaps left open there: where a shared skill is taught, and what happens when a player revisits completed content.

## Goals / Non-Goals

**Goals:**
- Fix a placement rule for skills shared across advanced tracks, so base-course and track content can be authored without duplicating teaching of the same skill.
- Define review as a non-persisted navigation mode over already-completed content, so it requires no new save-file state.
- Fix which of rank/completion vs. achievements are idempotent under review re-submission, and why they differ.

**Non-Goals:**
- Enumerating the actual base-course/track skill list (content authoring, not architecture — happens once this placement rule exists).
- Visual design of the journal or skill-tree screens (a `gui-lcars` implementation change's concern, per the existing non-goal in the archived design).
- Grading mechanics for the Multitasking track's non-deterministic checks (separate open thread, not part of this change).

## Decisions

### Shared-skill placement rule: base course if ≥2 enabled tracks need it, else track-intro
A skill is taught in the base course only if two or more *currently enabled* advanced tracks require it (in the MVP: `closures` and `mutable-state`, both needed by Interpreter and Multitasking). A skill needed by exactly one enabled track is taught as that track's own introductory module (in the MVP: `symbolic-data`, needed only by the Interpreter track) but is still recorded as a shared node in the prerequisite graph, so a future track that also needs it does not re-teach it — the graph lookup already described in the archived design (`curriculum` capability, module unlocks via granted-skills set) is enough to make this work without special-casing.

Alternatives considered: teaching every shared-capable skill in the base course regardless of how many tracks currently need it (rejected — bloats the mandatory base course with content only one track uses, contradicting the "free choice of advanced tracks" framing); deciding placement per-skill by hand with no general rule (rejected — reintroduces the risk of inconsistent, ad hoc duplication as more tracks are added later, e.g. Database or OOP).

### Review is a transient UI mode, not a persisted state
Reopening a completed module enters a `reviewing` mode that exists only in the UI layer. The persisted module state stays `completed`; no new field is added to the save format. This keeps `progress-persistence` untouched by this change — review is purely a `curriculum` (accessibility) and `gui-lcars` (editor + navigation) concern.

```
locked -> available -> in-progress -> completed
                                          |
                                          | player-initiated, any time
                                          v
                                     reviewing (transient, not persisted)
```

### Review submissions are graded for feedback but are idempotent on rank/completion
Static checks and automated tests still run on a review re-submission (Variant B, confirmed in discussion: the player can clear the preloaded solution and redo the exercise, which requires real pass/fail feedback to be meaningful). The result is shown to the player but does not re-grant rank or re-trigger completion, since both are already satisfied and re-granting would make progress trackable-but-inflatable by repeatedly re-passing the same exercise.

### Achievements remain evaluable during review, unlike rank/completion
Achievements are evaluated per-submission against a condition (e.g., an elegant/optimized solution) rather than being a monotonic completion counter. A player who finds a better solution during review has produced something the achievement system has not yet seen, so the same evaluation that runs on first-pass submissions runs on review submissions, and grants the achievement if the condition is newly met. This is a deliberate asymmetry from rank/completion: rank measures curriculum advancement (which review cannot re-advance, since the module is already past that point), while achievements measure the quality of a specific submission (which review can still discover).

### Navigation: journal is primary, skill tree is secondary
The journal (chronological log of completed entries, opening an entry enters review) is the primary/default screen, reusing the "log-entry" instructional framing already fixed in `game-progression` as the app's main navigational metaphor rather than only its lesson-text format. The skill-tree/curriculum view (structure, lock state, what's next) is a secondary tab for players who want to plan by structure rather than browse by history. Both views read the same underlying state (`curriculum` module states + `progress-persistence` save data); neither owns state the other lacks.

## Risks / Trade-offs

- [Loading the player's last successful submission into the editor on review requires the save data or a companion store to retain submission source, not just a pass/fail flag] → Scope note for the eventual `progress-persistence` implementation change: it must retain last-successful-source per exercise, not only completion booleans. Not a spec change here since `progress-persistence`'s existing "human-inspectable save format" requirement already permits this without contradiction; flagged so it isn't missed during implementation.
- [Two navigation views (journal + skill tree) reading the same state could drift if implemented independently] → Keep both as read-only views over one shared state source; no separate synchronization logic should be needed if neither view owns state.

## Open Questions

- Exact visual/interaction design of the journal and skill-tree screens — deferred to the `gui-lcars` implementation change, consistent with the existing deferral of LCARS visual detail in the archived design.
