---
name: handoff
description: Compact the current conversation into a handoff file in the OS temp dir, then emit a ready-to-paste starter prompt ("read <path>, then continue <action>") for the next session. Run when a session that will continue elsewhere is wrapping up.
argument-hint: "What will the next session be used for?"
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work, then emit the starter prompt that launches the next session.

## 1. Write the handoff file

Save to the **OS temporary directory**, not the workspace — a handoff is a transient bridge between sessions, not a committed artifact.

Include:

- **Status** — where the work stands now (done / in-progress / blocked), one paragraph.
- **Next action** — the concrete next step a fresh agent can start immediately.
- **Pointers, not copies** — reference existing artifacts by path or URL (PRDs, specs, ADRs, issues, commits, diffs). Do NOT duplicate their content.
- **Suggested skills** — which skills the next agent should invoke, in order.
- **Redact** anything sensitive (API keys, passwords, PII).

If the user passed an argument, treat it as what the next session focuses on and tailor the doc (and the action below) to it.

## 2. Emit the next-session starter prompt

After writing the file, output a **ready-to-paste starter prompt** for the next session — this is the point of the handoff: the file carries the detail, one line carries the entry point. Print it last, clearly delimited, in the user's language:

> 请阅读文件 `<absolute path to the handoff file>` 然后继续 `<next action>`

- `<path>` — the absolute path to the handoff file you just wrote.
- `<next action>` — the imperative the next agent should act on, drawn from the argument or inferred from the conversation (e.g. "实现 spec #3 的 acceptance 行为", "review the spec cut at Gate A", "continue debugging the redirect loop").

That single line is what the user pastes into the next session.

---

Adapted from upstream `handoff`: made **model-invoked** (no `disable-model-invocation`) so the SDD flow can invoke it at wrap-up, and added the step-2 starter-prompt emit so the handoff yields a ready-to-paste next-session input, not just a file.
