---
name: e2e-verify
description: Bring the project's local stack up against the ticket's worktrees (gaia.json stack) and verify acceptance criteria in a real browser via the Playwright MCP, with screenshots as evidence. Use only when the user explicitly requested browser QA for this run.
---

# E2E verify

Requires `stack.enabled: true` in `gaia.json`. Otherwise write `browser: no (stack not configured)` in `qa.md` and stop.

1. `bin/stack up <T>`. It takes the exclusive stack lock, exports `GAIA_WT_<REPO>` for each worktree, and runs
   `stack.up` and `stack.smoke`. If another ticket holds the lock, retry every few minutes for up to 30 min, then
   `blocked-stack`. Never steal the lock. If smoke is red, check the stack on the base branch before blaming the change.
2. **Sign-in, done by the orchestrator, never a subagent**: follow `stack.login`. If it produces a token, print it in a
   code block in the chat so the user can sign in, with its expiry. Never write tokens to files, logs or PRs.
3. Delegate to subagent `qa-browser` with the AC list and `stack.urls`.
4. Optionally run the project's E2E suite if `gaia.json` or the infra repo's CLAUDE.md names one. Foreground only.
5. **Restore, always (even when QA failed)**: `bin/stack down <T>`.

Evidence goes in `runs/<T>/qa.md`: AC → PASS/FAIL, screenshot path, console errors, failed network calls. Start the
file with `browser: yes`.
