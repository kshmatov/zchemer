## 1. Validate and Reconcile

- [x] 1.1 Run `openspec validate game-progression-engine --strict` and fix any structural issues in proposal/specs/design

## 2. Rank

- [x] 2.1 `engine/rank.rkt`: `RANK-THRESHOLDS` (6 labels) and `rank-for-completed-count`
- [x] 2.2 Tests: boundary values at each threshold, and just-below-threshold values, map to the correct rank

## 3. Achievement Catalog and Mechanism

- [x] 3.1 `engine/achievements.rkt`: `ACHIEVEMENT-CATALOG` (3 entries, 3 distinct condition styles) and `check-achievements`
- [x] 3.2 Tests: each of the 3 conditions correctly accepts a satisfying submission and rejects a non-satisfying one

## 4. Progress State Extension

- [x] 4.1 `engine/progress.rkt`: add `earned-achievements` field, `grant-achievement` (idempotent)
- [x] 4.2 Extend `save-progress`/`load-progress` for the new field; `load-progress` tolerates an old save file missing the `earned-achievements` key (defaults to `'()`) rather than erroring
- [x] 4.3 Tests: `grant-achievement` idempotency; round-trip save/load including `earned-achievements`; loading an old-format file (no `earned-achievements` key) succeeds with an empty list

## 5. GUI Wiring

- [x] 5.1 `gui/editor-panel.rkt`: after a pass, call `check-achievements` and `grant-achievement` for any newly-earned ones (unconditional on prior completion status), show them in the results area
- [x] 5.2 `gui/project-panel.rkt`: same, in `do-run!`'s pass branch (no catalog entries currently target either workspace module, so this wiring is presently a no-op in practice but keeps both panels consistent and ready for a future workspace-specific achievement)
- [x] 5.3 `gui/journal-panel.rkt`: add a rank label and an earned-achievements list-box; update `refresh-journal-panel!` to refresh both alongside the completed-entries list

## 6. Automated Tests

- [x] 6.1 Verify (don't reimplement) Idempotent Review Grading: a review pass on an already-completed lesson via the editor does not change `completed-modules`' membership count or duplicate the module id
- [x] 6.2 Retroactive Achievement Recognition: a first (non-achieving) pass, followed by a later review pass with a submission that now satisfies an achievement condition, grants that achievement even though the module was already completed
- [x] 6.3 An incorrect submission never grants an achievement, even if its source would otherwise satisfy a condition
- [x] 6.4 `gui/journal-panel.rkt`: rank label reflects `rank-for-completed-count` for the given completed-set; achievements list reflects exactly `earned-achievements`
- [x] 6.5 Run `raco test -x gui/main.rkt gui/` and `raco test engine/` and confirm every test (old and new) passes

## 7. Manual Smoke Test

- [x] 7.1 Run the app shell with a progress state that has earned an achievement and advanced rank; confirm the app opens without error against that state (`is-shown?` → `#t`) — functional smoke test only, no screenshot tool in this environment, as before; the Journal tab's actual rank/achievement display content is covered by the automated `journal-panel.rkt` tests (6.4)

## 8. Adopt as Content/Code Baseline

- [x] 8.1 Archive this change so rank/achievements become part of the reference engine and GUI
