---
description: Turn accumulated FRICTION.md entries into fixes (Gaia scripts/skills/config) or issues (repo problems)
---
Read `FRICTION.md`. Group entries by root cause and count them.
- **Gaia-side** (unclear skill, missing script, step repeated by hand, wrong gate in `gaia.json`): propose the edit, apply
  it after showing the diff. When a step keeps being re-derived by the model, turn it into a `bin/` script.
- **Repo-side** (flaky test, stale doc, missing seed, slow gate): draft one GitHub issue per root cause (title, evidence,
  suspected fix). File with `gh issue create -R <owner/repo>` only after the user confirms.
Move processed entries under `## Reaped <date>`. Don't delete them.
