## 1. Validate the Specification

- [ ] 1.1 Run `openspec validate define-project-scope --strict` and fix any structural issues in proposal/specs/design
- [ ] 1.2 Re-read all seven capability specs together and confirm no contradictions with `design.md`'s decisions (stack, sandbox profiles, save format)
- [ ] 1.3 Confirm the MVP boundary is consistent everywhere: base course (syntax/recursion/closures) + Interpreter and Multitasking tracks enabled; Network/Database/OOP visible but disabled; no class/teacher mode; no scripted story missions

## 2. Adopt as Project Baseline

- [ ] 2.1 Archive this change so its capability specs become the initial contents of `openspec/specs/`
- [ ] 2.2 Confirm `AGENTS.md` does not contradict the now-fixed decisions (stack, platform, MVP track scope); update it if it still reads as fully open

## 3. Scope Follow-Up Implementation Changes

- [ ] 3.1 Draft a change proposal for bootstrapping the Racket application skeleton (native window, LCARS shell, sandboxed `scheme-runtime`)
- [ ] 3.2 Draft a change proposal for the base course content and `curriculum` prerequisite-graph implementation
- [ ] 3.3 Draft a change proposal for the Scheme Interpreter track's `advanced-project-sandboxes` workspace
- [ ] 3.4 Draft a change proposal for the Multitasking track's concurrency-enabled sandbox profile
