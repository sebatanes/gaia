---
description: Show tickets in flight in Gaia (phase, PRs, blockers, stack lock)
---
For each `runs/*/state.json` (skip folders starting with `_`), print a table: ticket | phase | repos | PRs | last update | blocker.
Also print `bin/stack-lock status`, the worktrees under `worktrees/`, and the last 5 lines of `FRICTION.md`.
For `done` tickets whose PRs are merged (`gh pr view <url> --json state`), offer to clean up their worktrees with
`git -C <repo path> worktree remove worktrees/<repo>-<T>`. Ask before removing anything.
