## Context

See `proposal.md` for motivation. Builds on the save-format decision (S-expression, Racket's native reader/writer) fixed in the archived `define-project-scope` design, the skill graph fixed in `curriculum-review-and-navigation`/`define-base-course-skill-graph`, and the review-mode/persistence decisions fixed in this session's `review-persistence-and-terminology-fix` (which already assumes exercise-level granularity — this document is where that granularity is actually decided).

## Goals / Non-Goals

**Goals:**
- Fix the content-unit granularity (module vs. exercise) and a concrete authoring schema for both.
- Fix structural LCARS design principles that shape future layout work, without picking literal colors/fonts/pixel geometry.

**Non-Goals:**
- The exact color palette, typography, or pixel-level panel geometry — remains the `gui-lcars` implementation change's concern, per the original project-scope design's non-goal.
- Writing actual lesson/exercise content — content authoring, follow-up work.
- The syntax-highlighting token scheme for the editor — a detail of the `gui-lcars` implementation change, informed by but not fixed in this design.

## Decisions

### Content unit: module = lesson + N exercises, granted on all-pass
A module bundles one log-entry-style lesson text with one or more exercises; the module's skill(s) are granted to the player only once every exercise in it has passed. This matches the granularity already implied by the skill graph (`define-base-course-skill-graph`): each of the 11 fixed nodes is a substantial topic (e.g., `tail-recursion` split from `recursion-basic` specifically because it's "a distinct idiom and source of confusion"), which fits a multi-exercise lesson better than a single exercise standing in for an entire topic.

Alternative considered: module == exercise (1:1). Rejected — it would force every skill-graph node to be taught through exactly one exercise, under- or over-loading individual exercises to match topic weight rather than letting a topic's difficulty determine how many exercises it needs.

### Authoring format: S-expressions, following the save-format precedent
Module/exercise definitions are authored as Racket S-expressions, reusing the native reader/writer already chosen for the save format (`define-project-scope`'s design) rather than introducing a second data format and parser for content. Sketch:

```
(module
  (id recursion-basic)
  (title "...")
  (grants (recursion-basic))
  (requires (binding conditionals first-class-fn))
  (log-entry "...")
  (exercises
    (exercise (id ex1) (prompt "...") (starter-code "...")
              (tests (...)) (achievement #f))
    (exercise (id ex2) (prompt "...") (starter-code "...")
              (tests (...)) (achievement (elegant? ...)))))
```

A project-based module (Interpreter, Multitasking track workspaces) uses the same `module` wrapper, but replaces `exercises` with a reference to its suite: sample programs with expected output/error for the Interpreter track (per `advanced-project-sandboxes` — Interpreter Track Evaluation Workspace, Minimal Interpreted-Program Error Detection), or an invariant predicate plus stress-load parameters for the Multitasking track (per `advanced-project-sandboxes` — Multitasking Track Uses Real Concurrency). This is a sketch for future content-authoring work, not a finalized schema — exact field names and structure are implementation detail.

### LCARS as chrome around a readable workspace, not a redesign of the workspace itself
The canonical LCARS look (sparse, large color-blocked panels, minimal text) directly conflicts with a code editor's actual requirement (dense, readable monospace text, syntax highlighting). Resolution: LCARS styling governs the surrounding chrome (navigation sidebar, headers, panel framing) fully; the code/text workspace itself is LCARS-colored but prioritizes readability over stylistic purity. This sets a boundary for the future `gui-lcars` implementation change rather than picking specific values.

### Color encodes track/category; status uses icon/shape
Color is assigned per track/section (base course, Interpreter, Multitasking, etc.) and stays constant regardless of a module's state, matching LCARS's traditional use of color to denote functional/categorical grouping rather than status. Locked/available/completed state is instead conveyed by icon or shape, kept orthogonal to the track color so both can be read at a glance in the journal and skill-tree views. Error/alert feedback (`code-evaluation` — Learner-Facing Error Translation) is a third, independent visual layer — momentary feedback on a submission, not a property of a module or track — and isn't governed by either the track-color or status-icon system.

Alternative considered: color encodes status (locked/available/completed) instead. Rejected — a status-only palette reads as a generic progress tracker rather than LCARS's category-driven convention, and would need a second channel (icon/shape) for track identity anyway, so it doesn't reduce the number of visual channels needed.

### Persistent thin navigation sidebar across all screens
The primary navigation (journal / skill-tree entry points, consistent with `gui-lcars`'s existing Consistent LCARS Visual Styling requirement) stays visible as a slim sidebar across the journal, skill tree, inline editor, and project view, rather than being shown only on some screens. This follows directly from the chrome/workspace split above: a thin sidebar is cheap in screen space, so there's no real tension with the editor's need for room, unlike a full LCARS elbow panel would create.

## Risks / Trade-offs

- [The exercise-count-per-module isn't fixed by this design (could be 1, could be 5) — inconsistent exercise counts across modules could make some feel thin and others padded] → Leave to content authoring judgment per module; not an architectural constraint worth fixing in advance of writing real lessons.
- [A persistent sidebar, even thin, is real estate the code editor doesn't get — could matter on small screens] → Acceptable at this design stage; screen-size responsiveness is an implementation-time concern for the `gui-lcars` change, not an architectural blocker now.

## Open Questions

(none — all decisions needed to unblock content authoring and the future `gui-lcars` implementation change are fixed above; exact visual tokens remain that change's own non-goal-turned-goal, unchanged from the original project-scope design)
