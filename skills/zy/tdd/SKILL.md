---
name: tdd
description: Implement a planning-complete spec scenario-first — use after /to-spec has produced a spec plus the feature's contracts.md and trace.md. The tests come from the P0 scenarios in trace.md (requirement-side, not implementer-invented) — materialize one as a real failing e2e/interface test, drive it green with a tracer bullet, refactor, repeat. Unit tests are discretionary tooling, not the discipline.
---

# TDD: Implement a Spec

The **planning is already done** — `/to-spec` produced a planning-complete spec (AC projection, contract references, scope, context, rework path) plus the feature's `contracts.md` and `trace.md`. This skill is the implementation half: turn the spec's scenarios into code, **scenario-first**.

If no spec is in hand, run `/to-spec` first.

## Philosophy

**The tests are not yours to invent.** The feature's P0 scenarios (`S-NN` rows in `trace.md`) were derived from the approved PRD's acceptance criteria before any code existed — they are the requirement side of the double anchor. Materializing them test-first is the anti-cheat gate: a scenario that runs red before its implementation exists is a test that actually tests something. An implementer who writes the code first and the tests after tends to write tests that bless the code.

**Good scenario tests** exercise real code paths through the contract points (`C-NN` from `contracts.md`) — the public interface. They read like the requirement: "user at limit re-receives → 403 COUPON_LIMIT_EXCEEDED". They survive refactors because they don't care about internal structure.

**Unit tests are discretionary.** Use them when they help — pinning down a tricky edge while debugging, guarding an invariant the scenario suite doesn't see, characterizing legacy behavior before touching it. They are tooling, not the discipline; nothing gates on them. This is `/codebase-design`'s **"interface is the test surface"** principle: wanting to test _past_ the interface is a signal the module is the wrong shape — fix the interface, don't paper over it with a mock.

## Anti-Pattern: Dumping the Suite

**DO NOT materialize every scenario test first, then implement everything.** That's horizontal slicing at the scenario level: bulk-written tests outrun your understanding, and the first GREEN proves nothing about the architecture path.

**Correct approach**: vertical, one scenario at a time — materialize → red → tracer-bullet green → refactor → next. The full P0 suite being green is a **feature-level** property (checked by `/sdd-flow` at Stage 3), accumulated across specs — never a per-session dump.

```
WRONG (horizontal):
  RED:   S-01, S-02, S-03, S-04 all written
  GREEN: impl everything

RIGHT (vertical):
  S-01 → red → green → refactor
  S-02 → red → green → refactor
  ...
```

## Before Workflow

Read the [Git Contract](docs/agents/git-contract.md) branch strategy. If the active mode is feature-branch, confirm you're on the right branch (idempotent — don't re-create it each spec); if solo, there's nothing to do.

Read the spec's **Acceptance criteria** (the AC projection), the feature's `contracts.md`, and the `trace.md` rows whose `Spec` column names this spec — those rows are your work list.

## Workflow

The spec's **AC projection** tells you which scenarios you own; the **Design**'s _Contract references_ are the public surface you test through. Honor **Scope** — don't touch what's listed Out.

**Design testable code as you go.** As you write each piece of minimal code, shape it for testability per `/codebase-design`'s three rules: **accept dependencies, don't create them**; **return results, don't produce side effects**; **keep the surface small**. Tests then fall out naturally instead of needing mocks. When `/codebase-design` isn't loaded, those three phrases are enough to apply.

### 1. Materialize the first scenario (RED)

Take the spec's top-priority scenario (`S-NN` from `trace.md`) and write it as a **real e2e/interface-level test** in the repo's test suite — the one-line sequence from the trace row expanded into the test's Given/When/Then, asserting through the contract points (`C-NN`), checking exactly the error codes / fields / numbers `contracts.md` specifies. Run it → **it must fail**. If it passes before any implementation, the test is wired wrong (or the behavior already exists) — stop and find out which.

Never weaken an assertion to make GREEN easier: the numbers and codes come from `contracts.md`, and changing them is a contract change, not a testing convenience.

### 2. Tracer bullet (first GREEN)

Write the minimal vertical path — entry to storage — that makes that one scenario pass. This proves the path works end-to-end before you invest in breadth.

### 3. Incremental loop

For each remaining scenario the spec owns, in priority order:

```
RED:   materialize next scenario test → fails
GREEN: minimal code to pass → passes
```

Rules:

- One scenario at a time
- Only enough code to pass the current scenario
- Don't anticipate future scenarios
- Add discretionary unit tests when they genuinely help (debugging, edges, invariants) — clearly as support, never as a substitute for a P0 scenario the spec owes

### 4. Refactor

After each GREEN, look for refactor candidates:

- [ ] Extract duplication
- [ ] **Deepen modules** — via `/codebase-design`'s **DEEPENING** pattern; the spec's **Design** may have flagged deep-module opportunities
- [ ] **Check seam and depth on what you built** — deletion test (delete it; complexity vanishing means a pass-through) and one-vs-two-adapters (one adapter = a hypothetical seam, drop it). See `/codebase-design`.
- [ ] Apply SOLID principles where natural
- [ ] Consider what new code reveals about existing code
- [ ] Run the scenario suite after each refactor step

**Never refactor while RED.** Get to GREEN first. If a scenario stays RED after honest minimal effort, the design is wrong somewhere — fall back to the spec's **Rework on failure** point rather than forcing code to fit. If what you discovered is a contract-level wrongness (the number in `contracts.md` can't be right), stop and surface it — that's `/spec-sync` territory, not something to code around.

### 5. Maintain the codemap

If `/codemap` is loaded and the spec touched an area a `docs/codemap/` map covers, run `/codemap` **drift-check** against that map once the implementation is GREEN — if it reports drift, update the affected map. Skip when `/codemap` isn't loaded or no map covers the area. Do this before closing the spec, so the map stays current with the code.

### 6. Close the spec

With every scenario the spec owns GREEN, refactor done, and the codemap current:

1. **Flip** the spec file's `Status: ready-for-agent` → `implemented` — no human confirmation is owed at this point; Stage 3's review and the trace gate are the backstop.
2. **Append an evidence comment** to the spec file (below `## Rework on failure`; format documented in `/to-spec`'s issue template) — for each AC-projection line, the scenario test that proves it (file + name), the suite command and pass/fail tally, and the commit from step 3. Pointers only — no narration, no source pasting (same stale-proof rule codemaps use).
3. **Backfill `trace.md`** — for every row this spec owns: `Test` = `file::test name`, `Commit` = the implementing sha, `Status` = `done`. Stage this edit with the next commit, or amend it into step 4's if not yet pushed.
4. **Commit** the work — code plus the status flip. For what to stage, message conventions, and whether to commit, follow the [Git Contract](docs/agents/git-contract.md).

## Checklist Per Cycle

```
[ ] Scenario came from trace.md, not from reading my own code
[ ] Test went RED before its implementation existed
[ ] Test asserts through contract points (codes/fields/numbers per contracts.md)
[ ] Code is minimal for this scenario
[ ] No speculative features added
```
