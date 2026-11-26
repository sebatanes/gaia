---
name: repo-gates
description: Which gates each repo in gaia.json must pass and how to run and read them (bin/gates, bin/prove-red). Use before declaring any implementation done or when a gate is red.
---

# Repo gates

The gates are **data, not knowledge**: each repo's `gates[]` and `tests` in `gaia.json`. Never invent or skip one.

- Always run `bin/gates <worktree> [--fast]`. It is deterministic, writes `runs/<T>/gates-<repo>.log`, and prints one
  `PASS|FAIL|SKIP <gate>` line per gate. Copy those lines into `runs/<T>/gates.md`.
- `--fast` skips gates marked `"fast": false` (slow ones). The full run, once, before the PR is mandatory.
- `tests.policy: ci-only` (default): tests never run locally; `bin/gates` prints `SKIP test (tests: CI only)`; the PR's CI
  runs them and the `ci` phase reads the result. `tests.policy: local`: `bin/gates` runs `tests.cmd` (`fast_cmd` with
  `--fast`) and `bin/prove-red <wt> <test files>` checks new tests fail on the base.
- Contract repos: an owner's `contract.regen` must leave no diff; a consumer's `contract.codegen` output is committed
  with the copied contract file.

## Reading reds
- Look at the tail of `runs/<T>/gates-<repo>.log` first; quote the relevant lines to the implementer.
- A wall of "column does not exist" / schema errors usually means a **stale DB or volume**, not a broken change:
  `docker compose down -v` in the worktree and retry. Log it in FRICTION.md.
- Stale `node_modules`/build caches: gates should use `--build`; a clean `down -v` usually fixes them.
- A gate that fails on the base branch too is not this ticket's fault: report it to the user, log it, don't "fix" it here.
- Serial-green plus parallel-red points to a flaky test. Log it; don't serialize the test to hide it.
- A gate command that doesn't work at all (missing profile, wrong path) is a **config bug** in `gaia.json`: tell the user.

A gate is green only when it says PASS in this run. A previous run or another agent's report does not count.
