# Git Contract

This repo's git workflow contract — branch strategy, commit-message convention, and what does/doesn't enter the repo. The SDD skills that write docs or code to the repo follow this, and **declare the git semantics of every write**.

## Branch strategy

This is chosen during `/setup-skills` — pick one mode, delete the other, so the deployed contract states a single active mode. (Solo is the usual pick; reach for feature branches when the work needs isolation — long-running, parallel tracks, risky.)

- **Solo** — develop directly on the current branch; no feature branch is created.
- **Feature branch** — one branch per feature/bugfix: `feature/<slug>` or `bugfix/<slug>`. `<slug>` reuses the issue-tracker folder slug `.scratch/<YYYY-MM-DD>-<slug>/`. Created once at feature start (in `/sdd-flow`'s entry); `/tdd`'s pre-workflow check only confirms the current branch (idempotent, never re-created per spec).

_<Pick one during `/setup-skills` and delete the other — the deployed `docs/agents/git-contract.md` carries only the active mode.>_

## Commit messages

- Reference the issue slug (e.g. `feat(login-redirect): refresh-token rotation`).
- Follow this repo's existing commit-message and pre-commit conventions if any — recorded below.
- Repo-specific conventions (conventional-commits prefix, sign-off, issue key, …): _<fill in if the repo has any; leave as "none" if not>_

## What enters the repo

- `.scratch/` — the issue tracker; issues are the carrier for `spec`/`prd`/`bug`.
- `CONTEXT.md`, `docs/adr/`, `docs/codemap/` — domain docs and code terrain. Committed with the relevant spec (when `/tdd` closes it), or at the `/sdd-flow` summarize step.
- `docs/agents/` — this configuration. Committed when `/setup-skills` runs or when edited.

## What does NOT enter the repo

- `/handoff` output — written to the OS temp dir, never the repo.
- Local credentials, `.env`, API keys, tokens.
- Agent runtime data (`.agent-memory/`, local SQLite/Milvus Lite DBs, traces/episodes/candidates/assets).

## Declare git semantics on every write

When a skill writes a doc or code file into the repo, it states that write's git semantics in one line — which commit it lands in, or that it stays uncommitted (and why). Examples:

- `/to-prd` publishing a `prd`: _"writes the PRD to `.scratch/`; uncommitted — it lands in the commit `/sdd-flow` makes at entry, once approved at Gate 0."_
- `/to-spec` landing spec skeletons: _"writes specs to `.scratch/.../specs/`; uncommitted — they land together in the commit `/sdd-flow` makes after Gate A."_
- `/tdd` closing a spec: _"writes code + tests + flips status, and commits it on spec close."_
- `/codemap` refreshing a map mid-build: _"writes `docs/codemap/<map>.md`; rides the current spec's close commit."_

A skill that only reads, or writes outside the repo (e.g. `/handoff` to temp), doesn't declare.
