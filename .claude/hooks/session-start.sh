#!/usr/bin/env bash
# SessionStart: one-line banner, tickets in flight, and the human-owned vision (the agents read it every session).
root="${CLAUDE_PROJECT_DIR:-.}"; cd "$root" || exit 0
if [ ! -f gaia.json ]; then
  echo "gaia — not configured yet. Run: bin/gaia init <repo-path>...  then bin/gaia doctor. Tutorial: bin/gaia tutorial"; exit 0; fi
name=$(jq -r '.project.name // "project"' gaia.json); repos=$(jq -r '[.repos[].name] | join(", ")' gaia.json)
echo "gaia ($name: $repos) — ticket → PR. /ship <TICKET> | /tickets <url> | /address-review <T> | /gaia-status. Work only in worktrees/, never merge."
for s in runs/*/state.json; do [ -f "$s" ] || continue; jq -r '"  in-flight: \(.ticket) (\(.phase))"' "$s"; done 2>/dev/null | head -20
echo "--- docs/vision.md (human-owned) ---"; cat docs/vision.md 2>/dev/null
