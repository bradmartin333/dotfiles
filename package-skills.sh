#!/bin/bash
set -e

# Zip each skill in claude/skill-src/ into dist/<name>.zip.
# The zip holds the skill folder itself (dist/vikunja-task.zip -> vikunja-task/SKILL.md, ...),
# which is what the Claude desktop / claude.ai skill upload expects.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Kept out of claude/skills/ so Claude Code only loads the claude.ai-uploaded copy
SKILLS_DIR="$SCRIPT_DIR/claude/skill-src"
DIST_DIR="$SCRIPT_DIR/dist"

mkdir -p "$DIST_DIR"

for SKILL in "$SKILLS_DIR"/*/; do
    NAME="$(basename "$SKILL")"
    [ -f "$SKILL/SKILL.md" ] || continue
    rm -f "$DIST_DIR/$NAME.zip"
    (cd "$SKILLS_DIR" && zip -qr "$DIST_DIR/$NAME.zip" "$NAME" -x '*.DS_Store')
    echo "✓ Packaged $DIST_DIR/$NAME.zip"
done
