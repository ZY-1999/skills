---
name: codemap
description: Generate, update, or drift-check agent-facing CodeMaps — progressive code-terrain indexes that route an agent to the right source-linked evidence without loading the whole repo. Use it to map a feature from entry to effect, orient on an unfamiliar codebase, or check whether existing maps are stale after a diff. Feeds `/to-spec` (reduce chaos before splitting) and any skill that needs to "look at the terrain first".
---

# Codemap

## Core Position

Create **CodeMaps** for agents, not CodeWikis for humans.

A CodeMap saves context attention, not necessarily raw token count. It does not replace source code, tests, logs, or the current Spec. It routes the agent toward the right source-linked evidence, in the right order, with progressive disclosure.

Use a CodeMap as:

- **Project CodeMap** — breadth-first project terrain: capability index, module boundaries, dependency index, drill-down pointers.
- **Feature CodeMap** — depth-first capability terrain from entry to effect: branches, dependencies, risks, validation entry points.

## Workflow

1. Restate the requested scope and choose a mode:
   - `feature`: capability, business feature, bug chain, API flow, function/class-centered investigation.
   - `project`: repository, service, package, subsystem, or first-time onboarding map.
   - `drift-check`: compare current diff or touched files with existing CodeMaps.
   - `update-existing`: refresh an existing CodeMap after code-terrain changes.
2. Before writing a durable CodeMap, tell the user why a map/update is useful, the selected mode, scope, and expected path. Do not silently write persistent maps unless current task approval already covers it.
3. Read [references/principles.md](./references/principles.md) when the output shape, boundary, or the CodeWiki-vs-CodeMap distinction matters.
4. For drift checks, read [references/drift-check.md](./references/drift-check.md).
5. For updating an existing map, read [references/update-existing.md](./references/update-existing.md).
6. Inspect code with search first (`rg`, `rg --files`, language-aware tools if available). Prefer source facts over inferred naming matches.
7. Build progressive **Context Tree Nodes**:
   - start with a small orientation node;
   - add capability, module, entry, branch, effect, dependency, risk, and validation nodes only where they route future context;
   - keep compact indexes as lookup tables, not as the main structure;
   - point nodes to files, functions, classes, tests, configs, logs, and related maps;
   - mark each important relationship as `confirmed`, `inferred`, or `unknown`.
8. Write the map under `docs/codemap/` when the user requests a durable artifact or the work feeds `/to-spec`:
   - feature: `docs/codemap/<feature>.md`
   - project: `docs/codemap/<project>.md`
   - Set the map's `Last updated` field (see templates) to today's date, and refresh it on every update so the map self-documents its currency without a date in the filename.
9. Keep the CodeMap narrow enough to guide the next agent action. Do not paste large source blocks or turn it into a narrative system document.

## Templates

- Feature/capability maps → [references/feature-template.md](./references/feature-template.md).
- Project/system maps → [references/project-template.md](./references/project-template.md).
- Drift checks → [references/drift-check.md](./references/drift-check.md).
- Existing map updates → [references/update-existing.md](./references/update-existing.md).
- If a task spans multiple repos, create one Project CodeMap per relevant project, then add a separate interface or cross-service flow summary.

## Output Rules

- Prefer path-linked, source-grounded bullets over prose.
- Separate `Confirmed`, `Inferred`, and `Unknown`.
- Include `Next Drill-Down` so the next agent knows what to read only if needed.
- Include `Validation Entry` so the map can feed Spec / Plan / Review.
- Treat stale or conflicting CodeMaps as indexes to re-check, not truth.
- Do not treat a CodeMap as a changelog. Update only terrain-changing facts: entries, flows, module boundaries, dependencies, risks, validation entry points, or behavior-rule locations.
