#!/usr/bin/env bash
# scripts/unlock-all.sh — interactive menu, includes Full Blast option
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

echo ""
echo "=== Secret Scanner — Unlock Menu ==="
echo "1) Quickdraw       (open + close an issue)"
echo "2) Yolo             (branch + PR + merge without review)"
echo "3) Publicist        (v1.0.0 release)"
echo "4) Pull Shark       (choose 2 / 16 / 128 PRs)"
echo "5) Pair Extraordinaire (co-authored PR)"
echo "6) Full Blast       (run everything, in order)"
echo "0) Exit"
read -rp "Choose an option: " CHOICE

case "$CHOICE" in
  1) bash "$(dirname "$0")/quickdraw.sh" ;;
  2) bash "$(dirname "$0")/yolo.sh" ;;
  3) bash "$(dirname "$0")/publicist.sh" ;;
  4)
    read -rp "How many PRs? (2/16/128): " N
    bash "$(dirname "$0")/pull-shark.sh" "$N"
    ;;
  5)
    read -rp "Co-author name: " CN
    read -rp "Co-author email: " CE
    bash "$(dirname "$0")/pair-extraordinaire.sh" "$CN" "$CE"
    ;;
  6)
    echo "=== FULL BLAST — running all achievements ==="
    bash "$(dirname "$0")/quickdraw.sh"
    bash "$(dirname "$0")/yolo.sh"
    bash "$(dirname "$0")/publicist.sh"
    bash "$(dirname "$0")/pull-shark.sh" 2
    read -rp "Co-author name for pair session: " CN
    read -rp "Co-author email: " CE
    bash "$(dirname "$0")/pair-extraordinaire.sh" "$CN" "$CE"
    echo "=== FULL BLAST complete ==="
    ;;
  0) echo "Bye." ;;
  *) echo "Unknown option." ;;
esac
