---
name: spec-check
description: Audit a feature's SDD artifacts (or the whole .scratch tracker) along four dimensions — completeness, consistency, traceability, layer purity — and report P0/P1 findings plus a one-screen status board. Use when asked for spec quality or feature status, before Stage 3 sign-off in /sdd-flow, or to see what's in flight across the tracker.
---

# Spec Check — four-dimension audit + status board

The machine-side backstop of the SDD pipeline: it verifies the artifacts' internal and cross-artifact integrity so humans and gates can trust what they're looking at. Read-only — it reports, never edits.

## Inputs

- **A feature folder** (`.scratch/<feature>/`) — audit that feature.
- **Nothing** — audit every feature folder in the tracker that carries `contracts.md` (decomposed features only; bare PRDs just get a status line).

## Process

### 1. Gather

Read the feature folder: PRD (parent), `contracts.md`, `trace.md`, `specs/*`. Note each file's `Status:` label.

### 2. Audit — one fresh-context sub-agent

The auditor must not be whoever produced the artifacts. Spawn **one fresh-context `general-purpose` sub-agent**; hand it the feature folder path (it reads the files itself) and this brief — four dimensions, findings graded **P0** (a gate would block / a human would be misled) or **P1** (should fix, won't block):

1. **Completeness**
   - Every P0 AC in the PRD has: ≥1 scenario row in `trace.md`, ≥1 assertable contract point, and a spec claiming it (`Spec` column filled).
   - No spec left `needs-design`; `Parent` links resolve; `Blocked by` references exist.
2. **Consistency**
   - Numbers agree across anchors: AC quantity ↔ contract point quantity (limits, defaults, timeouts).
   - Specs reference `C-NN` by ID and their deltas agree with `contracts.md` — no inline re-definitions, no aliases for the same thing.
   - Sibling specs don't carry conflicting deltas on the same contract point or surface.
3. **Traceability**
   - Every `implemented` spec has an evidence comment; every `done` trace row has non-empty Test and Commit.
   - No P0 row `pending` while its spec claims `implemented` (a skipped scenario).
   - Status labels follow the one-direction lifecycle: `needs-info → needs-design → ready-for-human → ready-for-agent → implemented → closed`.
4. **Layer purity**
   - PRD free of technical contracts — no endpoints, schemas, error codes, module talk in ACs.
   - `contracts.md` free of user-value narrative.
   - Scenarios assertable as written (a scenario whose expectation can't be observed through a contract point is prose, not a test).

Return: findings grouped by dimension, each with file + line and the P0/P1 grade; then a per-feature board row.

> Trivial case —single small feature: run the audit inline instead of spawning, same brief.

### 3. Board

Render one line per feature (in chat, this is a dashboard not a document):

```
<feature>        prd:closed  specs: 3impl/0open  P0: 6/6 done  contracts: 9  findings: 0P0/2P1
<feature>        prd:ready-for-agent  specs: 1design/2agent  P0: 2/6 done  contracts: 5  findings: 1P0/3P1
```

### 4. Report

Present findings verbatim (grouped by dimension, P0 first), then the board. End with the one-line verdict: the worst P0 finding, or "no P0 findings" — and for each P0, which skill owns the fix (`/to-spec` for anchor defects, `/spec-sync` for ripples, `/tdd` for skipped scenarios).

## When NOT to use this skill

- You want the *code* reviewed → `/review` (different axis: diff vs spec).
- You want to *change* an artifact → `/spec-sync` or the owning skill; this one is read-only.
- The tracker has no decomposed features → nothing to audit beyond statuses; say so.
