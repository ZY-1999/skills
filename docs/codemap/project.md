# zy-skills (skills fork) CodeMap (project)

## 1. Orientation

- Last updated: `2026-10-13`
- Project: Chinese fork of [mattpocock/skills](https://github.com/mattpocock/skills) — agent-skill sources plus a multi-platform plugin package `zy-skills`
- Role / responsibility: author and maintain agent skills (upstream buckets kept verbatim + fork-local `zy/` SDD bucket), register them as a plugin, ship releases via changesets
- Main languages / frameworks: Markdown (`SKILL.md` + reference docs), bash (`scripts/`), npm/changesets for versioning
- Runtime / deployment shape: no runtime code — consumed as a plugin by Claude Code (marketplace), CodeBuddy, Cursor; or symlinked locally for Claude CLI / OpenCode
- Primary entry types: `SKILL.md` files (slash commands, user- or model-invoked), plugin manifests, `scripts/link-*.sh`
- Confidence:
  - confirmed: bucket layout, registration manifests, de-registration protocol, release workflow, SDD pipeline shape (`skills/zy/README.md`)
  - inferred: which platform adapters are actually consumed by whom (CodeBuddy/Cursor manifests exist; usage not observable from repo)
  - unknown: none material

## 2. Context Tree

```text
Node: zy-skills repo
  -> Node: Capability Index
  -> Node: Module Index
  -> Node: Entry Index
  -> Node: Domain And Data
  -> Node: External Dependencies
  -> Node: Cross-Module Flows
  -> Node: Validation
  -> Node: Risk Areas
  -> Node: Feature CodeMap Backlog
```

### Node: zy-skills repo

- Type: `project`
- Status: `confirmed`
- Purpose: skill authoring + plugin packaging for the SDD toolchain
- Read First:
  - `README.md`: Chinese top-level README — install, skill 清单, 取代策略 (de-registration) table
  - `CLAUDE.md`: repo layout rules (bucket contract, README/manifest registration rules, Agent Notice)
  - `skills/zy/README.md`: the fork's own rulebook — never edit upstream files, interop contract, issue types, per-skill index
  - `docs/invocation.md`: user-invoked vs model-invoked axis and its dependency rules
- Edges / Children: all nodes below
- Evidence: `package.json`, `.claude-plugin/plugin.json`, `skills/*/README.md`
- Unknowns: —
- Next Drill-Down: read the three READMEs above before changing any skill or registration

### Node: Capability Index

- Type: `capability`
- Status: `confirmed`
- Purpose: what this repo delivers
- Children:
  - **SDD pipeline (fork's core)** — grill → PRD → spec → tdd → review → maintain:
    - Main modules: `skills/zy/idea-to-prd`, `skills/zy/sdd-flow`, `skills/zy/to-spec`, `skills/zy/tdd`, `skills/zy/review`
    - Entry: `/idea-to-prd` (front half, stops at approved PRD), `/sdd-flow` (back half, PRD → shipped)
    - Feature CodeMap: pending
    - Status: `confirmed`
  - **Repo configuration & triage**:
    - Main modules: `skills/zy/setup-skills`, `skills/zy/route`, `skills/zy/to-prd`
    - Entry: `/setup-skills` (one-time), `/route` (intent → skill router)
    - Feature CodeMap: pending
    - Status: `confirmed`
  - **Diagnosis & architecture discovery**:
    - Main modules: `skills/zy/diagnose-bug`, `skills/zy/improve-architecture`
    - Entry: `/diagnose-bug`, `/improve-architecture`
    - Feature CodeMap: pending
    - Status: `confirmed`
  - **Terrain & handoff support**:
    - Main modules: `skills/zy/codemap`, `skills/zy/handoff`
    - Entry: `/codemap`, `/handoff`
    - Feature CodeMap: pending
    - Status: `confirmed`
  - **Packaging & registration** (see Cross-Module Flows):
    - Main modules: `.claude-plugin/`, `.codebuddy-plugin/`, `.cursor-plugin/`, `scripts/`
    - Entry: manifests + link scripts
    - Feature CodeMap: pending
    - Status: `confirmed`
- Evidence: `skills/zy/README.md` 用户调用/模型调用 sections; `.claude-plugin/plugin.json`
- Unknowns: —
- Validation: manifest-vs-disk cross-check (see Validation node)
- Next Drill-Down: `skills/zy/README.md` is the authoritative per-skill index

### Node: Module Index

- Type: `module`
- Status: `confirmed`
- Purpose: physical layout and per-module contracts
- Children:
  - `skills/zy/`:
    - Path: `skills/zy/`
    - Responsibility: fork-local SDD skills; the only bucket this fork edits freely
    - Key dependencies: reads `docs/agents/*.md` in *consumer* repos; interoperates with upstream skills by name
    - Risk notes: must not reuse upstream `name:` frontmatter values
  - `skills/engineering|productivity|misc|personal|in-progress|deprecated/`:
    - Path: `skills/*/`
    - Responsibility: upstream buckets, kept **verbatim** for clean merges from `origin/main`
    - Key dependencies: —
    - Risk notes: **never edit these files** (zy/README rule); superseded ones are de-registered, not deleted
  - `.claude-plugin/`:
    - Path: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`
    - Responsibility: plugin registration authority for Claude Code (20 skills: zy/ + 4 upstream) + local marketplace
    - Key dependencies: `.changeset/` bumps, release workflow
    - Risk notes: entry set + version hand-maintained in parallel with two other platform manifests
  - `.codebuddy-plugin/` and `.cursor-plugin/`:
    - Path: `.codebuddy-plugin/{plugin,marketplace}.json`, `.cursor-plugin/plugin.json`
    - Responsibility: platform adapters (CodeBuddy lists zy/-only; Cursor lists the full set)
    - Risk notes: same manual-sync risk; CodeBuddy/Cursor sets intentionally differ
  - `scripts/`:
    - Path: `scripts/link-skills.sh`, `scripts/link-opencode-skills.sh`, `scripts/list-skills.sh`
    - Responsibility: local deployment (symlinks/junctions into `~/.claude/skills`, `~/.config/opencode/skills`) and inventory
    - Key dependencies: `.claude-plugin/plugin.json` (opencode script reads it)
    - Risk notes: both link scripts guard against DEST being a symlink into this repo
  - `docs/`:
    - Path: `docs/invocation.md`, `docs/adr/`, `docs/agents/`, `docs/codemap/`
    - Responsibility: invocation conventions, ADRs, per-repo agent config templates (this repo's own `docs/agents/` was written by `/setup-skills`), CodeMaps
    - Key dependencies: consumed by SDD skills
    - Risk notes: `docs/agents/*` here configure **this** repo as an SDD consumer
  - Root files:
    - Path: `README.md`, `CLAUDE.md`, `CONTEXT.md`, `CHANGELOG.md`, `.plugins-cache.json`
    - Responsibility: orientation, layout rules, glossary (Issue tracker / Issue / Triage role), release history
    - Risk notes: `.plugins-cache.json` is tracked but holds machine-local plugin cache data (see Risk Areas)
- Evidence: `CLAUDE.md` layout section, `rg --files` inventory
- Unknowns: —
- Validation: `scripts/list-skills.sh` vs manifests
- Next Drill-Down: `CLAUDE.md` for the registration contract; `skills/zy/README.md` 注册 section

### Node: Entry Index

- Type: `entry`
- Status: `confirmed`
- Purpose: how anything reaches this repo's capabilities
- Entries:
  - CLI / commands (user-invoked, `disable-model-invocation: true`): `/route`, `/setup-skills`, `/improve-architecture` (zy/) + upstream `/grill-with-docs`, `/grill-me`, `/prototype`, `/teach`
  - Skills (model-invoked): `/idea-to-prd`, `/sdd-flow`, `/to-prd`, `/to-spec`, `/tdd`, `/review`, `/codemap`, `/diagnose-bug`, `/handoff` (zy/) + upstream `/grilling`, `/domain-modeling`, `/codebase-design`, `/writing-great-skills`
  - Plugin manifests (loaders read these): `.claude-plugin/plugin.json`, `.codebuddy-plugin/plugin.json`, `.cursor-plugin/plugin.json`
  - Deploy scripts: `scripts/link-skills.sh` (Claude CLI), `scripts/link-opencode-skills.sh` (OpenCode, Windows junctions)
  - CI: `.github/workflows/release.yml` on push to `main`
- Evidence: `.claude-plugin/plugin.json` skills array; `docs/invocation.md`; bucket READMEs
- Unknowns: whether `.codebuddy-plugin/marketplace.json` and `.cursor-plugin/plugin.json` are consumed by published channels or local dev only — `inferred`
- Validation: entry lists must match `.claude-plugin/plugin.json` + top-level README + bucket READMEs (CLAUDE.md contract)
- Next Drill-Down: `docs/invocation.md` before classifying any new skill

### Node: Domain And Data

- Type: `object`
- Status: `confirmed`
- Purpose: the vocabulary and persistent artifacts this repo (and its skills) revolve around
- Children:
  - Core domain objects: **Issue** (`spec` | `prd` | `bug`), **Issue tracker** (local markdown `.scratch/`), **Triage role** — defined in `CONTEXT.md`
  - State machines: issue Status lifecycle `needs-info/needs-triage → ready-for-human → ready-for-agent → (wontfix)`; SDD gates (Gate 0 = PRD approval, Gate A = spec approval) — see `docs/agents/triage-labels.md`, `skills/zy/sdd-flow/SKILL.md`
  - Config namespaces: consumer-repo `docs/agents/{issue-tracker,triage-labels,domain,git-contract}.md`; this repo's own copies live at the same paths here
  - De-registration registry: 取代策略 table in `README.md` (8 upstream skills de-registered so far)
- Evidence: `CONTEXT.md`, `docs/agents/`, `skills/zy/README.md` Issue 类型 section
- Unknowns: —
- Validation: glossary terms in `CONTEXT.md` must be used verbatim in new issues/proposals
- Next Drill-Down: `CONTEXT.md` (short) before writing any issue or PRD in this repo

### Node: External Dependencies

- Type: `dependency`
- Status: `confirmed`
- Purpose: what this repo depends on outside itself
- Children:
  - Upstream git remote: `mattpocock/skills` — merged into `origin/main`; drives the never-edit-upstream rule
    - failure surfaces: merge conflicts in upstream files signal local edits violated the rule
  - Plugin platforms: Claude Code (marketplace install), CodeBuddy, Cursor, OpenCode — consume the manifests/symlinks
  - Release tooling: `@changesets/cli` + `changesets/action@1` (`release.yml`) — opens version PRs on push to `main`
  - Storage / filesystem: `~/.claude/skills`, `~/.config/opencode/skills` (deploy targets)
- Evidence: `package.json` devDependencies, `.github/workflows/release.yml`, `scripts/link-*.sh`
- Unknowns: none material
- Validation: `npm ci` runs in release workflow
- Next Drill-Down: `.github/workflows/release.yml` before touching versioning

### Node: Cross-Module Flows

- Type: `flow`
- Status: `confirmed`
- Purpose: the two flows that touch multiple modules
- Major Flows:
  - Flow: **Skill authoring → release**
    - Modules: `skills/zy/<skill>/` → `skills/zy/README.md` + `README.md` + `.claude-plugin/plugin.json` (+ `.codebuddy-plugin/`, `.cursor-plugin/`) → `.changeset/` → `release.yml` → version PR
    - Entry: edit or add a SKILL.md under `skills/zy/`
    - Effect: new skill ships in next plugin version; if it supersedes an upstream skill, de-register that entry (files stay)
    - Drill-Down: pending feature map
  - Flow: **Local deploy for dogfooding**
    - Modules: `scripts/link-skills.sh` | `scripts/link-opencode-skills.sh` → `~/.claude/skills` | `~/.config/opencode/skills`
    - Entry: run the script; opencode variant reads `.claude-plugin/plugin.json` and prunes stale links
    - Effect: local CLI sees the skills without a plugin install
    - Drill-Down: script headers
- Evidence: `CLAUDE.md` registration rules, `skills/zy/README.md` 注册 section, script sources
- Unknowns: —
- Validation: registration contract checks (see Validation node)
- Next Drill-Down: CLAUDE.md's bucket contract is the checklist

### Node: Validation

- Type: `validation`
- Status: `confirmed`
- Purpose: how correctness is checked in a docs-only repo
- Validation Entry:
  - Test commands: none — no test suite
  - Consistency checks (manual/scriptable): `scripts/list-skills.sh` output vs `.claude-plugin/plugin.json` entries; every `engineering|productivity|misc` skill referenced in top-level README + manifest; `personal|in-progress|deprecated` skills in **neither** (CLAUDE.md contract)
  - Smoke paths: `bash -n scripts/*.sh`; run `/route` after a local link to confirm loading
  - Local run: `scripts/link-skills.sh` then invoke a skill in Claude CLI
  - Logs / metrics: —
  - Known CI checks: `release.yml` (`npm ci` + changesets version PR) on push to `main`
- Edges / Children:
  - proves: manifest/README consistency (when manually cross-checked), script syntax
  - does not prove: skill behavior (prompt-driven, only validated in real use)
- Evidence: `scripts/list-skills.sh`, `CLAUDE.md`, `.github/workflows/release.yml`
- Unknowns: —
- Next Drill-Down: —
 
### Node: Risk Areas

- Type: `risk`
- Status: `confirmed`
- Purpose: where drift and breakage concentrate
- Risks:
  - Risk: **Manual multi-manifest sync** — skill list + `version` hand-copied across `.claude-plugin/plugin.json`, `.codebuddy-plugin/plugin.json`, `.cursor-plugin/plugin.json`, two READMEs; nothing enforces consistency
    - Source: three parallel JSON manifests + docs
    - Affected capabilities: packaging, all platform installs
    - Suggested Feature CodeMap: registration-sync audit (backlog below)
  - Risk: **Version skew** — `package.json` says `1.0.0` while all plugin manifests say `1.0.1`; changesets bumps only `package.json`, manifests are hand-bumped
    - Source: `package.json` vs `.claude-plugin/plugin.json`
    - Affected capabilities: release
    - Suggested Feature CodeMap: same as above
  - Risk: **`.plugins-cache.json` is tracked but machine-local** — contains another machine's install paths (`C:\Users\102346\...`)
    - Source: `.plugins-cache.json`
    - Affected capabilities: repo hygiene
    - Suggested Feature CodeMap: no
  - Risk: **Upstream merge discipline** — any local edit to upstream bucket files will conflict on the next `origin/main` merge
    - Source: fork workflow
    - Affected capabilities: all upstream buckets
    - Suggested Feature CodeMap: no
- Unknowns: whether platform adapters (CodeBuddy/Cursor) have consumers besides this machine — `inferred`
- Validation: cross-check manifests when touching registration
- Next Drill-Down: Risk 1+2 before any release

### Node: Feature CodeMap Backlog

- Type: `capability`
- Status: `confirmed`
- Purpose: deep maps worth building when work starts there
- Backlog:
  - `registration-and-release-sync`:
    - Why: top risk — three manifests, two READMEs, one changeset pipeline, no checker
    - Likely entry: `.claude-plugin/plugin.json`
    - Likely files: manifests, `scripts/`, `release.yml`
    - Priority: high when next skill ships
  - `sdd-pipeline`:
    - Why: five zy/ skills hand off to each other across gates; a depth map would pin the seams (Gate 0/Gate A, spec lifecycle, git checkpoints)
    - Likely entry: `skills/zy/sdd-flow/SKILL.md`
    - Likely files: `skills/zy/{idea-to-prd,to-prd,to-spec,tdd,review,sdd-flow}/SKILL.md`
    - Priority: medium — build on first pipeline change
- Evidence: this map's Risk Areas
- Unknowns: —
- Next Drill-Down: create via `/codemap` feature mode when the work starts

## 3. Compact Indexes

### Capability Index Table

| Capability | Main Modules | Entry | Feature CodeMap | Status |
| ---------- | ------------- | ----- | --------------- | ------ |
| SDD pipeline | `skills/zy/{idea-to-prd,sdd-flow,to-spec,tdd,review}` | `/idea-to-prd`, `/sdd-flow` | pending | confirmed |
| Repo config & triage | `skills/zy/{setup-skills,route,to-prd}` | `/setup-skills`, `/route` | pending | confirmed |
| Diagnosis & architecture | `skills/zy/{diagnose-bug,improve-architecture}` | `/diagnose-bug`, `/improve-architecture` | pending | confirmed |
| Terrain & handoff | `skills/zy/{codemap,handoff}` | `/codemap`, `/handoff` | pending | confirmed |
| Packaging & registration | `.claude-plugin/`, `.codebuddy-plugin/`, `.cursor-plugin/`, `scripts/` | manifests + link scripts | pending | confirmed |

### Module Index Table

| Module / Package | Path | Responsibility | Key Dependencies | Risk Notes |
| ---------------- | ---- | -------------- | ---------------- | ---------- |
| zy bucket | `skills/zy/` | fork-local SDD skills | consumer-repo `docs/agents/*.md` | no upstream `name:` reuse |
| Upstream buckets | `skills/{engineering,productivity,misc,personal,in-progress,deprecated}/` | upstream skills, verbatim | `origin/main` merges | never edit |
| Claude plugin | `.claude-plugin/` | registration + marketplace | changesets | manual sync |
| Platform adapters | `.codebuddy-plugin/`, `.cursor-plugin/` | CodeBuddy / Cursor variants | — | manual sync, intentionally differing sets |
| Scripts | `scripts/` | local link/inventory | `.claude-plugin/plugin.json` | symlink-into-repo guard |
| Docs | `docs/` | invocation, ADRs, agent config, CodeMaps | SDD skills | `docs/agents/` is live config for this repo |

### Cross-Module Flow Table

| Flow | Modules | Entry | Effect | Drill-Down |
| ---- | ------- | ----- | ------ | ---------- |
| Skill authoring → release | zy bucket → READMEs → 3 manifests → changeset → release.yml | edit `skills/zy/<skill>/` | ships in next version; supersession de-registers upstream entry | pending |
| Local deploy | `scripts/link-*.sh` → home-dir skill dirs | run script | CLI sees skills w/o plugin install | script headers |

### Quick File Index

- `README.md`: project orientation + 取代策略 de-registration table
- `CLAUDE.md`: layout & registration contract + Agent Notice
- `skills/zy/README.md`: fork rulebook and per-skill index
- `docs/invocation.md`: user- vs model-invoked rules
- `CONTEXT.md`: domain glossary
- `.claude-plugin/plugin.json`: plugin registration authority
- `docs/agents/`: this repo's SDD consumer config (issue tracker, triage labels, domain docs, git contract)

## 4. Maintenance Notes

- Refresh this Project CodeMap when bucket boundaries, registration manifests, release flow, or validation commands change.
- Do not refresh the whole map for a narrow skill edit; update the relevant row/node or add a feature map instead.
- Run `/codemap` drift-check when unsure whether this map still matches the repo.
