#!/usr/bin/env bash
# scripts/quickdraw.sh — opens and closes a GitHub issue in under 5 minutes
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
TITLE="Quickdraw check — secret-scanner ($TS)"

echo "→ Opening issue..."
ISSUE_URL="$(gh issue create --repo "$REPO" \
  --title "$TITLE" \
  --body "Automated quickdraw issue created by scripts/quickdraw.sh at $TS. Verifying issue open/close flow for Secret Scanner.")"
echo "✓ Issue opened: $ISSUE_URL"

ISSUE_NUM="$(echo "$ISSUE_URL" | grep -oE '[0-9]+$')"

sleep 2

echo "→ Closing issue #$ISSUE_NUM..."
gh issue close "$ISSUE_NUM" --repo "$REPO" --comment "Closing as part of the quickdraw check — completed at $(date +%Y%m%d-%H%M%S)."
echo "✓ Issue #$ISSUE_NUM closed"

echo ""
echo "=== Quickdraw complete ==="
echo "Profile check: https://github.com/$(echo "$REPO" | cut -d/ -f1)"
echo "Issue: $ISSUE_URL"
