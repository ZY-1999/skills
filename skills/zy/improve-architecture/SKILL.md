---
name: improve-architecture
description: Scan a codebase for architectural deepening opportunities, publish a visual HTML report, then publish every candidate (Top recommendation included) as a lightweight needs-info PRD draft and stop. Discovery only — proposes no interfaces, runs no /to-prd synthesis; ships PRD drafts, not specs.
disable-model-invocation: true
---

# Improve Architecture

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones — as a visual HTML report, then publish PRD drafts and stop. **Discovery only — no interfaces proposed, no `/to-prd` synthesis.** It discovers candidates, publishes the report as the first artifact in a new SDD feature folder, and lifts every `Strong` / `Worth exploring` candidate (Top recommendation included) straight from its report card into a thin `needs-info` `prd` draft — Implementation / Testing Decisions left empty for `/idea-to-prd` mode 2 to grill later.

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

### 3. Publish every candidate as a lightweight `needs-info` draft

Every scan surfaces more than one candidate, and **every `Strong` / `Worth exploring` candidate lands in the issue tracker as a `needs-info` PRD draft — the Top recommendation included.** The report is a visual overview, not a backlog; nothing of substance should die inside `architecture-review.html`.

improve-architecture is **discovery only** — it does **not** run `/to-prd`. Synthesising a full PRD (filling Implementation / Testing Decisions, sketching test seams) is `/idea-to-prd` mode 2's job, once the user picks a draft to pursue. Instead, lift each candidate straight from its report card into a thin `prd` draft — Problem Statement / Deepening Goals / Solution-direction carried over, Implementation / Testing Decisions left empty.

Route each candidate to a draft by **independence**, not by rank:

- **Top recommendation + anything tightly coupled to it** → one draft in the scan's own feature folder (`.scratch/<YYYY-MM-DD>-architecture-review-<HHmmss>/`, alongside `architecture-review.html`). "Tightly coupled" = shares the same module / seam / files, or has a real dependency on the Top (e.g. one is the prefactor that makes the other possible). They belong in one draft because splitting them would manufacture artificial seams.
- **Independent candidates** (`Strong` / `Worth exploring`, but different module / different problem, each shippable alone) → one feature folder each (`.scratch/<YYYY-MM-DD>-<candidate-slug>/`), each its own draft.
- `Speculative` candidates → report only — too thin for a backlog slot.

Every draft, regardless of folder, is built the same way:

- `Type: prd` / `Status: needs-info` parent, using the architecture PRD shape (`Deepening Goals` in place of `User Stories`).
- Fill Problem Statement / Deepening Goals / Solution-direction from the card's Problem / Benefits / Solution; **leave Implementation Decisions and Testing Decisions empty** — they get filled when `/idea-to-prd` mode 2 grills the draft into an approved PRD.
- Don't redraw the diagram — point _Further Notes_ at the card's anchor in `architecture-review.html` so the draft traces back to its source.

### 4. Confirm the drafts are `needs-info`, then tell the user

Step 3 already wrote every draft as `needs-info` — there's no `/to-prd` run to override and no `ready-for-agent` default to fight. improve-architecture runs no gate; `needs-info` ("waiting on your review + the gaps `/idea-to-prd` will grill") is the honest state for unvetted discovery output.
Then tell the user, in chat:

- the scan's feature folder path (where `architecture-review.html` + the Top draft live),
- each independent candidate draft's feature folder path,
- the next move is theirs: run `/idea-to-prd` on any draft — it grills the gaps, flips `needs-info` → `ready-for-agent`, and runs Gate 0 (mode 2), then hands off to `/sdd-flow`.

## When NOT to use this skill

- You have a concrete feature idea (not an architecture scan) → `/idea-to-prd` (grill → PRD → Gate 0, then it hands off to `/sdd-flow`).
- You already know what to change → skip the scan; run `/to-prd` directly.
- You need a code-navigation index, not deepening candidates → `/codemap`.
