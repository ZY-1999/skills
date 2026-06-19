---
name: sdd-flow
description: Drive a feature from idea to shipped using the full Spec-Driven Development pipeline — grill → prd → spec → TDD → review → doc maintenance. Specs are produced by `/to-spec`, which self-vets both the decomposition and any complex spec design via best-of-N before landing them, so specs are reviewed and on disk before the human gate. Use when the user wants to run the whole SDD flow end-to-end, says "take this idea and ship it" / "run the full flow" / "spec to ship".
---

# SDD Flow

The end-to-end Spec-Driven Development pipeline. Each stage **delegates** to an existing skill — this skill owns only the hand-off, the best-of-N auto-review-and-commit on specs, and the human gates between stages. Do not restate the sub-skills' content here; invoke them.

Requires `/setup-skills` to have run in this repo (issue tracker, triage labels, domain docs). If `docs/agents/issue-tracker.md` is missing, stop and run `/setup-skills` first.

```
idea → grill → prd → [Gate 0] → spec → [Gate A] → tdd(per spec) → review → summarize
                 ↑ redo              ↑ redo
```

**Invocation contract.** Every stage uses model-invoked skills, so this orchestrator chains the whole pipeline automatically: grilling = `/grilling` + `/domain-modeling`; then `/to-prd`, `/to-spec`, `/tdd`, `/codemap`. `/handoff` is model-invoked too — at wrap-up this skill invokes it to write the handoff file and emit the next-session starter prompt. `/triage` remains user-invoked; this skill only reads its state, never invokes it.

## How specs get vetted

Spec quality is owned by `/to-spec`, not this orchestrator. `/to-spec` runs two adversarial best-of-N loops with a fresh-context judge — one on the **decomposition** (how the PRD is cut into specs) and one on each **complex spec's design** — and it lands every spec skeleton on disk *before* designing it. So when Stage 3 returns, the specs are already self-reviewed and on disk in the issue tracker, `ready-for-agent`. This skill just invokes `/to-spec` and then runs Gate A on the landed files. See `/to-spec` for the loop mechanics.

## Human gates — review the file, not the chat

Every human gate (Gate 0, Gate A) fires **after** its stage has already published the artifact to the issue tracker — the PRD / specs are on disk as real files in the issue tracker before the gate runs. So at a gate:

- **Don't re-paste or summarize the artifact in chat.** Chat coordinates; it doesn't re-host content that already lives in a file.
- **Point the user at the file(s).** Give the exact path(s) — the PRD file for Gate 0, the spec files in dependency order for Gate A. The user reviews the actual landed file in their editor; that file is the ground truth the next stage consumes, not a chat rendering of it.
- **In-file edits count as approved feedback.** If the user edits the file while reviewing, fold those edits in (for specs, re-run the affected part of the best-of-N loop against the edited file).
- Then ask the gate question and wait for the decision.

Never run a gate against chat-only content — if an artifact isn't on disk yet, publish it first.

## Stages

### 1. Grill — `/grilling` + `/domain-modeling`

Run a `/grilling` session, using the `/domain-modeling` skill — interview the user one question at a time until the plan is fully resolved, sharpening terminology and updating `CONTEXT.md` and ADRs inline as you go. This is the model-invoked core of `/grill-with-docs` (which is just these two skills wrapped as a user-invoked entry point).

If the user arrives already-grilled (the conversation carries a resolved design), skip ahead to Stage 2. Don't skip otherwise — every later stage consumes this shared understanding.

### 2. PRD — `/to-prd`

Synthesize the PRD from the grilled context (no interview — `/to-prd` forbids it). `/to-prd` sketches test seams and confirms them with the user, then publishes the PRD to the issue tracker tagged `ready-for-agent`.

### Gate 0 — human reviews the PRD

The PRD is already on disk (Stage 2 published it to the issue tracker). Point the user at that file and have them review it directly — don't re-paste it in chat (see *Human gates* above). Ask exactly: **"PRD looks good → break into specs? Or redo the PRD?"**

- **Redo** → back to Stage 2, feeding the user's feedback into the next draft.
- **Approve** → Stage 3.

Do not start specs until the human approves.

### 3. Specs — `/to-spec`

Decompose the approved PRD into planning-complete specs (each one = one `/tdd` session) via `/to-spec`. `/to-spec` self-vets the decomposition and each complex spec's design through best-of-N, lands every skeleton, then designs each one — so when it returns, the specs are on disk in the issue tracker, fully designed, `ready-for-agent`.

### Gate A — human reviews the spec breakdown

The specs are already on disk (Stage 3 published them in dependency order to the issue tracker). Point the user at those files and have them review them directly — don't re-paste the breakdown in chat (see *Human gates* above). Ask: **"Specs look right → start building? Or redo the breakdown?"**

- **Redo** → back to Stage 3 with the user's feedback.
- **Approve** → Stage 4.

### 4. Build — `/tdd` per spec, in dependency order

For each approved spec whose blockers are done:

1. Pick the next unblocked spec (read the tracker's status/labels — set by `/triage` — if unclear).
2. Run `/tdd` — red-green-refactor, one vertical slice per tracer bullet. The spec already carries the interface and prioritized behaviors, so `/tdd` starts straight at red-green (no separate planning step).
3. Commit. Update the spec's status (`ready-for-human`, or closed per the tracker).
4. Next spec.

Continue until every approved spec is built.

### 5. Review — `/review` + fix

Run the two-axis SDD review (Standards + Spec) against the merge-base of the branch — the point just before Stage 4 started. Use `/review` if that skill is loaded; otherwise fall back to `/code-review`, or flag for manual review if neither is available. Fix every hard finding, then re-run until clean or the only remaining findings are explicit judgement calls the human accepts.

### 6. Summarize & maintain docs

Before declaring done:

- [ ] Sweep `CONTEXT.md` for terms introduced during the build; add any still missing.
- [ ] Offer ADRs for any hard-to-reverse, surprising, real-trade-off decisions made along the way (the `/grill-with-docs` bar — sparingly).
- [ ] If code terrain shifted materially, run `/codemap` **drift-check** against the relevant `docs/codemap/` map — if it reports drift, update the affected map (skip if `/codemap` isn't loaded).
- [ ] Write a one-paragraph summary of what shipped, with pointers to the PRD / specs / PR — not a re-narration.
- [ ] If work continues in another session, invoke `/handoff` (it writes the handoff file and emits the next-session starter prompt).

## When NOT to use this skill

- One-off fix or trivial change → just `/tdd` or `/diagnosing-bugs` directly.
- You already have a PRD → start at Stage 3 (specs).
- You already have specs → start at Stage 4 (build).
- The repo hasn't run `/setup-skills` → run that first.
