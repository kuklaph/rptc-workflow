#!/usr/bin/env bash
# TDD Warning System
# Warns when creating implementation files without corresponding tests
# Reference: testing-guide.md (SOP fallback: .rptc/sop/ → ~/.claude/global/sop/ → ${CLAUDE_PLUGIN_ROOT}/sop/)

set -euo pipefail

# Read JSON input from stdin
input=$(cat)

# Parse JSON using jq if available, otherwise use grep/sed
if command -v jq &> /dev/null; then
  tool_name=$(echo "$input" | jq -r '.tool_name // empty')
  file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
else
  # Fallback parsing without jq
  tool_name=$(echo "$input" | grep -oP '"tool_name"\s*:\s*"\K[^"]+' || echo "")
  file_path=$(echo "$input" | grep -oP '"file_path"\s*:\s*"\K[^"]+' || echo "")
fi

# Only check Write and MultiEdit tools
if [[ "$tool_name" != "Write" && "$tool_name" != "MultiEdit" ]]; then
  exit 0
fi

# Exit if no file path
[[ -z "$file_path" ]] && exit 0

filename=$(basename "$file_path")
extension="${filename##*.}"
dirname=$(dirname "$file_path")
stem="${filename%.*}"

# Check if it's a test file
is_test_file() {
  local fp="$1"
  local fn=$(basename "$fp")

  [[ "$fn" =~ \.test\. ]] ||
  [[ "$fn" =~ \.spec\. ]] ||
  [[ "$fp" =~ __tests__ ]] ||
  [[ "$fn" =~ ^test_ ]] ||
  [[ "$fn" =~ _test\.py$ ]]
}

# Check if it's an implementation file
is_implementation_file() {
  local fp="$1"
  local ext="${fp##*.}"

  # Check if it's a code file
  [[ "$ext" =~ ^(ts|tsx|js|jsx|py)$ ]] && ! is_test_file "$fp"
}

# Exit early if it's a test file
if is_test_file "$file_path"; then
  exit 0
fi

# Exit early if not an implementation file
if ! is_implementation_file "$file_path"; then
  exit 0
fi

# Check for corresponding test file
test_exists=false

# Possible test file locations
test_paths=(
  "${dirname}/${stem}.test.${extension}"
  "${dirname}/${stem}.spec.${extension}"
  "${dirname}/__tests__/${stem}.test.${extension}"
  "${dirname}/test_${stem}.${extension}"
)

for test_path in "${test_paths[@]}"; do
  if [[ -f "$test_path" ]]; then
    test_exists=true
    break
  fi
done

# Warn if no test file found
if [[ "$test_exists" = false ]]; then
  test_suggestion="${stem}.test.${extension}"

  cat >&2 <<EOF

⚠️  TDD WARNING: Creating implementation without tests!

File: ${filename}
Recommended: Write tests first in ${test_suggestion}

Reference: testing-guide.md (TDD cycle) - Use /rptc:admin-sop-check to verify SOP location

EOF
fi

exit 0
