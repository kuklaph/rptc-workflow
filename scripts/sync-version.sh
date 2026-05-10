#!/bin/bash
# Version Synchronization Script for RPTC Workflow Plugin
#
# Purpose: Update all 7 version locations atomically from a single source
# Usage: ./scripts/sync-version.sh <version> [--skip-changelog]
# Example: ./scripts/sync-version.sh 1.2.3

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
VERSION=$1
SKIP_CHANGELOG=false

if [ "$2" = "--skip-changelog" ]; then
  SKIP_CHANGELOG=true
fi

# Validate version argument
if [ -z "$VERSION" ]; then
  echo -e "${RED}Error: Version number required${NC}"
  echo ""
  echo "Usage: $0 <version> [--skip-changelog]"
  echo ""
  echo "Examples:"
  echo "  $0 1.2.3                # Sync to version 1.2.3 and update CHANGELOG"
  echo "  $0 1.2.3 --skip-changelog  # Sync version only, skip CHANGELOG"
  echo ""
  echo "Version format: X.Y.Z (semantic versioning)"
  exit 1
fi

# Validate version format (semantic versioning)
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo -e "${RED}Error: Invalid version format '$VERSION'${NC}"
  echo ""
  echo "Expected format: X.Y.Z (e.g., 1.2.3)"
  echo ""
  exit 1
fi

# Check if jq is available (optional, we have fallback)
HAS_JQ=false
if command -v jq &> /dev/null; then
  HAS_JQ=true
fi

# Banner
echo ""
echo "════════════════════════════════════════════════════════"
echo -e "  ${BLUE}RPTC Version Synchronization${NC}"
echo "════════════════════════════════════════════════════════"
echo ""
echo -e "${YELLOW}Target Version:${NC} $VERSION"
echo ""

# Get current version for comparison
CURRENT_VERSION=$(grep '"version"' plugins/rptc/.claude-plugin/plugin.json | head -1 | awk -F'"' '{print $4}')
echo -e "${YELLOW}Current Version:${NC} $CURRENT_VERSION"
echo ""

# Check if version is changing
if [ "$VERSION" = "$CURRENT_VERSION" ]; then
  echo -e "${YELLOW}⚠️  Warning: Version is already $VERSION${NC}"
  echo ""
  read -p "Continue anyway? [y/N]: " CONFIRM
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
  echo ""
fi

# Confirm before proceeding
echo -e "${YELLOW}This will update all 7 version locations:${NC}"
echo "  1. plugins/rptc/.claude-plugin/plugin.json"
echo "  2. .claude-plugin/marketplace.json (metadata.version)"
echo "  3. .claude-plugin/marketplace.json (plugins[0].version)"
echo "  4. plugins/rptc/.codex-plugin/plugin.json"
echo "  5. README.md"
echo "  6. plugins/rptc/README.md"
echo "  7. CHANGELOG.md (add new section)"
echo ""
read -p "Continue? [y/N]: " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

echo ""
echo "🔧 Updating version locations..."
echo ""

# Create backup
BACKUP_DIR=".version-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo -e "${BLUE}Creating backup:${NC} $BACKUP_DIR"
mkdir -p "$BACKUP_DIR/claude-plugin" "$BACKUP_DIR/codex-plugin"
cp plugins/rptc/.claude-plugin/plugin.json "$BACKUP_DIR/claude-plugin/plugin.json"
cp .claude-plugin/marketplace.json "$BACKUP_DIR/"
cp plugins/rptc/.codex-plugin/plugin.json "$BACKUP_DIR/codex-plugin/plugin.json"
cp README.md "$BACKUP_DIR/root-README.md"
cp plugins/rptc/README.md "$BACKUP_DIR/package-README.md"
cp CHANGELOG.md "$BACKUP_DIR/"
echo ""

# 1. Update packaged Claude plugin.json
echo -n "  [1/7] Updating Claude plugin.json... "
if [ "$HAS_JQ" = true ]; then
  jq --arg version "$VERSION" '.version = $version' plugins/rptc/.claude-plugin/plugin.json > .tmp.json
  mv .tmp.json plugins/rptc/.claude-plugin/plugin.json
else
  # Fallback: use sed
  sed -i "s/\"version\": \"[0-9]*\.[0-9]*\.[0-9]*\"/\"version\": \"$VERSION\"/" plugins/rptc/.claude-plugin/plugin.json
fi
echo -e "${GREEN}✓${NC}"

# 2 & 3. Update .claude-plugin/marketplace.json (2 locations)
echo -n "  [2/7] Updating Claude marketplace.json (both locations)... "
if [ "$HAS_JQ" = true ]; then
  jq --arg version "$VERSION" '.metadata.version = $version | .plugins[0].version = $version' .claude-plugin/marketplace.json > .tmp.json
  mv .tmp.json .claude-plugin/marketplace.json
else
  # Fallback: use sed (replaces all "version" fields)
  sed -i "s/\"version\": \"[0-9]*\.[0-9]*\.[0-9]*\"/\"version\": \"$VERSION\"/g" .claude-plugin/marketplace.json
fi
echo -e "${GREEN}✓${NC}"

# 4. Update packaged Codex plugin.json
echo -n "  [3/7] Updating packaged Codex plugin.json... "
if [ "$HAS_JQ" = true ]; then
  jq --arg version "$VERSION" '.version = $version' plugins/rptc/.codex-plugin/plugin.json > .tmp.json
  mv .tmp.json plugins/rptc/.codex-plugin/plugin.json
else
  sed -i "s/\"version\": \"[0-9]*\.[0-9]*\.[0-9]*\"/\"version\": \"$VERSION\"/" plugins/rptc/.codex-plugin/plugin.json
fi
echo -e "${GREEN}✓${NC}"

# 5. Update root README.md
echo -n "  [4/7] Updating root README.md... "
sed -i "s/^\*\*Version\*\*:.*/\*\*Version\*\*: $VERSION/" README.md
echo -e "${GREEN}✓${NC}"

# 6. Update package README.md
echo -n "  [5/7] Updating package README.md... "
sed -i "s/^\*\*Version\*\*:.*/\*\*Version\*\*: $VERSION/" plugins/rptc/README.md
echo -e "${GREEN}✓${NC}"

# 7. Update CHANGELOG.md (add new section if not exists)
echo -n "  [6/7] Updating CHANGELOG.md... "
if [ "$SKIP_CHANGELOG" = true ]; then
  echo -e "${YELLOW}SKIPPED${NC}"
else
  if ! grep -q "## \[$VERSION\]" CHANGELOG.md; then
    DATE=$(date +%Y-%m-%d)
    # Create new section at the top
    {
      head -n 8 CHANGELOG.md  # Keep header (up to ---)
      echo ""
      echo "## [$VERSION] - $DATE"
      echo ""
      echo "### Added"
      echo ""
      echo "- "
      echo ""
      echo "### Changed"
      echo ""
      echo "- "
      echo ""
      echo "### Fixed"
      echo ""
      echo "- "
      echo ""
      echo "---"
      echo ""
      tail -n +9 CHANGELOG.md  # Rest of file
    } > .tmp.changelog.md
    mv .tmp.changelog.md CHANGELOG.md
    echo -e "${GREEN}✓${NC} (new section added)"
  else
    echo -e "${YELLOW}✓${NC} (section already exists)"
  fi
fi

echo -n "  [7/7] Verification... "
echo -e "${GREEN}✓${NC}"

echo ""
echo -e "${GREEN}✅ Version sync complete!${NC}"
echo ""

# Verify synchronization
echo "🔍 Verifying synchronization..."
echo ""

V1=$(grep '"version"' plugins/rptc/.claude-plugin/plugin.json | head -1 | awk -F'"' '{print $4}')
V2=$(grep '"version"' .claude-plugin/marketplace.json | head -1 | awk -F'"' '{print $4}')
V3=$(grep '"version"' .claude-plugin/marketplace.json | tail -1 | awk -F'"' '{print $4}')
V4=$(grep '"version"' plugins/rptc/.codex-plugin/plugin.json | head -1 | awk -F'"' '{print $4}')
V5=$(grep 'Version.*:' README.md | awk -F': ' '{print $2}')
V6=$(grep 'Version.*:' plugins/rptc/README.md | awk -F': ' '{print $2}')
V7=$(grep '## \[' CHANGELOG.md | head -1 | awk -F'[][]' '{print $2}')

ALL_MATCH=true
if [ "$V1" != "$VERSION" ] || [ "$V2" != "$VERSION" ] || [ "$V3" != "$VERSION" ] || \
   [ "$V4" != "$VERSION" ] || [ "$V5" != "$VERSION" ] || [ "$V6" != "$VERSION" ] || \
   [ "$V7" != "$VERSION" ]; then
  ALL_MATCH=false
fi

if [ "$ALL_MATCH" = true ]; then
  echo -e "${GREEN}✅ ALL VERSIONS SYNCHRONIZED: $VERSION${NC}"
  echo ""
  echo "Verified locations:"
  echo "  ✓ Claude package plugin.json:  $V1"
  echo "  ✓ Claude marketplace (meta):   $V2"
  echo "  ✓ Claude marketplace (plugin): $V3"
  echo "  ✓ Codex package plugin.json:   $V4"
  echo "  ✓ Root README.md:              $V5"
  echo "  ✓ Package README.md:           $V6"
  echo "  ✓ CHANGELOG.md:                $V7"
  echo ""
  # Clean up backup after successful sync
  echo -e "${BLUE}🧹 Removing backup directory...${NC}"
  rm -rf "$BACKUP_DIR"
  echo -e "${GREEN}✓${NC} Backup removed: $BACKUP_DIR"
else
  echo -e "${RED}❌ VERIFICATION FAILED - VERSIONS NOT SYNCHRONIZED!${NC}"
  echo ""
  echo "  Claude package plugin.json:  $V1"
  echo "  Claude marketplace (meta):   $V2"
  echo "  Claude marketplace (plugin): $V3"
  echo "  Codex package plugin.json:   $V4"
  echo "  Root README.md:              $V5"
  echo "  Package README.md:           $V6"
  echo "  CHANGELOG.md:                $V7"
  echo ""
  echo "Backup available at: $BACKUP_DIR"
  echo ""
  echo "To restore:"
  echo "  cp $BACKUP_DIR/claude-plugin/plugin.json plugins/rptc/.claude-plugin/plugin.json"
  echo "  cp $BACKUP_DIR/marketplace.json .claude-plugin/marketplace.json"
  echo "  cp $BACKUP_DIR/codex-plugin/plugin.json plugins/rptc/.codex-plugin/plugin.json"
  echo "  cp $BACKUP_DIR/root-README.md README.md"
  echo "  cp $BACKUP_DIR/package-README.md plugins/rptc/README.md"
  echo "  cp $BACKUP_DIR/CHANGELOG.md CHANGELOG.md"
  exit 1
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo -e "  ${GREEN}NEXT STEPS${NC}"
echo "════════════════════════════════════════════════════════"
echo ""
if [ "$SKIP_CHANGELOG" = false ]; then
  echo "1. Edit CHANGELOG.md to document your changes:"
  echo "   - Add items under ### Added, ### Changed, ### Fixed"
  echo "   - Remove empty sections"
  echo ""
fi
echo "2. Review changes:"
echo "   git diff"
echo ""
echo "3. Stage and commit:"
echo "   git add -A"
echo "   git commit -m 'chore(release): bump version to $VERSION'"
echo ""
echo "4. Create tag:"
echo "   git tag -a v$VERSION -m 'Release $VERSION'"
echo ""
echo "5. Push to remote:"
echo "   git push origin main --tags"
echo ""
echo -e "${BLUE}💡 Tip:${NC} The pre-commit hook will verify version sync before allowing commit"
echo ""
echo "════════════════════════════════════════════════════════"
