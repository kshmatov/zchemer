## 1. Validate and Reconcile the Specification

- [x] 1.1 Run `openspec validate curriculum-review-and-navigation --strict` and fix any structural issues in proposal/specs/design
- [x] 1.2 Re-read the updated `curriculum`, `game-progression`, and `gui-lcars` deltas together with the unmodified specs (`scheme-runtime`, `code-evaluation`, `advanced-project-sandboxes`, `progress-persistence`) and confirm no contradictions
- [x] 1.3 Confirm the review-mode asymmetry is consistent everywhere: rank/completion idempotent on re-submission, achievements still evaluable, no new persisted save-file state introduced

## 2. Adopt as Project Baseline

- [ ] 2.1 Archive this change so its delta requirements merge into `openspec/specs/curriculum/spec.md`, `openspec/specs/game-progression/spec.md`, and `openspec/specs/gui-lcars/spec.md`
- [x] 2.2 Confirm `AGENTS.md` still doesn't contradict the now-fixed decisions (it stays at the intent level; update only if it starts to read as excluding revisiting completed content)

## 3. Scope Follow-Up Work

- [ ] 3.1 Carry the `progress-persistence` scope note from design.md's Risks (retain last-successful-source per exercise, not just a completion boolean) into whichever future change implements save/load
- [ ] 3.2 When drafting the base-course/track content change, apply the shared-skill placement rule explicitly: skills required by two or more enabled tracks go in the base course; skills required by exactly one track are taught as that track's intro module
- [ ] 3.3 When drafting the `gui-lcars` implementation change, include the journal-primary / skill-tree-secondary navigation structure and the review-mode editor (preload last successful submission, clear-and-restart) in its scope
