---
name: enhancement
description: Enhancement orchestrator — fetches a ticket, creates a worktree, launches agents to explore, plan, implement, and review. Lighter than /feature.
metadata:
  version: "3.0"
---

# Enhancement Orchestrator

Improve existing functionality from a ticket — no new architecture, just making
what's there better. Same shape as `/bugfix` but with the enhancement branch
prefix. The orchestrator coordinates but does not write code.

## When to Use

- User wants to improve existing functionality from a tracked ticket
- User runs `/enhancement <issue-number>`

## Config

Read `agent-workflow.config.sh` for: `BACKEND_DIR`, `FRONTEND_DIR`,
`FRONTEND_INSTALL_CMD`, `TICKET_DIR`, `TICKET_PREFIX`, `ISSUE_FETCH_CMD`,
`BRANCH_PREFIX_ENHANCEMENT`. `<P>` = `$TICKET_PREFIX`, `<BR>` =
`$BRANCH_PREFIX_ENHANCEMENT`.

## Instructions

1. **Fetch the ticket** — `$ISSUE_FETCH_CMD <number> --json title,body,labels,assignees,milestone`.
2. **Determine areas** — backend / frontend / both (default both).
3. **Worktree** — `EnterWorktree(name: "<BR>-<P>-<number>")`, then
   `git branch -m "$(git branch --show-current)" <BR>/<P>-<number>-<short-slug>`.
4. **Ticket file** — `mkdir -p "$TICKET_DIR"`; write
   `$TICKET_DIR/<P>-<number>-<slug>.md` with frontmatter
   (`ticket`, `workflow: enhancement`, `branch`, `ticket_file`, `areas`,
   `created`) and sections `## Ticket / ## Exploration / ## Plan / ##
   Implementation / ## Review`. Commit: `chore: create ticket file for <P>-<number>`.
5. **Launch agents** sequentially, `mode: "bypassPermissions"`, prompt
   `Read \`.agents/skills/<skill>/SKILL.md\` and follow its instructions for ticket <P>-<number>.`:
   - **explore**
   - **plan** (+ `Write the plan directly to the ticket file — do NOT use plan mode.`) → present `## Plan`, wait for approval, re-run with feedback if needed.
   - **implement-be** — if `areas` includes backend and `BACKEND_DIR` set.
   - **implement-fe** — if `areas` includes frontend and `FRONTEND_DIR` set (+ `Run \`cd $FRONTEND_DIR && $FRONTEND_INSTALL_CMD\` first if dependencies are missing.`).
   - **review**
6. **`ExitWorktree(action: "keep")`**
7. **Output** — PR URL, summary, `git worktree remove <worktree path>`.

## Error Handling

Same as `/bugfix`: agent failure → stop and report; no `EnterWorktree` → `git
checkout -b`; ticket fetch fails → ask the user.

## Fallback (no devcontainer)

Output a manual runbook: `/explore` → `/plan` → `/implement-be` (if backend) →
`/implement-fe` (if frontend) → `/review`, each in a fresh session inside the
worktree.
