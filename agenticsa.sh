#!/usr/bin/env bash
set -euo pipefail

ANALYZER_CMD=("your-static-analyzer" "--format" "text")  # customize
MAX_PASSES="${MAX_PASSES:-3}"

# Ensure we are in a git repo (Codex safety requirement unless you bypass explicitly).
git rev-parse --is-inside-work-tree >/dev/null  2>&1 || { echo "Not inside a git repository. Exiting."; exit 1; }
