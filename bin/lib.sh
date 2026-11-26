# bin/lib.sh — shared helpers, sourced by every bin/ script. Everything project-specific comes from gaia.json.
# shellcheck shell=bash
F=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
CFG="${GAIA_CONFIG:-$F/gaia.json}"

die() { echo "$*" >&2; exit 1; }
need_cfg() { [ -f "$CFG" ] || die "gaia: no gaia.json at $CFG — run: bin/gaia init <repo-path>... (or copy examples/gaia.example.json)"; }

# cfg <jq-filter> [default] → raw value, or the default when null/missing
cfg() { need_cfg; local v; v=$(jq -r "($1) // empty" "$CFG"); if [ -n "$v" ]; then echo "$v"; else echo "${2:-}"; fi; }
cfg_json() { need_cfg; jq -c "$1" "$CFG"; }

git_base()      { cfg '.git.base' main; }
git_remote()    { cfg '.git.remote' origin; }
branch_prefix() { cfg '.git.branch_prefix' feat/; }
key_pattern()   { cfg '.tracker.key_pattern' '[A-Z][A-Z0-9]+-[0-9]+'; }
max_files()     { cfg '.git.max_files' 40; }

repo_names() { need_cfg; jq -r '.repos[].name' "$CFG"; }
# repo_get <name> <jq-path-inside-repo> [default]
repo_get() { need_cfg; local v; v=$(jq -r --arg n "$1" ".repos[] | select(.name==\$n) | ($2) // empty" "$CFG"); if [ -n "$v" ]; then echo "$v"; else echo "${3:-}"; fi; }
repo_exists() { need_cfg; jq -e --arg n "$1" '.repos[] | select(.name==$n)' "$CFG" >/dev/null; }
# repo_path <name> → absolute path of the user's checkout (gaia.json paths are relative to the factory dir)
repo_path() { local p; p=$(repo_get "$1" '.path'); [ -n "$p" ] || die "unknown repo '$1' (see gaia.json .repos)"
  case "$p" in /*) echo "$p";; *) (cd "$F" && cd "$p" 2>/dev/null && pwd) || echo "$F/$p";; esac; }

# wt_split <worktree-basename> → prints "<repo>\t<ticket>" (longest configured repo name that prefixes it)
wt_split() { local name=$1 best="" r
  while IFS= read -r r; do [[ "$name" == "$r-"* ]] && [ ${#r} -gt ${#best} ] && best=$r; done < <(repo_names)
  [ -n "$best" ] || die "can't tell which repo '$name' belongs to (worktrees are named <repo>-<TICKET>)"
  printf '%s\t%s\n' "$best" "${name#"$best"-}"; }

lower() { tr '[:upper:]' '[:lower:]'; }
# env var name for a repo's worktree: api-server → GAIA_WT_API_SERVER
wt_var() { echo "GAIA_WT_$(echo "$1" | tr '[:lower:]-.' '[:upper:]__')"; }
