## Why

`game-progression` is the last unimplemented base spec in the project: rank/level progression, discrete achievements independent of rank, idempotent review grading, and retroactive achievement recognition during review are all specified but nothing exists yet — `engine/progress.rkt` tracks completed modules and project refs, but no rank derivation, no achievement mechanism, and no GUI surfaces either. This change implements the generic mechanism `game-progression` fully specifies, plus a concrete starter achievement catalog (new content, analogous to the reference-suite/exercise content prior changes added) demonstrating it against real lessons.

## What Changes

- Add `engine/rank.rkt`: a pure `rank-for-completed-count` function mapping a completed-module count to a Starfleet-style rank label (visual/thematic only, per `AGENTS.md` — no narrative missions), over six ranks spanning the 15-module curriculum.
- Add `engine/achievements.rkt`: an `ACHIEVEMENT-CATALOG` table (module id, achievement id, label, a pure `submission-source -> boolean?` condition) plus `check-achievements` (which of a module's achievements a given submission satisfies). Ships a three-achievement starter catalog: one checking a submission avoids `let` (`binding`), one checking a submission is exactly one top-level form (`recursion-basic`), one checking submission length (`higher-order-fn`) — demonstrating the mechanism across distinct condition styles, not an exhaustive catalog for all 15 modules.
- Extend `engine/progress.rkt`'s `progress-state` with an `earned-achievements` field and a `grant-achievement` update function (idempotent, mirroring `mark-completed`'s pattern); extend the save/load format accordingly.
- Wire `gui/editor-panel.rkt` and `gui/project-panel.rkt`: after any passing grade (first completion or a later review re-check — per `game-progression`'s Retroactive Achievement Recognition During Review requirement, achievement checks run regardless of prior completion status), run `check-achievements` and grant/report any newly-earned ones. `mark-completed`'s own idempotency already satisfies Idempotent Review Grading (a review pass never re-triggers completion); this change doesn't need to change that logic, only verify it with a test.
- Add a rank display and an achievements list to `gui/journal-panel.rkt` (the app's primary navigation screen), refreshed by the existing `refresh-journal-panel!` alongside the completed-modules list.

## Capabilities

### New Capabilities
- `achievement-catalog-content`: The concrete starter catalog of achievement conditions (which module, what condition, what label) that `game-progression`'s Achievements for Notable Actions requirement assumes exists.

### Modified Capabilities
(none — the generic rank/achievement mechanism, idempotent review grading, and retroactive recognition are all already specified in full by `game-progression`; only the achievement catalog's concrete content is new)

## Impact

- Adds `engine/rank.rkt`, `engine/achievements.rkt`. Modifies `engine/progress.rkt` (additive: new field + function; existing fields/functions unchanged).
- Modifies `gui/editor-panel.rkt`, `gui/project-panel.rkt` (additive: achievement-check call after a pass), `gui/journal-panel.rkt` (additive: rank label + achievements list).
- New `openspec/specs/achievement-catalog-content/spec.md` capability.
- Out of scope: a full achievement catalog covering every one of the 15 modules (this is a representative starter set, same scoping precedent as `track-workspaces`' single reference suite/exercise); any UI for browsing achievement *descriptions* before earning them (only earned ones are shown, per the Journal's existing "completed entries" framing).
