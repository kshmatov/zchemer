## 1. Validate and Reconcile

- [x] 1.1 Run `openspec validate content-unit-and-lcars-design-language --strict` and fix any structural issues in proposal/design
- [x] 1.2 Confirm the module/exercise granularity is consistent with the terminology fixed by `review-persistence-and-terminology-fix` (exercise-level submission/grading/persistence, module-level skill-granting/navigation)
- [x] 1.3 Confirm the LCARS design language doesn't contradict any existing `gui-lcars` requirement (Native Desktop Application, Inline Code Editor, Dedicated Loaded-Project View, Consistent LCARS Visual Styling, Review Mode Editor, Journal as Primary Navigation, Skill Tree as Secondary Navigation)

## 2. Adopt as Content/Design Baseline

- [ ] 2.1 Archive this change so it becomes the reference content-unit schema and LCARS design language for future authoring and implementation work (no `specs/` merge — `skip_specs: true`)

## 3. Scope Follow-Up Work

- [ ] 3.1 When drafting the base-course/track content changes, author modules using the sketched S-expression schema, refining field names as real content surfaces gaps in it
- [ ] 3.2 When drafting the `gui-lcars` implementation change, apply the chrome/workspace split, track-color + status-icon system, and persistent thin sidebar as binding structural constraints, while still freely choosing the actual palette, typography, and pixel geometry within them
- [ ] 3.3 When implementing the editor's syntax highlighting, design its token-color scheme within the track's assigned color as an accent rather than introducing an unrelated palette for code specifically
