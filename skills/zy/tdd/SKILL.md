---
name: tdd
description: Implement a planning-complete spec test-first (red-green-refactor). Use after /to-spec has produced a spec — the spec already carries the interface and the prioritized behaviors to test, so this skill starts straight at the tracer bullet.
---

# TDD: Implement a Spec

The **planning is already done** — `/to-spec` produced a planning-complete spec (design, acceptance criteria, scope, context, rework path). This skill is the implementation half: take that spec and turn it into code, test-first.

If no spec is in hand, run `/to-spec` first.

Adapted from upstream `tdd`, with the Planning step removed — planning now lives in `/to-spec`.

## Philosophy

**Core principle**: Tests should verify behavior through public interfaces, not implementation details. Code can change entirely; tests shouldn't.

**Good tests** are integration-style: they exercise real code paths through public APIs. They describe _what_ the system does, not _how_ it does it. A good test reads like a specification — "user can checkout with valid cart" tells you exactly what capability exists. These tests survive refactors because they don't care about internal structure.

**Bad tests** are coupled to implementation. They mock internal collaborators, test private methods, or verify through external means (like querying a database directly instead of using the interface). The warning sign: your test breaks when you refactor, but behavior hasn't changed.

This is `/codebase-design`'s **"interface is the test surface"** principle: wanting to test *past* the interface is a signal the module is the wrong shape — fix the interface, don't paper over it with a mock. The testability rules below operationalize it (and hold whether or not `/codebase-design` is loaded).

## Anti-Pattern: Horizontal Slices

**DO NOT write all tests first, then all implementation.** This is "horizontal slicing" — treating RED as "write all tests" and GREEN as "write all code."

This produces **crap tests**:

- Tests written in bulk test _imagined_ behavior, not _actual_ behavior
- You end up testing the _shape_ of things (data structures, function signatures) rather than user-facing behavior
- Tests become insensitive to real changes — they pass when behavior breaks, fail when behavior is fine
- You outrun your headlights, committing to test structure before understanding the implementation

**Correct approach**: Vertical slices via tracer bullets. One test → one implementation → repeat. Each test responds to what you learned from the previous cycle.

```
WRONG (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
  ...
```

## Workflow

The spec's **Acceptance criteria** is your test list; the **Design**'s *Interface delta* is the public surface you test through. Work the behaviors in the spec's priority order, and honor **Scope** — don't touch what's listed Out.

**Design testable code as you go.** As you write each piece of minimal code, shape it for testability per `/codebase-design`'s three rules: **accept dependencies, don't create them**; **return results, don't produce side effects**; **keep the surface small**. Tests then fall out naturally instead of needing mocks. When `/codebase-design` isn't loaded, those three phrases are enough to apply.

### 1. Tracer Bullet

Write ONE test that confirms ONE thing about the system (start with the spec's top-priority critical path):

```
RED:   Write test for first behavior → test fails
GREEN: Write minimal code to pass → test passes
```

This is your tracer bullet — proves the path works end-to-end.

### 2. Incremental Loop

For each remaining behavior, in priority order:

```
RED:   Write next test → fails
GREEN: Minimal code to pass → passes
```

Rules:

- One test at a time
- Only enough code to pass current test
- Don't anticipate future tests
- Keep tests focused on observable behavior

### 3. Refactor

After all tests pass, look for refactor candidates:

- [ ] Extract duplication
- [ ] **Deepen modules** — via `/codebase-design`'s **DEEPENING** pattern; the spec's **Design** may have flagged deep-module opportunities
- [ ] **Check seam and depth on what you built** — deletion test (delete it; complexity vanishing means a pass-through) and one-vs-two-adapters (one adapter = a hypothetical seam, drop it). See `/codebase-design`.
- [ ] Apply SOLID principles where natural
- [ ] Consider what new code reveals about existing code
- [ ] Run tests after each refactor step

**Never refactor while RED.** Get to GREEN first. If a cycle stays RED after honest minimal effort, fall back to the spec's **Rework on failure** point rather than forcing code to fit.

### 4. Maintain the codemap

If `/codemap` is loaded and the spec touched an area a `docs/codemap/` map covers, run `/codemap` **drift-check** against that map once the implementation is GREEN — if it reports drift, update the affected map. Skip when `/codemap` isn't loaded or no map covers the area. Do this before closing the spec, so any map update lands in the same commit as the code.

### 5. Close the spec

With every behavior in the spec's **Acceptance criteria** GREEN, refactor done, and the codemap current, flip the spec file's `Status: ready-for-agent` → `ready-for-human` (or `closed`, per the tracker) so triage and the next stage know it's implemented.

## Checklist Per Cycle

```
[ ] Test describes behavior, not implementation
[ ] Test uses public interface only
[ ] Test would survive internal refactor
[ ] Code is minimal for this test
[ ] No speculative features added
```
