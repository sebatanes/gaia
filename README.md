# Gaia

**From a tracker ticket to a reviewed, ticket-linked pull request, for any project.** Gaia is a software factory that
runs on [Claude Code](https://claude.com/claude-code). You give it a ticket key; it plans, implements in isolated git
worktrees, runs your repos' gates, opens draft PRs, has an independent agent review them, watches CI and links
everything back to the ticket. A human always merges.

It also turns a PM's spec page (Notion, Coda, Google Docs, Confluence…) into well-formed tickets with testable acceptance
criteria, created only after explicit approval.

> **Start here:** `bin/gaia tutorial` opens the step-by-step guide (`site/index.html`), with an interactive
> walkthrough of the pipeline and a `gaia.json` generator.

## Quick start
```bash
cd ~/code && git clone <gaia-url> gaia && cd gaia          # next to your repos
bin/gaia init --tracker linear --team ENG ../my-api ../my-web   # writes gaia.json from what it detects
$EDITOR gaia.json docs/vision.md docs/primitives.md          # fix the TODOs
bin/gaia doctor                                              # tools, config, repos
claude                                                       # then: /mcp (log in to your tracker), /ship ENG-123
```
Or run `claude` and `/gaia-setup` for a guided setup.

Requirements: `claude`, `git`, `gh` (logged in), `jq`; `docker` if your gates or stack use containers.

## How it is made generic
Everything project-specific lives in **`gaia.json`** (reference: [`docs/config.md`](docs/config.md), examples in
[`examples/`](examples/)):

- **repos**: name, path, role (`contract-owner` → wave A, others → wave B), gates (any shell command), test policy
  (`ci-only` or `local`), contract regen/codegen, house rules (`notes`) and the reviewer's `review_checklist`.
- **tracker**: Linear, Jira, GitHub Issues or none; key pattern, pickup label, language, whether Gaia may comment or move status.
- **docs**: where specs live and whether writes are ever allowed.
- **git**: base branch, branch prefix, draft PRs, max files per PR.
- **stack**: optional local stack for browser QA; `bin/stack up <T>` exports `GAIA_WT_<REPO>` so your compose file can
  build from the ticket's worktrees.
- **rules**: extra binding rules in plain English.

The skills, agents and `bin/` scripts read that file; nothing in them names a specific product.

## Commands
| | |
|-|-|
| `/ship T` · `bin/gaia run [--browser] T` | full pipeline for one ticket |
| `bin/gaia resume T` · `bin/gaia queue T…` | continue / run several, one at a time |
| `/tickets URL` · `bin/gaia tickets URL` | spec → ticket drafts (headless creates nothing) |
| `/address-review T` | answer PR review comments and red checks |
| `/gaia-status` · `bin/gaia status` | tickets in flight |
| `/gaia-setup` · `bin/gaia init` · `bin/gaia doctor` | setup and checks |
| `bin/gaia poll` | pick up issues with the pickup label |
| `/nightly` · `/reap-friction` | background quality and self-improvement |

## What's inside
```
gaia.json            your project (not shipped; start from examples/)
bin/                 deterministic steps: gaia, init, doctor, worktree, gates, prove-red, preflight, state, stack, stack-lock, flaky-scan
.claude/agents/      planner, implementer (one per repo per wave), reviewer, qa-browser
.claude/skills/      ship-ticket, tracker-sync, repo-gates, pr-writer, e2e-verify, docs-to-tickets, tracker-language, status-message
.claude/commands/    /ship /tickets /address-review /gaia-status /gaia-setup /nightly /reap-friction
.claude/hooks/       guard-git (no merge, no push to base, commits only on feat/* in worktrees/), log-run, session-start
docs/                vision.md (human-owned), primitives.md (risk grading), config.md
runs/ worktrees/     per-ticket state and work (gitignored)
specs/               durable per-ticket records
site/                the tutorial
ops/                 launchd templates for poll and nightly
```

## Safety
Never merges, never pushes to the base branch (deny list + `guard-git.sh`). Works only in `worktrees/`, never in your
checkouts. `bin/preflight` fails closed on red gates, stray files and secret-looking literals. Ticket and doc text is
treated as data, not instructions. No tracker issues or doc writes without explicit approval. `docs/vision.md` is
edited by humans only.
