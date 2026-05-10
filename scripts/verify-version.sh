#!/bin/bash
# Version Verification Script for RPTC Workflow Plugin
# Verify all 7 version locations are synchronized

set -e

echo "════════════════════════════════════════════════════════"
echo "🔍 RPTC Version Synchronization Check"
echo "════════════════════════════════════════════════════════"
echo ""

# Extract versions from all locations
V1=$(grep '"version"' plugins/rptc/.claude-plugin/plugin.json | head -1 | awk -F'"' '{print $4}')
V2=$(grep '"version"' .claude-plugin/marketplace.json | head -1 | awk -F'"' '{print $4}')
V3=$(grep '"version"' .claude-plugin/marketplace.json | tail -1 | awk -F'"' '{print $4}')
V4=$(grep '"version"' plugins/rptc/.codex-plugin/plugin.json | head -1 | awk -F'"' '{print $4}')
V5=$(grep 'Version.*:' README.md | awk -F': ' '{print $2}')
V6=$(grep 'Version.*:' plugins/rptc/README.md | awk -F': ' '{print $2}')
V7=$(grep '## \[' CHANGELOG.md | head -1 | awk -F'[][]' '{print $2}')

# Display all versions
echo "📋 Version Locations:"
echo ""
printf "  %-50s %s\n" "1. plugins/rptc/.claude-plugin/plugin.json" "$V1"
printf "  %-50s %s\n" "2. .claude-plugin/marketplace.json (metadata)" "$V2"
printf "  %-50s %s\n" "3. .claude-plugin/marketplace.json (plugin)" "$V3"
printf "  %-50s %s\n" "4. plugins/rptc/.codex-plugin/plugin.json" "$V4"
printf "  %-50s %s\n" "5. README.md" "$V5"
printf "  %-50s %s\n" "6. plugins/rptc/README.md" "$V6"
printf "  %-50s %s\n" "7. CHANGELOG.md" "$V7"
echo ""

# Check if all match
if [ "$V1" = "$V2" ] && [ "$V2" = "$V3" ] && [ "$V3" = "$V4" ] && [ "$V4" = "$V5" ] && [ "$V5" = "$V6" ] && [ "$V6" = "$V7" ]; then
  echo "════════════════════════════════════════════════════════"
  echo "✅ ALL VERSIONS SYNCHRONIZED: $V1"
  echo "════════════════════════════════════════════════════════"
  echo ""
  echo "Safe to commit!"
  exit 0
else
  echo "════════════════════════════════════════════════════════"
  echo "❌ VERSION MISMATCH DETECTED!"
  echo "════════════════════════════════════════════════════════"
  echo ""
  echo "Unique versions found:"
  echo "$V1 $V2 $V3 $V4 $V5 $V6 $V7" | tr ' ' '\n' | sort -u
  echo ""
  echo "⚠️  DO NOT COMMIT until all versions match!"
  echo ""
  echo "Fix with:"
  echo "  ./scripts/sync-version.sh <correct-version>"
  echo ""
  exit 1
fi
