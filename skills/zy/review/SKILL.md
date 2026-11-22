---
name: review
description: Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes — Standards (does the code follow this repo's documented coding standards?) and Spec (does the code match what the originating issue/PRD asked for?). Runs both reviews in parallel fresh-context sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, asks to "review since X", or when a git commit was blocked by the zy-skills review gate.
---

# Review — two axes, since a fixed point

Two-axis review of the diff between `HEAD` and a fixed point:

- **Standards** — does the code conform to this repo's documented coding standards?
- **Spec** — does the code faithfully implement the originating issue / PRD / spec?

Both axes run as **parallel fresh-context sub-agents** so they don't pollute each other's context (and neither sees whatever chat produced the diff), then this skill aggregates their findings.

Requires `/setup-skills` to have run in this repo (issue tracker, triage labels). If `docs/agents/issue-tracker.md` is missing, stop and run `/setup-skills` first.

## Process

### 1. Pin the fixed point

Resolve the fixed point — a commit SHA, branch name, tag, `main`, `HEAD~5`, etc. Use the one the caller supplied (a calling skill like `/sdd-flow` already knows its merge-base — the commit just before its build stage began); if there isn't one, ask the user.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base). Also note the list of commits via `git log <fixed-point>..HEAD --oneline`.

Exception — when the fixed point is `HEAD` itself (reviewing the uncommitted working state, which is what the commit gate sends here), the diff command is `git diff HEAD` and there is no commit list. Stage untracked files first (`git add`) so they appear in that diff.

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here — not inside two parallel sub-agents.

### 2. Identify the spec source

Look for the originating spec, in this order:

1. A path the caller supplied.
2. Issue references in the commit messages (`#123`, `Closes #45`, GitLab `!67`, etc.) — fetch via the workflow in `docs/agents/issue-tracker.md`.
3. A PRD/spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
4. If nothing is found, ask the user where the spec is. If they say there isn't one, the **Spec** sub-agent will skip and report "no spec available".

Alongside the spec, pick up the feature folder's **`contracts.md`** and **`trace.md`** when they exist — they are the Spec axis's ground truth for interfaces and coverage.

### 3. Identify the standards sources

Anything in the repo that documents how code should be written, such as `CODING_STANDARDS.md` or `CONTRIBUTING.md`.

### 4. Spawn both sub-agents in parallel

Send a single message with two `Agent` tool calls. Use the `general-purpose` subagent for both.

**Standards sub-agent prompt** — include:

- The full diff command and commit list.
- The list of standards-source files you found in step 3.
- The brief: "Report — per file/hunk where relevant — every place the diff violates a documented standard. Cite the standard (file + the rule). Distinguish hard violations from judgement calls. Skip anything tooling enforces. Under 400 words."

**Spec sub-agent prompt** — include:

- The diff command and commit list.
- The path or fetched contents of the spec, plus `contracts.md` and `trace.md` when they exist.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong — checking interfaces against the contract points (`C-NN`) they cite, error codes and numbers included; (d) where `trace.md` exists, P0 rows whose Test/Commit columns the diff should have filled but didn't. Quote the spec line for each finding. Under 400 words."

If the spec is missing, skip the Spec sub-agent and note this in the final report.

### 5. Aggregate

Present the two reports under `## Standards` and `## Spec` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings — the two axes are deliberately separate (see _Why two axes_).

End with a one-line summary: total findings per axis, and the worst issue _within each axis_ (if any). Don't pick a single winner across axes — that's the reranking the separation exists to prevent.

### 6. Commit-gate verdict

The zy-skills plugin ships a PreToolUse hook that blocks agent-made `git commit`s in repos that ran `/setup-skills`, until a review approves the diff. When — and only when — this run covered the **uncommitted working state** (fixed point `HEAD`, diff `git diff HEAD`), close with a gate verdict:

- **No hard violations on either axis** (judgement calls and tooling-enforced items don't count) → record approval for this exact diff, so the pending commit goes through:

  ```bash
  git diff HEAD | git hash-object --stdin > "$(git rev-parse --git-dir)/zy-skills-review-approved"
  ```

  The marker holds the diff's hash, is consumed by the next gated commit, and stops matching as soon as anything changes — then review must re-run.

- **Any hard violation** → do **not** write the marker. Name the blocking findings in the summary so the author knows what to fix before committing.

Runs that reviewed a committed range (any fixed point other than working-tree-vs-`HEAD`) skip this step entirely.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.
