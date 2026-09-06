## Context

See `proposal.md` for motivation. `engine/curriculum.rkt` (from `curriculum-sequencing`) already defines the module-id vocabulary (`s-expr-basics`, ..., `interpreter-eval-workspace`, `multitasking-ledger-workspace`) that this module's `completed-modules` set uses; `engine/lesson-grader.rkt` grades an inline lesson submission and returns pass/fail, but doesn't retain anything — this module is what a future caller uses to persist that result.

## Goals / Non-Goals

**Goals:**
- Implement every `progress-persistence` requirement: local account-free save, human-readable format, per-track independence, resilience to missing/corrupt data, last-successful-submission retention (including replacement during review), and project-based exercise reference retention.
- Keep `progress-state` a plain immutable value with pure update functions, matching the functional style already used by `curriculum.rkt`.

**Non-Goals:**
- Deciding *when* to call `mark-completed`/`record-submission` (that's the future curriculum-engine-to-GUI wiring change's job) — this module only provides the primitives.
- Implementing "loading a project folder" itself — `record-project-ref` just persists whatever folder path/entry-point/pass-fail it's given.
- Achievement/rank derivation from progress data (`game-progression`) — out of scope, same as every prior change.

## Decisions

### On-disk format: one S-expression, association lists throughout (no hash-literal syntax)
```
((completed-modules . (s-expr-basics binding ...))
 (last-submissions . ((s-expr-basics . "(quote (hull shields sensors))") ...))
 (project-refs . ((interpreter-eval-workspace . (folder-path "/path/to/project" entry-point "main.rkt" pass-fail #t)) ...)))
```
Plain association lists were chosen over Racket's `#hash(...)` literal syntax for the two nested tables: `progress-persistence`'s Human-Inspectable Save Format requirement asks for something "legible without requiring specialized tools," and an alist reads as unambiguous plain data to someone unfamiliar with Racket's reader extensions, whereas `#hash(...)` looks like syntax rather than data at a glance. Internal lookups still use `assq`, exactly like `curriculum.rkt`'s `MODULE-TABLE`.

### `progress-state` is an immutable struct; every update returns a new value
```racket
(struct progress-state (completed-modules last-submissions project-refs) #:transparent)
```
`mark-completed`, `record-submission`, and `record-project-ref` each take a `progress-state` and return a new one, matching `curriculum.rkt`'s style (no mutation, no hidden state) and making `save-progress` simply "serialize whatever `progress-state` you were handed" with no separate dirty-tracking to get wrong.

### Resilience: `load-progress` never raises
`load-progress` returns `(fresh-progress)` whenever the file doesn't exist (`file-exists?` check) or `read` raises reading it (caught with `exn:fail?`), per the Resilience to Missing or Corrupt Save Data requirement's own scenario ("start normally with a fresh progress record instead of crashing").

### Per-track independence: no special-cased mechanism needed
Both `completed-modules` (a flat set of ids drawn from `curriculum.rkt`'s module table, which already keeps each track's ids and edges disjoint) and `last-submissions`/`project-refs` (keyed by module id) naturally keep every track's state independent without this module doing anything special — the same "just a set/table of ids" property `curriculum-sequencing`'s design already relied on for Free Advanced Track Selection carries over here directly.

### `record-submission` always replaces, matching the "last successful" contract
`record-submission` doesn't check whether a prior entry exists — it just sets `(module-id . src)` in `last-submissions`, overwriting any previous value. This directly implements both of `progress-persistence`'s submission scenarios (a fresh completion retains its source; a later passing resubmission during review replaces it) with one code path, since "replace unconditionally" already covers "insert for the first time."

## Risks / Trade-offs

- [Storing full submission source text for every completed inline lesson could make the save file large if the base course/tracks grow substantially] → Acceptable for the current 13-lesson scope; `progress-persistence`'s own spec explicitly requires retaining full source (not a hash/diff), so this isn't a design choice this module can trade away.

## Open Questions

(none)
