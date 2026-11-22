# Triage Labels

The SDD skills speak in terms of canonical triage roles. This file records the actual strings used in this repo's issue files.

| Role              | Label in this repo  | Meaning                                                  |
| ----------------- | ------------------- | -------------------------------------------------------- |
| `needs-triage`    | `needs-triage`      | Maintainer needs to evaluate this issue                  |
| `needs-info`      | `needs-info`        | Incomplete — waiting on missing info/design to be filled |
| `ready-for-human` | `ready-for-human`   | Complete, waiting on human review                        |
| `ready-for-agent` | `ready-for-agent`   | Human-approved; an AFK agent may execute                 |
| `implemented`     | `implemented`       | Built, evidence attached — no per-spec confirmation owed; stage gates and `/spec-check` are the backstop |
| `closed`          | `closed`            | Accepted at a stage gate (or wontfix'd); terminal        |
| `wontfix`         | `wontfix`           | Will not be actioned                                     |

**Lifecycle (one direction):** a freshly-created **complete** document is `ready-for-human` (awaiting review); an **incomplete** one is `needs-info` (awaiting gaps). Human review approval flips it to `ready-for-agent` (an AFK agent may now execute). A built spec goes to `implemented` (never back to `ready-for-human` — that label means "awaiting review", and the built state is instead backstopped by `/review` and `/spec-check`). Final acceptance at a stage gate flips it to `closed`.

When a skill mentions a role (e.g. "apply the AFK-ready triage label"), use the corresponding label string from the right-hand column.

One spec-specific extra: `/to-spec` lands spec skeletons as `needs-design` (design not yet filled) — a spec-only state between `needs-info` and `ready-for-human`, not a tracker-wide triage role.

Edit the right-hand column to match whatever vocabulary you actually use.
