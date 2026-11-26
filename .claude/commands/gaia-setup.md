---
description: Guided setup — point Gaia at your repos, write gaia.json, check it, and draft the docs templates with you
argument-hint: [repo paths...]
---
Set Gaia up for this user's project. Speak in the user's language; keep each step short and confirm before writing.
1. If no repo paths were given in **$ARGUMENTS**, ask which repos the project has (paths), which tracker (Linear, Jira,
   GitHub Issues, none) and team/key, and where specs live.
2. Run `bin/gaia init --tracker <kind> [--team <team>] [--name <name>] <paths…>` (add `--force` only if the user agrees to
   overwrite an existing `gaia.json`).
3. For each repo, read its README, CLAUDE.md, Makefile, compose files, package/pyproject and CI workflows (read-only), and
   propose better `gates`, `tests.policy`, `contract`, `notes` and `review_checklist`. Show the diff to `gaia.json`; apply on a yes.
4. Ask whether they want browser QA. If yes, work out `stack.up` / `smoke` / `restore` / `urls` / `login` with them (see
   `docs/config.md` → stack), including how their stack can use `GAIA_WT_<REPO>`.
5. `docs/vision.md` is human-owned: never edit it. Offer a draft in the chat they can paste. You may fill the
   `docs/primitives.md` table with real paths after showing it.
6. Run `bin/gaia doctor` and walk them through any FAIL/warn line. Remind them to log in to the tracker connector with `/mcp`.
7. Finish with their first command: `/ship <KEY>` on a small ticket. Mention `bin/gaia tutorial` for the full guide.
