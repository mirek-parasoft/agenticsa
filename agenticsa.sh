#!/usr/bin/env bash
set -euo pipefail

ANALYZER_CMD=("cpptestcli" "-fail" "-compiler" "gcc_13-64" "-config" "MISRA C++ and CERT.properties" "-report" "reports" "-exclude" "*/.build/*" "-exclude" "*/*_test.*" "-module" "." "-input" ".build/compile_commands.json")  # customize
MAX_PASSES="${MAX_PASSES:-1}"

# Ensure we are in a git repo (Codex safety requirement unless you bypass explicitly).
git rev-parse --is-inside-work-tree >/dev/null  2>&1 || { echo "Not inside a git repository. Exiting."; exit 1; }

# Ensure clean start
rm -fr reports
mkdir -p reports

# Function to run the analysis
run_analysis() {
  local out_file="$1"
  # Capture all output; preserve exit code
  set +e
  echo Running analysis with command:
  echo "${ANALYZER_CMD[@]}" 
  "${ANALYZER_CMD[@]}" > "$out_file" 2>&1
  local ec=$?
  set -e
  return "$ec"
}

for pass in $(seq 1 "$MAX_PASSES"); do
  echo "== Static analysis pass $pass/$MAX_PASSES ==" >&2

  report="$(mktemp)"
  if run_analysis "$report"; then
    echo "No violations found." >&2
    exit 0
  fi

  echo "Violations detected; invoking Codex..." >&2

  prompt_file="$(mktemp)"
  {
    echo "Please pull the C/C++test violations using the dedicated mcp tool."
    echo "Use available mcp tools to understand violated static analysis rules."
    echo "Your task is to edit the files with problems and fix all violations reported by C/C++test."
    echo "Do not attempt to build, run the project or run C/C++test static analysis!" 
    echo "Make the smallest changes possible to fix the reported violations."
    echo ""
  } > "$prompt_file"

  # Run Codex with write access to the workspace.
  # --full-auto is a convenience preset; you can use --sandbox workspace-write explicitly.
  codex exec --full-auto --sandbox workspace-write "$(cat "$prompt_file")"
  #rm -f "$report" "$prompt_file"
done

echo "Violations still present after $MAX_PASSES Codex passes." >&2
exit 1