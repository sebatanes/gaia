---
name: status-message
description: Template for the short team update (Slack, Teams, email) announcing tickets Gaia shipped and their PRs. Use when the user asks for "the message for the team", a status post, or a summary of tickets/PRs to share. Gaia never posts it; the user does.
---

# Status message

Write it in the user's chat language unless they ask otherwise. Lean, scannable, no internal jargon. Read
`runs/<T>/state.json` and `specs/<T>.md` for each ticket; never invent a PR or a status.

```
<one line: what this batch is about>

• <KEY> <ticket title> — <PR url(s)> (<draft | ready> · risk <grade>)
  <one line: what changed for the user>
• …

Needs a human: <tickets blocked or high risk, with the one question each>
To test: runs/<T>/manual-test.md
```
Drop the "Needs a human" line when nothing needs one. No costs, no secrets, no tokens. Give the text in a code block
ready to paste.
