# PRD template (architecture / code-structure deepening)

`Type: prd`. Use when the conversation is about deepening the codebase — turning shallow modules deep, consolidating seams, improving locality/leverage — typically fed by `/improve-architecture`'s `architecture-review.html` or a design discussion. Uses the `/codebase-design` vocabulary (**module**, **interface**, **depth**, **seam**, **adapter**, **leverage**, **locality**) — don't drift into "component," "service," "API," or "boundary." Like the feature PRD this is a `prd` parent that `/to-spec` decomposes into `spec`s; the difference from a feature PRD is framing and vocabulary, not issue type.

## Problem Statement

The architectural friction, in the project's domain language: which **module** is **shallow** (interface nearly as complex as its implementation), which **seam** leaks, where **locality** is lost so bugs hide in how things are called rather than what they do. Name the domain concept (per `CONTEXT.md`), not the handler class.

## Solution

The deepening direction: which module becomes deep, which seam consolidates, what the new interface hides. State the intended **depth** and **leverage** in plain terms.

## Deepening Goals

A numbered list, replacing the feature PRD's user stories. Each goal names a concrete architectural move and the payoff:

1. Deepen **<module>** by moving <complexity X> behind its interface, so that callers no longer <friction Y> (locality gain).
2. Consolidate **<seam A>** and **<seam B>** into one deep interface, removing the adapter that only existed to bridge them (leverage gain).

Cover every in-scope candidate from the report. Each goal should be independently valuable and map to at least one downstream spec.

## Implementation Decisions

Module/seam-level changes, using codebase-design vocabulary:

- Which modules/interfaces will change and how (deeper interface, merged seam, removed adapter)
- What stays untouched so the change stays bounded
- Schema / API / interaction changes, if any

Do NOT include specific file paths or code snippets — they go stale. Same prototype-snippet exception as the feature PRD: inline a decision-encoding snippet (state machine, type shape) only when prose is weaker, and trim to the decision-rich parts.

## Testing Decisions

How the deepening is verified:

- The interface is the test surface — test through the deepened module's interface, not its internals
- Which modules/interfaces get new or changed tests
- How existing tests must continue to pass (the deepening is behavior-preserving unless a goal explicitly changes behavior)
- Prior art for similar tests in the codebase

## Out of Scope

Candidates from the report that are independent — different module, different problem, each shippable alone. Do not fold them in. When this PRD comes from `/improve-architecture`, those candidates are published as separate `needs-info` `prd` drafts (one feature folder each) for later review — they don't stay marooned in `architecture-review.html`.

## Further Notes

Point back at the source — e.g. "Candidates synthesized from `architecture-review.html` in this feature folder." Note any ADR the deepening relates to (respecting or reopening).
