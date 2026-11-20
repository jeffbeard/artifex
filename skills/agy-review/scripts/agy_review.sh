#!/usr/bin/env bash
# Run one read-only Antigravity CLI (agy) review turn.
#
# Usage: agy_review.sh <prompt-file> <output-file> [conversation-id]
#
#   prompt-file      Review prompt (plain text).
#   output-file      Receives the reviewer's response text.
#   conversation-id  Optional. Resume this agy conversation (debate rounds).
#
# Side files written next to output-file:
#   <output-file>.raw.json   Full JSON from agy
#   <output-file>.stderr     agy stderr
#   <output-file>.session    Conversation id (for follow-ups)
#
# Last stdout line is a status record:
#   reviewer=agy status=<ok|unavailable|timeout|failed> session=<id> model=<name> output=<path> [reason=...]
#
# Exit codes: 0 ok, 2 usage, 124 timeout, 127 agy not installed, 1 any other failure.
#
# Environment:
#   AGY_REVIEW_TIMEOUT  agy --print-timeout value (default 10m)
#   AGY_REVIEW_MODEL    Model id to pass via --model (default: agy's configured model)
#
# Read-only by construction: --sandbox plus --mode plan, and never
# --dangerously-skip-permissions. Run from the repo root so agy loads AGENTS.md.
# Verified against agy 1.5.13.

set -u

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "usage: $(basename "$0") <prompt-file> <output-file> [conversation-id]" >&2
  exit 2
fi

prompt_file=$1
output_file=$2
conversation_id=${3:-}
print_timeout=${AGY_REVIEW_TIMEOUT:-10m}

status_line() {
  # $1 status, $2 reason (optional)
  local line="reviewer=agy status=$1 session=${session:-} model=${model:-unknown} output=$output_file"
  [ -n "${2:-}" ] && line="$line reason=$2"
  echo "$line"
}

json_field() {
  # $1 file, $2 top-level key. Prints the string value or nothing.
  if command -v jq >/dev/null 2>&1; then
    jq -r --arg k "$2" '.[$k] // empty' "$1" 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    python3 -I -c 'import json,sys
try:
    v = json.load(open(sys.argv[1])).get(sys.argv[2])
except Exception:
    v = None
if v is not None:
    sys.stdout.write(str(v))' "$1" "$2" 2>/dev/null
  fi
}

session=$conversation_id
model=${AGY_REVIEW_MODEL:-}
if [ -z "$model" ]; then
  settings="$HOME/.gemini/antigravity-cli/settings.json"
  [ -f "$settings" ] && model=$(json_field "$settings" model | tr ' ' '_')
fi
model=${model:-default}

if [ ! -r "$prompt_file" ]; then
  status_line failed "prompt-file-unreadable"
  exit 1
fi

if ! command -v agy >/dev/null 2>&1; then
  model=n/a
  status_line unavailable "agy-not-on-PATH"
  exit 127
fi

mkdir -p "$(dirname "$output_file")"
raw="$output_file.raw.json"
err="$output_file.stderr"
: > "$output_file"

args=(--print "$(cat "$prompt_file")" --output-format json --sandbox --mode plan --print-timeout "$print_timeout")
[ -n "${AGY_REVIEW_MODEL:-}" ] && args+=(--model "$AGY_REVIEW_MODEL")
[ -n "$conversation_id" ] && args+=(--conversation "$conversation_id")

# Outer watchdog: some agy versions hang without a TTY and ignore --print-timeout.
# Allow the inner timeout plus two minutes of slack.
to_seconds() {
  case "$1" in
    *h) echo $(( ${1%h} * 3600 )) ;;
    *m) echo $(( ${1%m} * 60 )) ;;
    *s) echo "${1%s}" ;;
    *) echo "$1" ;;
  esac
}
guard=$(( $(to_seconds "$print_timeout") + 120 ))

agy "${args[@]}" </dev/null >"$raw" 2>"$err" &
agy_pid=$!
( sleep "$guard"; kill -TERM "$agy_pid" 2>/dev/null ) >/dev/null 2>&1 &
watchdog_pid=$!
wait "$agy_pid"
rc=$?
kill "$watchdog_pid" 2>/dev/null
wait "$watchdog_pid" 2>/dev/null

if [ "$rc" -eq 143 ]; then
  status_line timeout "killed-after-${guard}s"
  exit 124
fi

found=$(json_field "$raw" conversation_id)
[ -n "$found" ] && session=$found
[ -n "$session" ] && echo "$session" > "$output_file.session"

agy_status=$(json_field "$raw" status)
json_field "$raw" response > "$output_file"
# Whitespace-only responses count as empty.
grep -q '[^[:space:]]' "$output_file" 2>/dev/null || : > "$output_file"

if [ "$rc" -ne 0 ]; then
  if grep -qiE 'timed? ?out|deadline' "$err" "$raw" 2>/dev/null; then
    status_line timeout "agy-exit-$rc"
    exit 124
  fi
  status_line failed "agy-exit-$rc"
  exit 1
fi

if [ ! -s "$output_file" ]; then
  # Not JSON, or JSON without a response: keep whatever agy printed.
  if [ -s "$raw" ] && [ -z "$agy_status" ]; then
    cp "$raw" "$output_file"
  elif grep -q '"denied_actions"' "$raw" 2>/dev/null; then
    # Headless agy auto-denies tools that need a permission prompt (shell
    # commands) and then prints nothing. The prompt must tell agy to use
    # file-reading tools only. Never fix this with --dangerously-skip-permissions.
    status_line failed "tool-permission-denied-see-stderr"
    exit 1
  else
    status_line failed "empty-response-agy-status-${agy_status:-none}"
    exit 1
  fi
fi

if [ -n "$agy_status" ] && [ "$agy_status" != "SUCCESS" ]; then
  status_line failed "agy-status-$agy_status"
  exit 1
fi

status_line ok
