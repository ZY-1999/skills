---
name: to-prd
description: Turn the current conversation into a parent issue — a feature PRD, a bug, or an architecture-deepening PRD — and publish it to the project issue tracker. No interview, just synthesis of what you already discussed. Picks the template by input nature; one fresh-context sub-agent adversarially reviews the draft — veracity first (are the facts real?), then feasibility — before it ships.
---

This skill takes the current conversation context and codebase understanding and produces a **parent issue** — a feature PRD, a bug, or an architecture-deepening PRD. Do NOT interview the user — just synthesize what you already know.

The issue tracker and triage label vocabulary should already be configured — run `/setup-skills` if not.

## Process

### 1. Explore the codebase

Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout, and respect any ADRs in the area you're touching.

### 2. Draft the PRD

Pick the template that matches what you're publishing and fill it from the conversation (no interviewing — synthesize what you already discussed). This is the **draft** — don't publish yet; step 4 publishes once the adversarial review (step 3) passes.

A feature PRD is **requirements-only**: what and why in the user's language, with numbered `AC-<story>-<NN>` acceptance criteria priority-marked P0/P1. Technical translation (endpoints, schemas, error codes) is `/to-spec`'s contract layer — keep it out of the PRD.

Three templates, picked by the nature of the input:

- **Feature** (default) → `Type: prd` → [prd-template.md](references/prd-template.md)
- **Bug** (something broken — wrong behavior, crash, wrong output) → `Type: bug` → [bug-template.md](references/bug-template.md)
- **Architecture / code-structure deepening** (deepening shallow modules, consolidating seams — typically fed by `/improve-architecture`'s report, or a design discussion using `/codebase-design` vocabulary) → `Type: prd` → [architecture-template.md](references/architecture-template.md)

When an orchestrator invokes this skill with an explicit type (`/improve-architecture` declares an architecture source), honor it. Otherwise infer from the conversation.

### 3. Adversarial review — one fresh-context sub-agent

The agent that just synthesised the PRD can't grade its own work — and a PRD is exactly where over-confident "the code currently..." assertions hide. Before publishing, run **one fresh-context sub-agent** (`general-purpose`); give it the PRD draft and repo access, plus the ADRs, glossary, and any CodeMap under `docs/codemap/`; never the synthesis chat — it must verify the facts against the actual code on its own. It returns PASS or specific defects (the line + what's wrong).

The review runs in two phases, **veracity first** — because feasibility judged against invented facts is worthless:

1. **Veracity — are the PRD's facts real?** Walk every assertion the PRD presents as established fact and verify it against the actual code (the anti-hallucination check):
   - **Codebase claims** ("module X currently does Y", "seam Z exists", "file F is responsible for D", "today the behavior is B") — flag any assumed, invented, or stale.
   - **ADR / glossary citations** — the referenced decision/term exists and says what the PRD claims.
   - **AC quality** — every user story carries numbered, priority-marked acceptance criteria; each P0 criterion is observable behavior with explicit numbers, not a solution sketch.

2. **Feasibility — is the plan buildable on those facts?** Only once the facts hold, judge the proposal against the (now-verified) codebase:
   - **Direction** — doesn't depend on a capability nothing provides; no step assumes infrastructure that doesn't exist.
   - **(Feature template) Layer purity** — no technical contracts (endpoints, schemas, error codes, module boundaries) leaked into this requirements document; the architecture template legitimately carries module/seam-level direction.
   - **ADR alignment** — no contradiction with a key-decision ADR; where the PRD must depart from one, it's flagged, not buried.
   - **(Architecture template)** the deepening direction is coherent against the current module structure.

If the sub-agent returns defects, loop back — re-explore the code and fix the draft (correct a claim, soften an over-confident assertion into a flagged assumption). Claim/direction defects stay in step 2. Re-run the sub-agent. If defects persist past **3 rounds**, stop and surface them to the user with the draft, un-published.

### 4. Publish

With the review passing, publish the PRD to the project issue tracker and apply the `ready-for-human` triage label (complete PRD, awaiting Gate 0 review) — no need for additional triage.
