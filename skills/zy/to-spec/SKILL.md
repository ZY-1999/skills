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
- **Consistent with siblings and ADRs** — its _Interface delta_ / _Internal architecture_ / naming agree with the specs already landed (step 4 skeletons + providers designed before it, since step 5 designs in dependency order), and it contradicts no key-decision ADR; where it must depart from an ADR, flag it for the human — don't land it quietly.

</design-bar>

Either way the design must clear the **design bar** above. `/codebase-design` is this step's vocabulary and principles — when loaded, lean on its patterns: **DESIGN-IT-TWICE** for genuine complexity and **DEEPENING** for the deep-module note.

Use the project glossary vocabulary in titles and bodies. Do NOT close or modify the parent PRD/bug issue.

### 6. Adversarial review — two fresh-context sub-agents

The agent that just designed the specs can't grade its own work. Fan out **two independent fresh-context sub-agents** (`general-purpose`, spawned in one message so they run in parallel) — each gets the landed specs plus **one** input and never the design chat, and returns PASS or specific defects (the spec + the failing line). Splitting along two axes keeps each sub-agent's context focused, because the inputs differ:

- **Sub-agent A — coverage vs. the source.** Input: the landed specs + the parent PRD/bug (or the grilled-design summary if no parent). **Does not read code.** Checks the three coverage axes:
  - **Goal coverage** — every goal / user story in the source maps to at least one spec's `Goal` + `Acceptance criteria`. No goal orphaned; no spec that serves nothing in the source.
  - **Test coverage** — when the source is a PRD, its **Testing Decisions** (what makes a good test, which modules, prior art) are reflected across the specs' acceptance behaviors and test-seam choices.
  - **Scope fidelity** — nothing out-of-scope crept in; nothing in-scope was dropped.

- **Sub-agent B — feasibility + cumulative consistency vs. the code.** Input: the landed specs + the **current codebase** (the `Context` areas each spec points at, plus `/codemap` if available) — never the source. Walk the specs **in `Blocked-by` order**, treat each one's _Interface delta_ / _Internal architecture_ as a transformation of the codebase, and **accumulate the running change** to check:
  - **Sequential coherence** — each consumer's assumed interface is actually produced by an earlier provider spec; no spec assumes a surface no predecessor sets up.
  - **Cumulative consistency** — specs touching the same file/surface accumulate to one _Interface delta_ / _Internal architecture_ / naming, not conflicting ones. (This is the step-5 design-bar "consistent with siblings" check seen globally and in order — the design bar only sees what landed before each spec; B sees every design together.)
  - **Feasibility** — applied cumulatively, the specs describe a codebase that can actually be built: real seams exist or are created by an earlier spec; nothing requires a change its predecessors don't make. Flag any spec unbuildable as written.

> **Trivial case** — single spec, or specs with no shared surface and no cross-spec coupling: drop Sub-agent B and run its check inline; keep A (coverage always matters).

If either sub-agent returns defects, loop back — add/merge/split specs (step 3) or refine a design (step 5) — and re-run the affected sub-agent. When both return PASS, all specs are `ready-for-human` (awaiting Gate A); point the user at the spec files in the issue tracker as the ground truth (don't re-paste them in chat).
