# Bug template

`Type: bug`. Use when the conversation is about something broken — wrong behavior, a crash, incorrect output. Fill every section from the conversation; investigate the codebase enough to write a credible root-cause hypothesis, but do not pin specific files or code. A bug is a **parent** — when the fix needs multiple coding steps, `/to-spec` decomposes it into `spec`s (each carrying `Parent: #<this bug>`).

## Summary

One line: what is broken, for whom.

## Problem Statement

The bug from the affected user's perspective — what they were trying to do and what went wrong. This is the symptom, not the root cause.

## Reproduction Steps

A numbered, minimal sequence that triggers the bug. Anyone following these should see it.

1. …
2. …

## Expected Behavior

What should have happened.

## Actual Behavior

What actually happens — including any error output, crash, or wrong state.

## Impact

Who is affected, how often, and how severe (data loss / security / blocker / annoyance). Ground it in evidence from the conversation or codebase, not speculation.

## Root Cause Hypothesis

Where in the module structure the bug most likely lives, and why — at module/seam granularity, not file/line. If the conversation has not established one, say so and point at the area to investigate. Do NOT include specific file paths or code snippets — they go stale.

## Proposed Fix Direction

The shape of the fix at module/seam level — what should change in which interface, and what must stay untouched. Not a patch.

## Testing Decisions

How the fix gets verified and how the bug is kept from regressing. This block is also the **done-definition** for the bug — a fix counts as done only when the checklist below holds, and the bug is not closed without it.

What the regression test looks like:

- Test external behavior through the right seam (the one the diagnosis identified)
- Which module/interface the regression test targets
- Prior art for similar tests in the codebase, if any

Done checklist — the bug is closed only when all hold:

- [ ] Original repro no longer reproduces (re-run the Reproduction Steps above)
- [ ] Regression test passes at the chosen seam (or the absence of a correct seam is documented)
- [ ] All `[DEBUG-...]` instrumentation is removed (`grep` the prefix)
- [ ] Throwaway diagnosis harnesses/scripts are deleted (or moved to a clearly-marked debug location)
- [ ] The hypothesis that turned out correct is stated in the commit / PR message — so the next debugger learns

## Out of Scope

What this bug does NOT cover — related issues that deserve their own bug/spec.

## Further Notes

Anything else — links to reports, logs, related bugs, or the grilled conversation that surfaced it.
