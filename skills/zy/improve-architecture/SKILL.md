---
name: improve-architecture
description: Scan a codebase for architectural deepening opportunities, publish a visual HTML report, run /to-prd to synthesise a Top PRD plus publish the remaining candidates as backlog drafts, then stop. Discovery only — proposes no interfaces; ships PRD drafts, not specs.
disable-model-invocation: true
---

# Improve Architecture

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones — as a visual HTML report, then publish PRD drafts and stop. **Discovery only — no interfaces proposed.** It discovers candidates, publishes the report as the first artifact in a new SDD feature folder, runs `/to-prd` to synthesise a Top PRD, and publishes the remaining candidates as backlog drafts.

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

### 3. Publish the candidates — Top PRD via /to-prd, the rest as backlog

Every scan surfaces more than one independent candidate. Only the Top recommendation gets the full PRD treatment this round, but **every other candidate must land in the issue tracker, not die in `architecture-review.html`** — the report is a visual overview, not a backlog. So Step 3 has two outputs.

#### 3a. Top PRD — `/to-prd`

Run `/to-prd` against the feature folder, telling it the source is **architecture** so it uses the architecture PRD template (`Type: prd`, with `Deepening Goals` in place of `User Stories`). The PRD covers **the Top recommendation plus any candidates tightly coupled to it — nothing else:**

- **In scope**: the Top recommendation, and any candidate that shares its module / seam / files, or has a real dependency on it (e.g. one is the prefactor that makes the other possible). These belong in one PRD.
- **Out of scope**: independent candidates — different module, different problem, each shippable alone. Do not fold them in; route them to Step 3b instead.

`architecture-review.html` is this PRD's **resource file** — `/to-prd` reads the in-scope candidates' Problem + Benefits + Solution-direction from it and synthesises them into the PRD's Problem Statement / Deepening Goals / Implementation Decisions, then publishes the `prd` to the same feature folder. Tell `/to-prd` to reference the report (e.g. a line in _Further Notes_ pointing at `architecture-review.html`) so the PRD traces back to its source.

#### 3b. Backlog — independent candidates, each its own feature folder

The `Strong` and `Worth exploring` candidates left out of the Top PRD are **pre-synthesized** — their Problem / Solution / Benefits already live in `architecture-review.html`. Don't re-run `/to-prd` per candidate (its explore + seam-sketch + per-parent confirm loop is overkill); publish them straight to the tracker as lightweight `prd` drafts for later review:

- **One feature folder each** — `.scratch/<YYYY-MM-DD>-<candidate-slug>/` with a `Type: prd` / `Status: needs-info` parent (these are lifted straight from the report card, not run through `/to-prd`'s synthesis — thinner than the Top PRD, with Implementation / Testing Decisions left empty).
- **Reuse the candidate card** — fill Problem Statement / Solution / Deepening Goals from the card's Problem / Solution / Benefits; leave Implementation Decisions and Testing Decisions empty (they get filled when the draft is grilled into an approved PRD). Do not redraw the diagram; point _Further Notes_ at the card's anchor in `architecture-review.html`.
- `Speculative` candidates stay in the report only — too thin for a backlog slot.

### 4. Mark every PRD `needs-info`, then tell the user

Once the Top PRD (Step 3a) and the backlog drafts (Step 3b) are all on disk, set each one's status to `needs-info` — yes, including the Top PRD. `/to-prd` tags its output `ready-for-agent` by default; this skill overrides that, because no human has vetted these PRDs yet and improve-architecture runs no gate. `needs-info` ("waiting on you for review + anything missing") is the honest state for discovery output.
Then tell the user, in chat:

- the scan's feature folder path (where `architecture-review.html` + the Top PRD live),
- each backlog draft's feature folder path,
- the next move is theirs: run `/idea-to-prd` on a draft — it grills the gaps, flips `needs-info` → `ready-for-agent`, and runs Gate 0 (mode 2), then hands off to `/sdd-flow`.

## When NOT to use this skill

- You have a concrete feature idea (not an architecture scan) → `/idea-to-prd` (grill → PRD → Gate 0, then it hands off to `/sdd-flow`).
- You already know what to change → skip the scan; run `/to-prd` directly.
- You need a code-navigation index, not deepening candidates → `/codemap`.
