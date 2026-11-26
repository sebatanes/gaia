# Primitives & risk grading

Every plan classifies each touched primitive as **reuse** (as-is), **combine** (compose existing pieces), **expand**
(extend one), or **new** (needs a justification). The highest grade wins.

Replace the generic rows with your project's real seams (file paths help the planner a lot). Keep it current: when a new
primitive appears, `/reap-friction` or a human adds a row.

| Primitive | Where (TODO: paths) | Default risk if expanded/new |
|-----------|---------------------|------------------------------|
| Authentication & authorization checks | | **high** |
| Multi-tenant / data-access filters | | **high** |
| Money: billing, pricing, invoices | | **high** |
| Data deletion & retention | | **high** |
| Database schema & migrations | | medium (high on hot tables) |
| Public API contract (OpenAPI, GraphQL schema, events) | | medium (breaking = high) |
| Background jobs, queues, schedules | | medium |
| Audit log / change history | | **high** |
| Observability (logs, metrics, traces naming) | | medium |
| Shared UI components & design tokens | | medium |
| UI routes / pages / layout | | low |
| Generated clients & types (regen only) | | low |
| Local dev stack, CI config | | low |
| Tests & E2E suites | | low |

**Feature flags (two-way doors).** For a user-visible change of medium or high risk, prefer shipping it behind a flag
(default off) using the project's existing flag mechanism (TODO: where it lives), and record its removal criterion in
`specs/<T>.md` → Cleanup owed.

**Policy by grade**
- low: full auto.
- medium: full auto. The reviewer must explicitly confirm the primitive's invariants in `review.md`.
- high: full auto up to the PR, which opens as a **draft** labelled `needs-human`.
