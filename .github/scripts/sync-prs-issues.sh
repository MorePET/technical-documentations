#!/usr/bin/env bash
set -eo pipefail

# Check if gh CLI is available and authenticated
if ! command -v gh >/dev/null 2>&1; then
  echo "⚠️  GitHub CLI (gh) not found. Skipping sync."
  exit 0
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "⚠️  GitHub CLI not authenticated. Skipping sync."
  echo "   Run 'gh auth login' to enable GitHub data sync."
  exit 0
fi

# Check if jq is available
if ! command -v jq >/dev/null 2>&1; then
  echo "⚠️  jq not found. Skipping sync."
  exit 0
fi

# Create directories
mkdir -p .github_data/issues
mkdir -p .github_data/prs

echo "📥 Checking for new/updated issues..."
updated_count=0

# Get script directory for formatter
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

gh issue list --state all --json number,updatedAt 2>/dev/null | jq -r '.[] | "\(.number)|\(.updatedAt)"' 2>/dev/null | while IFS='|' read -r num updated || [ -n "${num:-}" ]; do
  # Skip if num or updated is empty
  if [[ -z "${num:-}" ]] || [[ -z "${updated:-}" ]]; then
    continue
  fi

  file=".github_data/issues/${num}.md"

  # Fetch if file doesn't exist, is empty, or needs update
  if [[ ! -f "$file" ]] || [[ ! -s "$file" ]]; then
    echo "  ✓ Issue #${num} (new or empty)"
    # Use gh CLI for most fields, but fetch type from REST API
    gh_data=$(gh issue view "$num" --json number,title,state,author,createdAt,updatedAt,body,comments,assignees,labels,url 2>/dev/null)
    # Get repo name
    repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
    # Fetch type from REST API and merge it in
    type_data=$(curl -s -H "Authorization: token $(gh auth token 2>/dev/null)" -H "Accept: application/vnd.github+json" "https://api.github.com/repos/${repo}/issues/${num}" 2>/dev/null | jq -r '.type.name // ""')
    # Add type to JSON and format
    echo "$gh_data" | jq --arg type "$type_data" '. + {type: $type}' | bash "$SCRIPT_DIR/format-issue.sh" > "$file" 2>/dev/null || true
    ((updated_count++)) || true
  else
    # Get file modification time and compare (simple check: if file is old, update)
    file_time=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null || echo "0")
    github_time=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$updated" +%s 2>/dev/null || date -d "$updated" +%s 2>/dev/null || echo "0")

    if [[ "${github_time:-0}" -gt "${file_time:-0}" ]]; then
      echo "  ✓ Issue #${num} (updated)"
      # Use gh CLI for most fields, but fetch type from REST API
      gh_data=$(gh issue view "$num" --json number,title,state,author,createdAt,updatedAt,body,comments,assignees,labels,url 2>/dev/null)
      # Get repo name
      repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
      # Fetch type from REST API and merge it in
      type_data=$(curl -s -H "Authorization: token $(gh auth token 2>/dev/null)" -H "Accept: application/vnd.github+json" "https://api.github.com/repos/${repo}/issues/${num}" 2>/dev/null | jq -r '.type.name // ""')
      # Add type to JSON and format
      echo "$gh_data" | jq --arg type "$type_data" '. + {type: $type}' | bash "$SCRIPT_DIR/format-issue.sh" > "$file" 2>/dev/null || true
      ((updated_count++)) || true
    fi
  fi
done

echo "📥 Checking for new/updated PRs..."
gh pr list --state all --json number,updatedAt 2>/dev/null | jq -r '.[] | "\(.number)|\(.updatedAt)"' 2>/dev/null | while IFS='|' read -r num updated || [ -n "${num:-}" ]; do
  # Skip if num or updated is empty
  if [[ -z "${num:-}" ]] || [[ -z "${updated:-}" ]]; then
    continue
  fi

  file=".github_data/prs/${num}.md"

  # Fetch if file doesn't exist, is empty, or needs update
  if [[ ! -f "$file" ]] || [[ ! -s "$file" ]]; then
    echo "  ✓ PR #${num} (new or empty)"
    gh pr view "$num" --json number,title,state,author,createdAt,updatedAt,mergedAt,body,comments,assignees,labels,url,baseRefName,headRefName,reviews 2>/dev/null | bash "$SCRIPT_DIR/format-pr.sh" > "$file" 2>/dev/null || true
    ((updated_count++)) || true
  else
    file_time=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null || echo "0")
    github_time=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$updated" +%s 2>/dev/null || date -d "$updated" +%s 2>/dev/null || echo "0")

    if [[ "${github_time:-0}" -gt "${file_time:-0}" ]]; then
      echo "  ✓ PR #${num} (updated)"
      gh pr view "$num" --json number,title,state,author,createdAt,updatedAt,mergedAt,body,comments,assignees,labels,url,baseRefName,headRefName,reviews 2>/dev/null | bash "$SCRIPT_DIR/format-pr.sh" > "$file" 2>/dev/null || true
      ((updated_count++)) || true
    fi
  fi
done

echo "✅ Sync complete! (Only fetched new/updated items)"
