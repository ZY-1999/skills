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
