# Git Contract

This repo's git workflow contract — branch strategy, commit-message convention, and what does/doesn't enter the repo. The SDD skills that write docs or code to the repo follow this, and **declare the git semantics of every write**.

## Branch strategy

**Solo** — develop directly on the current branch; no feature branch is created.

## Commit messages

- Reference the issue slug (e.g. `feat(login-redirect): refresh-token rotation`).
- Follow this repo's existing commit-message and pre-commit conventions if any — recorded below.
- Repo-specific conventions: **conventional commits** — prefix every subject with `feat:`, `fix:`, `docs:`, `refactor:`, …; imperative English subject line; no sign-off required.

## What enters the repo

- `.scratch/` — the issue tracker; issues are the carrier for `spec`/`prd`/`bug`.
- `CONTEXT.md`, `docs/adr/`, `docs/codemap/` — domain docs and code terrain.
- `docs/agents/` — this configuration. Committed when `/setup-skills` runs or when edited.

## What does NOT enter the repo

- `/handoff` output — written to the OS temp dir, never the repo.
- Local credentials, `.env`, API keys, tokens.
- Agent runtime data (`.agent-memory/`, local SQLite/Milvus Lite DBs, traces/episodes/candidates/assets).

## Declare git semantics on every write

When a skill writes a doc or code file into the repo, it states that write's git semantics in one line — which commit it lands in, or that it stays uncommitted (and why).
