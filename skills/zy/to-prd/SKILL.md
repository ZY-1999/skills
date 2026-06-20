---
name: to-prd
description: Turn the current conversation into a parent issue — a feature PRD, a bug, or an architecture-deepening PRD — and publish it to the project issue tracker. No interview, just synthesis of what you already discussed. Picks the template by input nature; produces the parent that `/to-spec` decomposes into specs.
---

This skill takes the current conversation context and codebase understanding and produces a **parent issue** — a feature PRD, a bug, or an architecture-deepening PRD. Do NOT interview the user — just synthesize what you already know.

The issue tracker and triage label vocabulary should already be configured — run `/setup-skills` if not.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout, and respect any ADRs in the area you're touching.

2. Sketch out the seams at which you're going to test the change. Existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better - the ideal number is one.

Check with the user that these seams match their expectations.

3. Pick the template that matches what you're publishing, fill it from the conversation (no interviewing — synthesize what you already discussed), then publish it to the project issue tracker. Apply the `ready-for-agent` triage label - no need for additional triage.

Three templates, picked by the nature of the input:

- **Feature** (default) → `Type: prd` → [prd-template.md](references/prd-template.md)
- **Bug** (something broken — wrong behavior, crash, wrong output) → `Type: bug` → [bug-template.md](references/bug-template.md)
- **Architecture / code-structure deepening** (deepening shallow modules, consolidating seams — typically fed by `/improve-architecture`'s report, or a design discussion using `/codebase-design` vocabulary) → `Type: prd` → [architecture-template.md](references/architecture-template.md)

Architecture still publishes as `Type: prd` (a parent `/to-spec` decomposes into specs, same as a feature) — the difference from a feature PRD is framing and vocabulary, not issue type.

When an orchestrator invokes this skill with an explicit type (`/improve-architecture` declares an architecture source), honor it. Otherwise infer from the conversation.

---

Adapted from upstream `to-prd`: made **model-invoked** (no `disable-model-invocation`) so the SDD flow can orchestrate it, and the setup pointer resolves to `/setup-skills`. Extended beyond upstream to publish three parent types — feature `prd`, `bug`, and architecture-deepening `prd` — each from its own template in `references/`. The parent this produces is what `/to-spec` decomposes into `spec`s (each spec carries `Parent: #<this parent>`).
