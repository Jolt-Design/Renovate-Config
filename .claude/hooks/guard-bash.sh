#!/usr/bin/env bash
# PreToolUse hook (Bash): block destructive or secret-printing commands, and
# ask before pushing master (other Jolt repos read these presets from master).
# Help/version forms always pass through, so `git push --help` still works.
set -uo pipefail

cmd="$(jq -r '.tool_input.command // empty' 2>/dev/null)"
[[ -z "$cmd" ]] && exit 0

decide() { # $1 = deny|ask, $2 = reason
  jq -n --arg d "$1" --arg r "$2" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: $d, permissionDecisionReason: $r}}'
  exit 0
}

# One segment per line, split on ; && || | & and newlines. Plain help/version
# segments are dropped unless they contain $( or backticks.
segments="$(sed -E 's/(\|\||&&|[;|&])/\n/g' <<<"$cmd" |
  grep -vE '^[^`$]*(^|[[:space:]])(--help|-help|-h|help|--version|-version|version)([[:space:]][^`$]*)?$' || true)"
[[ -z "$segments" ]] && exit 0

# Start of a command: segment start or after (, then optional VAR=x prefixes and wrappers.
SEG='(^|\$\(|`|\()[[:space:]]*([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*((mise[[:space:]]+(exec|x)[[:space:]]+(.*[[:space:]])?--|command|time|nohup|sudo)[[:space:]]+)?'
GIT="${SEG}git([[:space:]]+(-C|-c)[[:space:]]+[^[:space:]]+)*[[:space:]]+"
END='([[:space:]]|$|[)])'

has() { grep -qE "$1" <<<"$segments"; }

# --- deny: prints secrets ---
has "${SEG}gh[[:space:]]+auth[[:space:]]+token" &&
  decide deny "Printing the GitHub token is not allowed."
has "${SEG}(printenv|env)[[:space:]]*($|[)])" &&
  decide deny "Dumping the environment would print credentials. Check specific non-secret variables instead."
has '\$\{?(GITHUB_TOKEN|GH_TOKEN)' &&
  decide deny "Don't print GitHub token variables."
has "${SEG}printenv[[:space:]]+(GITHUB_TOKEN|GH_TOKEN)" &&
  decide deny "Don't print GitHub token variables."
sed 's/\.env\.example//g' <<<"$segments" |
  grep -qE "${SEG}(cat|less|more|head|tail|bat|strings|xxd|nl)[[:space:]](.*)(\\.env([.[:space:]]|$)|\\.pem|\\.key${END})" &&
  decide deny "Don't print .env, .pem or .key files; they hold secrets."

# --- deny: irreversible ---
has "${SEG}rm[[:space:]]+(-[[:alpha:]]*r[[:alpha:]]*f|-[[:alpha:]]*f[[:alpha:]]*r)[[:alpha:]]*[[:space:]]+(/|~|~/|\\\$HOME|\\.|\\./|\\*)${END}" &&
  decide deny "Recursive delete of /, ~ or the repo root is blocked."
has "${SEG}gh[[:space:]]+repo[[:space:]]+delete" &&
  decide deny "Deleting GitHub repos is blocked for agents."

# --- git push: inspect each push segment's flags and refspecs ---
push_decision=""
while IFS= read -r seg; do
  grep -qE "${GIT}push${END}" <<<"$seg" || continue
  args="$(sed -E "s/^.*${GIT}push//" <<<"$seg")"
  args="${args%%[\`)]*}"
  force=0 all=0 positional=()
  read -ra words <<<"$args"
  for w in "${words[@]}"; do
    case "$w" in
      -f | --force | --force-with-lease* | --force-if-includes) force=1 ;;
      --all | --mirror | --branches) all=1 ;;
      -*) ;;
      *) positional+=("$w") ;;
    esac
  done
  refspecs=("${positional[@]:1}")
  master=$all
  [[ ${#refspecs[@]} -eq 0 ]] && master=1
  for r in "${refspecs[@]}"; do
    [[ "$r" == +* ]] && force=1
    grep -qE '(^\+?|:)(refs/heads/)?(master|main|HEAD)$' <<<"$r" && master=1
  done
  if ((force && master)); then
    decide deny "Force-pushing master is blocked. (A push with no branch named counts as master, since work happens on master here.)"
  elif ((master)); then
    push_decision="Pushing master changes Renovate's behaviour in every Jolt repo that extends these presets. Approve this push."
  elif ((force)); then
    [[ -z "$push_decision" ]] && push_decision="Force push rewrites remote history."
  fi
done <<<"$segments"
[[ -n "$push_decision" ]] && decide ask "$push_decision"

# --- ask: changes history or GitHub settings ---
has "${GIT}(reset[[:space:]]+(.*[[:space:]])?--hard|clean[[:space:]]+(.*[[:space:]])?-[[:alpha:]]*f)" &&
  decide ask "This discards local changes."
has "${SEG}gh[[:space:]]+(repo[[:space:]]+(archive|rename|edit)|api[[:space:]].*((-X|--method)[[:space:]]*(DELETE|PATCH|PUT|POST)|[[:space:]](-f|-F|--field|--raw-field|--input)[[:space:]]))" &&
  decide ask "This changes GitHub repo settings or data."

exit 0
