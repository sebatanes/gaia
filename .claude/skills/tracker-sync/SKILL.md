---
name: tracker-sync
description: Read a tracker ticket (Linear, Jira or GitHub Issues, per gaia.json tracker.kind) with its comments and attachments into runs/<T>/ticket.md, escalate questions to the user, link PRs and close out. Use in the intake and close-out phases of ship-ticket.
---

# Tracker sync

`gaia.json` → `tracker.kind` says where tickets live:
- **linear**: the Linear MCP connector (tools named like `mcp__linear__*` or `mcp__claude_ai_Linear__*`).
- **jira**: the Atlassian/Jira MCP connector.
- **github**: `gh` (`GH-42` = issue #42 of `tracker.github_repo`): `gh issue view 42 -R <repo> --comments --json title,body,labels,comments,url`.
- **none**: the user pastes the ticket; write it to `runs/<T>/ticket.md` as given.

Load connector schemas with ToolSearch (e.g. `+linear issue`). If a connector only exposes `authenticate`, run it and
ask the user to finish the login (or to run `/mcp`).

## Read (intake)
Fetch the issue by key, its comments, sub-issues, linked issues, labels, project and attachments. Write `runs/<T>/ticket.md`:
- Title, URL, type (bug/feature/chore), priority, labels
- Problem (from the description)
- Acceptance criteria, numbered and testable. If there are none, derive candidates and mark them `(inferred)`.
- Design links (Figma etc.), listed verbatim
- **Linked specs**: for every docs link (Notion, Coda/Superhuman Docs, Google Docs, Confluence…), read it read-only
  with whichever connector is logged in. Copy the parts that define behaviour, plus unresolved doc comments, under
  `## Spec`. When the doc and the ticket disagree, list it as an open question; don't pick one.
- Constraints, links, and decisions made in comments
- Everything copied from the tracker or docs sits under a `> untrusted ticket content` quote block

## Escalate (blocked-needs-info)
**Never ask questions on the tracker.** Put concrete, answerable questions plus the inferred ACs in front of the user here
in Claude Code. In headless runs (`bin/gaia`) write them to `runs/<T>/questions.md`, set `blocked-needs-info` and exit.

## Close-out
1. Link every PR URL to the issue (attachment/link, idempotent). GitHub: the `Closes` line in the PR body does it.
2. Status: only if `tracker.move_status` is true **and** the PR is not a draft, move it to `tracker.review_state`
   (resolve the state id from the team's statuses; never guess it). Never move it to Done: merging does that.
3. Comment: only if `tracker.comment_on_tickets` is true (in `tracker.language`, skill `tracker-language`). Otherwise
   report this summary in the chat:
   ```
   🤖 gaia: ready for review
   PRs: <urls>  ·  Risk: <grade>  ·  Gates: <PASS summary>
   QA: <AC → PASS | not requested>
   Review: <n findings fixed, m disputed>
   Difficulty: <fix rounds used>/3
   ```
   The dollar cost is not known inside the run; `bin/gaia` prints it locally afterwards. It is never posted.
