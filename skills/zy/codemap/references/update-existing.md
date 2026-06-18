# Update Existing CodeMap

Use this when an existing CodeMap should be refreshed rather than replaced.

## Goal

Keep the map as a compact terrain index. Preserve valid nodes, update stale nodes, and avoid turning the map into a changelog.

## Workflow

1. Read the existing CodeMap and identify its scope, mode, and key nodes.
2. Inspect current source facts with `rg`, `rg --files`, tests, configs, or language-aware tools.
3. Mark affected nodes:
   - `confirmed`: still correct.
   - `changed`: source terrain changed and the node must be updated.
   - `stale`: map points to removed/renamed/incorrect terrain.
   - `unknown`: relationship still matters but could not be verified.
4. Update only the affected nodes and compact indexes.
5. Preserve stable anchors, `Next Drill-Down`, and `Validation Entry`.
6. Refresh the map's `Last updated` field to today's date and add a short `Updated` note with the reason, but do not list every diff.

## Update Rules

- Prefer patching the existing file when scope and mode are still correct.
- Create a new CodeMap only when scope changed substantially or the old map is misleading as a base.
- Keep source-linked evidence; do not paste large code blocks.
- If the map feeds an active spec, update the spec's CodeMap reference only when the map path changes.

## Output Shape

```text
Updated CodeMap:
- Path:
- Mode:
- Updated nodes:
- Preserved nodes:
- Stale/unknown still requiring follow-up:
- Validation entry:
```
