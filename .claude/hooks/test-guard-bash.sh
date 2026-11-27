#!/usr/bin/env bash
# Runs guard-bash.sh on sample commands and fails if any decision is wrong.
# Usage: .claude/hooks/test-guard-bash.sh
set -uo pipefail

hook="$(dirname "$0")/guard-bash.sh"
fail=0

check() { # $1 = expected (allow|ask|deny), $2 = command
  local got
  got="$(jq -n --arg c "$2" '{tool_input:{command:$c}}' | bash "$hook" | jq -r '.hookSpecificOutput.permissionDecision // "allow"')"
  got="${got:-allow}"
  if [[ "$got" != "$1" ]]; then
    echo "FAIL: '$2' expected $1, got $got"
    fail=1
  fi
}

check ask   'git push origin master'
check ask   'git push origin "master"'
check ask   "git push origin 'HEAD:master'"
check ask   'git push origin HEAD:refs/heads/master'
check ask   'git push origin main:master'
check ask   'git push'
check allow 'git push origin feature'
check allow 'git push origin master:feature'
check ask   'git push -f origin feature'
check deny  'git push --force origin master'

((fail == 0)) && echo "guard-bash: all cases passed"
exit "$fail"
