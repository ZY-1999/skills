# Trace — <feature slug>

`Parent: #<n>`. The feature's traceability matrix: AC → scenario → contracts → spec → test → commit. Rows are created by `/to-spec`, backfilled by `/tdd`, gated by `/sdd-flow` (Stage 3), audited by `/spec-check`, rippled by `/spec-sync`.

| AC | P | Scenario | Contracts | Spec | Test | Commit | Status |
|----|---|----------|-----------|------|------|--------|--------|
| AC-2-01 | P0 | S-01 user at limit (3 held) re-receives → 403 COUPON_LIMIT_EXCEEDED | C-01, C-11 | specs/02-receive | `tests/coupon_test.py::test_limit_rejected` | `a1b2c3d` | done |
| AC-2-02 | P1 | S-02 first receive → 200 + couponId | C-01 | specs/02-receive | — | — | pending |

Column rules:

- **Scenario** (`S-NN`) — one P0 AC = at least one scenario: a one-line behavior sequence with an assertable expectation, walking named contract points. The full Given/When/Then lives in the materialized test code, not here.
- **Contracts** — `C-NN` IDs from `contracts.md`, comma-separated.
- **Spec** — the spec file that implements this scenario.
- **Test / Commit** — filled by `/tdd` on close: `file::test name` and the implementing commit sha.
- **Status** — `pending` until Test and Commit are both non-empty, then `done`.

**Gate (hard, not advisory):** every P0 row must be `done` before Stage 3 passes. A P0 AC with no scenario or no contract point is **untestable as written** — send it back to `/to-spec`, don't paper over it. P1 rows are filled when cheap, never gated.
