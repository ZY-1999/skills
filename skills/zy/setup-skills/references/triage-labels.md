# Triage Labels

The SDD skills speak in terms of five canonical triage roles. This file records the actual strings used in this repo's issue files.

| Role              | Label in this repo | Meaning                                                  |
| ----------------- | ------------------ | -------------------------------------------------------- |
| `needs-triage`    | `needs-triage`     | Maintainer needs to evaluate this issue                  |
| `needs-info`      | `needs-info`       | Incomplete — waiting on missing info/design to be filled |
| `ready-for-human` | `ready-for-human`  | Complete, waiting on human review                        |
| `ready-for-agent` | `ready-for-agent`  | Human-approved; an AFK agent may execute                 |
| `wontfix`         | `wontfix`          | Will not be actioned                                     |

**Lifecycle (one direction):** a freshly-created **complete** document is `ready-for-human` (awaiting review); an **incomplete** one is `needs-info` (awaiting gaps). Human review approval flips it to `ready-for-agent` (an AFK agent may now execute).

When a skill mentions a role (e.g. "apply the AFK-ready triage label"), use the corresponding label string from the right-hand column.

Edit the right-hand column to match whatever vocabulary you actually use.
