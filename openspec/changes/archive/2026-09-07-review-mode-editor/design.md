## Context

See `proposal.md`. Builds only on `gui/editor-panel.rkt` (from `inline-code-editor`) and `engine/progress.rkt`'s already-existing `progress-state-completed-modules`/`progress-state-last-submissions` accessors — both already tested and unchanged by this change.

## Goals / Non-Goals

**Goals:**
- Reopening a completed lesson in the editor preloads its retained last-successful submission.
- A "Очистить" button lets the player discard the preload and start blank.
- Reviewing and re-passing a completed lesson still replaces the retained submission (already true via `record-submission`'s existing always-replace behavior — verify with a test, don't reimplement).

**Non-Goals:**
- Any change to grading/persistence logic itself.
- Achievement/rank retroactive recognition (`game-progression`) — no achievement engine exists.

## Decisions

### Preload check: `member` on `completed-modules` + `assq` on `last-submissions`, not a new query
`load-selected!` now does:
```racket
(define state (unbox progress-box))
(define retained (and (member module-id (progress-state-completed-modules state))
                      (assq module-id (progress-state-last-submissions state))))
(send code-text erase)
(when retained (send code-text insert (cdr retained)))
```
No new accessor on `engine/progress.rkt` is needed — both fields it already exposes are sufficient. Checking `completed-modules` membership (not just presence in `last-submissions`) matters because `record-submission` is also available for future use before completion (e.g. an in-progress draft) — this change only ever calls it after a full pass, but gating the preload on "completed" keeps the behavior matching the spec's actual wording ("reopens a **completed** exercise's inline editor") rather than "any lesson with a retained draft."

### Clear button is unconditional, not merely aesthetic
"Очистить" always erases the code editor, regardless of whether the current lesson is completed or not — simplest correct behavior, and harmless on an already-blank editor.

## Risks / Trade-offs

(none beyond what `inline-code-editor`'s design.md already accepted for this editor's scope)

## Open Questions

(none)
