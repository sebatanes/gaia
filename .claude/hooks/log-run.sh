#!/usr/bin/env bash
# PostToolUse: append a compact event to runs/<ticket>/log.jsonl (ticket from runs/.current). Never logs tool output.
set -uo pipefail
root="${CLAUDE_PROJECT_DIR:-.}"; t=$(cat "$root/runs/.current" 2>/dev/null) || exit 0
[ -n "$t" ] || exit 0; mkdir -p "$root/runs/$t"
jq -c '{ts: (now|todate), tool: .tool_name,
        what: ((.tool_input.command // .tool_input.file_path // (.tool_input|tostring)) | tostring | .[0:200])}' \
  >> "$root/runs/$t/log.jsonl" 2>/dev/null || true
exit 0
