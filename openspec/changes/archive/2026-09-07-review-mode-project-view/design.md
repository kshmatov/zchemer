## Context

See `proposal.md`. Builds only on `gui/project-panel.rkt` (from `project-view`) and `engine/progress.rkt`'s already-existing `progress-state-project-refs` accessor — both unchanged by this change except the one callback addition.

## Goals / Non-Goals

**Goals:**
- Selecting an already-completed workspace with a retained project ref auto-loads its folder and entry point.
- A missing/moved folder is reported, not crashed on, and doesn't affect completion status.

**Non-Goals:**
- Any change to grading/persistence logic itself (already correct since `project-view`).
- Retroactive achievement recognition — no achievement engine exists.

## Decisions

### Workspace-picker callback: check `project-refs`, not `completed-modules`, for what to auto-load
The relevant check is "does this workspace have a retained project ref" (`(assq module-id (progress-state-project-refs state))`), not merely "is it completed" — the two are equivalent in practice since `project-view` only ever calls `record-project-ref` alongside a first `mark-completed`, but checking the ref directly is what actually supplies the folder path/entry point to load, and stays correct even if a future change ever recorded a ref without completion for some other reason.

### Missing-folder handling: `directory-exists?`, report via the existing results area, no new UI element
```racket
(cond
  [(not ref) (void)] ;; nothing retained yet - leave the panel as-is
  [(not (directory-exists? (first ref)))
   (show-results! (list (format "Папка проекта не найдена: ~a. Загрузите папку заново." (first ref))))]
  [else (load-folder! (first ref)) (assign-known-entry-point! (second ref))])
```
Reusing the results text area (already present for grading feedback) avoids introducing a second message widget just for this one case, and keeps the player's next action obvious ("Загрузить папку" is still right there, unaffected).

### Auto-loaded entry point comes from the retained ref, not re-derived from `scan-project-files`
`load-folder!` (from `project-view`) normally defaults the entry point to the alphabetically-first `.scm` file. On a review reopen, the retained entry-point filename (which may not be alphabetically first) is set explicitly after `load-folder!` runs, overriding that default — matching `gui-lcars`'s wording exactly ("against ... the entry-point file", the *retained* one, not a freshly-guessed one).

## Risks / Trade-offs

(none beyond what `project-view`'s design.md already accepted)

## Open Questions

(none)
