---
description: Background quality pass — flaky-test scan, friction reaping, legacy reaper, drift scan and exploratory QA (report-first; files nothing without GAIA_NIGHTLY_FILE=1)
---
Write everything to `runs/_nightly/<date>.md`. Only file issues when `GAIA_NIGHTLY_FILE=1`; otherwise write **draft** issue texts in the report.
1. **Flaky tests**: `bin/flaky-scan <repo>` for each repo with `ci.workflow` in `gaia.json` (`--file` only with GAIA_NIGHTLY_FILE=1).
2. **Friction**: run the `/reap-friction` flow, but only *propose* edits. Never apply them unattended.
3. **Legacy reaper**: `specs/*.md` → "Cleanup owed". For each item check its removal criterion (flag on everywhere? legacy
   path still referenced?). Draft removal tickets for the safe ones, "instrument first" for the rest.
4. **Drift scan** (read-only, one fresh subagent per repo): unused exports, endpoints/services without tests, CLAUDE.md
   claims that no longer match the code. Top 10 by value, with evidence.
5. **Exploratory QA** (only if `stack.enabled` and the stack lock is free): `bin/stack up _nightly`, subagent `qa-browser`
   explores the app for broken flows, console errors, a11y gaps and slow calls; `bin/stack down _nightly`.
Put a 5-line summary at the top.
