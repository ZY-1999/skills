---
name: route
description: Route any question to the skill or flow that fits it. A router over this fork's resolved skills.
disable-model-invocation: true
---

# Route

You don't remember every skill. Route the question to the one that fits.

Scan the **intent** below; run the skill on the right. One question → one skill (or one short chain).

## Build something

- **Start from an architecture scan** → `/improve-architecture`
- **Ship end-to-end, hands-off** → `/sdd-flow`
- **Drive it myself, I have a codebase** → `/grill-with-docs` → `/to-prd` → `/to-spec` → `/tdd`
- **Drive it myself, no codebase** → `/grill-me` → `/to-prd` → `/to-spec` → `/tdd`
- **I already have a PRD** → `/to-spec`
- **I already have a spec** → `/tdd`

## A bug

- **Find the root cause of one bug** → `/diagnosing-bugs`
- **The fix is clear, just implement it** → `/tdd`
- **Bugs / incoming requests are piling up** → `/triage`

## Design & modeling

- **Refine domain language / build the glossary (`CONTEXT.md`)** → `/domain-modeling`
- **Module boundaries, testability, interface shape** → `/codebase-design`

## Code & terrain

- **Need an agent-facing code map, or the map may be stale** → `/codemap`

## Session & context

- **Thread is full — fresh session, keep this conversation** → `/handoff`
- **Phase break — summarize in place** → `/compact` (built-in)
- **Throwaway prototype to answer a runnable question** → `/prototype`

## Learn

- **Learn a concept over multiple sessions** → `/teach`

## Review, setup & meta

- **Review current changes (Standards + Spec)** → `/review` (or `/code-review`)
- **First-time repo setup (tracker / labels / domain docs / codemap)** → `/setup-skills`
- **Write or edit a skill (in this repo)** → `/writing-great-skills`
- **I don't know which skill fits** → you're in the right place — that's what `/route` is for.
