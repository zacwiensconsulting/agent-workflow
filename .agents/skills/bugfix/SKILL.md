---
name: bugfix
description: Bug fix orchestrator — fetches a ticket, creates a worktree, launches agents to explore, plan, implement, and review.
metadata:
  version: "3.0"
---

# Bug Fix Orchestrator

Fetches a ticket, creates an isolated worktree, then launches sequential agents
to fix the bug. The orchestrator coordinates but does not write code.

## When to Use

- User wants to fix a bug from a tracked ticket
- User runs `/bugfix <issue-number>`

## Config

Read `agent-workflow.config.sh` at the repo root for: `BACKEND_DIR`,
`FRONTEND_DIR`, `FRONTEND_INSTALL_CMD`, `INTEGRATION_TEST_CMD`,
`INTEGRATION_TEST_TRIGGERS`, `TICKET_DIR`, `TICKET_PREFIX`, `ISSUE_FETCH_CMD`,
`BRANCH_PREFIX_BUGFIX`. Below, `<P>` = `$TICKET_PREFIX`, `<BR>` =
`$BRANCH_PREFIX_BUGFIX`.

## Instructions

### Step 1 — Fetch the ticket

```bash
$ISSUE_FETCH_CMD <number> --json title,body,labels,assignees,milestone
```

Extract title, description, labels, acceptance criteria.

### Step 2 — Determine affected areas

Classify from the body:
- **backend** — API, endpoint, service, database, business logic, server code
- **frontend** — UI, component, page, display, form
- **both** — mentions both or unclear (default to both)

(If the project defines extra areas — e.g. `mobile` — classify those too.)

### Step 3 — Create an isolated worktree

```
EnterWorktree(name: "<BR>-<P>-<number>")
```

Then rename the branch:

```bash
current=$(git branch --show-current)
git branch -m "$current" <BR>/<P>-<number>-<short-slug>
```

2–4 word kebab-case slug from the title. The worktree branches from HEAD.

### Step 4 — Create the ticket file

```bash
mkdir -p "$TICKET_DIR"
```

Write `$TICKET_DIR/<P>-<number>-<slug>.md`:

```markdown
---
ticket: <P>-<number>
workflow: bugfix
branch: <BR>/<P>-<number>-<slug>
ticket_file: <path to this file>
areas: [backend] | [frontend] | [backend, frontend]
created: <today's date>
---

# <P>-<number>: <Issue Title>

## Ticket
<Full issue body>

## Exploration
## Plan
## Implementation
## Review
```

Commit:
```bash
git add "$TICKET_DIR/<P>-<number>-<slug>.md"
git commit -m "chore: create ticket file for <P>-<number>"
```

### Step 5 — Launch agents

Launch each sequentially with `mode: "bypassPermissions"`. Wait for each to
complete before the next. Generic prompt:
`Read \`.agents/skills/<skill>/SKILL.md\` and follow its instructions for ticket <P>-<number>.`

- **5a — explore**
- **5b — plan** — append: `Write the plan directly to the ticket file — do NOT use plan mode.`
  After it completes: read the `## Plan` section, present it to the user, wait
  for approval. If they want changes, re-run with feedback appended.
- **5c — implement-be** — only if `areas` includes backend and `BACKEND_DIR` is set.
- **5d — implement-fe** — only if `areas` includes frontend and `FRONTEND_DIR` is
  set. Append: `Run \`cd $FRONTEND_DIR && $FRONTEND_INSTALL_CMD\` first if dependencies are missing.`
- **5e — test-integration** — only if `INTEGRATION_TEST_CMD` is set and the
  ticket matches `INTEGRATION_TEST_TRIGGERS`.
- **5f — review**

### Step 6 — Exit the worktree

```
ExitWorktree(action: "keep")
```

### Step 7 — Output

PR URL (from the review agent), summary of changes, and
`git worktree remove <worktree path>`.

## Error Handling

- If an agent fails, stop and report — do not continue to the next agent.
- If `EnterWorktree` is unavailable, fall back to `git checkout -b` in the current directory.
- If the ticket fetch fails, ask the user for the details manually.

## Fallback (no devcontainer / no bypassPermissions)

If not running with `--dangerously-skip-permissions`, output a manual runbook
instead of launching agents:

```
Run each in a fresh session inside the worktree:
1. /explore <number>
2. /plan <number>
3. /implement-be <number>   (if backend)
4. /implement-fe <number>   (if frontend)
5. /review <number>
```
