---
name: feature
description: Feature orchestrator — fetches a ticket, creates a worktree, launches agents to explore, plan, implement, test (integration/e2e/visual), and review.
metadata:
  version: "3.0"
---

# Feature Orchestrator

Build a new feature from a ticket. Full pipeline including integration, e2e, and
(if design specs exist) visual review. The orchestrator coordinates but does not
write code.

## When to Use

- User wants to build a new feature from a tracked ticket
- User runs `/feature <issue-number>`

## Config

Read `agent-workflow.config.sh` for: `BACKEND_DIR`, `FRONTEND_DIR`,
`FRONTEND_INSTALL_CMD`, `INTEGRATION_TEST_CMD`, `E2E_TEST_CMD`, `DESIGNS_DIR`,
`TICKET_DIR`, `TICKET_PREFIX`, `ISSUE_FETCH_CMD`, `BRANCH_PREFIX_FEATURE`.
`<P>` = `$TICKET_PREFIX`, `<BR>` = `$BRANCH_PREFIX_FEATURE`.

## Instructions

### Step 1 — Fetch the ticket
`$ISSUE_FETCH_CMD <number> --json title,body,labels,assignees,milestone`.

### Step 2 — Determine affected areas
backend / frontend / both (default both for features); plus any extra areas the
project defines.

### Step 3 — Worktree
`EnterWorktree(name: "<BR>-<P>-<number>")`, then
`git branch -m "$(git branch --show-current)" <BR>/<P>-<number>-<short-slug>`.

### Step 4 — Ticket file
`mkdir -p "$TICKET_DIR"`; write `$TICKET_DIR/<P>-<number>-<slug>.md`:

```markdown
---
ticket: <P>-<number>
workflow: feature
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
## Integration Tests
## E2E Tests
## Visual Review
## Review
```

Commit: `chore: create ticket file for <P>-<number>`.

### Step 5 — Launch agents

Sequentially, `mode: "bypassPermissions"`, prompt
`Read \`.agents/skills/<skill>/SKILL.md\` and follow its instructions for ticket <P>-<number>.`

- **5a — explore**
- **5b — plan** (+ `Write the plan directly to the ticket file — do NOT use plan mode.`) → present `## Plan`, wait for approval, re-run with feedback if needed.
- **5c — implement-be** — if `areas` includes backend and `BACKEND_DIR` set.
- **5d — implement-fe** — if `areas` includes frontend and `FRONTEND_DIR` set
  (+ `Run \`cd $FRONTEND_DIR && $FRONTEND_INSTALL_CMD\` first if dependencies are missing.`).
- **5e — test-integration** — only if `INTEGRATION_TEST_CMD` is set. (Skip otherwise.)
- **5f — test-e2e** — only if `areas` includes frontend and `E2E_TEST_CMD` is set.
- **5g — test-visual** — only if design specs exist (issue attachments or
  `$DESIGNS_DIR` contains specs for this feature). If it reports discrepancies
  that need fixing, return to **implement-fe** before review.
- **5h — review**

### Step 6 — `ExitWorktree(action: "keep")`

### Step 7 — Output
PR URL (from the review agent), summary of changes, and `git worktree remove
<worktree path>`.

## Error Handling

Agent failure → stop and report; no `EnterWorktree` → `git checkout -b`; ticket
fetch fails → ask the user.

## Fallback (no devcontainer)

Output a manual runbook: `/explore` → `/plan` → `/implement-be` (if backend) →
`/implement-fe` (if frontend) → `/test-integration` (if configured) →
`/test-e2e` (if frontend & configured) → `/test-visual` (if specs exist) →
`/review`, each in a fresh session inside the worktree.
