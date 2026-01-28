#!/bin/bash
# Auto-format code after edits
# Reference: languages-and-style.md (SOP: ~/.claude/global/sop/ or ${CLAUDE_PLUGIN_ROOT}/sop/)

set -e

# Read hook input from stdin
INPUT=$(cat)

# Extract file paths from environment variable
FILE_PATHS="$CLAUDE_FILE_PATHS"

# Exit if no files to process
if [ -z "$FILE_PATHS" ]; then
    exit 0
fi

# Process each file
for FILE in $FILE_PATHS; do
    # Get file extension
    EXT="${FILE##*.}"
    FILENAME=$(basename "$FILE")

    case "$EXT" in
        ts|tsx|js|jsx)
            # Format TypeScript/JavaScript with Prettier
            if command -v npx &> /dev/null; then
                if npx prettier --check "$FILE" &> /dev/null; then
                    npx prettier --write "$FILE" 2>&1 | sed 's/^/  /'
                    echo "✅ Formatted: $FILENAME"
                fi
            fi

            # Type-check TypeScript
            if [[ "$EXT" == "ts" || "$EXT" == "tsx" ]]; then
                if command -v npx &> /dev/null; then
                    if npx tsc --noEmit --skipLibCheck &> /dev/null; then
                        echo "✅ TypeScript check passed: $FILENAME"
                    else
                        echo "⚠️  TypeScript errors in: $FILENAME" >&2
                    fi
                fi
            fi
            ;;
        py)
            # Format Python with Black (prefer virtualenv over global)
            BLACK_CMD=""

            # Check for Black in common virtualenv locations
            for VENV_DIR in venv .venv env .env; do
                if [ -f "$CLAUDE_PROJECT_DIR/$VENV_DIR/bin/black" ]; then
                    BLACK_CMD="$CLAUDE_PROJECT_DIR/$VENV_DIR/bin/black"
                    break
                fi
            done

            # Fall back to global Black if not found in virtualenv
            if [ -z "$BLACK_CMD" ] && command -v black &> /dev/null; then
                BLACK_CMD="black"
            fi

            # Format if Black is available
            if [ -n "$BLACK_CMD" ]; then
                $BLACK_CMD "$FILE" 2>&1 | sed 's/^/  /'
                echo "✅ Formatted: $FILENAME"
            else
                echo "ℹ️  Black not found in virtualenv or globally" >&2
                echo "ℹ️  Install: pip install black" >&2
            fi
            ;;
        *)
            # No formatter configured for this file type
            ;;
    esac
done

exit 0
