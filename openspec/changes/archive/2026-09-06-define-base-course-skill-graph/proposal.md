## Why

`curriculum` requires an explicit prerequisite graph of skills, and `curriculum-review-and-navigation` fixed the rule for where a shared skill is taught (base course if ≥2 enabled tracks need it, otherwise as that track's intro module) — but no concrete skill nodes exist yet. Content authoring (writing actual base-course lessons and the Interpreter/Multitasking track intros) cannot start without a fixed sequence to write against.

## What Changes

- Fixes the concrete base-course skill sequence (8 nodes, simple → complex) and the intro-module skills for each MVP track (Interpreter: 2 nodes, Multitasking: 1 node), derived by applying the already-decided placement rule to what each MVP track's requirements actually need.
- Records `display`/`newline` as introduced within the `s-expr-basics` module rather than as its own graph node (trivial procedure call, not a gating prerequisite).
- Records `higher-order-fn` as a base-course module that does not gate any track (general Scheme literacy only).
- No requirement-level behavior changes: this instantiates the graph `curriculum` already requires to exist, rather than changing what the system must do. `specs/` is skipped for this change (`skip_specs: true`) accordingly.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
(none — see `skip_specs: true` in this change's `.openspec.yaml`; the concrete skill graph is content data, not a requirement change)

## Impact

- Provides the fixed reference sequence for the future base-course content change and the future Interpreter/Multitasking track-intro content, referenced from `curriculum-review-and-navigation`'s `tasks.md` (item 3.2).
- No existing code or specs are touched.
