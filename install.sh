#!/usr/bin/env bash

set -e

# Define directories
DOTFILES_DIR="$HOME/.dotfiles"
CLAUDE_DIR="$HOME/.claude"

# List of files to symlink (repo_file:home_link)
declare -A FILES=(
    ["zshrc"]="$HOME/.zshrc"
    ["gitconfig"]="$HOME/.gitconfig"
)

# Claude files to symlink
declare -A CLAUDE_FILES=(
    ["claude/settings.json"]="$CLAUDE_DIR/settings.json"
    ["claude/commands/vikunja-task.md"]="$CLAUDE_DIR/commands/vikunja-task.md"
)

# Helper function to create symlink safely
create_symlink() {
    local repo_file="$1"
    local target="$2"

    if [ ! -f "$repo_file" ]; then
        echo "⊘ Skipping $repo_file (file not found in dotfiles)"
        return 0
    fi

    # Remove existing file or symlink to avoid conflicts
    if [ -e "$target" ] || [ -L "$target" ]; then
        rm -f "$target"
    fi

    # Ensure the target's parent directory exists
    mkdir -p "$(dirname "$target")"

    # Create the symlink
    ln -s "$repo_file" "$target"
    echo "✓ Linked $target -> $repo_file"
}

echo "Creating symlinks..."

# Symlink regular dotfiles
for REPO_FILE in "${!FILES[@]}"; do
    TARGET="${FILES[$REPO_FILE]}"
    create_symlink "$DOTFILES_DIR/$REPO_FILE" "$TARGET"
done

# Symlink Claude files (create .claude dir if needed)
if [ ! -d "$CLAUDE_DIR" ]; then
    mkdir -p "$CLAUDE_DIR"
    echo "✓ Created $CLAUDE_DIR"
fi

for REPO_FILE in "${!CLAUDE_FILES[@]}"; do
    TARGET="${CLAUDE_FILES[$REPO_FILE]}"
    create_symlink "$DOTFILES_DIR/$REPO_FILE" "$TARGET"
done

echo -e "\nInstalling Homebrew dependencies..."
if command -v brew &> /dev/null; then
    if [ -f "$DOTFILES_DIR/Brewfile" ]; then
        brew bundle --file="$DOTFILES_DIR/Brewfile"
        echo "✓ Brewfile installation complete"
    else
        echo "⊘ Brewfile not found, skipping"
    fi
else
    echo "⊘ Homebrew not found, skipping Brewfile installation"
fi

echo -e "\n✓ Dotfiles installation complete!"
echo "  run 'exec zsh' to pick up the new shell config"

