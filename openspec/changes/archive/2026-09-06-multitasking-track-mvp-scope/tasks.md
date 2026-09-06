## 1. Validate and Reconcile

- [x] 1.1 Run `openspec validate multitasking-track-mvp-scope --strict` and fix any structural issues in proposal/specs/design
- [x] 1.2 Re-read the updated `advanced-project-sandboxes` requirement together with `scheme-runtime`'s Genuine Concurrency Semantics and Isolated, Resource-Bounded Execution requirements, and confirm no contradictions (repeated-run grading still respects the sandbox's time/memory limits per run)
- [x] 1.3 Confirm `code-evaluation`'s Automated Test-Based Grading requirement is consistent with invariant-predicate grading across repeated runs (it already generalizes to "expected results," this is a specific instance, not a conflicting mechanism)

## 2. Adopt as Project Baseline

- [ ] 2.1 Archive this change so its delta requirement merges into `openspec/specs/advanced-project-sandboxes/spec.md`

## 3. Scope Follow-Up Content Work

- [ ] 3.1 When drafting the `concurrency-primitives` intro module, build its practice exercise as a given unsafe solution the player must diagnose and fix, not a from-scratch design task
- [ ] 3.2 When drafting the track's main reference exercises (producer/consumer, bounded buffer, worker pool), design each with a per-exercise invariant predicate and a thread/iteration count wide enough to make a genuine race manifest reliably within a small number of repeated runs
- [ ] 3.3 When implementing the grading harness, treat the repeated-run count and any per-run resource limits as tunable parameters, not hardcoded assumptions baked into individual exercises
- [ ] 3.4 If an "Advanced Concurrency" track (`sync`, `place`, `future`) is ever scoped, re-run `curriculum`'s shared-skill placement rule against its actual requirements rather than assuming `concurrency-primitives`' current placement carries over unchanged
