# Contracts — <feature slug>

`Parent: #<n>` (omit if the source was a grilled conversation). The feature's **technical truth source**: every externally observable interface — endpoints, error codes, data fields, constraints. Created by `/to-spec`; changed only via `/spec-sync`; audited by `/spec-check`.

Rules:

- Every contract point carries an ID (`C-NN`) and lists the ACs it serves. Specs and `trace.md` **reference** IDs — never copy or alias a definition.
- **Numbers mirror the ACs verbatim** ("限领 3 张" ↔ `limit_per_user: 3`). A mismatch is a defect, not a style choice.
- No user-value narrative here — that lives in the PRD. Contracts state shapes and behaviors, not benefits.

## Interface contracts

One bullet per contract point — method/path (or function/message signature), request/response shape, error codes with their trigger conditions:

- **C-01** — `POST /coupons/receive`, body `{userId, couponCode}` → `200 {couponId}`; user at limit → `403 COUPON_LIMIT_EXCEEDED`; unknown code → `404 COUPON_NOT_FOUND`. (serves AC-2-01)
- **C-02** — …

## Data contracts

Fields, types, defaults, and constraints — the storage-side truth:

- **C-11** — `coupons.limit_per_user INT DEFAULT 3`, one row per user+coupon per receive. (serves AC-2-01)

## Shared error codes

Only when the stack defines codes used by several contract points — a name → code table, referenced as `#ERR-…` by the points above.
