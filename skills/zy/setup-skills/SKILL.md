---
name: setup-skills
description: Configure a repo for the SDD skills — set up its local-markdown issue tracker, triage label vocabulary, domain doc layout, and an initial project-level CodeMap. Run once before first use of the other skills.
disable-model-invocation: true
---

# Setup Skills

Scaffold the per-repo configuration that the skills assume:

- **Issue tracker** — where issues live. **Local markdown only** in this fork (no GitHub/GitLab).
- **Triage labels** — the strings used for the five canonical triage roles.
- **Domain docs** — where `CONTEXT.md` and ADRs live, and the consumer rules for reading them.
- **CodeMap** — an agent-facing code-terrain index under `docs/codemap/`. A project-level map is built once during setup; `/codemap` adds feature maps or refreshes it later.

This is a prompt-driven skill, not a deterministic script. Explore, present what you found, confirm with the user, then write.

## Existing spec / issue systems are reference only

The repo may already have its own spec / PRD / issue-tracking system — bespoke markdown under `docs/specs/`, an exported knowledge base, a legacy `SPECS.md`, anything of the kind. Treat it as **input, not authority**:

- In **Explore**, read it to understand the project's current state, terms, and prior decisions. That's reference material.
- It does **not** change the structure this skill sets up. The layouts of the issue tracker (`.scratch/`), triage labels, domain docs (`CONTEXT.md` + `docs/adr/`), and CodeMap (`docs/codemap/`) are defined by this skill's defaults. Don't relocate them to match the existing system, don't fork a second layout alongside it, and don't reshape this skill's files to fit it.
- If the existing system holds something worth keeping (a glossary, decision log, settled scope), fold that **content** into this skill's files — write it into `CONTEXT.md`, `docs/adr/`, `docs/agents/domain.md`. Adapt the content to this structure, never the structure to the content.

This is distinct from step 2's "raise as a question if the repo contradicts the default": that rule covers *this skill's own outputs* already pointing somewhere else. An unrelated pre-existing system is not a contradiction — it's source material. Only an explicit user request to point one of this skill's outputs at the existing system counts as a step-2 exception.

## Process

### 1. Explore

Look at the current repo to understand its starting state. Read whatever exists; don't assume:

- `AGENTS.md` and `CLAUDE.md` at the repo root — does either exist? Is there already an `## Agent skills` section in either?
- `CONTEXT.md` and `CONTEXT-MAP.md` at the repo root
- `docs/adr/` and any `src/*/docs/adr/` directories
- `docs/agents/` — does this skill's prior output already exist?
- `docs/codemap/` — does a project-level CodeMap already exist?
- `.scratch/` — sign that the local-markdown issue tracker convention is already in use
- Any pre-existing spec / PRD / issue system the repo already has (its own `docs/specs/`, a tracking doc, an exported knowledge base, …) — read it for context. **Reference only**; see the rule above.

### 2. Present the plan (defaults applied)

Summarise what's present and what's missing, then present the **defaults for all four items in one list** — don't walk through them one at a time. State that you'll apply these unless the user objects, and ask only for exceptions.

The defaults:

- **Issue tracker** — local markdown under `.scratch/` at the repo root. (Issues are the carrier for `spec`/`prd`/`bug`; `/to-spec` and `/triage` read/write here. See [issue-tracker-local.md](./references/issue-tracker-local.md).)
- **Triage labels** — each canonical role's string equals its name (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See [triage-labels.md](./references/triage-labels.md).
- **Domain docs** — single-context: one `CONTEXT.md` + `docs/adr/` at the repo root. Read by `/grill-with-docs`, `/tdd`, etc.
- **CodeMap** — build the project-level map across the whole repo via `/codemap`. Feeds `/to-spec`'s terrain step.

Raise a section as a question **only if** the repo's actual state contradicts the default — e.g. a monorepo needs multi-context (`CONTEXT-MAP.md` + per-context `CONTEXT.md` files), issues already live somewhere other than `.scratch/`, or the repo is too large/trivial for a CodeMap (or `/codemap` isn't installed). Otherwise proceed with the defaults.

### 3. Confirm and edit

Show the user a draft of:

- The `## Agent skills` block to add to whichever of `CLAUDE.md` / `AGENTS.md` is being edited (see step 4 for selection rules)
- The contents of `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, `docs/agents/domain.md`

Let them edit before writing.

### 4. Write

**Pick the file to edit:**

- If `CLAUDE.md` exists, edit it.
- Else if `AGENTS.md` exists, edit it.
- If neither exists, ask the user which one to create — don't pick for them.

Never create `AGENTS.md` when `CLAUDE.md` already exists (or vice versa) — always edit the one that's already there.

If an `## Agent skills` block already exists in the chosen file, update its contents in-place rather than appending a duplicate. Don't overwrite user edits to the surrounding sections.

The block:

```markdown
## Agent skills

### Issue tracker

[one-line summary — local markdown under `.scratch/`]. See `docs/agents/issue-tracker.md`.

### Triage labels

[one-line summary of the label vocabulary]. See `docs/agents/triage-labels.md`.

### Domain docs

[one-line summary of layout — "single-context" or "multi-context"]. See `docs/agents/domain.md`.

### CodeMap

[one-line summary — start here when exploring the codebase: a project-level terrain index under `docs/codemap/`; refresh or add feature maps via `/codemap`; when unsure whether a map is still trustworthy, run `/codemap` drift-check — if it reports drift, update the affected map].
```

Then write the three docs files using the seed templates in this skill folder as a starting point:

- [issue-tracker-local.md](./references/issue-tracker-local.md) — local-markdown issue tracker
- [triage-labels.md](./references/triage-labels.md) — label mapping
- [domain.md](./references/domain.md) — domain doc consumer rules + layout

Then build the project-level CodeMap: run `/codemap` in **project** mode to generate `docs/codemap/project.md`. Feature maps are added later as work needs them — not during setup. (Skip if `/codemap` isn't installed.)

### 5. Done

Tell the user the setup is complete and which skills will now read from these files — the project CodeMap feeds `/to-spec`'s terrain step and any terrain-aware skill. Mention they can edit `docs/agents/*.md` directly later, and refresh or extend the CodeMap via `/codemap` — re-running this skill is only necessary to restart from scratch.
