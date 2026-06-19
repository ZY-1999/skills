---
name: to-spec
description: Decompose a PRD, a bug, or the current (already-grilled) conversation into specs — atomic, planning-complete units an agent implements. One spec = one /tdd session. Both the breakdown and any complex spec design are adversarially best-of-N'd with a fresh-context judge; spec skeletons land on disk before per-spec design.
---

# To Spec

A **spec** is the atomic unit of agent coding: the minimal thing an agent implements in one session, **planning-complete** — interface, prioritized tests, and deep-module opportunities decided here, so implementation starts straight at red-green. This skill turns a **PRD**, a **bug**, or a grilled conversation into specs; `prd`/`bug` are the parents, `spec` is the leaf.

Two decisions dominate the outcome, both treated adversarially rather than trusted to the first draft: **how to cut the work into specs** (step 3) and **how to design each complex spec** (step 5). Both run as best-of-N with a fresh-context judge.

## Inputs

- **A PRD or bug issue** (pass its number, URL, or path) → fetch and decompose. Every spec references it as `Parent`.
- **A grilled conversation** (no PRD yet) → synthesise the agreed design, then decompose. Do **not** re-interview — the grilling already happened (typically via `/grill-with-docs`).

> Precondition: the issue tracker layout is configured — run `/setup-skills` if not.

## Spec quality bar

Every spec must clear this. It's the judge's checklist for both decomposition candidates (does each spec in the cut clear it?) and per-spec design candidates:

- **One-sentence goal** — what this round solves.
- **Visible In/Out boundaries** — know what not to touch.
- **Locatable context** — relevant code, requirements, constraints, past decisions.
- **Prioritized, verifiable acceptance** — behaviors to test (not implementation steps), critical paths first; you can't test everything. Each check says what it proves; prefer automated over manual.
- **Local failure recovery** — failure doesn't topple the whole.
- **Room for the agent to choose its path** — describe behaviour, not line-by-line implementation.

If a candidate trips a 反向指标 — goal still moving, not independently verifiable, scope bleed, no rework path, no approach/risk choice for the user, or acceptance holes — **split or redefine before publishing**.

## Process

The two adversarial steps share one loop:

> **Best-of-N.** Draft 2–3 independent candidates in parallel (spawn that many `general-purpose` sub-agents in one message, each given the same brief but told to diverge — different counts/axes, no convergence). Judge them in a **separate fresh-context sub-agent** — never let a drafter grade its own work — against the relevant quality bar. Refine the winner to address every defect, re-judge; repeat until PASS or **3 rounds** (then stop and surface remaining defects to the human). For a trivial case (single obvious answer, or one dictated by the parent), drop to one candidate and skip straight to the critique.

### 1. Gather context

Work from the conversation. If a PRD/bug reference was passed, fetch it and read body + comments; note its issue number for `Parent`.

### 2. Read the terrain before splitting

1. **Converge on the final goal** — what this ultimately achieves.
2. **List the sources of chaos** — unknown code, unknown requirements, cross-module coupling, risk, external dependencies.
3. **Map the terrain** — project glossary (`CONTEXT.md`), ADRs in the area you're touching, and a code map (`/codemap` when available, else explore directly). Flag — don't silently override — any decision that contradicts an ADR.

### 3. Decompose — best-of-N on the breakdown

The decomposition is the highest-leverage decision; a wrong cut propagates into every spec. Run the best-of-N loop on it. If there's no PRD/bug parent, synthesise the agreed design first, then decompose that. **Acceptance lives here, not at design time** — each spec's key acceptance behaviors (critical paths) are what make it independently verifiable, so they're part of the cut, not deferred. Each candidate is a **list of specs** (title, one-line goal, parent, blocked-by, what it delivers, **key acceptance behaviors**, test-seam sketch) — not yet designed in depth.

Judge against the **decomposition quality bar:**

- Each spec is one session's worth — too big to finish, split; too small to verify alone, merge.
- Cuts are **tracer bullets** — thin vertical slices through ALL layers (schema → API → UI → tests), not horizontal layer slices.
- Dependency order is acyclic; every `Blocked by` is real and minimal.
- The cut reduces risk and clarifies acceptance, not just divides work.
- No scope bleed; no spec whose goal is still moving.
- Prefactor ("make the change easy, then make the easy change") is its own spec, ordered first, when warranted.

<splitting-methods>

Pick the cut that best reduces risk and clarifies acceptance:

- **By code path**: entry → core logic → storage/external → presentation/caller.
- **By risk**: read-only/logging → state change → write path.
- **By acceptance**: smallest verifiable behaviour first, then expand.
- **By provider-consumer**: provider before consumer, contract before implementation.

</splitting-methods>

### 4. Land the skeletons — publish first, design after

Once the decomposition is settled, **publish every spec's skeleton to the issue tracker** in dependency order (blockers first, so `Blocked by` references real numbers) and set `Status: needs-design`, before designing any in depth — the breakdown becomes ground truth on disk, not stranded in chat. Fill the header (`Type`/`Parent`/`Blocked by`), `Goal`, `Acceptance criteria` (from step 3), `Scope`, `Context`; stub `Design` and `Rework on failure` with `> to be designed`.

### 5. Design each spec — best-of-N on the complex ones (parallelize across specs)

Design specs **in parallel** where the dependency graph allows: fan out one design task per independent spec in a single message. Respect `Blocked by` — a consumer spec's _Interface delta_ may depend on its provider's, so design providers first where that coupling exists; the skeletons already landed in dependency order in step 4, so the numbers encode the order. Acceptance is already set from step 3, so design here fills `Design` and `Rework on failure` (refine acceptance only if the concrete interface exposes a gap):

- **Simple spec** (single interface delta, few trade-offs, local) → design directly in one pass: pick the highest test seam available (fewer is better; ideal: one), decide the interface delta and internal design (modules/data flow).
- **Complex spec** (many interface decisions, cross-module, real trade-offs, deep-module opportunities) → run the best-of-N loop, each candidate giving the **interface delta** (with deep-module note) and the **internal design** (modules/data flow, test-seam choice).

Either way the design must clear the spec quality bar. Run `/codebase-design` when available for vocabulary and testability checks. Each spec is **self-contained** — a fresh-context agent needs nothing beyond it, the glossary, and relevant ADRs. When done, write it into the file and flip `Status: needs-design` → `ready-for-agent`.

Use the project glossary vocabulary in titles and bodies. Do NOT close or modify the parent PRD/bug issue.

<issue-template>

```markdown
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

Describe behaviour, not line-by-line implementation. No file paths or code snippets (they go stale) — exception: a prototype-produced decision-encoding snippet (state machine, reducer, schema, type shape) may be inlined in the decision-rich parts only, noted as prototype-sourced.

- **Interface delta** — what the public interface looks like _after_ this spec (new/changed signatures, endpoints, schema shape). Deep-module note: favour small interfaces hiding complex implementation. (Interface signatures/schema are deliverables, not "stale snippets" — the no-snippet rule above targets internal impl detail and file paths.)
- **Internal design** — the internal design decisions this spec needs (modules, data flow, state) beyond the interface above. Describe, don't prescribe — leave the agent room to choose its path.

## Rework on failure

One line: the revert/retry point, or "failure is isolated; redo this spec only".
```

</issue-template>

### 6. Self-review — coverage and cross-spec consistency

Before declaring done, self-check the specs two ways — against their source (the parent PRD/bug, or the grilled design if no parent) for **coverage**, and against each other for **consistency**:

- **Goal coverage** — every goal / user story in the source maps to at least one spec's `Goal` + `Acceptance criteria`. No goal orphaned; no spec that serves nothing in the source.
- **Test coverage** — when the source is a PRD, its **Testing Decisions** (what makes a good test, which modules, prior art) are reflected across the specs' acceptance behaviors and test-seam choices.
- **Scope fidelity** — nothing out-of-scope crept in; nothing in-scope was dropped.
- **No conflicts between specs** — where specs touch the same thing they must agree: one consistent *Interface delta* for any shared public surface (endpoint/schema/signature); no contradictory edits to the same code area (real `Blocked by` deps are fine); `Blocked by` directions match the actual interface coupling (a consumer is blocked by the provider it relies on); terms/names consistent across specs (per the `CONTEXT.md` glossary).

If a gap or conflict surfaces, loop back — add/merge/split specs (step 3) or refine a design (step 5) to close it. When coverage is complete and the specs are conflict-free, all specs are `ready-for-agent`; point the user at the spec files in the issue tracker as the ground truth (don't re-paste them in chat).
