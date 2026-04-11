#!/bin/bash

# Read all of stdin into a variable
input=$(cat)

# Extract fields with jq, "// 0" provides fallback for null
MODEL=$(echo "$input" | jq -r '.model.display_name')
CONTEXT_USAGE=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
OUTPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')

GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

function bar() {
  local PCT="$1"

  local COLOR=""
  if [ "$PCT" -lt 75 ]; then
    COLOR="$GREEN"
  elif [ "$PCT" -lt 90 ]; then
    COLOR="$YELLOW"
  else
    COLOR="$RED"
  fi

  # Build progress bar: printf -v creates a run of spaces, then
  # ${var// /▓} replaces each space with a block character
  BAR_WIDTH=10
  FILLED=$((PCT * BAR_WIDTH / 100))
  EMPTY=$((BAR_WIDTH - FILLED))
  BAR=""
  [ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="$COLOR${FILL// /▓}$RESET"
  [ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" && BAR="${BAR}${PAD// /░}"

  echo -e "$BAR $PCT%"
}

STATUS="$MODEL 󰆉 $(bar "$CONTEXT_USAGE") $INPUT_TOKENS $OUTPUT_TOKENS"
# "// empty" produces no output when rate_limits is absent
FIVE_H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
FIVE_H_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
WEEK=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
WEEK_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

LIMITS=""
[ -n "$FIVE_H" ] && LIMITS=" $(bar "$FIVE_H")${FIVE_H_RESET:+  $(date -d "@$FIVE_H_RESET" '+%I:%M%P')}"
[ -n "$WEEK" ] && LIMITS="${LIMITS:+$LIMITS | } $(bar "$WEEK")${WEEK_RESET:+  $(date -d "@$WEEK_RESET" '+%I:%M%P %A')}"

[ -n "$LIMITS" ] && STATUS="$STATUS\n$LIMITS"

STATUS="$STATUS \n ${DIR##*/}"

if git rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
  MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')

  GIT_STATUS=""
  [ "$STAGED" -gt 0 ] && GIT_STATUS="${GREEN}+${STAGED}${RESET}"
  [ "$MODIFIED" -gt 0 ] && GIT_STATUS="${GIT_STATUS}${YELLOW}~${MODIFIED}${RESET}"

  STATUS="$STATUS |  $BRANCH $GIT_STATUS"
fi

echo -e "$STATUS"
