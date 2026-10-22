#!/usr/bin/env bash

# Stop hook: keep Claude working until every extra git worktree is merged back and removed.

INPUT="$(cat)"
CWD="$(jq -r '.cwd' <<<"$INPUT")"

# Background agents hold their worktrees until they finish
if [ "$(jq '.background_tasks // [] | length' <<<"$INPUT")" -gt 0 ]; then
    exit 0
fi

# Drop entries whose directories are already gone so they can't block forever
git -C "$CWD" worktree prune 2>/dev/null

# First entry is always the main checkout
WORKTREES="$(git -C "$CWD" worktree list --porcelain 2>/dev/null | awk '/^worktree /{print substr($0, 10)}')"
MAIN="$(head -n 1 <<<"$WORKTREES")"
EXTRA="$(tail -n +2 <<<"$WORKTREES")"
[ -n "$EXTRA" ] || exit 0

BRANCH="$(git -C "$MAIN" branch --show-current)"

jq -n --arg extra "$EXTRA" --arg main "$MAIN" --arg branch "$BRANCH" '{
  hookSpecificOutput: {
    hookEventName: "Stop",
    additionalContext: "Leftover git worktrees:\n\($extra)\n\nBefore finishing: ExitWorktree if you are in one, merge each worktree'"'"'s changes into \($branch) in \($main), then `git worktree remove` it (`git worktree unlock` first if locked) and delete its branch. The user requires their current branch to have all changes and no worktrees left on disk. If a worktree is not from this session, ask the user before touching it."
  }
}'
