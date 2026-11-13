#!/usr/bin/env bash
# PostToolUse hook: run Biome on the file Claude just edited.
# biome.json's files.includes decides which files are touched; anything else is skipped.
# Exit 0 = fine or skipped (including Biome not installed).
# Exit 2 = format or lint error; stderr is shown to Claude.
set -uo pipefail

project_dir="${CLAUDE_PROJECT_DIR:-$PWD}"
file="$(jq -r '.tool_input.file_path // empty' 2>/dev/null)"

[[ -z "$file" || ! -f "$file" ]] && exit 0
case "$(realpath "$file")" in
  "$(realpath "$project_dir")"/*) ;;
  *) exit 0 ;;
esac
cd "$project_dir" || exit 0

if command -v mise >/dev/null 2>&1; then
  biome=(mise exec -C "$project_dir" -- biome)
elif command -v biome >/dev/null 2>&1; then
  biome=(biome)
else
  exit 0
fi

if ! out="$("${biome[@]}" check --write --files-ignore-unknown=true --no-errors-on-unmatched "$file" 2>&1)"; then
  echo "format hook: biome check failed for $file:" >&2
  echo "$out" >&2
  exit 2
fi

exit 0
