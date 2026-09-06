## Why

Two open questions from the original project-scope design remained unresolved: what a "module"/"exercise" actually is as a content data structure, and what LCARS-inspired visual style means structurally beyond "apply LCARS conventions consistently." Explore-mode discussion (2026-09-06) resolved both. Content authoring and the future `gui-lcars` implementation change cannot start without them fixed.

## What Changes

- Fixes the content-unit granularity: a module is a lesson (log-entry text, granted/required skills) containing one or more exercises; a module's skill is granted only once every exercise in it passes. Sketches a concrete S-expression schema for both inline and project-based modules, consistent with the project's existing choice to use Racket's native reader/writer for the save format.
- Fixes three structural (not pixel-level) LCARS design decisions: LCARS styling is decorative chrome around a workspace that prioritizes code readability over stylistic purity; color encodes track/category membership while status (locked/available/completed) is encoded by icon/shape, not color; primary navigation (a thin persistent sidebar) stays visible across all screens rather than appearing per-screen.
- No requirement-level behavior changes: both are content-authoring/visual-design decisions that don't change what the system is observably required to do — `curriculum`'s and `gui-lcars`'s existing requirements (explicit prerequisite graph, consistent LCARS styling) already cover this generically. `specs/` is skipped for this change (`skip_specs: true`) accordingly.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
(none — see `skip_specs: true` in this change's `.openspec.yaml`)

## Impact

- Provides the fixed content-unit schema for the future base-course and track content changes.
- Provides the structural design language for the future `gui-lcars` implementation change (which still owns the actual color palette, typography, and pixel-level layout — unchanged non-goal from the original project-scope design).
- No existing code or specs are touched.
