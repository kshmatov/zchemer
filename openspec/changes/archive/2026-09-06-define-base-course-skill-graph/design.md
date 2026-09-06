## Context

See `proposal.md` for motivation. This applies the shared-skill placement rule fixed in `curriculum-review-and-navigation` (`specs/curriculum/spec.md` — Shared-Skill Base Course Placement) to the MVP tracks fixed in the original scope change (Interpreter, Multitasking). Target learner: a programmer experienced in other languages, new to Scheme (per `AGENTS.md`).

## Goals / Non-Goals

**Goals:**
- Fix a concrete, ordered list of skill nodes for the base course and for each MVP track's intro module, derived from what each track's own requirements (`advanced-project-sandboxes`, `scheme-runtime`) actually need — not an arbitrary curriculum outline.
- Resolve base-vs-track placement for every node using the already-decided rule, so the split is traceable rather than a judgment call made silently during content writing.

**Non-Goals:**
- Writing lesson text, exercises, or automated tests for any node (a future content-authoring change).
- Deciding node placement for tracks outside the MVP (Network, Database, OOP) — deferred until those tracks are enabled, per `advanced-project-sandboxes`'s "Unavailable Tracks Are Visible but Disabled" requirement.
- Continuations, macros (`syntax-rules`), or other R6RS constructs not required by the base course or either MVP track — out of scope per the archived project-scope design's risk note on R6RS subset scoping.

## Decisions

### Derivation method: work backward from what each MVP track actually requires
Rather than picking topics that "feel like" a Scheme course outline, each node was derived by asking what the Interpreter track (write and grade a player's own `eval`/`apply` against a reference suite) and the Multitasking track (real concurrency, invariant-based grading) concretely need to function, then applying the placement rule to the resulting set. This keeps the graph minimal and justified rather than encyclopedic.

### Base course sequence (8 nodes)

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

- `s-expr-basics`: atoms, pairs/lists, prefix notation. Introduces `display`/`newline` inline (not a separate node — a trivial procedure call, not a gating prerequisite for anything).
- `binding`: `define`, `let`.
- `conditionals`: `if`, `cond`, booleans.
- `first-class-fn`: `lambda` as a value, passing/returning functions.
- `recursion-basic` → `tail-recursion`: structural recursion, then the accumulator/iterative-process pattern — split into two nodes because tail recursion is a distinct idiom (and a distinct source of learner confusion) from first getting recursion to work at all.
- `mutable-state`: promoted to base because both MVP tracks need it (Interpreter: `define`/`set!` inside the interpreted language; Multitasking: shared state is the entire point of the track).
- `data-structures`: promoted to base because both MVP tracks need it (Interpreter: environment representation; Multitasking: representing shared counters/queues).
- `closures`: needed by both MVP tracks (Interpreter: `eval` must construct closures for `lambda` forms; Multitasking: thread bodies capture shared state).
- `higher-order-fn`: kept in base for general Scheme literacy even though neither MVP track's grading logic requires it directly (a player's `eval` handles `map`/`filter` through generic procedure application, not special-cased support). Does not gate track access, since track access is gated by full base-course completion (`curriculum` — Base Course Scope), not by this specific node.

Alternative considered: dropping `higher-order-fn` from the MVP graph entirely since it gates nothing. Rejected — the user confirmed keeping it as general literacy; removing it would leave a real Scheme fundamental unaddressed in the only mandatory course content the game has.

### Track intro sequences

**Interpreter** (`symbolic-data` → `environment-model`):
- `symbolic-data`: `quote`/`quasiquote`, code as data — required because `eval` operates on Scheme source as a data structure, and this is not otherwise covered by the base course.
- `environment-model`: representing a chain of lexical scopes as a data structure (frames), and how `closures` + `data-structures` combine to do it — the classic "how do you actually build an interpreter" lesson. Kept as its own node rather than folded into `symbolic-data` or assumed to fall out of `closures`/`data-structures` automatically, because composing those two into an environment-chain model is itself a non-obvious step worth teaching directly.

**Multitasking** (`concurrency-primitives`):
- `concurrency-primitives`: Racket's thread/semaphore/channel/`sync` API — kept single-node and track-local since it is Racket-specific and, in the MVP, needed by exactly one track. If a future track (e.g., Network) also needs channel-style primitives, the placement rule already handles promoting it to the base course at that point without retroactively changing this node's identity.

## Risks / Trade-offs

- [`environment-model` and `symbolic-data` are both new, Interpreter-only nodes with no base-course precedent — underestimating their teaching difficulty could make the Interpreter track's entry cost higher than the Multitasking track's single-node intro] → Flag for the future Interpreter track content change to validate node sizing once real lesson content is drafted; not a reason to merge or split further now.
- [Parallel branching after `first-class-fn` (`recursion-basic`, `mutable-state`, `data-structures` all become available at once) assumes these three don't have real dependencies on each other — if content authoring later finds `data-structures` examples are easier to write using recursion, the graph edges would need to change] → Acceptable at this stage; revisit if content authoring surfaces a real ordering constraint.

## Open Questions

- Exact within-base ordering of the three parallel branches (`recursion-basic`, `mutable-state`, `data-structures`) once base-course completion is monolithic-gated anyway — doesn't change the graph's edges or the tracks' requirements, so it's safe to leave to content authoring rather than resolve here.
