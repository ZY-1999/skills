---
name: idea-to-prd
description: SDD's front half, and the one-command end-to-end entry: grill a raw idea/requirement → synthesise the PRD → human Gate 0 → hand off to /sdd-flow. Also completes an existing incomplete PRD draft by grilling only its gaps. Owns grilling + PRD + Gate 0 only; no git.
---

# Idea → PRD

The front half of the Spec-Driven Development pipeline: turn a raw idea or requirement into an **approved PRD on disk**, then hand off to `/sdd-flow` for everything after. Owns only grilling, PRD synthesis, and the human Gate 0 — **no git operations**.

Requires `/setup-skills` to have run in this repo (issue tracker, triage labels, domain docs). If `docs/agents/issue-tracker.md` is missing, stop and run `/setup-skills` first.

```
idea → grill → prd → [Gate 0] → /sdd-flow (spec → build → review → maintain)
                 ↑ redo
```

**Invocation contract.** Every stage uses model-invoked skills, so this skill chains automatically: grilling = `/grilling` + `/domain-modeling`, then `/to-prd`. On Gate 0 approval it invokes `/sdd-flow` (also model-invoked) to run the rest — so `/idea-to-prd` is the one-command end-to-end entry: idea all the way to shipped.

## Human gate — review the file, not the chat

Gate 0 fires **after** Stage 2 has already published the PRD to the issue tracker — the PRD is a real file on disk before the gate runs. So:

- **Don't re-paste or summarize the PRD in chat.** Chat coordinates; the file is the ground truth.
- **Point the user at the PRD file** — give the exact path; the user reviews the landed file in their editor.
- **In-file edits count as approved feedback** — fold them in.
- Then ask the gate question and wait.

Never run the gate against chat-only content — if the PRD isn't on disk yet, publish it first.

## Stages

### Entry mode — raw idea, or completing a draft?

Detect which of two inputs you have:

1. **Raw idea / requirement** (default) — the conversation carries an idea, no PRD on disk yet. Grill the full design (Stage 1) → synthesise a fresh PRD (Stage 2).
2. **An incomplete PRD draft on disk** — typically a `needs-info` PRD left by `/improve-architecture` (empty Implementation / Testing Decisions, or thin Deepening Goals). Don't grill from scratch or re-synthesise — read the draft, grill **only** its gaps (Stage 1 alt), then update the draft in place (Stage 2 alt).

If the user points at a PRD file whose status is `needs-info` or whose required sections are incomplete, that's mode 2. If in doubt, ask. Both modes converge on the same Gate 0.

### 1. Grill — `/grilling` + `/domain-modeling`

No branch yet — the grill writes `CONTEXT.md` / ADRs into the working tree uncommitted. The branch lands at `/sdd-flow`'s entry once the PRD is approved.

Run a `/grilling` session, using the `/domain-modeling` skill — interview the user one question at a time until the plan is fully resolved, sharpening terminology and updating `CONTEXT.md` and ADRs inline as you go.

If the user arrives already-grilled (the conversation carries a resolved design), skip ahead to Stage 2. Don't skip otherwise — Stage 2 consumes this shared understanding.

**Mode 2 alt — grill the gaps, not the whole design.** Skip the full interview. Read the draft, list which required sections are empty or thin (Implementation Decisions, Testing Decisions, vague Deepening Goals, …), and grill the user one question at a time **only** on those gaps — updating the draft inline as each closes. The settled parts of the design stay settled; you're completing a PRD, not re-exploring it.

### 2. PRD — `/to-prd`

Synthesize the PRD from the grilled context (no interview — `/to-prd` forbids it).

**Mode 2 alt — update in place, don't re-synthesise.** The PRD already exists on disk — don't re-run `/to-prd`'s synthesis (steps 1-3) for a fresh draft; it would overwrite. Instead, fold the grill's output straight into the existing PRD file: **fill the empty sections** and **cut what the grill overturned** (claims, directions, or over-confident assertions the gap-fill just falsified). Then run `/to-prd`'s adversarial review (step 4 — fresh-context sub-agent, veracity first) on the updated draft; on PASS, flip its status `needs-info` → `ready-for-human` (now complete, awaiting Gate 0).

### Gate 0 — human reviews the PRD

The PRD is already on disk (Stage 2 published it). Point the user at that file and have them review it directly — don't re-paste it in chat. Ask exactly: **"PRD looks good → break into specs? Or redo the PRD?"**

- **Redo** → back to Stage 2, feeding the user's feedback into the next draft.
- **Approve** → invoke `/sdd-flow` to continue.

Do not hand off until the human approves.

## When NOT to use this skill

- You already have an approved PRD on disk → `/sdd-flow` directly (it owns everything after Gate 0).
- The PRD comes from an architecture scan → start with `/improve-architecture` (it scans, publishes every candidate as a `needs-info` draft — Top included — and stops). To pursue one of those drafts, bring it back here — `/idea-to-prd` completes it (mode 2) → Gate 0 → `/sdd-flow`.
- One-off fix or trivial change → just `/tdd` or `/diagnose-bug` directly.
- The repo hasn't run `/setup-skills` → run that first.
