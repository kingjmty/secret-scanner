#!/usr/bin/env bash
# scripts/pair-extraordinaire.sh — co-authored merged PR. Usage: ./pair-extraordinaire.sh "Name" "email@example.com"
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

NAME="${1:?Usage: pair-extraordinaire.sh \"Name\" \"email@example.com\"}"
EMAIL="${2:?Usage: pair-extraordinaire.sh \"Name\" \"email@example.com\"}"
TS="$(date +%Y%m%d-%H%M%S)"
BRANCH="pair/$TS"

echo "→ Creating branch $BRANCH..."
git checkout -b "$BRANCH"

mkdir -p .pair
echo "paired session at $TS with $NAME <$EMAIL>" > ".pair/$TS.txt"
git add ".pair/$TS.txt"

git commit -m "chore(pair): co-authored session ($TS)

Co-authored-by: $NAME <$EMAIL>"

echo "→ Pushing branch..."
git push -u origin "$BRANCH"

echo "→ Opening PR..."
PR_URL="$(gh pr create --repo "$REPO" \
  --title "chore(pair): co-authored session ($TS)" \
  --body "Co-authored session with $NAME <$EMAIL>, created at $TS." \
  --base main --head "$BRANCH")"
echo "✓ PR opened: $PR_URL"

echo "→ Merging..."
gh pr merge "$PR_URL" --squash --admin --delete-branch
echo "✓ Merged with co-author $NAME <$EMAIL>"

echo ""
echo "=== Pair Extraordinaire complete ==="
echo "Profile check: https://github.com/$(echo "$REPO" | cut -d/ -f1)"
echo "PR: $PR_URL"
