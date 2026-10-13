Skills are organized into bucket folders under `skills/`:

- `engineering/` — daily code work
- `productivity/` — daily non-code workflow tools
- `misc/` — kept around but rarely used
- `personal/` — tied to my own setup, not promoted
- `in-progress/` — drafts not yet ready to ship
- `deprecated/` — no longer used

Every skill in `engineering/`, `productivity/`, or `misc/` must have a reference in the top-level `README.md` and an entry in `.claude-plugin/plugin.json`. Skills in `personal/`, `in-progress/`, and `deprecated/` must not appear in either.

> **Fork note**: when a `zy/` skill fully supersedes an upstream skill, that upstream skill is **de-registered** — removed from `.claude-plugin/plugin.json` and from the top-level `README.md`'s available-skills list — while its files stay in their bucket for clean merging with `origin/main`. See the 取代策略 table in the top-level `README.md`. Superseded so far: `ask-matt`→`/route`, `setup-matt-pocock-skills`→`/setup-skills`, `to-prd`→`zy/to-prd`, `tdd`→`zy/tdd`, `to-issues`→`zy/to-spec`, `handoff`→`zy/handoff`, `improve-codebase-architecture`→`zy/improve-architecture`, `diagnosing-bugs`→`zy/diagnose-bug`.

Each skill entry in the top-level `README.md` must link the skill name to its `SKILL.md`.

Each bucket folder has a `README.md` that lists every skill in the bucket with a one-line description, with the skill name linked to its `SKILL.md`. Bucket `README.md`s and the top-level `README.md` group entries into **User-invoked** and **Model-invoked**.

Every `SKILL.md` is either user-invoked (`disable-model-invocation: true`, reachable only by the human) or model-invoked (model- or user-reachable). For the full definitions, description conventions, and why a user-invoked skill can invoke model-invoked skills but never another user-invoked one, see [docs/invocation.md](./docs/invocation.md).

## Agent Notice

### Grill first

Every time the agent receives a requirement, interview the user first with the model-invoked `/grilling` skill — paired with `/domain-modeling` when the decisions should be captured as ADRs/glossary — and keep asking until the full context is clear. Only then start the work.

### Issue tracker

Local markdown under `.scratch/` at the repo root — one directory per feature, `spec`/`prd`/`bug` issues as numbered markdown files. See `docs/agents/issue-tracker.md`.

### Triage labels

The five canonical roles use their own names as label strings (`needs-triage`, `needs-info`, `ready-for-human`, `ready-for-agent`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

### CodeMap

Start here when exploring the codebase: a project-level terrain index lives under `docs/codemap/`. Refresh or add feature maps via `/codemap`; when unsure whether a map is still trustworthy, run `/codemap` drift-check — if it reports drift, update the affected map.

### Git contract

Solo — develop directly on the current branch; commit messages follow conventional commits (`feat:`, `fix:`, `docs:`, `refactor:` …). See `docs/agents/git-contract.md`.
