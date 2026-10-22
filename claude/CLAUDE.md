# Global preferences

## Git worktrees
- Default to working on the current branch. Ask before creating a worktree (EnterWorktree, `git worktree add`, or a subagent with worktree isolation).
- Any worktree used must be cleaned up before the task is done: merge its changes into the branch I was on, `git worktree remove` it, and delete its branch. End state: my current branch has all the changes and no extra worktrees remain on disk.
