#!/usr/bin/env bash

set -e

# Define directories
DOTFILES_DIR="$HOME/.dotfiles"
CLAUDE_DIR="$HOME/.claude"

# List of files to symlink (repo_file:home_link)
# Plain arrays rather than declare -A so this runs on macOS's stock bash 3.2
FILES=(
    "zshrc:$HOME/.zshrc"
    "gitconfig:$HOME/.gitconfig"
)

# Claude files to symlink
CLAUDE_FILES=(
    "claude/settings.json:$CLAUDE_DIR/settings.json"
    "claude/CLAUDE.md:$CLAUDE_DIR/CLAUDE.md"
)

# Clear the way for a symlink: drop an old symlink, back up a real file or directory
move_aside() {
    local target="$1"

    if [ -L "$target" ]; then
        rm -f "$target"
    elif [ -e "$target" ]; then
        mv "$target" "$target.bak.$(date +%Y%m%d%H%M%S)"
        echo "✓ Backed up existing $target"
    fi
}

# Helper function to create symlink safely
create_symlink() {
    local repo_file="$1"
    local target="$2"

    if [ ! -f "$repo_file" ]; then
        echo "⊘ Skipping $repo_file (file not found in dotfiles)"
        return 0
    fi

    move_aside "$target"

    # Ensure the target's parent directory exists
    mkdir -p "$(dirname "$target")"

    # Create the symlink
    ln -s "$repo_file" "$target"
    echo "✓ Linked $target -> $repo_file"
}

echo "Creating symlinks..."

# Symlink regular dotfiles
for ENTRY in "${FILES[@]}"; do
    create_symlink "$DOTFILES_DIR/${ENTRY%%:*}" "${ENTRY#*:}"
done

# Symlink Claude files (create .claude dir if needed)
if [ ! -d "$CLAUDE_DIR" ]; then
    mkdir -p "$CLAUDE_DIR"
    echo "✓ Created $CLAUDE_DIR"
fi

for ENTRY in "${CLAUDE_FILES[@]}"; do
    create_symlink "$DOTFILES_DIR/${ENTRY%%:*}" "${ENTRY#*:}"
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
echo "  vikunja-task needs the Vikunja MCP server (once per machine):"
echo "    claude mcp add -s user --transport http vikunja https://tasks.coblab.net/api/v2/mcp --header 'Authorization: Bearer <token>'"
echo "  run 'exec zsh' to pick up the new shell config"

