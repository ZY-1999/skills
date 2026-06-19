---
name: to-spec
description: Decompose a PRD, a bug, or the current (already-grilled) conversation into specs — atomic, planning-complete units an agent implements. One spec = one /tdd session. The breakdown is adversarially best-of-N'd with a fresh-context judge; complex-spec design uses /codebase-design (DESIGN-IT-TWICE for genuine complexity); spec skeletons land on disk before per-spec design.
---

# To Spec

A **spec** is the atomic unit of agent coding: the minimal thing an agent implements in one session, **planning-complete** — all planning settled here (simple specs let internals emerge in `/tdd`), so implementation starts straight at red-green. This skill turns a **PRD**, a **bug**, or a grilled conversation into specs; `prd`/`bug` are the parents, `spec` is the leaf.

## Inputs

- **A PRD or bug issue** (pass its number, URL, or path) → fetch and decompose. Every spec references it as `Parent`.
- **A grilled conversation** (no PRD yet) → synthesise the agreed design, then decompose. Do **not** re-interview — the grilling already happened (typically via `/grill-with-docs`).

> Precondition: the issue tracker layout is configured — run `/setup-skills` if not.

## Process

### 1. Gather context

Work from the conversation. If a PRD/bug reference was passed, fetch it and read body + comments; note its issue number for `Parent`.

### 2. Read the terrain before splitting

1. **Converge on the final goal** — what this ultimately achieves.
2. **List the sources of chaos** — unknown code, unknown requirements, cross-module coupling, risk, external dependencies.
3. **Map the terrain** — project glossary (`CONTEXT.md`), ADRs in the area you're touching, and a code map (`/codemap` when available, else explore directly). Flag — don't silently override — any decision that contradicts an ADR.

### 3. Decompose — best-of-N on the breakdown

The decomposition is the highest-leverage decision; a wrong cut propagates into every spec. If there's no PRD/bug parent, synthesise the agreed design first, then decompose that. **Acceptance lives here, not at design time** — each spec's key acceptance behaviors (critical paths) are what make it independently verifiable, so they're part of the cut, not deferred.

> **Best-of-N.** Draft 2–3 independent candidates in parallel (spawn that many `general-purpose` sub-agents in one message, each given the same brief but told to diverge — different counts/axes, no convergence). Judge them in a **separate fresh-context sub-agent** — never let a drafter grade its own work — against the decomposition bar below. Refine the winner to address every defect, re-judge; repeat until PASS or **3 rounds** (then stop and surface remaining defects to the human). For a trivial case (single obvious answer, or one dictated by the parent), drop to one candidate and skip straight to the critique. Each candidate is a **list of specs** (title, one-line goal, parent, blocked-by, what it delivers, **key acceptance behaviors**) — not yet designed in depth.

> **Reverse signals** — a spec isn't ready → split or redefine: goal still moving · not independently verifiable · scope bleed · no rework path · acceptance holes.

<decomposition-bar>

Is the cut sound? Judge candidates against:

- Each spec has a one-line goal + key acceptance behaviors (critical paths), independently verifiable.
- Each is one session's worth (too big → split, too small to verify alone → merge); cuts are **tracer bullets** — vertical slices through all layers, not horizontal.
- Dependency order acyclic; every `Blocked by` real and minimal.
- Prefactor ("make the change easy, then make the easy change") is its own spec, ordered first, when warranted.

</decomposition-bar>

<splitting-methods>

Pick the cut that best reduces risk and clarifies acceptance:

- **By code path**: entry → core logic → storage/external → presentation/caller.
- **By risk**: read-only/logging → state change → write path.
- **By acceptance**: smallest verifiable behaviour first, then expand.
- **By provider-consumer**: provider before consumer, contract before implementation.

</splitting-methods>

### 4. Land the skeletons — publish first, design after

Once the decomposition is settled, **publish every spec's skeleton to the issue tracker** using [references/issue-template.md](./references/issue-template.md), in dependency order (blockers first, so `Blocked by` references real numbers) and set `Status: needs-design`, before designing any in depth — the breakdown becomes ground truth on disk, not stranded in chat. Fill the header (`Type`/`Parent`/`Blocked by`), `Goal`, `Acceptance criteria` (from step 3), `Scope`, `Context`; stub `Design` and `Rework on failure` with `> to be designed`.

### 5. Design each spec (parallelize across specs; DESIGN-IT-TWICE for complex ones)

Design specs **in parallel** where the dependency graph allows: fan out one design task per independent spec in a single message. Respect `Blocked by` — a consumer spec's _Interface delta_ may depend on its provider's, so design providers first where that coupling exists; the skeletons already landed in dependency order in step 4, so the numbers encode the order. Acceptance is already set from step 3, so design here fills `Design` and `Rework on failure` (refine acceptance only if the concrete interface exposes a gap):

- **Design directly by default** — decide the **interface delta** (cross the fewest test seams — ideal: one) and, where structural decisions are non-trivial, the **internal architecture** (module boundaries, seam placement, state/data-flow). Trivial internals are left to emerge in `/tdd`. `/codebase-design`'s vocabulary and principles apply throughout.
- **Escalate to `/codebase-design`'s DESIGN-IT-TWICE only when the spec earns it** — many interface decisions, cross-module coupling, real trade-offs, deep-module opportunities. Then spin up parallel designs of the interface delta (with deep-module note) + internal architecture, each a _radically different_ way, and compare on three axes — **depth** (behaviour per unit of interface), **locality** (change concentrates in one place), **seam placement** (where the interface lives). It's a heavyweight tool for genuine complexity, not a default — if `/codebase-design` isn't loaded, still apply it manually against the design bar below.

<design-bar>

Is each spec's design deep enough? Judge the design against:

- **Interface delta** — public surface clear and deep; **deletion test**: deleting it should not make complexity vanish (else pass-through — deepen).
- **Internal architecture** — structural decisions made (module boundaries, seam, state/data-flow, deep-module opportunities), or none needed for a trivial spec; implementation detail left to `/tdd`.
- **Test seam** — fewest crossed, ideally one external seam; interface is the test surface.
- **Self-contained** — a fresh-context agent needs nothing beyond this spec + glossary + ADRs; describe behaviour, not implementation.

</design-bar>

Either way the design must clear the **design bar** above. `/codebase-design` is this step's vocabulary and principles — when loaded, lean on its patterns: **DESIGN-IT-TWICE** for genuine complexity and **DEEPENING** for the deep-module note. When done, write it into the file and flip `Status: needs-design` → `ready-for-agent`.

Use the project glossary vocabulary in titles and bodies. Do NOT close or modify the parent PRD/bug issue.

### 6. Self-review — coverage and cross-spec consistency

Before declaring done, self-check the specs two ways — against their source (the parent PRD/bug, or the grilled design if no parent) for **coverage**, and against each other for **consistency**:

- **Goal coverage** — every goal / user story in the source maps to at least one spec's `Goal` + `Acceptance criteria`. No goal orphaned; no spec that serves nothing in the source.
- **Test coverage** — when the source is a PRD, its **Testing Decisions** (what makes a good test, which modules, prior art) are reflected across the specs' acceptance behaviors and test-seam choices.
- **Scope fidelity** — nothing out-of-scope crept in; nothing in-scope was dropped.
- **No conflicts between specs** — where specs touch the same thing they must agree:
  - one consistent _Interface delta_ for any shared public surface (endpoint/schema/signature);
  - one consistent _Internal architecture_ for any shared structural concern (state ownership, data-flow direction, seam placement);
  - no contradictory edits to the same code area (real `Blocked by` deps are fine);
  - `Blocked by` directions match the actual interface coupling (a consumer is blocked by the provider it relies on);
  - terms/names consistent across specs (per the `CONTEXT.md` glossary).

If a gap or conflict surfaces, loop back — add/merge/split specs (step 3) or refine a design (step 5) to close it. When coverage is complete and the specs are conflict-free, all specs are `ready-for-agent`; point the user at the spec files in the issue tracker as the ground truth (don't re-paste them in chat).
