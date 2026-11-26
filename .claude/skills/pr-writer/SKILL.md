---
name: pr-writer
description: Commit, push and open the PR(s) for a Gaia ticket with the standard PR body. Use in the pr phase of ship-ticket.
---

# PR writer

In each touched worktree, **first** run `bin/preflight <wt> <T>`. Any FAIL means stop: don't push, fix the cause.
1. `git add -A`, then review `git diff --cached --stat`. No stray files (`.env`, coverage, `runs/`, editor files).
2. Commit with a conventional message: `<type>(<scope>): <summary> (<T>)`, ending with the co-author line from the
   session's attribution instructions.
3. `git push -u <git.remote> <branch>`.
4. `gh pr create --base <base> --head <branch> --title "<type>(<scope>): <summary> (<T>)" --body-file runs/<T>/pr-<repo>.md`
   plus `--draft` when `git.draft_prs` is true (default), and `--label needs-human` when risk is `high`. The ticket key in
   the title and branch is what makes tracker↔GitHub integrations auto-link the PR. For `tracker.kind: github`, add
   `Closes <owner/repo>#<n>` to the body.
5. Record the PR URL: `bin/state <T> set prs '{"<repo>":"<url>", …}'` (merge with the existing value).

## Body template (`runs/<T>/pr-<repo>.md`)
```markdown
## <T>: <ticket title>
Ticket: <ticket url>   ·   Related PRs: <other repo PRs>

### Why
<1–3 sentences: the user problem, not the diff>

### What changed
- <bullet per meaningful change, with file refs>

### Primitives & risk
<reuse|combine|expand|new> on <primitives> → risk **<low|medium|high>** (<one-line justification>)

### Verification
| Gate | Result |
|------|--------|
<lines from runs/<T>/gates.md>
- Tests: <proven red on base: names | CI only>
- Browser QA: <AC → PASS list, screenshots>   (omit when browser QA was not requested)

### Rollback
<revert is safe | needs migration downgrade <rev> | behind flag <X>>

### Flag & cleanup
<flag name + default> · cleanup owed: <legacy path/flag + removal criterion>

### Follow-ups
<draft issue proposals (listed, NOT filed)>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```
Omit empty sections and parts (no "Related PRs" for one repo, no Flag section without a flag). Never write "none".
Use the attribution footer from the session's instructions when they give one.
