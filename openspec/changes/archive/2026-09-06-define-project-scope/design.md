## Context

See `proposal.md` for motivation. Constraints fixed during discussion (see this change's spec files for the resulting behavior contracts): solo player, native desktop app (no Electron/browser runtime), embedded R6RS engine that both teaches and checks code, MVP advanced tracks limited to Scheme Interpreter and Multitasking, local-only persistence.

## Goals / Non-Goals

**Goals:**
- Pick one implementation stack that covers native GUI, an R6RS-capable runtime, and safe execution of untrusted player code, to keep solo-maintainable.
- Define how the prerequisite graph, sandboxed execution, and save format are represented concretely enough to unblock task breakdown.

**Non-Goals:**
- Deciding exact LCARS color/typography tokens or pixel-level layout (a `gui-lcars` implementation change's concern).
- Designing the Network, Database, or OOP track sandboxes (out of MVP scope per `advanced-project-sandboxes` spec).
- Multi-user/class features, cloud sync, or accounts (explicitly out of scope for this product per proposal).

## Decisions

### Stack: Racket (`racket/gui` + `racket/sandbox`)
Chosen over Chez Scheme + hand-built native GUI, Guile + GTK, and a Rust/C++ host embedding a separate Scheme engine.

Rationale:
- `racket/gui` produces genuinely native, standalone executables (`raco exe` / `raco distribute`) on Windows/macOS/Linux without a browser or Electron-style runtime, satisfying `gui-lcars`'s native-application requirement.
- Racket supports the R6RS language directly (`#!r6rs` / `(import (rnrs …))`), close enough to the base course and interpreter-track scope decided in `curriculum` and `scheme-runtime`.
- `racket/sandbox` provides exactly the isolation primitive `scheme-runtime` and `code-evaluation` require (time/memory limits, restricted namespace) without building a custom process-isolation layer from scratch.
- Single language/toolchain for host app and executed code minimizes solo-dev surface area versus a two-language host+engine split.

Alternatives considered: Chez Scheme (fastest, most reference-accurate R6RS, but no GUI or sandbox story — both would be built from scratch); Guile+GTK (mature native GUI, but R6RS is a compatibility shim over Guile's own dialect, risking subtle divergence from what the base course teaches); Rust/C++ host embedding a Scheme library (maximum GUI control, but doubles the runtime/language surface for a solo project with no corresponding benefit given Racket already satisfies the constraints).

### Sandbox configuration for the Multitasking track
`racket/sandbox` restricts networking, threads, and other primitives by default for security. The Multitasking track's requirement for *real* concurrency (`scheme-runtime` — Genuine Concurrency Semantics) means the sandbox configuration for that track must explicitly re-enable Racket's thread/place/future primitives while keeping other restrictions (filesystem, network, eval budget) in place. This is a track-specific sandbox profile, not the default profile used for the base course and other exercises.

### Code editor widget
Built as a custom widget on `racket/gui`'s `text%`/`editor-canvas%`, rather than reusing `framework`'s DrRacket-style `color:text%` components, so the LCARS visual language (panel chrome, color coding, typography) can be applied without fighting a pre-styled DrRacket look. This means syntax highlighting is implemented directly (tokenizing R6RS syntax) rather than inherited for free.

### Prerequisite graph representation
The `curriculum` capability's prerequisite graph is represented as a directed acyclic graph of skill nodes, where each base-course and advanced-track module declares the skills it grants and the skills it requires. A module unlocks when all its required skills are present in the player's granted-skills set (from `progress-persistence`). This keeps cross-track skill sharing (e.g., recursion learned in the base course satisfying a prerequisite for the Interpreter track) a data lookup rather than special-cased logic per track.

### Save format
Player progress (rank/level, achievements, granted-skills set, per-track completion state) is serialized as an S-expression to a single local file next to the application, satisfying `progress-persistence`'s human-inspectable requirement and reusing Racket's native reader/writer instead of a separate JSON library.

### Error translation layer
`code-evaluation`'s requirement to translate raw runtime errors into learner-facing hints is implemented as a mapping from Racket's exception structure (`exn:fail:*` hierarchy and source-location info) to canned, LCARS-styled message templates keyed by error category (arity, unbound identifier, contract violation, timeout, etc.), with the offending source location highlighted in the editor.

## Risks / Trade-offs

- [Racket's R6RS support has known gaps/divergences from a strict reference R6RS implementation] → Scope the base course and MVP tracks to the subset already decided (syntax, recursion, closures, concurrency primitives) and re-validate before enabling `syntax-rules`-heavy or continuation-heavy content later.
- [Building syntax highlighting on raw `text%` instead of reusing `framework`'s coloring is more upfront work] → Accept as a one-time cost; scope a minimal tokenizer (keywords, strings, comments, parens) for the MVP editor rather than full semantic highlighting.
- [Track-specific sandbox profiles (default vs. concurrency-enabled) increase the number of trust configurations to maintain] → Keep the set of profiles small and explicit (one per track category needing non-default permissions), documented alongside `scheme-runtime`.
- [Native packaging for three desktop platforms (Windows/macOS/Linux) via `raco distribute` has platform-specific quirks] → Treat cross-platform packaging as its own task in the implementation change rather than assuming it "just works" from Racket's tooling.

## Open Questions

- Exact LCARS color palette, typography, and panel geometry — deferred to the `gui-lcars` implementation change; does not affect these specs or the task breakdown for this change.
- Precise set of achievement conditions beyond "notable/elegant solution" — deferred to `game-progression` implementation; the requirement (achievements exist, are independent of rank) is already fixed.
