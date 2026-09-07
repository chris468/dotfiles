#!/usr/bin/env bash
# Render GitHub issues as an ASCII dependency tree, rooted at issues that
# have no open blockers of their own -- including issues with no
# dependency relationship at all, which are shown as standalone roots.
# Open issues with an open linked PR are shown as in-work.
# Closed issues are hidden by default; pass --all to include them.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: show-github-issue-dependencies.sh [--root NUMBER] [--all] [--no-color]

Fetches every issue's blocked_by relationships via GitHub's issue
dependencies API and prints the resulting DAG as an indented tree, in the
order work can be done: roots are issues with no open blockers (workable
now) -- including issues with no dependency relationship at all, which
appear as standalone roots -- and each issue's children are the issues it
blocks (workable once it's done). Read top-to-bottom, depth-first, to get
a valid work order.

An issue blocked by more than one thing appears once in full under its
first parent (numeric root order, then child order) and as a stub
"(already shown above)" line under any later parent, so diamonds don't get
re-expanded.

Open issues with one or more open pull requests linked via "Closes #N" (or
similar) are shown as [in-work] instead of [open].

By default, closed issues are left out of the tree entirely (including as
blockers), which can turn issues that were only blocked by a closed issue
into roots. Pass --all to include closed issues.

Options:
  --root NUMBER   Only render the subtree rooted at issue NUMBER, ignoring
                   whether that issue itself has blockers.
  --all           Include closed issues in the tree (default: omitted).
  --no-color      Disable ANSI coloring (auto-disabled when stdout is not
                   a TTY).
  -h, --help      Show this help.
EOF
}

ROOT_FILTER=""
USE_COLOR=1
[[ -t 1 ]] || USE_COLOR=0
SHOW_ALL=0

while [[ $# -gt 0 ]]; do
  case "$1" in
  --root)
    ROOT_FILTER="${2:?--root requires an issue number}"
    shift 2
    ;;
  --all)
    SHOW_ALL=1
    shift
    ;;
  --no-color)
    USE_COLOR=0
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown argument: $1" >&2
    usage >&2
    exit 1
    ;;
  esac
done

if [[ -n "$ROOT_FILTER" && ! "$ROOT_FILTER" =~ ^[0-9]+$ ]]; then
  echo "--root must be an issue number" >&2
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
DB="$TMPDIR/db.json"

echo "Fetching issues from $REPO..." >&2
gh api --paginate -H "Accept: application/vnd.github+json" \
  "/repos/$REPO/issues?state=all&per_page=100" |
  jq -s '
        add
        | map(select(.pull_request == null))
        | map({
            number,
            title,
            state,
            blocked_by: .issue_dependencies_summary.total_blocked_by
          })
      ' >"$TMPDIR/issues.json"

declare TOTAL
if [[ $SHOW_ALL == 1 ]]; then
  TOTAL=$(jq 'length' "$TMPDIR/issues.json")
else
  TOTAL=$(jq 'map(select(.state != "closed")) | length' "$TMPDIR/issues.json")
fi

: >"$TMPDIR/blocked_by.jsonl"
while read -r n; do
  [[ -z "$n" ]] && continue
  echo "  looking up blockers for #$n..." >&2
  gh api -H "Accept: application/vnd.github+json" \
    "/repos/$REPO/issues/$n/dependencies/blocked_by" |
    jq -c --arg n "$n" '{number: ($n | tonumber), blockers: [.[].number]}' \
      >>"$TMPDIR/blocked_by.jsonl"
done < <(jq -r '.[] | select(.blocked_by > 0 and .state != "closed") | .number' "$TMPDIR/issues.json")

OWNER="${REPO%%/*}"
NAME="${REPO#*/}"

: >"$TMPDIR/pr_state.jsonl"
mapfile -t OPEN_NUMS < <(jq -r '.[] | select(.state == "open") | .number' "$TMPDIR/issues.json")
if [[ ${#OPEN_NUMS[@]} -gt 0 ]]; then
  echo "Checking linked PR status for ${#OPEN_NUMS[@]} open issue(s)..." >&2
  CHUNK_SIZE=50
  for ((i = 0; i < ${#OPEN_NUMS[@]}; i += CHUNK_SIZE)); do
    chunk=("${OPEN_NUMS[@]:i:CHUNK_SIZE}")
    query="query(\$owner: String!, \$repo: String!) { repository(owner: \$owner, name: \$repo) {"
    for idx in "${!chunk[@]}"; do
      query+=" i${idx}: issue(number: ${chunk[idx]}) { number closedByPullRequestsReferences(includeClosedPrs: true, first: 25) { nodes { state } } }"
    done
    query+=" } }"
    gh api graphql -f query="$query" -f owner="$OWNER" -f repo="$NAME" |
      jq -c '.data.repository[] | {number, in_work: ((.closedByPullRequestsReferences.nodes // []) | any(.state == "OPEN"))}' \
        >>"$TMPDIR/pr_state.jsonl"
  done
fi

jq -n \
  --slurpfile issues "$TMPDIR/issues.json" \
  --slurpfile deps <(jq -s '.' "$TMPDIR/blocked_by.jsonl") \
  --slurpfile prstates <(jq -s '.' "$TMPDIR/pr_state.jsonl") \
  --argjson show_all "$([[ "$SHOW_ALL" == 1 ]] && echo true || echo false)" \
  '
    ($issues[0]) as $issues
    | ($deps[0] // []) as $deps
    | ($prstates[0] // [] | map({(.number | tostring): .in_work}) | add // {}) as $in_work
    | ($issues | map({(.number | tostring): .state}) | add // {}) as $states
    | (
        if $show_all then $deps
        else
            $deps
            | map(select($states[(.number | tostring)] != "closed"))
            | map(.blockers |= [.[] | select($states[(. | tostring)] != "closed")])
        end
      ) as $deps_f
    | {
        nodes: (
          $issues
          | map({
              (.number | tostring): {
                title,
                state,
                in_work: ($in_work[(.number | tostring)] // false)
              }
            })
          | add // {}
        ),
        blocked_by: ($deps_f | map({(.number | tostring): .blockers}) | add // {}),
        blocking: (
            [$deps_f[] | .blockers[] as $b | {blocker: $b, blocked: .number}]
            | group_by(.blocker)
            | map({(.[0].blocker | tostring): (map(.blocked) | sort)})
            | add // {}
        )
      }
    ' >"$DB"

declare -A shown

node_info() {
  jq -r --arg n "$1" '
        .nodes[$n] as $meta
        | [
            ($meta.title // "(unknown title)"),
            ($meta.state // "unknown"),
            (($meta.in_work // false) | tostring),
            ((.blocking[$n] // []) | sort | join(","))
          ] | @tsv
    ' "$DB"
}

print_node() {
  local num="$1" line_prefix="$2" title="$3" state="$4" in_work="$5"
  local label="$state"
  [[ "$state" == "open" && "$in_work" == "true" ]] && label="in-work"

  if [[ "$USE_COLOR" == 1 && "$state" == "closed" ]]; then
    printf '%s#%s %s \033[2m[%s]\033[0m\n' "$line_prefix" "$num" "$title" "$label"
  elif [[ "$USE_COLOR" == 1 && "$label" == "in-work" ]]; then
    printf '%s#%s %s \033[33m[%s]\033[0m\n' "$line_prefix" "$num" "$title" "$label"
  elif [[ "$USE_COLOR" == 1 ]]; then
    printf '%s#%s %s \033[32m[%s]\033[0m\n' "$line_prefix" "$num" "$title" "$label"
  else
    printf '%s#%s %s [%s]\n' "$line_prefix" "$num" "$title" "$label"
  fi
}

walk() {
  local num="$1" prefix="$2" is_last="$3" is_root="$4"
  local connector="" child_prefix="$prefix"

  if [[ "$is_root" != 1 ]]; then
    if [[ "$is_last" == 1 ]]; then
      connector="└── "
      child_prefix="${prefix}    "
    else
      connector="├── "
      child_prefix="${prefix}│   "
    fi
  fi

  local title state in_work children_csv
  IFS=$'\t' read -r title state in_work children_csv < <(node_info "$num")

  if [[ -n "${shown[$num]:-}" ]]; then
    print_node "$num" "${prefix}${connector}" "$title" "$state" "$in_work"
    printf '%s(already shown above)\n' "$child_prefix"
    return
  fi
  shown[$num]=1
  print_node "$num" "${prefix}${connector}" "$title" "$state" "$in_work"

  [[ -z "$children_csv" ]] && return

  local children=()
  IFS=',' read -r -a children <<<"$children_csv"
  local last_idx=$((${#children[@]} - 1)) i child_is_last
  for i in "${!children[@]}"; do
    child_is_last=0
    [[ "$i" == "$last_idx" ]] && child_is_last=1
    walk "${children[$i]}" "$child_prefix" "$child_is_last" 0
  done
}

roots=()
if [[ -n "$ROOT_FILTER" ]]; then
  roots=("$ROOT_FILTER")
else
  while read -r r; do
    roots+=("$r")
  done < <(jq -r --argjson show_all "$([[ "$SHOW_ALL" == 1 ]] && echo true || echo false)" '
        (.nodes | to_entries | map(select($show_all or .value.state != "closed")) | map(.key)) as $all
        | (.blocked_by | with_entries(select(.value | length > 0)) | keys) as $blocked
        | ($all - $blocked) | map(tonumber) | sort | .[]
    ' "$DB")
fi

if [[ ${#roots[@]} -eq 0 ]]; then
  echo "No dependency relationships found." >&2
  exit 0
fi

echo "Legend: [open] pending, [in-work] open with an open PR, [closed] done (dim). Top-to-bottom = work order: children are unblocked once their parent is done."
[[ "$SHOW_ALL" == 1 ]] || echo "(closed issues hidden; pass --all to include them)"
echo
for r in "${roots[@]}"; do
  walk "$r" "" 0 1
done

if [[ -z "$ROOT_FILTER" ]]; then
  PARTICIPANTS=$(jq '
        (.blocked_by | keys) as $blocked
        | (.blocking | keys) as $blockers
        | (($blocked + $blockers) | unique) | length
    ' "$DB")
  echo
  declare KIND
  if [[ "$SHOW_ALL" == 1 ]]; then
    KIND=""
  else
    KIND=" open"
  fi
  echo "$PARTICIPANTS of $TOTAL$KIND issues have a blocked_by/blocking relationship; the rest appear above as standalone roots." >&2
fi
