## 1. Validate and Reconcile

- [x] 1.1 Run `openspec validate review-persistence-and-terminology-fix --strict` and fix any structural issues in proposal/specs/design
- [x] 1.2 Re-read the corrected `game-progression` and `gui-lcars` requirements together with `code-evaluation`'s Automated Test-Based Grading and `curriculum`'s Completed Module Accessibility, and confirm "module" vs. "exercise" usage is now consistent everywhere
- [x] 1.3 Confirm the two new `progress-persistence` requirements fully cover what `gui-lcars`'s Review Mode Editor and Review Mode for Loaded Projects each depend on

## 2. Adopt as Project Baseline

- [ ] 2.1 Archive this change so its delta requirements merge into `openspec/specs/progress-persistence/spec.md`, `openspec/specs/game-progression/spec.md`, and `openspec/specs/gui-lcars/spec.md`

## 3. Scope Follow-Up Content/Implementation Work

- [ ] 3.1 When implementing save/load, design the S-expression schema for per-exercise retained data (inline: source; project-based: folder path, entry point, status) as part of the same effort that implements the rest of the save format
- [ ] 3.2 When implementing the loaded-project view, handle the missing-folder case by prompting the player to re-select a folder rather than failing silently or crashing
