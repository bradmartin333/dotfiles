#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Regenerating Brewfile..."
brew bundle dump --file="$SCRIPT_DIR/Brewfile" --force

echo "✓ Brewfile regenerated at $SCRIPT_DIR/Brewfile"
