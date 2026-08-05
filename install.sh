#!/usr/bin/env bash

# Define directories
DOTFILES_DIR="$HOME/.dotfiles"

# List of files to symlink (repo_file:home_link)
declare -A FILES=(
    ["zshrc"]="$HOME/.zshrc"
    ["gitconfig"]="$HOME/.gitconfig"
    ["bash_aliases"]="$HOME/.bash_aliases"
)

# Shell files to source after linking (gitconfig is not shell syntax, skip it)
SOURCE_FILES=("$HOME/.zshrc" "$HOME/.bash_aliases")

echo "Creating symlinks..."
for REPO_FILE in "${!FILES[@]}"; do
    TARGET="${FILES[$REPO_FILE]}"

    # Remove existing file or symlink to avoid conflicts
    rm -rf "$TARGET"

    # Create the symlink
    ln -s "$DOTFILES_DIR/$REPO_FILE" "$TARGET"
    echo "Linked $TARGET -> $DOTFILES_DIR/$REPO_FILE"
done

echo "Sourcing dotfiles..."
for TARGET in "${SOURCE_FILES[@]}"; do
    source "$TARGET"
    echo "Sourced $TARGET"
done

if command -v brew &> /dev/null; then
    echo "Installing Brewfile dependencies..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"
else
    echo "Homebrew not found, skipping Brewfile installation."
fi

echo "Dotfiles installation complete!"

