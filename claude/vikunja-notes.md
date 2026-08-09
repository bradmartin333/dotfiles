# Vikunja ↔ GitHub repo convention

Used by `claude/commands/vikunja-task.md`.

## Task references need a per-project Identifier prefix

Vikunja's `#1`, `#2`, ... UI numbers are a **per-project** counter, not globally
unique — two different projects can both have a "#1". The MCP server's task
lookup only takes the global numeric `id`, so `/vikunja-task` can't accept
bare `#N` safely.

Fix: set an **Identifier** prefix per project (Project → Settings → General,
short code like `MOVE`). Vikunja then displays and the API returns tasks as
`MOVE-42` — globally unique and still human-typeable. `/vikunja-task` accepts
either this `PREFIX-N` form or the raw global numeric `id`; it resolves
`PREFIX-N` → project → global id before doing anything else.

Set this on every project you want to reference tasks from.

## One Project = one GitHub repo

One Vikunja **Project** = one GitHub repo. The repo is identified in the Project's
description as either:

- a full GitHub URL — `https://github.com/<owner>/<repo>`, or
- a bare `<owner>/<repo>` token

If a Project has neither, `/vikunja-task` falls back to scanning the individual
task's own description the same way before giving up and asking.

Tag existing Projects with this once; new Projects should get it when created.
