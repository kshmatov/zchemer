## Context

See `proposal.md` for motivation. No code exists yet anywhere in the project (`openspec/` currently holds specs and archived design docs only) — this content is written ahead of the curriculum engine, GUI, and sandbox that will eventually load and run it.

### Reference: the finalized base-course skill graph

Carried forward from `openspec/changes/archive/2026-09-06-define-base-course-skill-graph/design.md` (its task 2.2, "record the finalized graph somewhere content authors will actually find it," was left undone — this section is that record):

```
s-expr-basics ──▶ binding ──▶ conditionals ──▶ first-class-fn
                                                      │
                          ┌───────────────────────────┼───────────────────────────┐
                          ▼                            ▼                           ▼
                    recursion-basic              mutable-state              data-structures
                          │                    (set!, begin, side           (vectors, hash
                          ▼                       effects)                   tables, assoc
                    tail-recursion                                           lists)
                          │
                          ▼
                      closures
                          │
                          ▼
                  higher-order-fn
                (map/filter/fold — general
                 literacy, gates nothing)
```

Per-node scope (unchanged from the archived design):
- `s-expr-basics`: atoms, pairs/lists, prefix notation; `display`/`newline` introduced inline.
- `binding`: `define`, `let`.
- `conditionals`: `if`, `cond`, booleans.
- `first-class-fn`: `lambda` as a value, passing/returning functions.
- `recursion-basic`: structural recursion.
- `tail-recursion`: accumulator/iterative-process pattern, taught as distinct from `recursion-basic`.
- `mutable-state`: `set!`, `begin`, side effects.
- `data-structures`: vectors, hash tables, assoc lists.
- `closures`: needed later by both MVP tracks (env representation in Interpreter; thread bodies capturing shared state in Multitasking).
- `higher-order-fn`: `map`/`filter`/`fold`; general literacy, gates nothing further.

Track-intro content authors (Interpreter's `symbolic-data`/`environment-model`, Multitasking's `concurrency-primitives`) should treat this section, not the archived change, as the live reference for how the base course ends and where their track's intro picks up.

## Goals / Non-Goals

**Goals:**
- Fix one concrete, consistent file format for a base-course lesson (instructional text, exercise prompt, automated tests) that content for all ten nodes follows.
- Make the format generic enough that a future curriculum engine can parse it, without designing that engine now.

**Non-Goals:**
- Building the parser, GUI, sandbox execution, or persistence wiring that will eventually load this content — none of that exists in code yet, and none of it is created by this change.
- Achievement-condition logic (`game-progression`'s "notable solution" achievements) — this change only defines correctness tests, not elegance/optimization heuristics.
- Track-intro content (`symbolic-data`, `environment-model`, `concurrency-primitives`) — separate future changes per the archived change's tasks 3.2/3.3.

## Decisions

### File layout: one directory per lesson under `content/base-course/`
Each node gets `content/base-course/<NN>-<node-id>/` (e.g. `content/base-course/01-s-expr-basics/`), numbered by its position in the fixed order, containing:
- `lesson.md` — a YAML front-matter block (`node`, `title`) followed by two Markdown sections, `## Log Entry` (first-person instructional text) and `## Exercise` (the task prompt).
- `tests.rktd` — a single Racket-readable s-expression, a list of test cases: `((call (fn-name arg ...) expected) ...)`, read by a future grader rather than parsed as prose.
- `checks.rktd` — optional; a list of disallowed/required symbols for `code-evaluation`'s Static Checks requirement, omitted entirely when a lesson has none (expected for nearly all base-course lessons — static checks matter more for later tracks like the Interpreter's `eval` ban).

Alternatives considered:
- *A single JSON/YAML file per lesson bundling all three parts* — rejected: mixing prose (log entry) with s-expression test data in one non-Scheme format fights the project's stated preference for human-readable S-expressions (`progress-persistence`) and Racket-native tooling (`AGENTS.md`), and produces worse diffs for prose edits.
- *One big file for all ten lessons* — rejected: harder to review/diff per-node, and conflicts with reopening/review flows (`gui-lcars` — Review Mode Editor) that operate per-exercise.

### Directory numbering encodes the fixed order directly
Using a `NN-` prefix (`01-`, `02-`, ...) rather than relying on an external ordering file makes the sequence visible in a plain directory listing, matching how `progress-persistence` values plain-text inspectability.

### Test format: call-based, not REPL-transcript
Tests express a procedure call and its expected result (`(call <expression> expected)`, where `<expression>` is typically `(fn-name arg ...)` but may be any nested application, e.g. `((compose f g) x)`, so closures and first-class-function exercises work without a special case) rather than a raw REPL transcript, because most base-course exercises ask the player to define a specific procedure (e.g. `binding`'s exercise defines a `let`-based computation) rather than produce program output — this matches `advanced-project-sandboxes`' later distinction between comparing printed output (Interpreter track) and comparing a returned/computed value (everything else).

**Exception for `01-s-expr-basics`:** discovered during content authoring — `call` assumes the player has `define`d something to call, but `define` is not introduced until `02-binding`. That lesson's `tests.rktd` instead uses `(expr expected)`: the submission's final top-level expression is evaluated as-is and compared to `expected`, with no wrapping procedure name required. Every later lesson (`02` onward) uses `call`, since `define` is available from `02-binding` on.

## Risks / Trade-offs

- [The `.rktd` test format is a guess at what a not-yet-built grading engine will actually want to consume] → Kept deliberately minimal (a plain list of call/expected pairs) so a future engine change can wrap or reshape it without needing this content rewritten from scratch.
- [Numbering lessons by directory prefix couples content order to filesystem order] → Acceptable: the order is already fixed by the skill graph and is not expected to change without a new content-scoping change.

## Open Questions

- Exact `lesson.md` front-matter schema beyond `node`/`title` (e.g. whether to record estimated difficulty or rank-points granted) is left to the future game-progression wiring change, since it doesn't affect this change's specs, approach, or task breakdown.
