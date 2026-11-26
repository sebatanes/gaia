#!/usr/bin/env bash
# PreToolUse(Bash) guard: gaia may commit/push ONLY on <branch_prefix>* branches inside worktrees/,
# never merges, never pushes to the base branch, never runs destructive git. Exit 2 = block (stderr goes to Claude).
set -uo pipefail
root="${CLAUDE_PROJECT_DIR:-$(pwd)}"; cfg="$root/gaia.json"
pfx=$(jq -r '.git.branch_prefix // "feat/"' "$cfg" 2>/dev/null || echo feat/)
base=$(jq -r '.git.base // "main"' "$cfg" 2>/dev/null || echo main)
cmd=$(jq -r '.tool_input.command // ""')
block() { echo "guard-git: BLOCKED — $1. Gaia rule: worktrees + ${pfx}* only, humans merge." >&2; exit 2; }

[[ "$cmd" =~ gh[[:space:]]+pr[[:space:]]+merge ]] && block "gh pr merge"
[[ "$cmd" =~ gh[[:space:]]+api.*(merge|/merges) ]] && block "merge via gh api"
[[ "$cmd" =~ git[[:space:]].*push.*[[:space:]:]($base|main|master)([[:space:]]|$) ]] && block "push to $base"
[[ "$cmd" =~ git[[:space:]].*(reset[[:space:]]+--hard|clean[[:space:]]+-[a-z]*f|branch[[:space:]]+-D) ]] && block "destructive git"

# commit/push/checkout/stash must target a gaia worktree, never the user's checkouts
if [[ "$cmd" =~ git[[:space:]]+(-C[[:space:]]+[^[:space:]]+[[:space:]]+)?(commit|push|checkout|switch|stash|rebase|merge|cherry-pick) ]]; then
  dir=$(pwd)
  [[ "$cmd" =~ -C[[:space:]]+([^[:space:]]+) ]] && dir="${BASH_REMATCH[1]}"
  [[ "$cmd" =~ ^[[:space:]]*cd[[:space:]]+([^[:space:];&]+) ]] && dir="${BASH_REMATCH[1]}"
  case "$dir" in
    "$root"/worktrees/*|worktrees/*) ;;
    *) block "git write outside $root/worktrees ($dir)";;
  esac
  if [[ "$cmd" =~ (commit|push) ]]; then
    br=$(cd "$root" && git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
    [[ "$br" == "$pfx"* ]] || block "commit/push on branch '$br' (must be ${pfx}*)"
  fi
fi
exit 0
