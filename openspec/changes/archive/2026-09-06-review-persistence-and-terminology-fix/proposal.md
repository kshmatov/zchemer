## Why

A review pass over the full spec baseline (2026-09-06, after fixing the content-unit granularity — a module is a lesson containing multiple exercises, not a 1:1 mapping) surfaced two real gaps: `progress-persistence` never commits to retaining what `gui-lcars`'s Review Mode Editor requires it to retain, and three requirements written before the module/exercise granularity was settled use "module" where "exercise" is the correct unit — one of them (`gui-lcars` — Review Mode Editor) is internally inconsistent between its own requirement text and scenario.

## What Changes

- `progress-persistence` gains two requirements: retaining the source of a player's most recent successful submission per completed inline exercise (updated on any later successful resubmission, including during review), and retaining a completed project-based exercise's folder path, selected entry-point file, and pass/fail status rather than a copy of its files (which already live on the player's filesystem) — with resilience when a retained folder path no longer resolves.
- `game-progression`'s Idempotent Review Grading and Retroactive Achievement Recognition During Review requirements are corrected from "module" to "exercise," matching the granularity already used correctly by `code-evaluation`'s Automated Test-Based Grading and by `game-progression`'s own Achievements for Notable Actions requirement.
- `gui-lcars`'s Review Mode Editor requirement is corrected to consistently say "exercise" (its own scenario already did; only the requirement statement was wrong), and gains a new requirement, Review Mode for Loaded Projects, giving project-based exercises (Interpreter, Multitasking tracks) the same review capability inline exercises already have, symmetric with the retained folder-path/entry-point data.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `progress-persistence`: adds retention requirements for last-successful-submission source (inline) and project folder reference (project-based), so `gui-lcars`'s review requirements are actually satisfiable.
- `game-progression`: corrects module→exercise terminology in the two review-related requirements added by `curriculum-review-and-navigation`.
- `gui-lcars`: corrects module→exercise terminology in Review Mode Editor and adds Review Mode for Loaded Projects.

## Impact

- Closes a spec-consistency gap where one capability's requirement depended on data another capability never committed to storing.
- No existing code is touched.
