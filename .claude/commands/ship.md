---
description: Resolve a tracker ticket end-to-end — plan, implement, gates, PR, review, link back. Browser QA only if the user asked for it in this message.
argument-hint: <TICKET e.g. ENG-123>
---
Run the `ship-ticket` skill for ticket **$ARGUMENTS**.
If `runs/$ARGUMENTS/state.json` exists, resume from its phase. Otherwise start at intake.
