## Context

See `proposal.md` for motivation. Builds on `gui-shell-navigation` (`gui/app.rkt`, `gui/journal-panel.rkt`, `gui/skill-tree-panel.rkt`, `gui/lcars-style.rkt`), `engine/lesson-grader.rkt` (`grade-lesson-submission`), and `engine/progress.rkt` (`progress-state`, `mark-completed`, `record-submission`, `save-progress`) — all already archived and tested. Per `AGENTS.md`, the editor is built directly on `text%`/`editor-canvas%`, not a third-party widget.

## Goals / Non-Goals

**Goals:**
- A working editor tab: pick one of the 13 existing lessons, write code, check it against its `tests.rktd`, see per-entry results, and have a full pass persist and show up in the Journal/Skill Tree.
- Syntax highlighting for the base course's taught keywords, as a pure, independently-testable function.

**Non-Goals:**
- DrRacket-grade coloring (strings, comments, nested-paren-aware tokenization) — investigated using `framework`'s `racket:text%`, but its `start-colorer` needs a full `get-token`/lexer/`matches` setup that duplicates DrRacket-internal machinery for little benefit at this lesson-editor's scale; a simple keyword-only highlighter satisfies `gui-lcars`'s actual wording ("with syntax highlighting") without that complexity.
- Review Mode Editor (preloading a completed exercise's last submission) — a natural next slice, but kept separate so this change stays reviewable on its own.
- Anything for the Interpreter/Multitasking workspaces — this editor is only for the 13 inline lessons; the workspaces' project-based submissions are the future loaded-project view's job.

## Decisions

### Syntax highlighting: a pure keyword-position function, applied via `text%`'s own `change-style`
`gui/code-editor.rkt` exports `(keyword-positions text-string) -> (listof (cons start end))`, matching whole-word occurrences of the base course's taught keywords (`define`, `lambda`, `if`, `cond`, `else`, `let`, `let*`, `letrec`, `quote`, `quasiquote`, `unquote`, `set!`, `begin`, `and`, `or`, `case`, `when`, `unless`) using `pregexp`'s lookahead (`(?=...)`) for the trailing boundary and a leading-boundary character class captured in a group (`#:match-select cadr`) to avoid needing lookbehind, which Racket's `pregexp` doesn't support. A `text%` subclass overrides `after-insert`/`after-delete` to re-run `keyword-positions` over the whole buffer and re-apply styles (amber for keywords, default otherwise) after every edit — simple and correct at lesson-sized buffers (a few lines), where re-scanning the whole buffer on each keystroke has no perceptible cost.

Alternative considered: `framework`'s `racket:text%`, which is DrRacket's actual editor class — rejected for this change after investigation (`start-colorer` expects a 3-argument lexer/token-matcher setup, essentially reimplementing DrRacket's own Racket-mode wiring); worth revisiting in a later change if richer highlighting (strings, comments) becomes worth the investment.

### Lesson-to-directory mapping lives in the GUI layer, not `engine/`
`engine/curriculum.rkt` is content-agnostic (module ids only, no filesystem knowledge). `gui/editor-panel.rkt` defines its own small table, `LESSON-DIRS`, mapping each of the 13 lesson module ids to its `content/` directory — the same 13 ids `curriculum.rkt`'s `MODULE-TABLE` already has, excluding the two workspace ids (`interpreter-eval-workspace`, `multitasking-ledger-workspace`), which use a different submission contract (`run-program`/`run-ledger`, not `tests.rktd`'s `call`/`expr` entries) and belong to the future project view instead.

### Refreshing Journal/Skill Tree in place, rather than rebuilding the frame
`make-journal-panel`/`make-skill-tree-panel` already build their rows/list-box once. This change extracts each one's row-building logic into a shared internal helper and adds `refresh-journal-panel!`/`refresh-skill-tree-panel!`, which clear the panel's existing children (`(send panel change-children (lambda (l) '()))`) and rebuild them from a new completed-set — same visual result as reconstructing the panel, without `gui/app.rkt` needing to tear down and recreate the `tab-panel%`'s children.

### Shared progress state: a mutable box in `gui/app.rkt`, passed down
`gui/app.rkt` now holds a `(box progress-state)` and a `save-path`. The editor panel is given the box (to read/update) and a `refresh!` thunk (calling both other panels' `refresh!` with the box's current completed-set) to call after a successful check-and-persist. This is the minimum shared mutable state needed for one tab's action to visibly affect another tab — no broader event/observer system is introduced for a three-tab app.

## Risks / Trade-offs

- [Whole-buffer re-highlighting on every keystroke would not scale to large files] → Accepted: this editor is explicitly for the inline single-snippet lessons, which are always short; the future loaded-project view (larger files) is out of scope here and can revisit if needed.
- [A mutable box for shared progress-state is a step away from the purely-functional style `engine/` uses] → Necessary at the GUI layer, where user actions genuinely mutate what's currently displayed; `engine/progress.rkt` itself remains pure, only `gui/app.rkt`'s own state-holding is mutable.

## Open Questions

(none)
