# PRD template (feature)

`Type: prd`. Use when the conversation is about a new feature or capability. Fill every section from the conversation — do not interview.

This is a **requirements-only** document: what and why, in the user's language. Technical translation (endpoints, schemas, error codes, module boundaries) happens later in `contracts.md`, produced by `/to-spec` — do not put it here.

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A complete, numbered list of user stories with acceptance criteria. Write each story in the language of the conversation, using that language's canonical user-story format — never mix languages inside one story:

- English: `As an <actor>, I want <feature>, so that <benefit>`
- 中文：`作为<角色>，我希望<功能>，以便<收益>`

Directly under each story, its acceptance criteria — one line each, numbered `AC-<story>-<NN>` and priority-marked:

1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
   - AC-1-01 (P0): opening the app shows each account's current balance within 3 seconds
   - AC-1-02 (P1): balances update without a manual refresh
1. 作为手机银行客户，我希望在首页看到账户余额，以便更好地决定自己的开支
   - AC-2-01 (P0)：打开 App 后 3 秒内显示各账户当前余额

Rules for acceptance criteria:

- **P0** = must ship. Every P0 gets a scenario, a contract point, and a test — the trace gate enforces this. **P1** = wanted; covered when cheap.
- Observable behavior in the user's language. Each criterion states what happens, not how.
- Numbers explicit (limits, quantities, timeouts) — they are mirrored verbatim in `contracts.md` and cross-checked at `/to-spec` time.
- No JSON, schemas, SQL, endpoints, or file paths — those are contract-layer concerns (layer purity).

This list should be extremely extensive and cover all aspects of the feature.

## Out of Scope

A description of the things that are out of scope for this PRD.

## Further Notes

Any further notes about the feature.
