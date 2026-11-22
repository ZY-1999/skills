---
name: sdd-flow
description: "Drive a feature from an approved PRD to shipped — the back half of the Spec-Driven Development pipeline: align → spec → build → review → doc maintenance. Translates the PRD's ACs into contracts + a scenario trace matrix via /to-spec, builds each spec scenario-first via /tdd, reviews, and maintains docs."
---

# SDD Flow (PRD → ship)

The back half of the Spec-Driven Development pipeline: everything **after Gate 0** — the PRD is approved and on disk; this skill turns it into shipped code. Never run against chat-only content — if the approved PRD is not on disk yet, guide users to use `/route`.

Requires `/setup-skills` to have run in this repo (issue tracker, triage labels, domain docs). If `docs/agents/issue-tracker.md` is missing, stop and run `/setup-skills` first.

The process is as follows:

```
prd(approved) → contracts+trace+specs → [Gate A] → tdd(per spec) → review+trace-gate → summarize
                      ↑ redo
```

## Entry — flip the PRD to ready-for-agent

At entry, **flip the PRD's status to `ready-for-agent`** — this is the only skill that sets `ready-for-agent`; the flip marks the PRD as human-approved and now entering agent execution.

## Commit the work

Commit the current work product now — the published PRD, plus any `CONTEXT.md` / ADR edits the session produced. For what to stage, message conventions, and whether to commit, follow the [Git Contract](docs/agents/git-contract.md).

## Stages

### 1. Specs — `/to-spec`

Decompose the approved PRD into planning-complete specs (each one = one `/tdd` session) via `/to-spec`. `/to-spec` translates the PRD's acceptance criteria into `contracts.md` (double-anchor cross-check), seeds the scenario rows of `trace.md`, self-vets the decomposition through best-of-N + judge, lands every skeleton, then designs each one (directly by default, DESIGN-IT-TWICE for the complex ones) — so when it returns, the feature folder carries `contracts.md`, `trace.md`, and fully designed specs, `ready-for-human` (awaiting Gate A).

### Gate A — human reviews the alignment card

The machine has already vetted the decomposition (best-of-N judge + two-axis adversarial review in `/to-spec`). The human reviews a **Gate A card** — one screen, not N spec files:

- **The cut** — every spec as one line: number + title + one-line goal + `Blocked by`
- **P0 alignment** — the P0 rows of `trace.md`: AC → scenario → contract points → spec (this is where wrong numbers and orphaned ACs show)
- **Machine verdicts** — the adversarial review results (PASS / residual defects)
- **Suggested spot-check** — the one highest-risk spec to actually read, with the reason (most depended-on / introduces a new seam / most uncertainty)

Have the human **spot-check the suggested spec** (or one they pick) in the tracker files — full reads of the rest are optional, the machine reviews carry them. This is also where **test-seam choices** get human judgment (which seam each spec crosses, whether new seams are justified). Ask: **"Specs look right → start building? Or redo the breakdown?"**

- **Redo** → back to Stage 1 with the user's feedback.
- **Approve** → flip every spec `ready-for-human` → `ready-for-agent`. Commit the current work product now — the landed spec skeletons, their designs, `contracts.md`, `trace.md`. For what to stage, message conventions, and whether to commit, follow the [Git Contract](docs/agents/git-contract.md), then Stage 2.

### 2. Build — `/tdd` per spec, in dependency order

Orchestrate from the main context; **run each `/tdd` in a fresh-context sub-agent** (`general-purpose`) so the build does not accumulate into this session. One sub-agent per spec; wait for it to finish before starting the next unblocked one.

For each approved spec whose blockers are done:

1. Pick the next unblocked spec (read the tracker's status/labels if unclear).
2. Spawn a sub-agent whose brief is: follow `/tdd` on this spec to completion (materialize scenarios from `trace.md` red → tracer-bullet green → incremental loop → refactor → codemap drift-check if `/codemap` is loaded → close: status flip to `implemented` + evidence comment + trace backfill + commit, per the Git Contract). Hand it only what it needs to start cold:
   - the **spec path**, the feature's **`contracts.md`** and **`trace.md`** paths (its work list is the trace rows naming this spec)
   - pointers from the spec's **Context** (modules, ADR numbers, glossary terms) — paths/IDs, not pasted bodies
   - `docs/agents/git-contract.md` (and `docs/agents/issue-tracker.md` if status flips go through the tracker)
   - never this orchestration chat, prior specs' diffs, or unrelated PRD grilling
3. Take the sub-agent's result (PASS / closed, or **Rework on failure**). If rework, surface it to the user before continuing — don't silently paper over a spec whose design the build proved wrong.

Continue until every approved spec is built.

### 3. Review + trace gate — `/review`, then the matrix

Run `/review` against the merge-base just before Stage 2 started (the Gate A spec commit), handing it the specs, `contracts.md`, and `trace.md` from the tracker — it runs the two-axis (Standards + Spec) review in fresh-context sub-agents, so the review isn't biased by the code you just wrote in Stage 2. Never inline self-review (e.g. `/code-review` in the main context); if `/review` isn't available, spawn one fresh-context `general-purpose` sub-agent yourself with the same two-axis brief.

Fix every hard finding, then re-run until clean, or the only remaining findings are explicit judgement calls the human accepts.

Then run the **trace gate** (hard, not advisory):

1. Execute the feature's P0 scenario suite (the materialized tests behind `trace.md`'s S-rows) — all green.
2. Every P0 row in `trace.md` is `done` (non-empty Test and Commit). A `pending` P0 row means a scenario was skipped — send the owning spec back to `/tdd`, don't waive it.

If the gate refuses to pass because a contract itself was wrong, that's a `/spec-sync` conversation with the human — surface it, don't code around it.

### 4. Summarize & maintain docs

Before declaring done:

- [ ] Sweep `CONTEXT.md` for terms introduced during the build; add any still missing.
- [ ] Offer ADRs for any hard-to-reverse, surprising, real-trade-off decisions made along the way (the `/grill-with-docs` bar — sparingly).
- [ ] Flip every spec `implemented` → `closed`, and the parent PRD/bug to `closed` — the human accepted the outcome at this stage's gates; no further per-spec confirmation is owed.
- [ ] Write a one-paragraph summary of what shipped, with pointers to the PRD / contracts / specs / trace — not a re-narration. Mention `/spec-sync` as the way to ripple any later requirement change.

## When NOT to use this skill

- You have a raw idea, not a PRD yet → `/idea-to-prd` first (grill → PRD → Gate 0; routing here afterwards is a separate user decision — see `/route`).
- One-off fix or trivial change → just `/tdd` or `/diagnose-bug` directly.
- You already have specs → start at Stage 2 (build).
- The repo hasn't run `/setup-skills` → run that first.
