# <Spec title>

Type: spec
Status: needs-design # → ready-for-agent once step 5 design is filled in
Parent: #<prd-or-bug-issue-number> # omit if the source was a grilled conversation
Blocked by: #<n> # or "None — can start immediately"

## Goal

One sentence: what this spec solves.

## Acceptance criteria

The behaviors to test, critical paths first — you can't test everything. List behaviors, not implementation steps. Each check notes what it proves; prefer automated (tests, logs, run output, screenshots) over manual.

- [ ] Behavior 1 (critical path) — <what it proves>
- [ ] Behavior 2 — <what it proves>

## Scope

- **In**: what this spec touches.
- **Out**: what it deliberately does not — don't "fix" these opportunistically.

## Context

Pointers to the existing terrain this spec sits in — relevant modules/code areas, ADR numbers, glossary terms, constraints, past decisions. Point, don't prescribe: no new file paths, no code. A fresh-context agent reads these before coding.

## Design

Behaviour, not line-by-line implementation. No file paths or implementation snippets (they go stale) — interface signatures/schema are deliverables, not snippets; a prototype-sourced decision shape (state machine, reducer, schema) may be inlined in decision-rich parts only.

- **Interface delta** — public surface _after_ this spec (new/changed signatures, endpoints, schema). **Deep-module note**: is the surface small relative to the complexity it hides? If a cluster of shallow modules sits here, note where `/codebase-design`'s **DEEPENING** applies.
- **Internal architecture** — structural decisions beyond the interface (module boundaries, seam placement, state ownership, data-flow). Implementation detail is `/tdd`'s to emerge.

## Rework on failure

One line: the revert/retry point, or "failure is isolated; redo this spec only".
