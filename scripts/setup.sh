#!/usr/bin/env bash
# scripts/setup.sh — checks dependencies and makes scripts executable
set -euo pipefail

echo "=== Secret Scanner setup ==="

# --- Node check ------------------------------------------------------------
if ! command -v node >/dev/null 2>&1; then
  echo "✗ Node.js is not installed. Install Node 18+ from https://nodejs.org"
  exit 1
fi
NODE_MAJOR="$(node -v | sed 's/v//' | cut -d. -f1)"
if [ "$NODE_MAJOR" -lt 18 ]; then
  echo "✗ Node 18+ required, found $(node -v)."
  exit 1
fi
echo "✓ Node $(node -v)"

# --- gh CLI check ------------------------------------------------------------
if ! command -v gh >/dev/null 2>&1; then
  echo "✗ GitHub CLI (gh) is not installed."
  echo "  Install: https://cli.github.com"
  exit 1
fi
echo "✓ gh $(gh --version | head -n1)"

if gh auth status >/dev/null 2>&1; then
  echo "✓ gh is authenticated"
else
  echo "⚠ gh is not authenticated yet. Run: gh auth login"
fi

# --- npm install ------------------------------------------------------------
if [ -f package.json ]; then
  echo "→ Installing npm dependencies..."
  npm install --no-audit --no-fund || echo "⚠ npm install had issues, continuing"
fi

# --- make scripts executable -------------------------------------------------
chmod +x scripts/*.sh 2>/dev/null || true
echo "✓ scripts/*.sh are executable"

echo "=== setup complete ==="
echo "Next: bash scripts/unlock-all.sh"
