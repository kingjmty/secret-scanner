#!/usr/bin/env bash
# scripts/yolo.sh — creates a branch, opens a PR, merges without review
set -euo pipefail

# --- gh auth check -----------------------------------------------------
if ! gh auth status >/dev/null 2>&1; then
  echo "✗ GitHub CLI is not authenticated."
  echo "  Fix it with: gh auth login"
  exit 1
fi

# --- repo auto-detect ----------------------------------------------------
REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)"
if [ -z "$REPO" ]; then
  echo "✗ Could not auto-detect the repo. Run this from inside a cloned GitHub repo."
  exit 1
fi
echo "→ Using repo: $REPO"

TS="$(date +%Y%m%d-%H%M%S)"
BRANCH="yolo/$TS"

echo "→ Creating branch $BRANCH..."
git checkout -b "$BRANCH"

echo "→ Recording a small change..."
mkdir -p .yolo
echo "yolo run at $TS" > ".yolo/$TS.txt"
git add ".yolo/$TS.txt"
git commit -m "chore(yolo): automated yolo commit ($TS)"

echo "→ Pushing branch..."
git push -u origin "$BRANCH"

echo "→ Opening PR..."
PR_URL="$(gh pr create --repo "$REPO" \
  --title "chore(yolo): automated yolo run ($TS)" \
  --body "Automated PR created by scripts/yolo.sh at $TS." \
  --base main --head "$BRANCH")"
echo "✓ PR opened: $PR_URL"

echo "→ Merging without review..."
gh pr merge "$PR_URL" --squash --admin --delete-branch
echo "✓ PR merged"

echo ""
echo "=== Yolo run complete ==="
echo "Profile check: https://github.com/$(echo "$REPO" | cut -d/ -f1)"
echo "PR: $PR_URL"
