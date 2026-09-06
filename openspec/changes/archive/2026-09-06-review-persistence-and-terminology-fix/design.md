## Context

See `proposal.md` for motivation. This is a consistency-fix change surfaced by a full-baseline review pass (2026-09-06) after the content-unit granularity was fixed (a module is a lesson containing multiple exercises — see this session's `content-unit-and-lcars-design-language` change) and after the review-mode requirements were first added by `curriculum-review-and-navigation`, before that granularity existed.

## Goals / Non-Goals

**Goals:**
- Make `gui-lcars`'s review requirements actually satisfiable by committing `progress-persistence` to retain the data they depend on.
- Align "module" vs. "exercise" terminology across `game-progression` and `gui-lcars` with the granularity already used correctly in `code-evaluation`.

**Non-Goals:**
- Revisiting the review-mode design itself (idempotent rank/completion, retroactive achievements, project vs. inline distinction) — already decided; this only fixes the words and the missing persistence commitment.
- The exact save-file schema (S-expression field names, nesting) — implementation detail for the future `progress-persistence` implementation change.

## Decisions

### Persist source for inline exercises, reference for project-based ones
An inline exercise's only artifact is the code itself, so persistence retains that code directly. A project-based exercise's artifacts are ordinary files already living on the player's filesystem at a folder the player chose — copying them into the save file would duplicate data that can go stale relative to the real files (e.g., if the player keeps editing outside a review session) and bloats a save format meant to stay human-inspectable. Retaining the folder path, entry-point file, and last pass/fail status is the minimal reference needed to reopen the same project view on review.

### Missing-folder resilience follows the same pattern as corrupt-save resilience
`progress-persistence` already requires starting cleanly rather than failing to launch when the save file itself is missing or corrupt. A retained project folder path that no longer resolves (moved, renamed, or deleted outside the game) is the same class of problem at a smaller scope — reported to the player and recoverable (re-select a folder) rather than treated as fatal, without discarding the exercise's earned completion status.

### Terminology fix: "exercise" is the correct unit for submission-level requirements
`code-evaluation`'s Automated Test-Based Grading and `game-progression`'s own Achievements for Notable Actions both already correctly scope grading and achievement conditions to an exercise, not a module. The three requirements corrected here (`game-progression`'s two review requirements, `gui-lcars`'s Review Mode Editor) were written before the module-contains-multiple-exercises granularity was fixed and inherited "module" from a time when the distinction didn't yet matter. `curriculum`'s Completed Module Accessibility correctly keeps "module" — reopening a module for review is module-level navigation; what happens once inside (submitting, preloading a prior solution, earning an achievement) is exercise-level, per the corrected requirements.

## Risks / Trade-offs

- [Retaining a folder path instead of file contents means review-mode fidelity for project-based exercises depends on the player not having modified the folder outside the game since their last successful grading] → Acceptable: the folder is the player's own workspace, not a game-managed artifact: showing it "as last left on disk" is the honest behavior, not a bug to guard against.

## Open Questions

(none)
