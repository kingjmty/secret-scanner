#!/usr/bin/env bash
# scripts/pull-shark.sh — opens and merges N PRs. 2=Bronze, 16=Silver, 128=Gold
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

COUNT="${1:-2}"

case "$COUNT" in
  2) TIER="Bronze" ;;
  16) TIER="Silver" ;;
  128) TIER="Gold" ;;
  *) TIER="Custom ($COUNT)" ;;
esac

echo "→ Running Pull Shark batch: $COUNT PRs ($TIER tier)"

for i in $(seq 1 "$COUNT"); do
  TS="$(date +%Y%m%d-%H%M%S)"
  BRANCH="pull-shark/$TS-$i"
  git checkout -b "$BRANCH" main 2>/dev/null || git checkout -b "$BRANCH"
  mkdir -p .pull-shark
  echo "pull shark #$i at $TS" > ".pull-shark/$TS-$i.txt"
  git add ".pull-shark/$TS-$i.txt"
  git commit -m "chore(pull-shark): entry $i/$COUNT ($TS)"
  git push -u origin "$BRANCH"

  PR_URL="$(gh pr create --repo "$REPO" \
    --title "chore(pull-shark): entry $i/$COUNT" \
    --body "Automated Pull Shark entry $i of $COUNT, created at $TS." \
    --base main --head "$BRANCH")"

  gh pr merge "$PR_URL" --squash --admin --delete-branch
  echo "✓ [$i/$COUNT] merged: $PR_URL"

  git checkout main
  git pull origin main --quiet
done

echo ""
echo "=== Pull Shark ($TIER) complete: $COUNT PRs merged ==="
echo "Profile check: https://github.com/$(echo "$REPO" | cut -d/ -f1)"
