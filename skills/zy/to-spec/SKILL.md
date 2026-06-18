---
name: to-spec
description: Decompose a PRD, a bug, or the current (already-grilled) conversation into specs — atomic, planning-complete units an agent implements. One spec = one /tdd session.
---

# To Spec

A **spec** is the atomic unit of agent coding: the minimal thing an agent implements in one session. It is **planning-complete** — the interface, the prioritized tests, and the deep-module opportunities are decided here, so implementation starts straight at red-green. This skill turns a **PRD**, a **bug**, or a grilled conversation into specs; `prd`/`bug` are the parents, `spec` is the leaf.

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

## Process

### 1. Gather context

Work from the conversation. If a PRD/bug reference was passed, fetch it and read the full body and comments; note its issue number for `Parent`.

### 2. Reduce chaos — read the terrain first

Before splitting:

1. **Converge on the final goal** — what this ultimately achieves.
2. **List the sources of chaos** — unknown code, unknown requirements, cross-module coupling, risk, external dependencies.
3. **Map the terrain** — project glossary (`CONTEXT.md`), ADRs in the area you're touching, and a code map (e.g. `/codemap` when available, or explore directly). Flag — don't silently override — any decision that contradicts an ADR.

### 3. Draft specs

**Synthesise the design** (if no PRD/bug parent), then break the work into **tracer-bullet** specs: thin vertical cuts through ALL layers end-to-end (schema → API → UI → tests), not horizontal slices of one layer. **Size each spec to one implementation session** — too big, split it.

- **Sketch test seams** — prefer existing seams; use the highest one possible. The fewer, the better (ideal: one).
- **Note prefactor opportunities** ("make the change easy, then make the easy change") — any prefactoring is its own spec, done first.

Each spec is **planning-complete** — interface, behaviors-to-test (see the quality bar above), and deep-module opportunities are all decided now, not deferred to implementation:

- **Interface changes** — what the public interface looks like *after* this spec (the delta).
- **Deep-module opportunities** — favour small interfaces hiding complex implementation; run `/codebase-design` when available for the vocabulary and testability checks.

<splitting-methods>

Pick the cut that best reduces risk and clarifies acceptance:

- **By code path**: entry → core logic → storage/external → presentation/caller.
- **By risk**: read-only/logging → state change → write path.
- **By acceptance**: smallest verifiable behaviour first, then expand.
- **By provider-consumer**: provider before consumer, contract before implementation.

</splitting-methods>

Each spec must be **self-contained** — a fresh-context agent implementing it needs nothing beyond the spec, the glossary, and relevant ADRs.

### 4. Confirm with the user

Present the breakdown as a numbered list. Per spec, show: **Title**, **Goal** (one sentence), **Parent**, **Blocked by**, **What it delivers**, **How it's verified**, **Interface changes**, **Behaviors to test (prioritized)**.

Check with the user: granularity right? every spec clears the quality bar? for each spec, is the interface shape right and are the prioritized behaviors the ones that matter most? dependencies and order correct? merge or split any? Iterate until approved.

### 5. Publish

For each approved spec, **publish to the issue tracker** — the concrete location, file naming, and format are defined in the issue tracker doc (configured by `/setup-skills`). Publish in **dependency order** (blockers first) so each spec can reference real issue numbers in `Blocked by`.

<issue-template>

```markdown
# <Spec title>

Type: spec
Status: ready-for-agent
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

</issue-template>

Apply `Status: ready-for-agent` — each spec is AFK-ready for implementation. Use the project glossary vocabulary in titles and bodies. Do NOT close or modify the parent PRD/bug issue.
