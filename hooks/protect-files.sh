#!/usr/bin/env bash
# Protected File Guard
# Blocks edits to sensitive or auto-generated files
# Reference: CLAUDE.md (security principles - project root)

set -euo pipefail

# Protected files list
PROTECTED_FILES=(
  "package-lock.json"
  "yarn.lock"
  "pnpm-lock.yaml"
  "bun.lockb"
  "poetry.lock"
  "Cargo.lock"
  "Gemfile.lock"
  ".env"
  ".env.local"
  ".env.production"
)

# Protected directories
PROTECTED_DIRS=(
  ".git/"
  "node_modules/"
  "__pycache__/"
  ".venv/"
  "venv/"
  "dist/"
  "build/"
)

# Read JSON input from stdin
input=$(cat)

# Parse file path from JSON
if command -v jq &> /dev/null; then
  file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
else
  # Fallback parsing without jq
  file_path=$(echo "$input" | grep -oP '"file_path"\s*:\s*"\K[^"]+' || echo "")
fi

# Exit if no file path
[[ -z "$file_path" ]] && exit 0

filename=$(basename "$file_path")

# Check if file is in protected list
for protected_file in "${PROTECTED_FILES[@]}"; do
  if [[ "$filename" == "$protected_file" ]]; then
    reason="Protected file: ${filename} (auto-generated, do not edit manually)"

    # Output JSON for hook system
    cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"${reason}"}}
EOF

    # Output error to stderr
    echo -e "\n❌ BLOCKED: ${reason}\n" >&2

    exit 2
  fi
done

# Check if file is in protected directory
for protected_dir in "${PROTECTED_DIRS[@]}"; do
  if [[ "$file_path" == *"${protected_dir}"* ]]; then
    reason="Protected directory: ${protected_dir} (system-managed)"

    # Output JSON for hook system
    cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"${reason}"}}
EOF

    # Output error to stderr
    echo -e "\n❌ BLOCKED: ${reason}\n" >&2

    exit 2
  fi
done

# Check if file starts with .env (any environment file)
if [[ "$filename" =~ ^\.env ]]; then
  reason="Environment file: ${filename} (contains secrets, use env vars instead)"

  # Output JSON for hook system
  cat <<EOF
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"${reason}"}}
EOF

  # Output error to stderr
  echo -e "\n❌ BLOCKED: ${reason}\n" >&2

  exit 2
fi

# File is not protected
exit 0
