# gaia.json reference

`bin/gaia init <repo-path>...` writes a first version; `bin/gaia doctor` validates it. Paths are relative to the Gaia folder.

| Key | Default | What it does |
|-----|---------|--------------|
| `project.name`, `project.description` | — | Shown in the banner; read by the planner. |
| `tracker.kind` | `linear` | `linear`, `jira`, `github` or `none`. Linear/Jira go through their MCP connector; GitHub through `gh`. |
| `tracker.team` | — | Team/project key used to create and search issues (e.g. `ENG`). |
| `tracker.key_pattern` | `[A-Z][A-Z0-9]+-[0-9]+` | Regex for ticket keys. For GitHub issues use `GH-[0-9]+` (GH-42 = issue #42 of `tracker.github_repo`). |
| `tracker.github_repo` | — | `owner/name`, only for `kind: github`. |
| `tracker.pickup_label` | `gaia` | `bin/gaia poll` picks up open issues with this label (and without `gaia-blocked`). |
| `tracker.language` | `English` | Language of everything Gaia writes to the tracker and docs. |
| `tracker.comment_on_tickets` | `false` | When false, Gaia never comments on tickets: summaries go to the chat. |
| `tracker.move_status` | `false` | When true, close-out moves the ticket to `tracker.review_state` (only if the PR is not a draft). |
| `docs.kind` | `any` | Where specs live (`notion`, `coda`, `google-docs`, `confluence`, `any`). Read with whichever connector is logged in. |
| `docs.write_allowed` | `false` | Even when true, Gaia writes to docs only when the user asks in the conversation. |
| `git.base` / `git.remote` | `main` / `origin` | Base branch for worktrees and PRs (`repos[].base` overrides per repo). |
| `git.branch_prefix` | `feat/` | Branches are `<prefix><ticket-lower>-<slug>`. The guard hook only lets Gaia commit/push on these. |
| `git.draft_prs` | `true` | Open every PR as a draft. |
| `git.max_files` | `40` | Preflight fails above this many changed files (split the ticket). |
| `git.forbidden_paths_regex` | — | Extra paths preflight refuses to push (added to `.env`, keys, coverage, `node_modules`, `runs/`). |
| `repos[]` | — | One entry per repo, see below. |
| `stack.*` | `enabled: false` | Local stack for browser QA, see below. |
| `design.figma` | `false` | When true, planner/implementer/QA use the Figma MCP for linked designs. |
| `rules[]` | `[]` | Extra binding rules in plain English (e.g. "Never touch the billing module"). |

## `repos[]`
| Key | What it does |
|-----|--------------|
| `name` | Short id. Worktrees are `worktrees/<name>-<TICKET>`. |
| `path` | The user's checkout (never modified). |
| `role` | `contract-owner` (wave A: owns an API contract), `primary`, `service`, `consumer` (wave B: uses the contract), `infra` (stack, CI, E2E). The planner orders waves by role. |
| `description` | One line; helps the planner pick repos. |
| `base` | Overrides `git.base`. |
| `gates[]` | `{name, cmd, fast}` — commands run in the worktree by `bin/gates`. `fast: false` = full run only. Exit 0 = PASS. |
| `tests` | `{policy: "ci-only"}` (default) or `{policy: "local", cmd: "… {paths}", fast_cmd: "…"}`. `{paths}` is replaced by test files for `bin/prove-red`, or by nothing for a full run. |
| `copy_files[]` | Untracked files copied from the checkout into each worktree (e.g. `.env`). Never committed. |
| `contract` | Owners: `{file: "openapi.json", regen: "<cmd>"}`. Consumers: `{from: "<owner repo>", file: "openapi.json", codegen: "<cmd>"}`. |
| `notes` | Extra conventions the implementer must follow in this repo. |
| `review_checklist[]` | Invariants the reviewer must check on every diff in this repo. |
| `ci` | `{workflow: "ci.yml", junit_artifact: "junit-*"}` for `bin/flaky-scan`. |

## `stack`
| Key | What it does |
|-----|--------------|
| `enabled` | Turns browser QA on. |
| `dir` | Where the stack commands run (often an "infra"/"local" repo or one of the app repos). |
| `up` / `smoke` / `restore` | Shell commands. `bin/stack up <T>` exports `GAIA_WT_<REPO>` (e.g. `GAIA_WT_WEB=/…/worktrees/web-ENG-12`) before `up` and `smoke`; `restore` runs with them unset. |
| `urls` | Named URLs QA visits (`{app: "http://localhost:3000"}`). |
| `login` | How a human signs in locally (e.g. "make token EMAIL=dev@local, paste it in the sign-in form"). Gaia prints tokens in chat, never into files. |
| `logs` | Command to read backend logs after QA. |

Pointing your stack at the worktrees is up to `stack.up`. The simplest pattern is a compose file whose build contexts
default to your checkouts and switch to the worktree when the var is set:
```yaml
services:
  web: { build: { context: "${GAIA_WT_WEB:-../web}" } }
  api: { build: { context: "${GAIA_WT_API:-../api}" } }
```
