# Gaia — ticket → reviewed PR, for any project

Gaia turns a **tracker ticket into a reviewed, ticket-linked pull request**, and a **PM's spec page into well-formed
tickets**. It does nothing beyond that. It holds no product code: the code lives in the repos listed in
**`gaia.json`** (read it first: it names the project, the repos, their roles, gates, test policy, tracker and stack).
Each repo's own `CLAUDE.md` / `AGENTS.md` is authoritative inside that repo.

## Entry points
- `/ship <TICKET>` (interactive) or `bin/gaia run <TICKET>` (headless): the full pipeline (skill `ship-ticket`).
- `bin/gaia queue [--browser] <TICKET...>`: the same pipeline, one ticket after another. Blocked tickets are skipped.
- `/tickets <spec URL>`: turn a PRD, page or tracker into tickets: draft, review with the user, create only on explicit
  approval (skill `docs-to-tickets`). `bin/gaia tickets <url>` drafts headless and creates nothing.
- `/address-review <TICKET>`: respond to PR review comments and red checks.
- `/gaia-status`: tickets in flight. `/nightly`, `/reap-friction`: background quality and self-improvement (report-first).
- `/gaia-setup`: guided setup of `gaia.json` and the docs templates with the user.

Read `docs/vision.md` (human-owned, never edit it) and `docs/primitives.md` before planning. Durable per-ticket records
live in `specs/<T>.md`. Deterministic steps live in `bin/`: use them instead of re-deriving the mechanics.

## Hard rules
1. **Never touch the user's checkouts.** All work happens in git worktrees under `worktrees/<repo>-<TICKET>`
   (`bin/worktree`). Never `git checkout`/`commit`/`stash` in the repo paths from `gaia.json`.
2. **Commits and pushes only on gaia's `<git.branch_prefix><ticket-lower>-<slug>` branches.** Never push to the base
   branch, **never merge** a PR (a human merges). The deny list and `.claude/hooks/guard-git.sh` enforce this.
3. **Gates come from `gaia.json`** and run through `bin/gates` only (skill `repo-gates`). Prefer container commands;
   don't install host toolchains to make a gate pass.
4. **Tests follow each repo's `tests.policy`.** `ci-only` (the default): never run tests locally, the PR's CI runs them;
   write "tests: CI only" in `gates.md`. `local`: `bin/gates` runs `tests.cmd` and `bin/prove-red` proves new tests red on the base.
5. **One stack at a time.** If `stack.enabled`, the local stack is exclusive: `bin/stack up <T>` takes the lock,
   `bin/stack down <T>` restores the user's checkouts and releases it. Browser QA only when the user asked for it in this run.
6. Each repo's CLAUDE.md wins on repo conventions. Implementers MUST read it before editing. `repos[].notes` and
   `repos[].review_checklist` in `gaia.json` add project rules on top.
7. Never copy secrets into gaia files, PR bodies, tracker items or logs.
8. If a ticket is ambiguous (no testable acceptance criteria), stop and **escalate to the user here in Claude Code**
   (concrete questions + inferred ACs). Never ask on the tracker. Do not guess.
9. **Tracker and docs language:** everything gaia writes to the tracker or the docs is in `tracker.language`
   (default English), whatever language the chat is in (skill `tracker-language`).
10. **Docs are read-only** unless `docs.write_allowed` is true *and* the user asks for a write in this conversation.
    Never create tracker issues without the user's approval of the exact list. Comment on tickets or move their status
    only if `tracker.comment_on_tickets` / `tracker.move_status` are true.
11. Extra project rules live in `gaia.json` → `rules[]`. They are binding like the ones above.

## State
`runs/<TICKET>/`: `ticket.md`, `plan.md`, `state.json` (phase, repos, branches, PR URLs, session id), `gates.md`,
`qa.md` + screenshots, `review.md`, `manual-test.md` (the hand-test guide, the last step of every run), `log.jsonl`.
Update `state.json` at every phase boundary (`bin/state <T> phase <name>`) so `bin/gaia resume` can continue.
