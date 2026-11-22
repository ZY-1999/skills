---
name: to-spec
description: Decompose a PRD, a bug, the current (already-grilled) conversation, or a simple complete requirement into specs — atomic, planning-complete units an agent implements. Simple requirements pass a completeness gate at entry — anything under-specified is routed to /grill-me or /to-prd, never guessed into specs. First translates the parent's acceptance criteria into a technical contracts file (double-anchor cross-check) and a scenario trace matrix, then decomposes best-of-N with a fresh-context judge; complex-spec design uses /codebase-design (DESIGN-IT-TWICE for genuine complexity); spec skeletons land on disk before per-spec design.
---

# To Spec

A **spec** is the atomic unit of agent coding: the minimal thing an agent implements in one session, **planning-complete** — all planning settled here (simple specs let internals emerge in `/tdd`), so implementation starts straight at red-green. This skill turns a **PRD**, a **bug**, a grilled conversation, or a simple complete requirement (admitted only through the completeness gate) into specs; `prd`/`bug` are the parents, `spec` is the leaf.

The PRD is requirements-only, so this skill owns the **translation into technical terms**, landing two feature-level artifacts before any decomposition:

- **`contracts.md`** — the technical truth source: contract points (`C-NN` — endpoints, error codes, data fields, constraints).
- **`trace.md`** — the traceability matrix: AC → scenario → contracts → spec → test → commit.

## Inputs

- **A PRD or bug issue** (pass its number, URL, or path) → fetch and decompose. Every spec references it as `Parent`.
- **A grilled conversation** (no PRD yet) → synthesise the agreed design, then decompose. Do **not** re-interview — the grilling already happened (typically via `/grill-with-docs`).
- **A simple, complete requirement** (neither grilled nor distilled — it already answers everything a grill would ask) → vet it against the completeness bar below, then decompose directly, no `Parent`. Fails the bar → hand it back as the bar says — never guess.

<completeness-bar>

Admit a requirement through the no-PRD door only if **both** hold:

- **Simple** — one feature surface; the outcome fits in a sentence or two; nothing here would earn a long grill or DESIGN-IT-TWICE.
- **Complete** — goal, scope (in and out), and the done-defining behaviors are stated or directly implied; no open question a grill would have to settle (users, edge cases, data shapes, error handling); the goal isn't still moving.

Either check failing means the requirement isn't to-spec-ready — decomposing it anyway bakes the guesses into every spec. Hand it back instead: `/grill-me` when the gaps are still open (raw idea), `/to-prd` when the design was discussed but never distilled into a parent.

A requirement that passes the bar plays the grilled-design role for the rest of the process: its done-defining behaviors are numbered as `AC-1-NN` (all P0) and enter the same double-anchor translation as any PRD's acceptance criteria.

</completeness-bar>

> Precondition: the issue tracker layout is configured — run `/setup-skills` if not.

## Process

### 1. Gather context

Work from the conversation. If a PRD/bug reference was passed, fetch it and read body + comments; note its issue number for `Parent`. If there is **no parent and no grilling happened**, the requirement itself is the source — run the completeness bar first: on pass it plays the grilled-design role for the rest of the process (still no `Parent`); on fail, stop at the hand-back and do not decompose a guessed requirement.

### 2. Read the terrain before splitting

1. **Converge on the final goal** — what this ultimately achieves.
2. **List the sources of chaos** — unknown code, unknown requirements, cross-module coupling, risk, external dependencies.
3. **Map the terrain** — project glossary (`CONTEXT.md`), ADRs in the area you're touching, and a code map (`/codemap` when available, else explore directly). Flag — don't silently override — any decision that contradicts an ADR.

### 3. Align — translate ACs into contracts (double-anchor)

Write the feature's `contracts.md` ([references/contracts-template.md](./references/contracts-template.md)) at the feature folder root: for every acceptance criterion in the parent (or in the vetted requirement's numbered behaviors), design the contract point(s) that make it observable — endpoint + error code, field + constraint, or assertable behavior. This is where requirement language becomes technical language; it happens **before** decomposition so every cut is anchored to a testable surface.

Then **cross-check both anchors against each other**:

- **Coverage** — every P0 AC maps to at least one assertable contract point. An AC with no anchor is untestable as written: surface it to the human immediately (fix the PRD or design the missing contract) — don't decompose around it.
- **Numbers** — quantities in the AC equal quantities in the contract ("限领 3 张" ↔ `limit_per_user: 3`). A mismatch is a defect on one side; find out which before proceeding.
- **Layer purity** — contracts carry no user narrative; if the PRD already leaked technical detail, carry it into `contracts.md` and note the leak for `/spec-check`.

### 4. Scenarios — seed the trace matrix

For every P0 AC, write one scenario (`S-NN`): a one-line behavior sequence with an assertable expectation, walking named contract points. Land `trace.md` ([references/trace-template.md](./references/trace-template.md)) with one row per scenario — Contracts and Spec columns filled during decomposition, Test/Commit left empty for `/tdd`. These scenarios are the feature's executable acceptance suite; `/sdd-flow` gates Stage 3 on every P0 row being `done`.

### 5. Decompose — best-of-N on the breakdown

The decomposition is the highest-leverage decision; a wrong cut propagates into every spec. If there's no PRD/bug parent, synthesise the agreed design first (a vetted simple requirement already *is* that design), then decompose that. **Acceptance lives here, not at design time** — each spec's AC projection (which parent ACs + contract points it covers) is what makes it independently verifiable, so the projection is part of the cut, not deferred.

> **Best-of-N, file-grounded.** Candidates are drafted to disk, not prompt-fed into chat — the judge reviews grounded files, and losing candidates never enter your context. Drafts live under the feature folder's `.drafts/decompose/` (create the feature folder now if no parent is on disk yet; step 6 reuses it).
>
> Spawn 2–3 `general-purpose` sub-agents in one message, each told to diverge (different counts/axes, no convergence) and each writing its candidate to its **own folder** `.drafts/decompose/candidate-<N>/` — a list of specs (title, one-line goal, parent, blocked-by, what it delivers, **AC projection** — the ACs and `C-NN` points each spec carries), not yet designed — returning only the path. Judge in a **separate fresh-context sub-agent** (never a drafter) by pointing it at `.drafts/decompose/`; it reads the folders and returns the winner plus defects against the bar below. Refine the winner **in its folder**, re-judge (re-reads); repeat until PASS or **3 rounds** (then surface remaining defects to the human with the drafts). Trivial case — single obvious answer, or one dictated by the parent: one candidate, straight to the critique.
>
> Drafts are transient: once the cut is confirmed (judge PASS), carry the winner into step 6; delete `.drafts/decompose/` once the skeletons land — the breakdown now lives as ground-truth issues.
>
> **Reverse signals** — a spec isn't ready → split or redefine: goal still moving · not independently verifiable · scope bleed · no rework path · acceptance holes.

<decomposition-bar>

Is the cut sound? Judge candidates against:

- Each spec has a one-line goal + an **AC projection** (source AC ids + `C-NN` contract points), independently verifiable.
- Each is one session's worth (too big → split, too small to verify alone → merge); cuts are **tracer bullets** — vertical slices through all layers, not horizontal.
- **Anchor completeness** — every P0 AC's scenario lands in exactly one spec (or a documented chain); no contract point is claimed by two specs with conflicting deltas.
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

### 6. Land the skeletons — publish first, design after

Once the decomposition is settled, **publish every spec's skeleton to the issue tracker** using [references/issue-template.md](./references/issue-template.md), in dependency order (blockers first, so `Blocked by` references real numbers) and set `Status: needs-design`, before designing any in depth — the breakdown becomes durable ground truth on disk, not a transient draft. Fill the header (`Type`/`Parent`/`Blocked by`), `Goal`, `Acceptance criteria` (the AC projection from step 5), `Scope`, `Context`; stub `Design` and `Rework on failure` with `> to be designed`. Fill the `Spec` column of every `trace.md` row as the skeletons land.

### 7. Design each spec (parallelize across specs; DESIGN-IT-TWICE for complex ones)

Design specs **in parallel** where the dependency graph allows: fan out one design task per independent spec in a single message. Respect `Blocked by` — a consumer spec's _Contract references_ may depend on its provider's, so design providers first where that coupling exists; the skeletons already landed in dependency order in step 6, so the numbers encode the order. Acceptance is already set from step 5, so design here fills `Design` and `Rework on failure` (refine acceptance only if the concrete interface exposes a gap):

- **Design directly by default** — decide the **contract references** (the `C-NN` points this spec implements or extends, plus the slice's public-surface delta) and, where structural decisions are non-trivial, the **internal architecture** (module boundaries, seam placement, state/data-flow). Trivial internals are left to emerge in `/tdd`. `/codebase-design`'s vocabulary and principles apply throughout. A design that discovers a new or changed contract lands it in `contracts.md` first — never defines one inline.
- **Escalate to `/codebase-design`'s DESIGN-IT-TWICE only when the spec earns it** — many interface decisions, cross-module coupling, real trade-offs, deep-module opportunities. Then spin up parallel designs of the interface delta (with deep-module note) + internal architecture, each a _radically different_ way, and compare on three axes — **depth** (behaviour per unit of interface), **locality** (change concentrates in one place), **seam placement** (where the interface lives). It's a heavyweight tool for genuine complexity, not a default — if `/codebase-design` isn't loaded, still apply it manually against the design bar below.

<design-bar>

Is each spec's design deep enough? Judge the design against:

- **Contract references** — the `C-NN` points it serves are explicit, and its surface delta agrees with `contracts.md` (IDs referenced, never re-defined); **deletion test**: deleting it should not make complexity vanish (else pass-through — deepen).
- **Internal architecture** — structural decisions made (module boundaries, seam, state/data-flow, deep-module opportunities), or none needed for a trivial spec; implementation detail left to `/tdd`.
- **Test seam** — fewest crossed, ideally one external seam; the contract points are the test surface.
- **Self-contained** — a fresh-context agent needs nothing beyond this spec + `contracts.md` + glossary + ADRs; describe behaviour, not implementation.
- **Consistent with siblings and ADRs** — its _Contract references_ / _Internal architecture_ / naming agree with the specs already landed (step 6 skeletons + providers designed before it, since step 7 designs in dependency order), and it contradicts no key-decision ADR; where it must depart from an ADR, flag it for the human — don't land it quietly.

</design-bar>

Either way the design must clear the **design bar** above. `/codebase-design` is this step's vocabulary and principles — when loaded, lean on its patterns: **DESIGN-IT-TWICE** for genuine complexity and **DEEPENING** for the deep-module note.

Use the project glossary vocabulary in titles and bodies. Do NOT close or modify the parent PRD/bug issue.

### 8. Adversarial review — two fresh-context sub-agents

The agent that just designed the specs can't grade its own work. Fan out **two independent fresh-context sub-agents** (`general-purpose`, spawned in one message so they run in parallel) — each gets the landed specs plus **one** input and never the design chat, and returns PASS or specific defects (the spec + the failing line). Splitting along two axes keeps each sub-agent's context focused, because the inputs differ:

- **Sub-agent A — coverage vs. the source.** Input: the landed specs + `contracts.md` + `trace.md` + the parent PRD/bug (or the grilled-design summary / vetted requirement if no parent). **Does not read code.** Checks the four coverage axes:
  - **Goal coverage** — every goal / user story in the source maps to at least one spec's `Goal` + AC projection. No goal orphaned; no spec that serves nothing in the source.
  - **Double-anchor** — re-run the step-3 cross-check against the final artifacts: every P0 AC's scenario row exists in `trace.md`, walks real `C-NN` points, and lands in exactly one spec; AC numbers equal contract numbers. Any row that fails is untestable — a defect.
  - **Test coverage** — every P0 scenario has a spec accountable for it (the `Spec` column is filled); the parent's testing intent is reflected in the projections and seam choices.
  - **Scope fidelity** — nothing out-of-scope crept in; nothing in-scope was dropped.

- **Sub-agent B — feasibility + cumulative consistency vs. the code.** Input: the landed specs + `contracts.md` + the **current codebase** (the `Context` areas each spec points at, plus `/codemap` if available) — never the source. Walk the specs **in `Blocked-by` order**, treat each one's _Contract references_ / _Internal architecture_ as a transformation of the codebase, and **accumulate the running change** to check:
  - **Sequential coherence** — each consumer's assumed interface is actually produced by an earlier provider spec; no spec assumes a surface no predecessor sets up.
  - **Cumulative consistency** — specs touching the same file/surface accumulate to one _Contract delta_ / _Internal architecture_ / naming, not conflicting ones; contract points claimed by several specs accumulate one delta in `contracts.md`. (This is the step-7 design-bar "consistent with siblings" check seen globally and in order — the design bar only sees what landed before each spec; B sees every design together.)
  - **Feasibility** — applied cumulatively, the specs describe a codebase that can actually be built: real seams exist or are created by an earlier spec; nothing requires a change its predecessors don't make. Flag any spec unbuildable as written.

> **Trivial case** — single spec, or specs with no shared surface and no cross-spec coupling: drop Sub-agent B and run its check inline; keep A (coverage always matters).

If either sub-agent returns defects, loop back — add/merge/split specs (step 5), fix a contract (step 3), or refine a design (step 7) — and re-run the affected sub-agent. When both return PASS, all specs are `ready-for-human` (awaiting Gate A); point the user at the spec files, `contracts.md`, and `trace.md` in the issue tracker as the ground truth (don't re-paste them in chat).
