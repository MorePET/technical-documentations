#!/usr/bin/env bash
# Format GitHub issue JSON into markdown matching `gh issue view --comments` output

set -eo pipefail

# Read JSON from stdin
json=$(cat)

# Extract fields
number=$(echo "$json" | jq -r '.number // ""')
title=$(echo "$json" | jq -r '.title // ""')
type=$(echo "$json" | jq -r '.type // ""')
state=$(echo "$json" | jq -r '.state // ""')
author=$(echo "$json" | jq -r '.author.login // ""')
created_at=$(echo "$json" | jq -r '.createdAt // ""')
updated_at=$(echo "$json" | jq -r '.updatedAt // ""')
body=$(echo "$json" | jq -r '.body // ""')
url=$(echo "$json" | jq -r '.url // ""')
comments=$(echo "$json" | jq -r '.comments // []')
assignees=$(echo "$json" | jq -r '.assignees[]?.login // empty' | tr '\n' ',' | sed 's/,$//')
labels=$(echo "$json" | jq -r '.labels[]?.name // empty' | tr '\n' ',' | sed 's/,$//')

# Calculate time ago (simplified)
time_ago() {
  if [[ -z "$1" ]]; then
    echo "unknown time"
    return
  fi

  created_ts=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$1" +%s 2>/dev/null || date -d "$1" +%s 2>/dev/null || echo "0")
  now_ts=$(date +%s)
  diff=$((now_ts - created_ts))

  days=$((diff / 86400))
  hours=$(((diff % 86400) / 3600))

  if [[ $days -gt 0 ]]; then
    if [[ $days -eq 1 ]]; then
      echo "about 1 day ago"
    else
      echo "about ${days} days ago"
    fi
  elif [[ $hours -gt 0 ]]; then
    if [[ $hours -eq 1 ]]; then
      echo "about 1 hour ago"
    else
      echo "about ${hours} hours ago"
    fi
  else
    echo "less than 1 hour ago"
  fi
}

# Count comments
comment_count=$(echo "$comments" | jq 'length')

# Get time ago string (unused but kept for future use)
# shellcheck disable=SC2034
time_str=$(time_ago "$created_at")

# Determine state symbol
state_upper=$(echo "$state" | tr '[:lower:]' '[:upper:]')
case "$state_upper" in
  "OPEN")
    state_symbol="🔵"
    ;;
  "CLOSED")
    state_symbol="✅"
    ;;
  *)
    state_symbol="◯"
    ;;
esac

# Get newest date (updated or created)
if [[ -n "$updated_at" && "$updated_at" != "null" ]]; then
  newest_date="$updated_at"
else
  newest_date="$created_at"
fi
# Format date nicely (just date part)
newest_date_short=$(echo "$newest_date" | cut -d'T' -f1)

# Print YAML frontmatter FIRST (at top of file)
echo "---"
echo "type:	${type}"
echo "labels:	${labels}"
echo "comments:	${comment_count}"
echo "assignees:	${assignees}"
echo "projects:	"
echo "milestone:	"
echo "number:	${number}"
echo "url:	${url}"
echo "createdAt:	${created_at}"
echo "updatedAt:	${updated_at}"
echo "---"
echo ""

# Print title as heading with link
echo "# ${title}"
echo "${url}"
echo ""

# Print markdown table with most important fields
echo "| State | Date | Type | Author | Assignees |"
echo "|-------|------|------|--------|-----------|"
echo "| ${state_symbol} ${state_upper} | ${newest_date_short} | ${type} | ${author} | ${assignees} |"
echo ""

# Print body
if [[ -n "$body" && "$body" != "null" ]]; then
  echo "$body"
  echo ""
fi

# Print comments (with separator)
if [[ $comment_count -gt 0 ]]; then
  echo "$comments" | jq -r '.[] |
    "---\nauthor:	\(.author.login)\nassociation:	\(.authorAssociation | ascii_downcase)\nedited:	false\nstatus:	none\n---\n\n\(.body)\n"'
  echo ""
fi
