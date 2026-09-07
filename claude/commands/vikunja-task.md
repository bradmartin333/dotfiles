---
description: Pick up a Vikunja task by ID, resolve its repo, branch, and start work
---

Arguments (`$ARGUMENTS`): `<task-ref>`.

## 1. Resolve and fetch the task

`<task-ref>` can be given two ways — the plain "#N" you see in the Vikunja UI is a **per-project** counter, not a global ID, and is NOT accepted directly because it's ambiguous across projects:

- **A bare number** (e.g. `217`) — the task's global numeric `id`. Call `vikunja_tasks.get` with it directly.
- **`PREFIX-N`** (e.g. `MOVE-42`) — a project's short **Identifier** prefix (set per-project in Vikunja under Project → Settings → General) plus its per-project task index. This form is globally unique and human-typeable, unlike bare `#N`. Resolve it:
  1. List projects (`vikunja_projects.list`) and find the one whose `identifier` field case-insensitively matches `PREFIX`.
     - No match → stop and report: that project likely has no Identifier configured yet. Point at `~/.dotfiles/claude/vikunja-notes.md` for the convention and ask the user to set one (or give a bare numeric ID instead).
  2. List that project's tasks (`vikunja_tasks.list` with `projectId`) and find the one whose `index` equals `N`.
     - No match → stop and report the task index wasn't found in that project.
  3. Use that task's global `id` for `vikunja_tasks.get` and everything downstream.

If `<task-ref>` matches neither shape, or the resolved task doesn't exist, or the MCP server isn't reachable, stop and report that clearly — don't guess at task details.

Once fetched, note the task's own `identifier` field (e.g. `MOVE-42`, or `#N` if its project has no prefix) — use this (not the raw arg) for branch naming and human-facing references from here on, since it's stable regardless of which input form was used.

## 2. Resolve the repo

Fetch the task's parent project via the `vikunja` MCP tools. Search the project's description for a repo reference:
- A GitHub URL (`https://github.com/<owner>/<repo>`), or
- A bare `<owner>/<repo>` token.

If the project description has neither, fall back to scanning the task's own description the same way. If still nothing is found, stop and ask the user which repo this task belongs to rather than guessing.

## 3. Gather full context before doing anything

Don't start work off the title and description alone — pull in what's already been said about this task:

- **Comments:** call `vikunja_tasks.comment` with the task's `id` and no `comment` argument to list existing comments. Read through them for prior decisions, blockers, or requirements that supersede or refine the description — treat later comments as more current than the original description if they conflict.
- **Related tasks:** check the fetched task's `related_tasks` object. Each relation kind (subtask, parenttask, related, blocking, blocked, etc.) can carry prior decisions or requirements that this task builds on or depends on — don't skip past them as decoration. If a related task's own description/comments look relevant but are thin in what `related_tasks` already returned, pull the full task with `vikunja_tasks.get` (and its comments) using that related task's `id`. Note anything load-bearing from related tasks in the step 6 orient summary.
- **Attachments:** check the fetched task object for an `attachments` array (filename/id/size metadata). The MCP server's `attach` subcommand isn't implemented (MCP protocol limitation), so file *content* can't be pulled through it. If attachments exist and their content actually matters for the work:
  - Try a direct read via the Vikunja REST API using the same credentials already configured for the `vikunja` MCP server (`VIKUNJA_URL`/`VIKUNJA_API_TOKEN` in `~/.claude.json`'s `mcpServers.vikunja.env`): `GET {VIKUNJA_URL}/tasks/{id}/attachments/{attachmentId}`.
  - If that's not workable, just tell the user what attachments exist (filenames) and that you can't read their contents automatically — don't silently ignore them.

Ask for clarification if any of the above context is unclear or incomplete, and don't proceed until you have a clear understanding of the task's requirements.

## 4. Open the workspace

- If `~/src/<repo>` doesn't exist, run `gh repo clone <owner>/<repo> ~/src/<repo>`.
- `cd` into `~/src/<repo>`.

## 5. Branch (git-flow by task type, confirmed first)

If the task contains the label `research`, then do not make a branch at all — just move the task to "Doing" and start work in the current branch. If action items are discovered, suggest creating a new task for them instead of branching off this one. (Skip the confirmation below in this case — no branch decision to make.)

Otherwise, don't assume git-flow — confirm with the user first: ask whether to branch per the usual git-flow procedure below, or work directly in the current/develop branch instead (sometimes preferred, e.g. for a small change that doesn't warrant its own branch). If they want to work directly in the current branch, skip the rest of this step (no branch created, no base to fast-forward) and go straight to step 6, noting in the orient summary that this task is running without a dedicated branch.

If git-flow branching is confirmed, determine a prefix from the task's Vikunja label(s), case-insensitive substring match:
- contains "hotfix", "urgent", or "critical" → `hotfix/`
- contains "bug" or "fix" → `bugfix/`
- otherwise → `feature/`

Branch name: `<prefix><sanitized-identifier>-<slugified-task-title>` (identifier lowercased with any `#`/non-alnum stripped, e.g. `MOVE-42` → `move-42`; spaces/punctuation in the title → `-`). **Do not create a worktree** — just a normal branch in the repo.

- **Resume check first:** run `git branch --list '*<sanitized-identifier>*'`. If a matching local branch exists, `git checkout` it and skip straight to step 6 — do not create a new branch or re-branch from base.
- **Otherwise:** `hotfix/` branches from latest `main`; `feature/`/`bugfix/` branch from latest `develop`, falling back to `main` if the repo has no `develop`. Fetch and fast-forward the base branch, then `git checkout -b <branch-name> <base>`.
- **Move the task to "Doing"** — only when a *new* branch was just created above (not on resume). The MCP server has no kanban/bucket tool, so do this via a direct REST call using the same credentials already configured for the `vikunja` MCP server (`VIKUNJA_URL`/`VIKUNJA_API_TOKEN` in `~/.claude.json`'s `mcpServers.vikunja.env`):
  1. `GET {VIKUNJA_URL}/projects/{project_id}/views` → find the entry with `view_kind == "kanban"`, note its `id` as `{view_id}`.
  2. `GET {VIKUNJA_URL}/projects/{project_id}/views/{view_id}/buckets` → find the bucket whose `title` case-insensitively matches "doing", note its `id` as `{bucket_id}`. If no such bucket exists, skip this silently and mention it in the orient summary — don't guess a different bucket or create one.
  3. `POST {VIKUNJA_URL}/projects/{project_id}/views/{view_id}/buckets/{bucket_id}/tasks` with JSON body `{"task_id": <task's global id>}`.

## 6. Orient

Print a short summary: task title, description, labels, due date, resolved repo, the branch now checked out (new, resumed, or none if working directly in the current branch), a distilled takeaway from existing comments and related tasks (if any), and any attachments found (if any).

## 7. Working agreement for the rest of the session

- As work progresses, post short progress comments on the Vikunja task automatically via the `vikunja` MCP comment tool — no need to ask each time.
- Always ask for explicit confirmation before marking the Vikunja task Done.
- Commit locally as work is completed. Never run `git push` or `gh pr create` on your own initiative — leave pushing and opening a PR to the user, and wait for them to ask.
- Exception: if the user explicitly grants standing consent to push/open PRs as you go (e.g. "you can take the wheel on pushes from here" or "push whenever you're ready without asking"), honor that for the rest of *this* session only — it doesn't carry forward to future invocations of this skill, and it never extends to marking the Vikunja task Done, which always requires confirmation regardless.
- **Whenever this task's branch gets pushed to GitHub**, post a comment on the Vikunja task with its branch link: `https://github.com/<owner>/<repo>/tree/<branch>` (get `<owner>/<repo>` from step 2's resolved repo).
- **Whenever a PR gets opened for this task**, post a comment on the Vikunja task with the PR URL (`gh pr create` prints it on success — use that exact URL, don't reconstruct it).

## 8. Guidelines for creating new tasks

- Make sure task names are simple so that future branches can have a clean slugified name. Avoid punctuation, special characters, and long sentences.
- If a task is too big, break it into subtasks with relations established in Vikunja. Subtasks can use the same repo and branch as the parent task.
