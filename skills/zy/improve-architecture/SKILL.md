---
name: improve-architecture
description: Scan a codebase for architectural deepening opportunities, publish a visual HTML report, run /to-prd to synthesise a PRD, run SDD's Gate 0 on it, then hand off to /sdd-flow to continue from specs. Discovery only — proposes no interfaces.
disable-model-invocation: true
---

# Improve Architecture

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones — as a visual HTML report, then carry it into the SDD pipeline. **Discovery only — no interfaces proposed.** It discovers candidates, publishes the report as the first artifact in a new SDD feature folder, runs `/to-prd` to synthesise a PRD, runs SDD's **Gate 0** on that PRD, then hands off to `/sdd-flow` to continue from specs.

> Precondition: the issue tracker is configured — run `/setup-skills` first if `.scratch/` isn't set up.

Informed by the project's domain model and built on a shared design vocabulary:

- Run the `/codebase-design` skill for the architecture vocabulary (**module**, **interface**, **depth**, **seam**, **adapter**, **leverage**, **locality**) and its principles (the deletion test, "the interface is the test surface", "one adapter = hypothetical seam, two = real"). Use these terms exactly in every suggestion — don't drift into "component," "service," "API," or "boundary."
- The domain language in `CONTEXT.md` gives names to good seams; ADRs in `docs/adr/` record decisions this skill must not re-surface as theoretical refactors.

## Process

### 1. Explore

Read the project's domain glossary (`CONTEXT.md`) and any ADRs in the area you're touching first.

Then use the Agent tool with `subagent_type=Explore` to walk the codebase. Don't follow rigid heuristics — explore organically and note where you experience friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow** — interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want.

### 2. Publish the report to the issue tracker

**Create the feature folder.** Resolve today's date as `<YYYY-MM-DD>` and the current time as `<HHmmss>` (seconds keep each scan unique; colons are illegal in Windows filenames). The scan-slug is `architecture-review-<HHmmss>`. Create `.scratch/<YYYY-MM-DD>-architecture-review-<HHmmss>/` and write a self-contained `architecture-review.html` into it — Tailwind + Mermaid via CDN, nothing else.

Render the report per [references/html-report.md](./references/html-report.md) — scaffold, candidate-card fields, diagram patterns, and vocabulary. Each candidate card carries **Files** / **Problem** / **Solution** (plain English) / **Benefits** (in locality & leverage terms, how tests improve) / **Before-After diagram** / recommendation-strength badge (`Strong` / `Worth exploring` / `Speculative`). End with a **Top recommendation**.

**The report is a discovery artifact — no interfaces proposed.** Use `CONTEXT.md` vocabulary for the domain and the `/codebase-design` vocabulary for the architecture. If `CONTEXT.md` defines "Order," talk about "the Order intake module" — not "the FooBarHandler," and not "the Order service."

**ADR conflicts**: only surface a candidate that contradicts an ADR when the friction is real enough to warrant revisiting it, and mark it clearly (e.g. a warning callout: _"contradicts ADR-0007 — but worth reopening because…"_). Don't list every theoretical refactor an ADR forbids.

**Review the HTML before opening.** Read it back and verify:

- **Structure** — `<!doctype html>`, paired `<html>`/`<head>`/`<body>`, every `<article>`, `<section>`, `<div>`, `<svg>` closed; no stray tags.
- **CDN scripts** — exactly two: the Tailwind CDN `<script src="https://cdn.tailwindcss.com">` and the Mermaid CDN `<script src="https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js">`. URLs exact.
- **Mermaid blocks** — each `<pre class="mermaid">` is valid: a diagram type on the first line (`flowchart LR`, `graph TD`, `sequenceDiagram`, …), well-formed node and edge syntax, `classDef`/`class` statements correct. Mermaid is the most error-prone part — a bad block renders an error box instead of the diagram.
- **No stray JS** — the only scripts are the two CDN imports (plus the Mermaid `initialize` call); no app code.

Fix anything broken, re-check, then open the file for the user — `xdg-open <path>` on Linux, `open <path>` on macOS, `start <path>` on Windows — and tell them the absolute path.

### 3. Run /to-prd — the report is the PRD's resource file

Run `/to-prd` against the feature folder. The PRD covers **the Top recommendation plus any candidates tightly coupled to it — nothing else:**

- **In scope**: the Top recommendation, and any candidate that shares its module / seam / files, or has a real dependency on it (e.g. one is the prefactor that makes the other possible). These belong in one PRD; `/to-spec` will split them into a spec sequence.
- **Out of scope**: independent candidates — different module, different problem, each shippable alone. They stay recorded in `architecture-review.html` for a later scan or a manual feature. Do not fold them in.

`architecture-review.html` is this PRD's **resource file** — `/to-prd` reads the in-scope candidates' Problem + Benefits + Solution-direction from it and synthesises them into the PRD's Problem Statement / User Stories / Implementation Decisions, then publishes the `prd` to the same feature folder. Tell `/to-prd` to reference the report (e.g. a line in _Further Notes_ pointing at `architecture-review.html`) so the PRD traces back to its source.

### 4. Gate 0 — user reviews the PRD, then hand off to /sdd-flow

The PRD is on disk in the feature folder (Step 3 published it) — the same kind of PRD `/sdd-flow` produces in its Stage 2, made by the same `/to-prd`. This is SDD's **Gate 0**, and it runs identically to `/sdd-flow`'s .

- Point the user at the PRD file (not the chat) and have them review it directly. Ask: **"PRD looks good → break into specs? Or redo the PRD?"**
- **Redo** → back to Step 3: re-run `/to-prd` with the user's feedback.
- **Approve** → equals `/sdd` prd file review completed, run remaining steps of `/sdd-flow`.

## When NOT to use this skill

- You have a concrete feature idea (not an architecture scan) → `/sdd-flow` directly.
- You already know what to change → skip the scan; run `/to-prd` directly.
- You need a code-navigation index, not deepening candidates → `/codemap`.
