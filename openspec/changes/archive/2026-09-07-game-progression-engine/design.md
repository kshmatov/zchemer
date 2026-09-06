## Context

See `proposal.md`. Builds on `engine/progress.rkt` (extended additively), `engine/curriculum.rkt`'s `MODULE-TABLE` (15 total modules, used for rank thresholds), `engine/static-check.rkt`'s `read-all-forms` (reused for achievement conditions), and `gui/editor-panel.rkt`/`gui/project-panel.rkt`'s existing "on a pass" branches (from `inline-code-editor`/`project-view`).

## Goals / Non-Goals

**Goals:**
- A pure, derivable rank label from the completed-module count — no new persisted state beyond what already exists.
- A generic, extensible achievement-condition mechanism, seeded with three real, distinct-style conditions.
- Wire both the inline editor and project view to check achievements on every pass (including review passes), per Retroactive Achievement Recognition.
- Verify (not reimplement) Idempotent Review Grading: `mark-completed`'s existing no-op-if-already-completed behavior already satisfies it.

**Non-Goals:**
- An exhaustive achievement catalog for all 15 modules — three is enough to prove the mechanism generalizes across condition styles; more can be added to the table later without touching the mechanism.
- Any UI for previewing achievement conditions before earning them.
- Persisting rank as stored state — it's always recomputed from `completed-modules`, avoiding a second source of truth that could drift from actual completion.

## Decisions

### Rank: six Starfleet-style labels over the 15-module curriculum, purely derived
```racket
RANK-THRESHOLDS : (listof (cons exact-nonnegative-integer? string?))
'((0 . "Курсант") (3 . "Энсин") (6 . "Лейтенант младшего ранга")
  (9 . "Лейтенант") (12 . "Лейтенант-коммандер") (15 . "Коммандер"))

(rank-for-completed-count n) -> the label for the highest threshold <= n
```
Purely visual/thematic per `AGENTS.md` (LCARS/Star Trek styling, no narrative missions) — matches the ranks already implied by the ship's-log framing every lesson uses. Six evenly-spaced thresholds (every 3 of the 15 modules) keep rank changes noticeable without needing a weighted-progress formula `game-progression` doesn't actually require (its own wording is "advances as curriculum modules are completed," not any specific weighting).

### Achievement catalog: three conditions, three distinct styles, all pure functions over submission source
```racket
ACHIEVEMENT-CATALOG : (listof (list module-id achievement-id label (string? -> boolean?)))
'((binding no-let-needed "Обошлась без let"
    (lambda (src) (not (member 'let (read-all-forms/flat src)))))
  (recursion-basic single-form "Ни одной лишней строчки"
    (lambda (src) (= (length (read-all-forms src)) 1)))
  (higher-order-fn concise-solution "Компактное решение"
    (lambda (src) (< (string-length src) 90))))
```
Three different kinds of check (absence of a specific symbol anywhere in the parsed forms; exact top-level form count; raw source length) demonstrate the mechanism isn't just one special case wearing three names, satisfying this change's own Achievement Catalog Coverage requirement. `no-let-needed` reuses `static-check.rkt`'s symbol-scanning approach (a flattened walk over `read-all-forms`, checking for absence rather than `find-disallowed-symbols`' presence) rather than duplicating a new scanner.

Alternative considered: achievement conditions keyed only to a specific reference solution string (exact match) — rejected as trivial and not "notable" in any generalizable sense; a structural/length-based condition rewards genuinely distinct approaches, matching the spec's own example ("an unusually elegant or optimized solution").

### `check-achievements` only runs after a passing grade, in the GUI layer
`(check-achievements module-id submission-src)` itself is unconditional (a pure function - the GUI is what decides *when* to call it), but both `gui/editor-panel.rkt`'s `do-check!` and `gui/project-panel.rkt`'s `do-run!` only call it inside their existing "submission passed" branch, satisfying "Achievement Conditions Are Independent of, but Subsequent to, Correctness Grading" by construction: an incorrect submission never reaches the call at all.

### Achievement checking runs on every pass, unconditionally on prior completion status
Unlike `mark-completed` (idempotent: a no-op if already completed) and unlike `last-submissions`' replace-on-review semantics, the achievement check runs on *every* passing grade, first-time or review, and `grant-achievement` is itself idempotent (checks membership before adding) — this is exactly Retroactive Achievement Recognition During Review: a module already completed can still yield a newly-earned achievement on a later review pass, while an already-earned achievement is never duplicated.

### `progress-state` gains `earned-achievements`, save/load extended accordingly
```racket
(struct progress-state (completed-modules last-submissions project-refs earned-achievements) #:transparent)
(grant-achievement state achievement-id) ;; idempotent, mirrors mark-completed
```
The on-disk format gains a fourth top-level entry, `(earned-achievements . (...))`, alongside the existing three - `load-progress`'s existing missing/corrupt-file resilience is unaffected (a fresh state's new field is simply `'()`), and old save files without this key would need `load-progress` to tolerate an absent key going forward (implemented via `(cond [(assq 'earned-achievements data) => cdr] [else '()])` instead of a bare `assq`+`cdr` that would error on an old file missing the key).

### Journal shows rank + earned achievements, refreshed the same way as the completed list
`make-journal-panel`/`refresh-journal-panel!` gain a rank `message%` (computed from `(length completed-modules)`) and a second `list-box%` listing earned achievement labels, both rebuilt on every `refresh-journal-panel!` call alongside the existing completed-entries list-box — no new refresh mechanism, reusing the pattern `inline-code-editor` already established.

## Risks / Trade-offs

- [A three-achievement catalog is a thin demonstration, not a complete feature] → Accepted; same scoping precedent as `track-workspaces`' single reference suite/exercise - the mechanism, not exhaustive content, is this change's actual contribution.
- [Old save files predate `earned-achievements` and lack that key] → Handled explicitly in `load-progress` (see above), not left to accidentally crash on an old file.

## Open Questions

(none)
