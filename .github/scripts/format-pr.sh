#!/usr/bin/env bash
# Format GitHub PR JSON into markdown matching `gh pr view --comments` output

set -eo pipefail

# Read JSON from stdin
json=$(cat)

# Extract fields
number=$(echo "$json" | jq -r '.number // ""')
title=$(echo "$json" | jq -r '.title // ""')
state=$(echo "$json" | jq -r '.state // ""')
author=$(echo "$json" | jq -r '.author.login // ""')
created_at=$(echo "$json" | jq -r '.createdAt // ""')
updated_at=$(echo "$json" | jq -r '.updatedAt // ""')
merged_at=$(echo "$json" | jq -r '.mergedAt // ""')
body=$(echo "$json" | jq -r '.body // ""')
url=$(echo "$json" | jq -r '.url // ""')
comments=$(echo "$json" | jq -r '.comments // []')
base_ref=$(echo "$json" | jq -r '.baseRefName // ""')
head_ref=$(echo "$json" | jq -r '.headRefName // ""')
assignees=$(echo "$json" | jq -r '.assignees[]?.login // empty' | tr '\n' ',' | sed 's/,$//')
labels=$(echo "$json" | jq -r '.labels[]?.name // empty' | tr '\n' ',' | sed 's/,$//')
reviews=$(echo "$json" | jq -r '.reviews // []')

# Calculate time ago (simplified)
time_ago() {
  if [[ -z "$1" || "$1" == "null" ]]; then
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

# Count comments and reviews
comment_count=$(echo "$comments" | jq 'length')
review_count=$(echo "$reviews" | jq 'length')

# Get time ago string (unused but kept for future use)
# shellcheck disable=SC2034
time_str=$(time_ago "$created_at")

# Determine state and symbol
state_upper=$(echo "$state" | tr '[:lower:]' '[:upper:]')
if [[ "$state_upper" == "MERGED" || (-n "$merged_at" && "$merged_at" != "null") ]]; then
  state_upper="MERGED"
  state_symbol="🔀"
elif [[ "$state_upper" == "CLOSED" ]]; then
  state_symbol="❌"
else
  state_symbol="🔵"
fi

# Get newest date (merged, updated, or created)
if [[ -n "$merged_at" && "$merged_at" != "null" ]]; then
  newest_date="$merged_at"
elif [[ -n "$updated_at" && "$updated_at" != "null" ]]; then
  newest_date="$updated_at"
else
  newest_date="$created_at"
fi
# Format date nicely (just date part)
newest_date_short=$(echo "$newest_date" | cut -d'T' -f1)

# Print YAML frontmatter FIRST (at top of file)
echo "---"
echo "labels:	${labels}"
echo "assignees:	${assignees}"
echo "reviewers:	"
echo "projects:	"
echo "milestone:	"
echo "number:	${number}"
echo "url:	${url}"
echo "createdAt:	${created_at}"
echo "updatedAt:	${updated_at}"
echo "mergedAt:	${merged_at}"
echo "baseRefName:	${base_ref}"
echo "headRefName:	${head_ref}"
echo "additions:	"
echo "deletions:	"
echo "auto-merge:	disabled"
echo "---"
echo ""

# Print title as heading with link
echo "# ${title}"
echo "${url}"
echo ""

# Print markdown table with most important fields
echo "| State | Date | Branch | Author | Assignees | Reviews | Comments |"
echo "|-------|------|--------|--------|-----------|---------|----------|"
echo "| ${state_symbol} ${state_upper} | ${newest_date_short} | ${head_ref} → ${base_ref} | ${author} | ${assignees} | ${review_count} | ${comment_count} |"
echo ""

# Print body
if [[ -n "$body" && "$body" != "null" ]]; then
  echo "$body"
  echo ""
fi

# Print reviews if any
if [[ $review_count -gt 0 ]]; then
  echo "$reviews" | jq -r '.[] | select(.body != null and .body != "") |
    "---\nauthor:	\(.author.login)\nassociation:	\(.authorAssociation | ascii_downcase)\nstate:	\(.state)\n---\n\n\(.body)\n"'
  echo ""
fi

# Print comments
if [[ $comment_count -gt 0 ]]; then
  echo "$comments" | jq -r '.[] |
    "---\nauthor:	\(.author.login)\nassociation:	\(.authorAssociation | ascii_downcase)\nedited:	false\n---\n\n\(.body)\n"'
  echo ""
fi
