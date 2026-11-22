---
name: spec-sync
description: Ripple a requirement or contract change across a feature's spec artifacts before any code changes. Given a change ("把限领 3 张改成 5") or an edited PRD/contracts file, lists every downstream artifact that must follow — ACs, contract points, scenarios, specs, materialized tests, trace rows — and updates them together. Use whenever a decomposed feature's requirement shifts; the most-used SDD skill in steady state.
---

# Spec Sync — change one thing, update everything it touches

A decomposed feature's artifacts are cross-anchored: PRD AC ↔ contract point ↔ scenario ↔ spec ↔ test ↔ trace row. Change one anchor and every artifact citing it goes stale silently — the classic failure is "changed the limit in the PRD, forgot the error message and the test". This skill makes the ripple explicit and complete.

> Precondition: the feature has been decomposed (feature folder carries `contracts.md` + `trace.md`). If it hasn't, there's nothing to sync — edit the PRD and re-run `/to-spec`.

## Inputs

- **A stated change** — the user describes what should change ("the per-user coupon limit goes from 3 to 5"), or
- **An edited file** — the user (or a session) already changed the PRD or `contracts.md`; diff it (`git diff <feature-folder>` for tracked files, else compare against the artifacts' internal consistency) to recover the change.

## Process

### 1. Anchor the change

Locate exactly which anchors moved:

- Which **ACs** (`AC-<n>-<NN>`) changed wording, numbers, or priority.
- Which **contract points** (`C-NN`) those ACs map to — and whether the change demands new points or kills old ones.
- Which **scenarios** (`S-NN` in `trace.md`) walk those ACs/points.

If the change is too vague to anchor (no AC corresponds to it), it's a new requirement — route to `/idea-to-prd` (front half), not a sync.

### 2. Build the ripple list

Walk the anchors' citations downstream and list **every artifact that must change**, each with what changes in it:

1. **PRD** — the AC line(s): numbers, wording, priority marks.
2. **`contracts.md`** — the `C-NN` point(s): numbers, codes, shapes; new IDs for new points; struck points marked, not silently deleted (history matters to readers).
3. **`trace.md`** — affected scenario rows: rewritten expectations; `Status` flipped back to `pending`; stale `Test`/`Commit` entries struck.
4. **Specs** — every spec whose AC projection or contract references cite the moved anchors: assertion lines updated; specs whose design is invalidated flip to `needs-design`.
5. **Tests** — the materialized scenario tests behind affected `Test` cells: file + what must change (or be rewritten when the scenario changed shape).
6. **Code** — do NOT change code in this skill; that's the owning spec's rework (next step routes it).

Present the list to the user — one line per artifact — and get a go-ahead before editing. A ripple the user didn't expect is a signal the anchors are wrong somewhere; resolve that first.

### 3. Apply the ripple

Update every listed artifact in one pass, keeping IDs stable (renumbering breaks citations elsewhere). Preserve `Parent`/`Blocked by` structure; a spec whose `Blocked by` set changed gets its dependencies restated.

### 4. Re-run the double-anchor cross-check

On the changed rows only, re-verify: every P0 AC still maps to an assertable contract point, numbers agree on both sides, each scenario still lands in exactly one spec. Any failure → back to step 1 with the mismatch.

### 5. Report what now needs rebuilding

- Specs flipped to `needs-design` → they need `/to-spec`'s design step again.
- Specs still sound but with pending trace rows → they need a `/tdd` session (rework per their **Rework on failure** line).
- All-green already (test-only change) → just re-run the scenario suite.

Hand the routing decision to the user — typically `/sdd-flow` Stage 2 picks the specs back up, or a single `/tdd` for a small ripple.

## When NOT to use this skill

- The feature isn't decomposed yet → edit the PRD, re-run `/to-spec`.
- The change is purely internal (refactor, no observable behavior) → no anchor moved; nothing to sync.
- Multiple independent changes at once → sync them one at a time; interleaved ripples are unauditable.
