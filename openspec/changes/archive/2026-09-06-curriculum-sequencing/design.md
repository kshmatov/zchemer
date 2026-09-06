## Context

See `proposal.md` for motivation. The graph itself is not new — it was fixed in prose/ASCII-diagram form by `define-base-course-skill-graph`'s design.md and carried forward by `base-course-content`'s design.md (its "Reference: the finalized base-course skill graph" section). This change is the first to turn that diagram into data a program can query, and to build the gating logic `curriculum`'s spec already requires.

## Goals / Non-Goals

**Goals:**
- Encode the fixed graph (base course + both enabled tracks' intro chains + their workspaces) as data.
- Implement `module-status`/`available-modules` exactly matching `curriculum`'s Base Course Scope, Free Advanced Track Selection, and Completed Module Accessibility requirements.
- Distinguish enabled vs. planned tracks per `advanced-project-sandboxes`' Unavailable Tracks requirement.

**Non-Goals:**
- Reading/writing the actual completed-set from a save file — that's `progress-persistence`'s job; this module takes a completed-set as a plain input and returns statuses, with no I/O of its own.
- Any GUI presentation (skill tree, journal) — `gui-lcars`'s job.
- Rank/achievement computation — `game-progression`'s job.

## Decisions

### Every module (lesson node or workspace) is one flat table entry with direct prerequisites
`engine/curriculum.rkt` represents the whole graph as one list of `(module-id . prereqs)` pairs, where `prereqs` is a list that may contain either real module ids (an ordinary edge) or the single virtual token `'base-course`, which the query logic expands to "every one of the ten base-course node ids" rather than treating it as a literal completed module. This directly encodes `curriculum`'s Base Course Scope requirement (a track's first node needs the *entire* base course, not just the specific nodes it conceptually builds on) without hand-listing all ten base-course ids as prerequisites on every track-intro node.

Alternative considered: giving each track-intro node explicit prerequisites on only the base-course nodes it actually builds on (e.g., `symbolic-data` depending on nothing in particular, `environment-model` depending on `closures`+`data-structures`) — rejected, since `curriculum`'s Base Course Scope requirement is explicitly monolithic ("require its completion" — the whole course — "before any advanced track becomes available"), not a per-skill dependency; encoding it any other way would silently reintroduce the "teach only what's needed" placement question that `define-base-course-skill-graph` already resolved by promoting shared skills into the base course.

### Table entries, in full:

```
s-expr-basics       : ()
binding             : (s-expr-basics)
conditionals        : (binding)
first-class-fn      : (conditionals)
recursion-basic     : (first-class-fn)
mutable-state       : (first-class-fn)
data-structures     : (first-class-fn)
tail-recursion      : (recursion-basic)
closures            : (tail-recursion)
higher-order-fn     : (closures)

symbolic-data              : (base-course)
environment-model          : (symbolic-data)
interpreter-eval-workspace  : (environment-model)

concurrency-primitives      : (base-course)
multitasking-ledger-workspace : (concurrency-primitives)
```

`interpreter-eval-workspace` and `multitasking-ledger-workspace` are the module ids for each track's main workspace (implemented in `track-workspaces`'s `engine/interpreter-workspace.rkt`/`engine/multitasking-workspace.rkt`) — this change only adds them as graph nodes for sequencing purposes; it does not change those modules.

### `module-status` computation
`(module-status id completed-set)` returns:
- `'completed` if `id` is in `completed-set`.
- `'available` if not completed and every direct prerequisite is satisfied — where `'base-course` is satisfied only when all ten base-course node ids are in `completed-set`, and any other prerequisite id is satisfied when it is itself in `completed-set`.
- `'locked` otherwise.

This directly matches `curriculum`'s Completed Module Accessibility requirement too: since status is a pure function of `completed-set` membership plus static edges, a module already in `completed-set` always reports `'completed` regardless of anything else — there is no separate "unlock" state to accidentally revert.

### Enabled vs. planned tracks as a separate small table, not graph nodes
`network`, `database`, and `oop` have no lessons yet, so they are not entries in the module table at all — they are listed only in a separate `PLANNED-TRACKS` constant (alongside `ENABLED-TRACKS` for `interpreter`/`multitasking`), matching `advanced-project-sandboxes`' "Planned tracks have no modules" scenario directly by construction rather than by a filter.

## Risks / Trade-offs

- [Hard-coding the graph as a literal table duplicates what's already described in `base-course-content`'s design.md prose] → Accepted, same trade-off already made by every prior content change: the prose stays the human-readable reference, this table is the first machine-readable copy, and both changes' `design.md`s explicitly cross-reference each other so drift is visible if the graph ever changes.

## Open Questions

(none)
