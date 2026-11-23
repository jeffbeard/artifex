#!/usr/bin/env bash
# Run one read-only Antigravity CLI (agy) review turn.
#
# Usage: agy_review.sh <prompt-file> <output-file> [conversation-id]
#
#   prompt-file      Review prompt (plain text).
#   output-file      Receives the reviewer's response text.
#   conversation-id  Optional. Resume this agy conversation (debate rounds).
#
# Side files go in a work/ directory beside output-file, named after it. When
# output-file is itself inside a directory named work, they sit next to it.
#   work/<output-name>.raw.jsonl  agy's event stream, appended while agy runs
#   work/<output-name>.stderr     agy stderr
#   work/<output-name>.session    Conversation id (for follow-ups)
#   work/<output-name>.cmd        Exact agy command line (REVIEW_DEBUG=1 only)
#   work/<output-name>.agy.log    agy's own log (REVIEW_DEBUG=1 only)
#   work/<output-name>.recover.*  Event stream and text of a recovery turn, if one ran
#
# Progress: while agy runs, stdout gets a line such as
#   [agy 40s] 31 events, last: tool read_file
# every ten seconds in which new events arrived. The .raw.jsonl file has the
# events themselves.
#
# Last stdout line is a status record:
#   reviewer=agy status=<ok|unavailable|timeout|failed> session=<id> model=<name> output=<path>
#     [duration=<n>s] [tokens=<n>] [partial=yes] [recovered=yes] [reason=...]
#
# partial=yes means the run did not finish but output-file holds the text agy
# had written so far. recovered=yes means agy hit its time limit before writing
# any finding, and the review came from one short follow-up turn in the same
# conversation: it is a review, but from exploration that was cut short.
# reason comes from agy's own finished_reason when it gave one.
#
# Exit codes: 0 ok, 2 usage, 124 timeout, 127 agy (or both jq and python3) not
# installed, 1 any other failure.
#
# Environment:
#   AGY_REVIEW_TIMEOUT  agy --print-timeout value (default 20m). The outer
#                       watchdog allows two minutes more.
#   AGY_REVIEW_MODEL    Model id to pass via --model (default: agy's configured model)
#   AGY_REVIEW_EFFORT   Reasoning effort to pass via --effort (default: agy's configured effort)
#   REVIEW_DEBUG        Set to 1 to keep the command line and agy's log (see above)
#
# Read-only by construction: --sandbox plus --mode plan (the write gate), and
# never --dangerously-skip-permissions. Run from the repo root so agy loads AGENTS.md.
# Needs jq or python3 to read agy's output. Verified against agy 1.5.15.

set -u

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "usage: $(basename "$0") <prompt-file> <output-file> [conversation-id]" >&2
  exit 2
fi

prompt_file=$1
output_file=$2
conversation_id=${3:-}
print_timeout=${AGY_REVIEW_TIMEOUT:-20m}
duration=""
tokens=""
partial=""
recovered=""

status_line() {
  # $1 status, $2 reason (optional)
  local line="reviewer=agy status=$1 session=${session:-} model=${model:-unknown} output=$output_file"
  [ -n "$duration" ] && line="$line duration=${duration}s"
  [ -n "$tokens" ] && line="$line tokens=$tokens"
  [ -n "$partial" ] && line="$line partial=yes"
  [ -n "$recovered" ] && line="$line recovered=yes"
  [ -n "${2:-}" ] && line="$line reason=$2"
  echo "$line"
}

json_field() {
  # $1 JSON file, $2 top-level key. Prints the string value or nothing.
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

stream_field() {
  # $1 event stream (one JSON object per line), $2 field. Prints the value or nothing.
  # Lines that are not JSON, such as a last line cut off by a kill, are skipped.
  #   conversation_id, status, finished_reason, error, response: from the result
  #     event (conversation_id falls back to the first event that carries one)
  #   tokens: total tokens from the result event
  #   partial: the text of the last agent_response step, joined from its deltas
  if command -v jq >/dev/null 2>&1; then
    jq -rRn --arg k "$2" '
      [inputs | fromjson? | select(type == "object")] as $e
      | (($e | map(select(.event == "result")) | last | .result) // {}) as $r
      | if $k == "conversation_id" then
          ($r.conversation_id
           // ($e | map(.conversation_id // .step_update.conversation_id // empty) | first)
           // empty)
        elif $k == "tokens" then ($r.usage.total_tokens // empty)
        elif $k == "partial" then
          ($e | map(select(.event == "step_update" and .step_update.step_type == "agent_response") | .step_update)) as $s
          | ($s | map(.step_index) | max) as $m
          | $s | map(select(.step_index == $m) | .text_delta // "") | join("")
        else ($r[$k] // empty) end' "$1" 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    python3 -I -c 'import json,sys
events = []
for line in open(sys.argv[1], errors="replace"):
    try:
        obj = json.loads(line)
    except Exception:
        continue
    if isinstance(obj, dict):
        events.append(obj)
key = sys.argv[2]
result = {}
for e in events:
    if e.get("event") == "result" and isinstance(e.get("result"), dict):
        result = e["result"]
out = None
if key == "conversation_id":
    out = result.get("conversation_id")
    if out is None:
        for e in events:
            su = e.get("step_update")
            out = e.get("conversation_id") or (su.get("conversation_id") if isinstance(su, dict) else None)
            if out:
                break
elif key == "tokens":
    usage = result.get("usage")
    out = usage.get("total_tokens") if isinstance(usage, dict) else None
elif key == "partial":
    steps = [e["step_update"] for e in events
             if e.get("event") == "step_update" and isinstance(e.get("step_update"), dict)
             and e["step_update"].get("step_type") == "agent_response"]
    if steps:
        last = max(s.get("step_index", 0) for s in steps)
        out = "".join(s.get("text_delta") or "" for s in steps if s.get("step_index", 0) == last)
else:
    out = result.get(key)
if out is not None:
    sys.stdout.write(str(out))' "$1" "$2" 2>/dev/null
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

if ! command -v jq >/dev/null 2>&1 && ! command -v python3 >/dev/null 2>&1; then
  model=n/a
  status_line unavailable "needs-jq-or-python3"
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

# stream-json, not json: events reach the raw file while agy works, so a caller
# can see progress, and text written before a timeout is not lost.
#
# --mode plan is the write gate. Verified on agy 1.5.15: headless agy with
# --sandbox alone creates files when asked, and with --mode plan the same
# write_file call is denied. Never drop it. --disable-slash-commands stops
# plan mode from also expanding /plan into planning instructions, which
# contradict a review prompt.
flags=(--output-format stream-json --sandbox --mode plan --disable-slash-commands)
[ -n "${AGY_REVIEW_MODEL:-}" ] && flags+=(--model "$AGY_REVIEW_MODEL")
[ -n "${AGY_REVIEW_EFFORT:-}" ] && flags+=(--effort "$AGY_REVIEW_EFFORT")
first_flags=("${flags[@]}" --print-timeout "$print_timeout")
[ -n "$conversation_id" ] && first_flags+=(--conversation "$conversation_id")
if [ "${REVIEW_DEBUG:-}" = 1 ]; then
  first_flags+=(--log-file "$side.agy.log")
  {
    printf 'cd %q\n' "$PWD"
    printf 'agy --print "$(cat %q)"' "$prompt_file"
    printf ' %q' "${first_flags[@]}"
    printf ' </dev/null\n'
  } > "$side.cmd"
fi

to_seconds() {
  case "$1" in
    *h) echo $(( ${1%h} * 3600 )) ;;
    *m) echo $(( ${1%m} * 60 )) ;;
    *s) echo "${1%s}" ;;
    *) echo "$1" ;;
  esac
}

run_agy() {
  # $1 prompt text, $2 event stream file, $3 watchdog seconds, then agy flags.
  # Sets rc to agy's exit status. Prints a progress line to stdout every ten
  # seconds in which new events arrived.
  local prompt=$1 stream=$2 limit=$3
  shift 3
  agy --print "$prompt" "$@" </dev/null >"$stream" 2>>"$err" &
  local agy_pid=$!
  # Outer watchdog: some agy versions hang without a TTY and ignore
  # --print-timeout. The traps are set before each sleep starts and end it with its subshell, so no timer
  # outlives this script and later signals a process that has reused agy's pid.
  (
    trap 'kill $(jobs -p) 2>/dev/null; exit 0' TERM
    sleep "$limit" &
    wait $!
    kill -TERM "$agy_pid" 2>/dev/null
  ) >/dev/null 2>&1 &
  local watchdog_pid=$!
  (
    seen=0
    trap 'kill $(jobs -p) 2>/dev/null; exit 0' TERM
    while kill -0 "$agy_pid" 2>/dev/null; do
      sleep 10 >/dev/null 2>&1 &
      wait $!
      count=$(wc -l < "$stream" 2>/dev/null | tr -d ' ')
      if [ "${count:-0}" != "$seen" ]; then
        seen=$count
        last=$(tail -n 1 "$stream" 2>/dev/null)
        step=$(printf '%s' "$last" | sed -n 's/.*"step_type":"\([a-z_]*\)".*/\1/p')
        tool=$(printf '%s' "$last" | sed -n 's/.*"tool_name":"\([a-z_]*\)".*/\1/p')
        echo "[agy ${SECONDS}s] $count events, last: ${step:-event}${tool:+ $tool}"
      fi
    done
  ) 2>/dev/null &
  local progress_pid=$!
  # If this script is itself stopped, take agy and both helpers down with it.
  trap 'kill "$agy_pid" "$watchdog_pid" "$progress_pid" 2>/dev/null; exit 143' TERM INT
  wait "$agy_pid"
  rc=$?
  trap - TERM INT
  kill "$watchdog_pid" "$progress_pid" 2>/dev/null
  wait "$watchdog_pid" "$progress_pid" 2>/dev/null
}

is_review() {
  # True when the file holds at least one finding block or the NO FINDINGS line.
  grep -qE '^(ID:|NO FINDINGS)' "$1" 2>/dev/null
}

: > "$err"
SECONDS=0
# Allow the inner timeout plus two minutes of slack.
guard=$(( $(to_seconds "$print_timeout") + 120 ))
run_agy "$(cat "$prompt_file")" "$raw" "$guard" "${first_flags[@]}"
duration=$SECONDS

found=$(stream_field "$raw" conversation_id)
[ -n "$found" ] && session=$found
[ -n "$session" ] && echo "$session" > "$side.session"

agy_status=$(stream_field "$raw" status)
finished=$(stream_field "$raw" finished_reason | tr -c 'A-Za-z0-9_.\n-' '_')
tokens=$(stream_field "$raw" tokens)

# The finished response if there is one, otherwise whatever agy had written.
stream_field "$raw" response > "$output_file"
grep -q '[^[:space:]]' "$output_file" 2>/dev/null || stream_field "$raw" partial > "$output_file"
# Whitespace-only responses count as empty.
grep -q '[^[:space:]]' "$output_file" 2>/dev/null || : > "$output_file"

fail() {
  # $1 status, $2 reason, $3 exit code. Text kept from an unfinished run is partial.
  [ -s "$output_file" ] && partial=yes
  status_line "$1" "$2"
  exit "$3"
}

if [ "$rc" -eq 143 ]; then
  fail timeout "killed-after-${guard}s" 124
fi

if [ "$finished" = print_timeout ]; then
  # agy ran out of time while still reading or thinking. What it worked out is
  # in the conversation, not in the output. On a first review turn, resume the
  # conversation once for a short turn with no tools and ask for the findings.
  if [ -z "$conversation_id" ] && [ -n "$session" ] && ! is_review "$output_file"; then
    echo "[agy ${SECONDS}s] print_timeout before any finding; resuming $session to collect findings"
    recover_raw="$side.recover.raw.jsonl"
    recover_out="$side.recover.txt"
    run_agy "Time limit reached. Do not read any more files or call any tools. Report now every finding you have identified so far, in the block format the review prompt asked for. If you have none, reply with the single line: NO FINDINGS" \
      "$recover_raw" 300 "${flags[@]}" --print-timeout 3m --conversation "$session"
    duration=$SECONDS
    stream_field "$recover_raw" response > "$recover_out"
    more=$(stream_field "$recover_raw" tokens)
    [ -n "$tokens" ] && [ -n "$more" ] && tokens=$(( tokens + more ))
    if [ "$rc" -eq 0 ] && is_review "$recover_out"; then
      cp "$recover_out" "$output_file"
      recovered=yes
      status_line ok print_timeout
      exit 0
    fi
  fi
  fail timeout print_timeout 124
fi

if [ "$rc" -ne 0 ]; then
  if grep -qiE 'timed? ?out|deadline' "$err" "$raw" 2>/dev/null; then
    fail timeout "${finished:-agy-exit-$rc}" 124
  fi
  fail failed "${finished:-agy-exit-$rc}" 1
fi

if [ ! -s "$output_file" ]; then
  if [ -s "$raw" ] && [ -z "$found" ]; then
    # Not an event stream: keep whatever agy printed.
    cp "$raw" "$output_file"
  elif grep -q '"denied_actions"' "$raw" 2>/dev/null; then
    # Headless agy auto-denies tools that need a permission prompt (shell
    # commands, and writes under --mode plan) and then prints nothing. The
    # prompt must tell agy to use file-reading tools only. Never fix this with
    # --dangerously-skip-permissions or by dropping --mode plan.
    status_line failed "tool-permission-denied-see-stderr"
    exit 1
  else
    status_line failed "empty-response-agy-status-${agy_status:-none}"
    exit 1
  fi
fi

if [ -n "$agy_status" ] && [ "$agy_status" != "SUCCESS" ]; then
  fail failed "${finished:-agy-status-$agy_status}" 1
fi

status_line ok
