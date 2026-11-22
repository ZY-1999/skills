# <Spec title>

Type: spec
Status: needs-design # → ready-for-human once step 7 design is filled in (awaiting Gate A review)
Parent: #<prd-or-bug-issue-number> # omit if the source was a grilled conversation or a vetted simple requirement
Blocked by: #<n> # or "None — can start immediately"

## Goal

One sentence: what this spec solves.

## Acceptance criteria

The **AC projection** — the slice of the parent's acceptance criteria this spec delivers, not a fresh list. Each line cites its source AC and the contract assertions it covers; slice-local additions are allowed only when tied to a contract point:

- [ ] AC-2-01 (P0) via C-01: receiving at limit returns `403 COUPON_LIMIT_EXCEEDED` — proves the limit is enforced at the interface
- [ ] AC-2-02 (P1) via C-01: first receive returns `200 {couponId}` — proves the happy path

## Scope

- **In**: what this spec touches.
- **Out**: what it deliberately does not — don't "fix" these opportunistically.

## Context

Pointers to the existing terrain this spec sits in — relevant modules/code areas, ADR numbers, glossary terms, constraints, past decisions. Point, don't prescribe: no new file paths, no code. A fresh-context agent reads these before coding.

## Design

Behaviour, not line-by-line implementation. No file paths or implementation snippets (they go stale) — interface signatures/schema are deliverables, not snippets; a prototype-sourced decision shape (state machine, reducer, schema) may be inlined in decision-rich parts only.

- **Contract references** — the `C-NN` points from the feature's `contracts.md` this spec implements or extends, plus the slice's **delta**: what the public surface looks like *after* this spec (new/changed signatures, endpoints, schema), phrased as changes to those contract points. If design discovers a new or changed contract, land it in `contracts.md` first (assign the ID there), then reference it here — never define a contract inline. **Deep-module note**: is the surface small relative to the complexity it hides? If a cluster of shallow modules sits here, note where `/codebase-design`'s **DEEPENING** applies.
- **Internal architecture** — structural decisions beyond the interface (module boundaries, seam placement, state ownership, data-flow). Implementation detail is `/tdd`'s to emerge.

## Rework on failure

One line: the revert/retry point, or "failure is isolated; redo this spec only".

<!--
Evidence comment — appended by /tdd on close (not part of the design skeleton).
Shape:
  > **Comment** — implemented <date>; Status → implemented
  > - [x] AC-2-01 via C-01 — `tests/coupon_test.py::test_limit_rejected`
  > - Scenario suite run: `<command>` → N passed, 0 failed
  > - Commit: `<sha>` · trace.md rows backfilled (S-01 → done)
Pointers only; no narration or source pasting.
-->
