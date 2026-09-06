## Context

See `proposal.md` for motivation. Builds directly on `engine/curriculum.rkt` (`MODULE-TABLE`, `module-status`) and `engine/progress.rkt` (`load-progress`, `progress-state`), both already archived and tested. Per `AGENTS.md`, the GUI uses `racket/gui` (no Electron/browser/webview).

## Goals / Non-Goals

**Goals:**
- A native window that opens and shows two tabs: Journal (primary) and Skill Tree (secondary), per `gui-lcars`.
- A small, consistently-applied LCARS color palette shared by both views.
- Wire real data through: the Skill Tree reflects `curriculum.rkt`'s actual computed statuses for a given completed-set; the Journal reflects `progress.rkt`'s actual saved completion order.

**Non-Goals:**
- The inline code editor, syntax highlighting, or running submissions (`gui-lcars`'s Inline Code Editor requirement) — needs wiring to `engine/lesson-grader.rkt`/the two workspaces, a separate change.
- The loaded-project view — needs `advanced-project-sandboxes`' project-loading mechanism, which doesn't exist yet.
- Review mode (reopening a completed exercise preloaded with its last submission, or reopening a project) — needs the editor/project view to exist first.
- Pixel-accurate Star Trek LCARS chrome (rounded/angled panel shapes, elbow connectors) — this slice uses color-coded rectangular panels and a consistent palette/typography, which already satisfies `gui-lcars`'s actual requirement wording ("panel shapes, color-coded regions, typography remain visually consistent") without needing custom-painted curved geometry; that refinement can follow in a later visual-polish change if wanted.

## Decisions

### Journal order: reuse `progress-state`'s existing insertion order, no new timestamp field
`progress.rkt`'s `mark-completed` already conses each newly-completed module onto the front of `completed-modules`, so the stored list is already in most-recent-first order, preserved exactly through `save-progress`/`load-progress` (both just read/write the list as-is). The Journal panel displays this order directly rather than adding a separate timestamp to `progress-state` — `progress-persistence`'s spec requires a "chronological log," not any particular direction, and most-recent-first is the same convention the base course's own log-entry framing already uses (a ship's log where the latest entry is what you check first).

### Skill Tree shows every `MODULE-TABLE` entry, not just base-course nodes
Per `gui-lcars`'s Skill Tree wording ("the base course and each advanced track with their completion and lock state"), every entry in `curriculum.rkt`'s `MODULE-TABLE` (base-course nodes, both tracks' intro nodes, both workspaces) is listed with its computed `module-status`. `ENABLED-TRACKS`/`PLANNED-TRACKS` distinction (visible-but-disabled tracks) is deferred to a later change, since `PLANNED-TRACKS` currently has zero modules to show and nothing to visually distinguish yet beyond a track name — not worth inventing a placeholder UI for empty content in this slice.

### Widget construction is separated from `show`, so tests never pop a visible window
Every panel-building function (`make-journal-panel`, `make-skill-tree-panel`, `make-app-frame`) takes an existing parent container and returns without calling `show` on any top-level frame — `gui/main.rkt` is the only place that calls `(send frame show #t)`. This lets `rackunit` tests construct real widgets (a real `frame%` as an invisible parent is fine — `racket/gui` widget construction doesn't require visibility) and inspect them (item counts, labels, computed colors) without a window ever appearing during `raco test`.

### Color palette and status mapping
```racket
BG-COLOR       "black"
PANEL-COLOR    (make-color 20 20 30)     ; dark panel background
ACCENT-AMBER   (make-color 255 153 0)    ; LCARS orange/amber
ACCENT-LAVENDER (make-color 204 153 255) ; LCARS lavender
TEXT-COLOR     "white"

(status->color 'locked)     -> a muted grey
(status->color 'available)  -> ACCENT-AMBER
(status->color 'completed)  -> a green
```
Both panels import this one module for every color decision, so a future palette change (e.g. real Trek-accurate hues) touches one file.

### Running the test suite: exclude `gui/main.rkt`
`gui/main.rkt` is a plain runnable script (no `module+ test` submodule), so a bare `raco test gui/` tries to run its module body directly — which pops a real window and blocks on the GUI event loop. Use `raco test -x gui/main.rkt gui/` (matching how `raco test engine/` already tolerates `engine/info.rkt`, a non-test file, in that directory).

### Forward note for the editor-wiring change
`gui/app.rkt`'s `tab-panel%` is built with a fixed `TAB-LABELS` list and one child panel per label. A future change adding the inline editor (and later the project view) should append a third (and fourth) tab/child-panel pair to this same `tab-panel%`, rather than restructuring the Journal/Skill Tree tabs this change already builds.

## Risks / Trade-offs

- [No screenshot tooling in this environment means the LCARS styling's actual visual result can't be verified here beyond "the right widgets exist with the right computed colors"] → Documented explicitly in `proposal.md`'s Impact section and in this change's final report; the user can run `racket gui/main.rkt` themselves to see it.
- [Reusing `completed-modules`' list order as "chronological" assumes a player never needs true wall-clock timestamps (e.g., "completed 3 days ago") — if a later change needs that, `progress-state` will need a real timestamp field] → Acceptable for this slice; `gui-lcars`'s spec only requires chronological *ordering*, not timestamp display.

## Open Questions

(none)
