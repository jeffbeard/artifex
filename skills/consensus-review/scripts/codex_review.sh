#!/usr/bin/env bash
# Run one read-only Codex CLI review turn.
#
# Usage: codex_review.sh <prompt-file> <output-file> [session-id]
#
#   prompt-file   Review prompt (plain text).
#   output-file   Receives the reviewer's final message.
#   session-id    Optional. Resume this Codex session (debate rounds).
#
# Side files go in a work/ directory beside output-file, named after it. When
# output-file is itself inside a directory named work, they sit next to it.
#   work/<output-name>.raw.jsonl  Full JSONL event stream from codex
#   work/<output-name>.stderr     codex stderr
#   work/<output-name>.session    Session (thread) id, for follow-ups
#
# Last stdout line is a status record:
#   reviewer=codex status=<ok|unavailable|timeout|failed> session=<id> model=<name> output=<path> [reason=...]
#
# Exit codes: 0 ok, 2 usage, 124 timeout, 127 codex not installed, 1 any other failure.
#
# Environment:
#   CODEX_REVIEW_TIMEOUT  Seconds before the run is killed (default 600)
#   CODEX_REVIEW_MODEL    Model to pass via -m (default: codex's configured model)
#
# Uses `codex exec`, not `codex review`: `codex review --uncommitted|--base`
# rejects a custom prompt, so it cannot produce the shared finding format, and
# the debate round needs a resumable session.
# Read-only by construction: sandbox read-only, never an approval-bypass flag.
# Run from the repo root so codex loads AGENTS.md. Verified against codex-cli 0.171.0.

set -u

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "usage: $(basename "$0") <prompt-file> <output-file> [session-id]" >&2
  exit 2
fi

prompt_file=$1
output_file=$2
session=${3:-}
guard=${CODEX_REVIEW_TIMEOUT:-600}

model=${CODEX_REVIEW_MODEL:-}
if [ -z "$model" ] && [ -f "${CODEX_HOME:-$HOME/.codex}/config.toml" ]; then
  model=$(sed -n 's/^model[[:space:]]*=[[:space:]]*"\(.*\)".*/\1/p' "${CODEX_HOME:-$HOME/.codex}/config.toml" | head -n 1)
fi
model=${model:-default}

status_line() {
  local line="reviewer=codex status=$1 session=${session:-} model=$model output=$output_file"
  [ -n "${2:-}" ] && line="$line reason=$2"
  echo "$line"
}

if [ ! -r "$prompt_file" ]; then
  status_line failed "prompt-file-unreadable"
  exit 1
fi

if ! command -v codex >/dev/null 2>&1; then
  model=n/a
  status_line unavailable "codex-not-on-PATH"
  exit 127
fi

out_dir=$(dirname "$output_file")
side_dir=$out_dir
[ "$(basename "$out_dir")" = work ] || side_dir="$out_dir/work"
mkdir -p "$side_dir"
side="$side_dir/$(basename "$output_file")"
raw="$side.raw.jsonl"
err="$side.stderr"
: > "$output_file"

if [ -n "$session" ]; then
  # `exec resume` has no -s flag; set the sandbox through config.
  args=(exec resume "$session" - -c 'sandbox_mode="read-only"' --json -o "$output_file")
else
  args=(exec -s read-only --json -o "$output_file" -)
fi
[ -n "${CODEX_REVIEW_MODEL:-}" ] && args+=(-m "$CODEX_REVIEW_MODEL")

codex "${args[@]}" <"$prompt_file" >"$raw" 2>"$err" &
codex_pid=$!
( sleep "$guard"; kill -TERM "$codex_pid" 2>/dev/null ) >/dev/null 2>&1 &
watchdog_pid=$!
wait "$codex_pid"
rc=$?
kill "$watchdog_pid" 2>/dev/null
wait "$watchdog_pid" 2>/dev/null

found=$(sed -n 's/.*"type":"thread.started","thread_id":"\([^"]*\)".*/\1/p' "$raw" | head -n 1)
[ -n "$found" ] && session=$found
[ -n "$session" ] && echo "$session" > "$side.session"

if [ "$rc" -eq 143 ]; then
  status_line timeout "killed-after-${guard}s"
  exit 124
fi

if [ "$rc" -ne 0 ]; then
  status_line failed "codex-exit-$rc"
  exit 1
fi

if [ ! -s "$output_file" ]; then
  status_line failed "empty-response"
  exit 1
fi

status_line ok
