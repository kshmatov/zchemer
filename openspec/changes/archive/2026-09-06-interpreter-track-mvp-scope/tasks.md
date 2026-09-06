## 1. Validate and Reconcile

- [x] 1.1 Run `openspec validate interpreter-track-mvp-scope --strict` and fix any structural issues in proposal/specs/design
- [x] 1.2 Re-read the updated `advanced-project-sandboxes` requirements together with `code-evaluation`'s Static Checks Before Execution and `scheme-runtime`'s Isolated, Resource-Bounded Execution, and confirm no contradictions (in particular: the anti-cheat scenario references `code-evaluation`'s existing mechanism rather than duplicating it)
- [x] 1.3 Confirm the corrected `mutable-state` rationale is consistent with `curriculum`'s Shared-Skill Base Course Placement requirement (general-literacy + single-current-track justification, same pattern already used for `higher-order-fn`)

## 2. Adopt as Project Baseline

- [ ] 2.1 Archive this change so its delta requirement merges into `openspec/specs/advanced-project-sandboxes/spec.md`
- [x] 2.2 Treat this change's design.md, not the earlier two archived changes' design docs, as the current source of truth for why `mutable-state` is in the base course

## 3. Scope Follow-Up Content Work

- [ ] 3.1 When drafting the Interpreter track's reference sample-program suite, cover both success cases (output comparison) and the three required error cases (unbound-variable, arity-mismatch, non-procedure-application)
- [ ] 3.2 When drafting the Interpreter track's intro content (`symbolic-data`, `environment-model`), make explicit that the environment is extended functionally (no host-side mutation needed), consistent with the interpreted language having no `set!`
- [ ] 3.3 If an "Advanced Interpreter" track is ever scoped (call/cc, mutation, player-written parser), re-run `curriculum`'s shared-skill placement rule against its actual requirements rather than assuming any current placement carries over unchanged
