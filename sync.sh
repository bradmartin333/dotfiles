#!/usr/bin/env bash

set -e

# Bring an already set up machine in line with the repo, then capture its local changes.
# Order matters: pull and install before dumping, or the dump overwrites Brewfile entries
# added on other machines.

DOTFILES_DIR="$HOME/.dotfiles"
cd "$DOTFILES_DIR"

echo "Pulling latest dotfiles..."
if [ -z "$(git status --porcelain)" ]; then
    git pull --ff-only
else
    echo "⊘ Skipping pull (uncommitted changes in $DOTFILES_DIR)"
fi

echo -e "\nRunning install..."
"$DOTFILES_DIR/install.sh"

echo -e "\nDumping Homebrew packages to Brewfile..."
if command -v brew &> /dev/null; then
    brew bundle dump --file="$DOTFILES_DIR/Brewfile" --force
    echo "✓ Brewfile updated"
else
    echo "⊘ Homebrew not found, skipping Brewfile dump"
fi

echo -e "\nChanges to review before committing (this repo is public):"
git status --short
