## Why

`advanced-project-sandboxes` requires the Interpreter track to let a player implement and grade their own `eval`/`apply`, but left the language subset, the grading comparison, error-handling expectations, parsing responsibility, and the anti-cheat boundary undefined. Explore-mode discussion (2026-09-06) resolved all of these; content authoring for the track's intro modules and reference suite cannot start without them fixed.

## What Changes

- `advanced-project-sandboxes`'s Interpreter Track Evaluation Workspace requirement is narrowed to a concrete MVP language subset (definitions, `lambda`, conditionals, application, quotation — excluding `call/cc` and any variable/data mutation for this MVP) and clarified on two previously-unstated points: the reference suite's reader/parser is provided by the host, not written by the player, and grading compares the player's evaluator's printed output rather than a top-level return value.
- Adds a requirement for the minimal error detection a correct player evaluator must perform: unbound-variable, arity-mismatch, and non-procedure-application, distinct from primitive-level errors that Racket already raises for free when primitives are delegated.
- Adds a scenario clarifying the interpreter track's anti-cheat boundary: only delegating evaluation to Racket's own `eval` (or an equivalent dynamic-evaluation escape hatch) is disallowed by `code-evaluation`'s static check; the player's own implementation techniques (including `apply`, host-level mutation, etc.) are unrestricted.
- Corrects a design-level rationale carried over from `curriculum-review-and-navigation`/`define-base-course-skill-graph`: `mutable-state` is no longer justified as a base-course placement by the Interpreter track's needs (mutation is now out of that track's MVP scope). It stays in the base course, but for general Scheme literacy and the Multitasking track, not because two MVP tracks share it.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `advanced-project-sandboxes`: narrows and clarifies the Interpreter Track Evaluation Workspace requirement (language subset, reader provided, output-based grading, anti-cheat scenario) and adds a minimal error-detection requirement.

## Impact

- Fixes the reference sequence for the future Interpreter track content change (intro lessons for `symbolic-data`/`environment-model`, the reference sample-program suite, and its expected-output/expected-error fixtures).
- Supersedes the specific placement rationale for `mutable-state` recorded in the design docs of the two prior archived changes; those documents are left as-is (historical record of decisions at the time), and this change's `design.md` carries the corrected reasoning going forward.
- No existing code is touched.
