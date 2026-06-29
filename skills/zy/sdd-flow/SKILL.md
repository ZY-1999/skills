---
name: sdd-flow
description: Drive a feature from an approved PRD to shipped — the back half of the Spec-Driven Development pipeline: spec → build → review → doc maintenance. Decomposes the PRD into specs via /to-spec, builds each via /tdd, reviews, and maintains docs.
---

# SDD Flow (PRD → ship)

The back half of the Spec-Driven Development pipeline: everything **after Gate 0** — the PRD is approved and on disk; this skill turns it into shipped code. Never run against chat-only content — if the approved PRD is not on disk yet, guide users to use `/route`.

Requires `/setup-skills` to have run in this repo (issue tracker, triage labels, domain docs). If `docs/agents/issue-tracker.md` is missing, stop and run `/setup-skills` first.

The process is as follows:

```
prd(approved) → spec → [Gate A] → tdd(per spec) → review → summarize
                      ↑ redo
```

## Entry — flip the PRD to ready-for-agent

At entry, **flip the PRD's status to `ready-for-agent`** — this is the only skill that sets `ready-for-agent`; the flip marks the PRD as human-approved and now entering agent execution.

## Commit the work

Commit the current work product now — the published PRD, plus any `CONTEXT.md` / ADR edits the session produced. For what to stage, message conventions, and whether to commit, follow the [Git Contract](docs/agents/git-contract.md).

## Stages

### 1. Specs — `/to-spec`

Decompose the approved PRD into planning-complete specs (each one = one `/tdd` session) via `/to-spec`. `/to-spec` self-vets the decomposition through best-of-N + judge, lands every skeleton, then designs each one (directly by default, DESIGN-IT-TWICE for the complex ones) — so when it returns, the specs are on disk in the issue tracker, fully designed, `ready-for-human` (awaiting Gate A).

### Gate A — human reviews the spec breakdown

The specs are already on disk (Stage 1 published them in dependency order to the issue tracker). Point the user at those files and have them review them directly — don't re-paste the breakdown in chat. Ask: **"Specs look right → start building? Or redo the breakdown?"**

- **Redo** → back to Stage 1 with the user's feedback.
- **Approve** → flip every spec `ready-for-human` → `ready-for-agent`.Commit the current work product now — the landed spec skeletons and their designs. For what to stage, message conventions, and whether to commit, follow the [Git Contract](docs/agents/git-contract.md), then Stage 2.

### 2. Build — `/tdd` per spec, in dependency order

For each approved spec whose blockers are done:

1. Pick the next unblocked spec (read the tracker's status/labels if unclear).
2. Run `/tdd` — red-green-refactor, one vertical slice per tracer bullet. The spec already carries the interface and prioritized behaviors, so `/tdd` starts straight at red-green (no separate planning step).
3. Next spec.

Continue until every approved spec is built.

### 3. Review — `/review` + fix

Run the two-axis SDD review (Standards + Spec) against the merge-base of the branch — the point just before Stage 2 started. Use `/review` if that skill is loaded; otherwise fall back to `/code-review`, or flag for manual review if neither is available. Fix every hard finding, then re-run until clean or the only remaining findings are explicit judgement calls the human accepts.

### 4. Summarize & maintain docs

Before declaring done:

- [ ] Sweep `CONTEXT.md` for terms introduced during the build; add any still missing.
- [ ] Offer ADRs for any hard-to-reverse, surprising, real-trade-off decisions made along the way (the `/grill-with-docs` bar — sparingly).
- [ ] If code terrain shifted materially, run `/codemap` **drift-check** against the relevant `docs/codemap/` map — if it reports drift, update the affected map (skip if `/codemap` isn't loaded).
- [ ] Write a one-paragraph summary of what shipped, with pointers to the PRD / specs / PR — not a re-narration.

## When NOT to use this skill

- You have a raw idea, not a PRD yet → `/idea-to-prd` first (it runs grill → PRD → Gate 0, then hands off here).
- One-off fix or trivial change → just `/tdd` or `/diagnose-bug` directly.
- You already have specs → start at Stage 2 (build).
- The repo hasn't run `/setup-skills` → run that first.
