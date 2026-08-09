#!/usr/bin/env bash
# scripts/publicist.sh — creates a v1.0.0 GitHub Release
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

TAG="v1.0.0"

if git rev-parse "$TAG" >/dev/null 2>&1; then
  TS="$(date +%Y%m%d-%H%M%S)"
  TAG="v1.0.0-$TS"
  echo "⚠ v1.0.0 already exists locally, using $TAG instead"
fi

echo "→ Tagging $TAG..."
git tag -a "$TAG" -m "Release $TAG"
git push origin "$TAG"

echo "→ Creating GitHub Release..."
RELEASE_URL="$(gh release create "$TAG" --repo "$REPO" \
  --title "Secret Scanner $TAG" \
  --notes "First public release of Secret Scanner, created by scripts/publicist.sh.")"
echo "✓ Release created: $RELEASE_URL"

echo ""
echo "=== Publicist run complete ==="
echo "Profile check: https://github.com/$(echo "$REPO" | cut -d/ -f1)"
echo "Release: $RELEASE_URL"
