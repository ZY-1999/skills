---
name: to-spec
description: Decompose a PRD, a bug, or the current (already-grilled) conversation into specs — atomic, planning-complete units an agent implements. One spec = one /tdd session. Both the breakdown and any complex spec design are adversarially best-of-N'd with a fresh-context judge; spec skeletons land on disk before per-spec design.
---

# To Spec

A **spec** is the atomic unit of agent coding: the minimal thing an agent implements in one session. It is **planning-complete** — the interface, the prioritized tests, and the deep-module opportunities are decided here, so implementation starts straight at red-green. This skill turns a **PRD**, a **bug**, or a grilled conversation into specs; `prd`/`bug` are the parents, `spec` is the leaf.

Two decisions dominate the outcome, and this skill treats both adversarially rather than trusting the first draft: **how to cut the work into specs** (the decomposition), and **how to design each complex spec**. Both run as best-of-N with a fresh-context judge.

## Inputs

- **A PRD or bug issue** (pass its number, URL, or path) → fetch it and decompose. Every spec you produce references it as `Parent`.
- **A grilled conversation** (no PRD yet) → synthesise the agreed design, then decompose. Do **not** re-interview — the grilling already happened (typically via `/grill-with-docs`).

> Precondition: the issue tracker layout should already be configured — run `/setup-skills` if not.

## Spec quality bar

Every spec is a **task unit** and must clear the bar below. Each spec must have:

- **One-sentence goal** — what this round solves.
- **Visible In/Out boundaries** — know what not to touch.
- **Locatable context** — relevant code, requirements, constraints, past decisions.
- **Prioritized, verifiable acceptance** — list behaviors to test (not implementation steps), critical paths first; you can't test everything. Each check says what it proves; prefer automated over manual.
- **Local failure recovery** — failure doesn't topple the whole.
- **Room for the agent to choose its path** — describe behaviour, not line-by-line implementation.

If a candidate trips a 反向指标 — goal still moving, not independently verifiable, scope bleed, no rework path, no approach/risk choice for the user, or acceptance holes — **split or redefine it before publishing**.

This bar is the judge's checklist both for ranking **decomposition candidates** (does each spec in the cut clear it?) and for ranking **per-spec design candidates**.

## Process

### 1. Gather context

Work from the conversation. If a PRD/bug reference was passed, fetch it and read the full body and comments; note its issue number for `Parent`.

### 2. Reduce chaos — read the terrain first

Before splitting:

1. **Converge on the final goal** — what this ultimately achieves.
2. **List the sources of chaos** — unknown code, unknown requirements, cross-module coupling, risk, external dependencies.
3. **Map the terrain** — project glossary (`CONTEXT.md`), ADRs in the area you're touching, and a code map (e.g. `/codemap` when available, or explore directly). Flag — don't silently override — any decision that contradicts an ADR.

### 3. Decompose — best-of-N on the breakdown itself

The decomposition is the highest-leverage decision here — a wrong cut propagates into every spec that follows. Generate it adversarially; don't ship the first cut.

If there's no PRD/bug parent (grilled-conversation input), synthesise the agreed design first, then decompose that.

1. **Draft 2–3 decomposition candidates in parallel** — spawn that many `general-purpose` sub-agents in one message, each given the same brief (the converged goal, the chaos map, the terrain, and the splitting methods below) but told to produce an *independent* breakdown: different spec counts, different cut axes, different calls on whether to prefactor first. Diversity is the point — don't let them converge. Each candidate is a **list of specs** (title, one-line goal, parent, blocked-by, what it delivers, test-seam sketch) — not yet designed in depth.
2. **Judge** all candidates in a separate fresh-context sub-agent — never let a drafter grade its own work. Give the judge every candidate plus the **decomposition quality bar** below. It ranks them, picks the strongest, and returns concrete defects in that winner, each tied to a checklist item.
3. **Refine** the winner to address every defect, then re-judge. Repeat until PASS, or until 3 rounds — at 3 rounds, stop and surface the remaining defects to the human rather than looping forever.

> For a trivial decomposition (a single obvious spec, or one already dictated by the parent) you may drop to a single candidate and skip straight to step 2's critique.

**Decomposition quality bar (the judge's checklist):**

- Each spec is one implementation session's worth — too big to finish in a session, split; too small to verify on its own, merge.
- Cuts are **tracer bullets** — thin vertical slices through ALL layers (schema → API → UI → tests), not horizontal slices of one layer.
- Dependency order is acyclic; every `Blocked by` is real and minimal.
- The cut reduces risk and clarifies acceptance (the splitting-methods intent), not just divides work.
- No scope bleed; no spec whose goal is still moving.
- Prefactor ("make the change easy, then make the easy change") is its own spec, ordered first, when warranted.

<splitting-methods>

Pick the cut that best reduces risk and clarifies acceptance:

- **By code path**: entry → core logic → storage/external → presentation/caller.
- **By risk**: read-only/logging → state change → write path.
- **By acceptance**: smallest verifiable behaviour first, then expand.
- **By provider-consumer**: provider before consumer, contract before implementation.

</splitting-methods>

### 4. Land the skeleton — publish first, design per-spec after

Once the decomposition is settled, **publish every spec's skeleton to the issue tracker immediately**, before designing any of them in depth. The breakdown becomes the ground truth on disk, not something stranded in chat.

For each spec, create its file under `.scratch/<feature>/specs/` in **dependency order** (blockers first, so `Blocked by` can reference real issue numbers). Fill the skeleton fields; stub the design fields:

- **Filled:** Title, `Type: spec`, `Parent`, `Blocked by`, `Goal` (one sentence), `What it delivers` (one line), `Scope` (in/out bullets).
- **Stubbed:** `Interface changes`, `What to build`, `Acceptance criteria`, `Rework on failure` — leave a `> to be designed` marker.
- `Status: needs-design` — marks the spec as landed-but-undesigned. `/tdd` consumes only `ready-for-agent` specs, so a `needs-design` spec is safely ignored until step 5 finishes it. (`needs-design` is a spec-lifecycle state owned by this skill, not one of the `/setup-skills` triage roles.)

### 5. Design each spec — best-of-N on the complex ones

Design specs one at a time, in dependency order, filling each skeleton file's design fields. Calibrate effort to complexity:

- **Simple spec** (single interface delta, few behavior trade-offs, local) → design it directly in one pass: pick the highest test seam available (fewer is better; ideal: one), decide the interface shape, list the prioritized behaviors-to-test. No need for candidates.
- **Complex spec** (many interface decisions, cross-module, real design trade-offs, deep-module opportunities) → run a per-spec **best-of-N**: draft 2–3 independent designs in parallel (each gives the interface delta, the deep-module note, the test-seam choice, and the prioritized behaviors-to-test), judge them in a fresh-context sub-agent against the **spec quality bar**, refine the winner until PASS or 3 rounds.

Either way, each design must clear the spec quality bar — interface decided, prioritized & verifiable acceptance, local failure recovery, room for the agent to choose its path. Run `/codebase-design` when available for the vocabulary and testability checks on the interface.

Each spec is **self-contained** — a fresh-context agent implementing it needs nothing beyond the spec, the glossary, and relevant ADRs.

When a design is done, write it into the spec's file and flip `Status: needs-design` → `ready-for-agent`.

<issue-template>

```markdown
# <Spec title>

Type: spec
Status: needs-design   # → ready-for-agent once step 5 design is filled in
Parent: #<prd-or-bug-issue-number> # omit if the source was a grilled conversation
Blocked by: #<n> # or "None — can start immediately"

## Goal

One sentence: what this spec solves.

## Context

Pointers to the existing terrain this spec sits in — relevant modules/code areas, ADR numbers, glossary terms, constraints, past decisions. Point, don't prescribe: no new file paths, no code. A fresh-context agent reads these before coding.

## Scope

- **In**: what this spec touches.
- **Out**: what it deliberately does not — don't "fix" these opportunistically.

## Interface changes

What the public interface looks like *after* this spec — the delta (new/changed signatures, endpoints, schema shape). Deep-module note: favour small interfaces hiding complex implementation.

## What to build

Concise end-to-end behaviour, not layer-by-layer — the internal design decisions this spec needs (modules, data flow) beyond the interface above. Describe behaviour, not implementation — leave the agent room to choose its path.

No file paths or code snippets (they go stale) — unless a prototype produced a decision-encoding snippet (state machine, reducer, schema, type shape); then inline only the decision-rich parts and note it came from a prototype.

## Acceptance criteria

The behaviors to test, critical paths first — you can't test everything. List behaviors, not implementation steps. Each check notes what it proves; prefer automated (tests, logs, run output, screenshots) over manual.

- [ ] Behavior 1 (critical path) — <what it proves>
- [ ] Behavior 2 — <what it proves>

## Rework on failure

One line: the revert/retry point, or "failure is isolated; redo this spec only".
```

> Step 4 fills the header + `Goal` + `Scope` and stubs the rest with `> to be designed`; step 5 fills `Interface changes`, `What to build`, `Acceptance criteria`, `Rework on failure`, then flips `Status` to `ready-for-agent`.

</issue-template>

Use the project glossary vocabulary in titles and bodies. Do NOT close or modify the parent PRD/bug issue.

### 6. Confirm with the user

All specs are now on disk, fully designed, `ready-for-agent`. Point the user at the `.scratch/<feature>/specs/` files and have them review the files directly — don't re-paste the breakdown in chat (the files are the ground truth). Ask: **"Specs look right? Anything to merge, split, or redesign?"**

Iterate: in-file edits count as approved feedback; redo the affected step (decomposition, or the per-spec design) on request. When this skill runs inside `/sdd-flow`, this confirm step *is* the flow's Gate A — don't double-ask.
