---
name: troubleshoot
description: Troubleshoot orchestrator — investigates a reported issue, diagnoses root cause, and optionally pivots to a fix workflow.
metadata:
  version: "3.0"
---

# Troubleshoot Orchestrator

Investigate issues where the root cause is unknown. Launches explore + plan
(diagnosis) agents, then — if a code bug is confirmed — pivots to implement +
review (same as the bugfix tail).

## When to Use

- User reports a problem but doesn't know the root cause / sees unexpected behavior
- An alert fired and needs investigation
- User runs `/troubleshoot <issue-number>`

## Config

Read `agent-workflow.config.sh` for: `BACKEND_DIR`, `FRONTEND_DIR`,
`FRONTEND_INSTALL_CMD`, `TICKET_DIR`, `TICKET_PREFIX`, `ISSUE_FETCH_CMD`,
`BRANCH_PREFIX_TROUBLESHOOT`. `<P>` = `$TICKET_PREFIX`, `<BR>` =
`$BRANCH_PREFIX_TROUBLESHOOT`. If the project has a logs skill, note its name.

## Instructions

### Step 1 — Fetch the ticket (with comments)
`$ISSUE_FETCH_CMD <number> --json title,body,labels,assignees,milestone,comments` —
comments often hold repro steps.

### Step 2 — Worktree
`EnterWorktree(name: "<BR>-<P>-<number>")`, then
`git branch -m "$(git branch --show-current)" <BR>/<P>-<number>-<short-slug>`.

### Step 3 — Ticket file
`mkdir -p "$TICKET_DIR"`; write `$TICKET_DIR/<P>-<number>-<slug>.md` with
frontmatter (`ticket`, `workflow: troubleshoot`, `branch`, `ticket_file`,
`areas: [unknown]`, `created`) and sections:
`## Ticket / ## Symptoms / ## Exploration / ## Diagnosis / ## Resolution`.
Commit: `chore: create ticket file for <P>-<number>`.

### Step 4 — Check logs if relevant
If the issue mentions errors / alerts / production behavior and the project has a
logs skill, run it and add findings under `## Symptoms`, then commit.

### Step 5 — Launch diagnosis agents

Sequentially, `mode: "bypassPermissions"`:
- **explore** — `Read \`.agents/skills/explore/SKILL.md\` and follow its instructions for ticket <P>-<number>. This is a troubleshooting investigation — focus on finding the root cause, not just affected files.`
- **plan (diagnosis)** — `Read \`.agents/skills/plan/SKILL.md\` and follow its instructions for ticket <P>-<number>. This is a troubleshooting workflow — the plan should focus on root cause diagnosis and resolution options. Write directly to the ticket file — do NOT use plan mode.`

### Step 6 — Present diagnosis, decide next steps

Read the ticket file, present the diagnosis. Outcomes:
- **Code bug found** — ask the user whether to continue with implement + review
  (steps 7a–7c below).
- **Config / infra issue** — document the resolution; no further agents.
- **Cannot reproduce** — document findings; suggest closing or requesting more info.

If continuing to fix:
- **7a — implement-be** — if needed and `BACKEND_DIR` set.
- **7b — implement-fe** — if needed and `FRONTEND_DIR` set (+ `Run \`cd $FRONTEND_DIR && $FRONTEND_INSTALL_CMD\` first if dependencies are missing.`).
- **7c — review**

### Step 7 — `ExitWorktree(action: "keep")`

### Step 8 — Output
Diagnosis summary; resolution (PR URL if a code fix, else manual steps);
`git worktree remove <worktree path>`.

## Error Handling

Agent failure → stop and report; no `EnterWorktree` → `git checkout -b`; ticket
fetch fails → ask the user.

## Fallback (no devcontainer)

Output a manual runbook: `/explore` (deep investigation + logs) → `/plan` (root
cause diagnosis); then, based on outcome, `/implement-be` / `/implement-fe` /
`/review`.
