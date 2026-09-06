## Why

Explore-mode discussion (2026-09-06) surfaced two gaps left open by the initial project-scope change: (1) `curriculum` never said *where* a skill needed by more than one advanced track should be taught, risking duplicate teaching of the same skill in each track; (2) none of `curriculum`, `game-progression`, or `gui-lcars` said whether a player can return to an already-completed module, or what happens to their progress/rewards if they do. Both block writing the actual base-course/track content, since content authors need to know whether a skill belongs in the base course or a track, and whether "completed" is a one-way door.

## What Changes

- `curriculum` gains a placement rule for skills required by multiple advanced tracks (teach once, in the base course) versus skills required by a single track (teach as that track's intro module, but still recorded as a shared graph node for future tracks), and a guarantee that completed modules stay reachable without losing progress.
- `game-progression` gains idempotent handling of re-passing an already-completed module during a revisit: rank and completion do not re-trigger, but achievement conditions are still evaluated and can be granted retroactively.
- `gui-lcars` gains a defined review mode for the inline editor (reopens with the player's last successful submission, with an option to clear and restart) and a two-view navigation model: a chronological log/journal as the primary screen, with a curriculum/skill-tree view as a secondary tab.
- No code changes — this change only updates specs and records the design decisions behind them.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `curriculum`: adds the shared-skill placement rule and the completed-module accessibility guarantee.
- `game-progression`: adds idempotent rank/completion on review re-submission, and retroactive achievement recognition during review.
- `gui-lcars`: adds the review-mode editor behavior and the journal-primary / skill-tree-secondary navigation structure.

## Impact

- Affects future content-authoring work (which module teaches which skill) and the future implementation of navigation, the editor, and the progress/achievement engine.
- No existing code is touched (none exists yet); this narrows and extends the spec baseline these systems will be built against.
