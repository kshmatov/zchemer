## 1. Validate and Reconcile

- [x] 1.1 Run `openspec validate define-base-course-skill-graph --strict` and fix any structural issues in proposal/design
- [x] 1.2 Cross-check every node's placement against `curriculum`'s Shared-Skill Base Course Placement requirement: confirm `closures`, `mutable-state`, `data-structures` are each genuinely required by both MVP tracks, and `symbolic-data`, `environment-model`, `concurrency-primitives` are each genuinely required by only one
- [x] 1.3 Confirm no node is required by `advanced-project-sandboxes` or `scheme-runtime` that isn't already represented in the graph (re-read both specs against the final node list)

## 2. Adopt as Content Baseline

- [ ] 2.1 Archive this change so the skill graph becomes the reference sequence content authors write against (no `specs/` merge — `skip_specs: true`)
- [ ] 2.2 Record the finalized graph somewhere content authors will actually find it when starting lesson work (e.g. referenced from the future base-course content change's own design.md, rather than left only in this archived change)

## 3. Scope Follow-Up Content Work

- [ ] 3.1 Draft the base-course content change: one lesson (instructional log text + exercise + automated tests) per base node, in the fixed order
- [ ] 3.2 Draft the Interpreter track's intro content for `symbolic-data` and `environment-model`, ahead of the track's main "write your own eval" workspace
- [ ] 3.3 Draft the Multitasking track's intro content for `concurrency-primitives`, ahead of the track's main concurrent-exercise workspace
- [ ] 3.4 When a future track (e.g. Network) is scoped, re-run the placement rule against its actual requirements before assuming any existing track-local node (e.g. `concurrency-primitives`) should be promoted to base course
