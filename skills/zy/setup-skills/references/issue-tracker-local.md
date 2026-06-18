# Issue tracker: Local Markdown

Issues for this repo live as markdown files in `.scratch/`. In this SDD setup, an **issue is the carrier** for one of three kinds of work — `spec`, `prd`, or `bug`.

## Conventions

- One feature per directory: `.scratch/<YYYY-MM-DD>-<feature-slug>/`
- Each issue is `.scratch/<YYYY-MM-DD>-<feature-slug>/specs/<NN>-<slug>.md`, numbered from `01`
- Each issue file opens with a `Type:` line near the top :
  - `spec` — the atomic unit of agent coding; the minimal thing `/tdd` implements. A leaf.
  - `prd` — a product requirement doc; a parent that `/to-spec` decomposes into `spec`s.
  - `bug` — a bug report; a parent that `/to-spec` decomposes into `spec`s when the fix needs more than one step.
- Triage state is recorded as a `Status:` line near the top (see `triage-labels.md` for the role strings)
- Comments and conversation history append to the bottom of the file under a `## Comments` heading

Example minimal issue file:

```markdown
# Fix login redirect loop

Type: bug
Status: needs-triage

<the bug report / spec / PRD body>

## Comments

- 2026-06-18 — reproduced on staging with…
```

## When a skill says "publish to the issue tracker"

Create a new file under `.scratch/<YYYY-MM-DD>-<feature-slug>/specs/` (creating the directory if needed), with the correct `Type:` line.

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path. The user will normally pass the path or the issue number directly.
