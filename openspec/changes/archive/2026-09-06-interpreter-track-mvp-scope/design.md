## Context

See `proposal.md` for motivation. This builds on the MVP track scope fixed in the archived `define-project-scope` change and the skill graph fixed in the archived `curriculum-review-and-navigation` / `define-base-course-skill-graph` changes. It resolves the Interpreter track's remaining open questions: language depth, grading semantics, and the anti-cheat boundary.

## Goals / Non-Goals

**Goals:**
- Fix a concrete, minimal MVP language subset for the interpreted language, grading comparison, error-handling expectations, and anti-cheat scope for the Interpreter track.
- Correct the placement rationale for `mutable-state` now that the Interpreter track no longer needs it, without re-litigating where the skill lives (it stays in the base course).

**Non-Goals:**
- Designing the "Advanced Interpreter" track floated during discussion (`call/cc`, mutation, player-written parser) — noted as a future possibility, not scoped here. If pursued later, it would need its own placement-rule pass per `curriculum`'s Shared-Skill Base Course Placement requirement, the same way any new track does.
- Writing the reference sample-program suite itself or the intro lesson content for `symbolic-data`/`environment-model` — content authoring, follow-up work.

## Decisions

### MVP language subset: no `call/cc`, no mutation (variable or data)
The interpreted language covers definitions, `lambda`, conditionals, application, and quotation — the constructs already fixed as base-course/track-intro skills (`recursion-basic`, `closures`, `data-structures`, `symbolic-data`, `environment-model`). `call/cc` and mutation (`set!`, `set-car!`, `vector-set!`, etc.) are excluded for this MVP.

Consequence for `environment-model`: without `set!` in the interpreted language, the environment can be extended purely functionally (a new frame consed onto the existing chain) rather than requiring in-place mutation of an existing frame. This simplifies what `environment-model` needs to teach — no host-side mutation technique is required to make the interpreted language's `define` work.

### Correction: `mutable-state`'s base-course placement no longer cites the Interpreter track
`curriculum-review-and-navigation`'s design.md and `define-base-course-skill-graph`'s design.md both justified promoting `mutable-state` to the base course partly because "the Interpreter track needs `define`/`set!` inside the interpreted language." That is no longer accurate: mutation is out of the Interpreter MVP's scope per the decision above.

`mutable-state` still belongs in the base course, but the justification changes to match the same reasoning already used for `higher-order-fn`: general Scheme literacy, plus it remains a real prerequisite for the Multitasking track (shared mutable state is that track's central concern) and for the speculative future "Advanced Interpreter" track (mutation would very plausibly return there). This is a correction to recorded rationale, not a re-decision of placement — the node stays exactly where it was. The archived design docs are left unedited as a historical record of what was known when they were written; this document is the current source of truth for why `mutable-state` is in the base course.

### Grading by printed output, not return value
Since the interpreted language has no mutation, the only externally observable effect of running a reference program is what it prints (`display`/`newline`). Comparing printed output rather than a top-level return value is therefore not just a simplification but the only signal that actually exists to compare, and it stays consistent even if a later track re-introduces mutation and other observable effects.

### Reader provided by the host, not implemented by the player
Reference programs are supplied to the player's evaluator as already-parsed data structures (via Racket's own reader), not as raw source text. Parsing is a distinct skill from evaluating, is not covered by `symbolic-data`/`environment-model`, and including it would conflate "write a reader" with "write an evaluator" in a single grading pass. Writing a parser is deferred to a future advanced track alongside `call/cc` and mutation.

### Minimal error detection: only evaluator-intrinsic error categories
Three error categories are graded because they are concepts the player's own evaluator logic must implement (environment lookup failure, arity checking, procedure-value checking): unbound variable, arity mismatch, non-procedure application. Errors arising from delegated primitive calls (e.g., `car` on a non-pair) are excluded from this requirement because a player who implements primitive application by calling the underlying Racket procedure gets those checks for free from Racket's own runtime — requiring the player to re-implement them would test Racket API knowledge, not interpreter design.

A full condition/exception system exposed to programs *inside* the interpreted language (`guard`, custom error objects) is out of scope — deferred to the same speculative "Advanced Interpreter" track as `call/cc` and mutation.

### Anti-cheat scope: ban only evaluation delegation, not implementation technique
The static check (`code-evaluation` — Static Checks Before Execution) blocks a submission that calls Racket's own `eval` or an equivalent dynamic-evaluation escape hatch (`dynamic-require`, `namespace-eval`, etc.), since that would let a player bypass writing an evaluator entirely. It does not restrict how the player's own Racket implementation is written — `apply` (a plain higher-order call, not code-as-data evaluation) and any host-level Racket technique, including mutation in the *implementation* itself, remain unrestricted. The mutation exclusion from the earlier decision applies only to what the *interpreted* language exposes to programs running inside it, not to how the player's Racket code implementing the evaluator is written.

## Risks / Trade-offs

- [Excluding a player-written reader could make the track feel narrower than "build an interpreter" implies to a player expecting to parse text too] → Acceptable trade-off for MVP scope focus; a player-written reader is a natural extension for the speculative Advanced Interpreter track.
- [The three-category minimal error list may prove too small or too large once real reference programs are drafted] → Flag for the future Interpreter track content change to validate against actual sample programs, not a reason to expand scope speculatively now.

## Open Questions

(none — all decisions needed to write the reference suite and intro content are fixed above)
