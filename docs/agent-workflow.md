# Agent Workflow

> See [agent-workflow.puml](agent-workflow.puml) for the visual diagram.
> See [../ADAPTING.md](../ADAPTING.md) for how to configure this for your project.

## Overview

Orchestrator skills (`/bugfix`, `/feature`, `/enhancement`, `/troubleshoot`)
fetch a ticket, create an isolated git worktree, then launch a chain of
sub-agents — one per workflow step — each with a fresh context window and (when
run inside a sandboxed devcontainer) zero permission prompts.

The orchestrator coordinates but does not write code.

All project-specific details (directory names, build/test commands, reference
skills, branch prefixes) live in `agent-workflow.config.sh` at the repo root.
The skills read it; you edit it once per project.

## Prerequisites

- `gh` authenticated (for `gh issue view` / `gh pr create`) — or adjust
  `ISSUE_FETCH_CMD` in the config if you track tickets elsewhere.
- A filled-in `agent-workflow.config.sh` and `./install.sh` already run.
- *Optional* — a devcontainer + `dev.sh` so agents can run with
  `bypassPermissions`. Without it, orchestrators emit a manual runbook instead
  of launching agents.

## Architecture

```
User runs /bugfix 119
    │
    ▼
Orchestrator (current session)
    ├── 1. Fetch ticket  (gh issue view)
    ├── 2. Classify areas (backend / frontend / both / …)
    ├── 3. EnterWorktree → git branch -m to <prefix>/<TICKET>-<n>-<slug>
    ├── 4. Create ticket file in $TICKET_DIR + commit
    │
    ├── 5a. Agent: /explore         → updates ticket, commits
    ├── 5b. Agent: /plan            → updates ticket, commits
    │       ▼  Orchestrator shows the plan to the user, waits for approval
    │
    ├── 5c. Agent: /implement-be    → TDD, commits   (if backend)
    ├── 5d. Agent: /implement-fe    → TDD, commits   (if frontend)
    ├── 5e. Agent: /test-integration → (if INTEGRATION_TEST_CMD set & relevant)
    ├── 5f. Agent: /test-e2e        → (feature workflow, if frontend & E2E_TEST_CMD set)
    ├── 5g. Agent: /test-visual     → (feature workflow, if design specs exist)
    ├── 5h. Agent: /review          → runs full suite, pushes, opens PR
    │
    ├── 6. ExitWorktree (keep)
    └── 7. Display PR URL + cleanup command
```

## Orchestrator flow (detail)

### 1 — Fetch the ticket
`$ISSUE_FETCH_CMD <number> --json title,body,labels,assignees,milestone`
(troubleshoot also fetches `comments`).

### 2 — Classify areas
Read the body. Classify as **backend**, **frontend**, **both**, or any extra
areas your project defines (see ADAPTING.md "Adding a new area").

### 3 — Enter a worktree
`EnterWorktree(name: "<prefix>-<TICKET_PREFIX>-<number>")`, then
`git branch -m "$(git branch --show-current)" <prefix>/<TICKET_PREFIX>-<number>-<short-slug>`
using a 2–4 word kebab-case slug from the title. The worktree branches from HEAD.
If `EnterWorktree` is unavailable, fall back to `git checkout -b`.

### 4 — Create the ticket file
Write `$TICKET_DIR/<TICKET_PREFIX>-<number>-<slug>.md`:

```markdown
---
ticket: <TICKET_PREFIX>-<number>
workflow: bugfix | feature | enhancement | troubleshoot
branch: <prefix>/<TICKET_PREFIX>-<number>-<slug>
ticket_file: <path to this file>
areas: [backend] | [frontend] | [backend, frontend] | …
created: <date>
---

# <TICKET_PREFIX>-<number>: <Title>

## Ticket
<issue body (+ comments for troubleshoot)>

## Exploration
## Plan
## Implementation
## Integration Tests        (feature only)
## E2E Tests                (feature only)
## Visual Review            (feature only)
## Review
```

Commit it: `chore: create ticket file for <TICKET_PREFIX>-<number>`.

### 5 — Launch agents
Each agent is launched with `mode: "bypassPermissions"`, sequentially (they
share the worktree filesystem — never run them in parallel). Prompt template:

```
Read `.agents/skills/<skill>/SKILL.md` and follow its instructions for ticket <TICKET_PREFIX>-<number>.
```

After the **plan** agent finishes, the orchestrator reads the `## Plan` section
from the ticket file, presents it to the user, and waits for approval. On
rejection, re-run the plan agent with the feedback appended to the prompt.

Step gating:
- `implement-be` — only if `areas` includes backend and `BACKEND_DIR` is set.
- `implement-fe` — only if `areas` includes frontend and `FRONTEND_DIR` is set.
  The orchestrator's prompt tells it to run `FRONTEND_INSTALL_CMD` first if deps
  are missing.
- `test-integration` — only if `INTEGRATION_TEST_CMD` is set *and* the ticket
  matches `INTEGRATION_TEST_TRIGGERS`.
- `test-e2e` — feature workflow, only if `areas` includes frontend and
  `E2E_TEST_CMD` is set.
- `test-visual` — feature workflow, only if design specs exist (issue
  attachments or `$DESIGNS_DIR`). If it finds discrepancies that need fixing,
  loop back to `implement-fe` before `review`.

### 6 — Exit the worktree
`ExitWorktree(action: "keep")`.

### 7 — Output
PR URL (from the review agent), a summary of changes, test results, and the
cleanup command: `git worktree remove <worktree path>`.

## Workflow variants

| Workflow | Steps | Branch prefix |
|---|---|---|
| Bugfix | explore → plan → implement-be/fe → review | `$BRANCH_PREFIX_BUGFIX` |
| Feature | explore → plan → implement-be → implement-fe → test-integration → test-e2e → test-visual → review | `$BRANCH_PREFIX_FEATURE` |
| Enhancement | explore → plan → implement-be/fe → review | `$BRANCH_PREFIX_ENHANCEMENT` |
| Troubleshoot | explore → plan(diagnosis) → (may pivot to implement-be/fe → review) | `$BRANCH_PREFIX_TROUBLESHOOT` |

## Ticket files, E2E videos, visual review

- **Ticket files** live in `$TICKET_DIR` (visible, tracked, part of the PR). The
  filename includes a kebab-case slug for readability. Frontmatter carries a
  `ticket_file:` self-reference.
- **E2E videos** (if Playwright runs with `video: 'on'`) are copied to
  `$E2E_VIDEOS_DIR` and committed. Safety limits: ≤ 50 MB per file, ≤ 10 files
  per PR (oldest pruned). The review agent ensures they're committed before
  opening the PR; they're listed in the PR body.
- **Visual review** (feature only) compares e2e screenshots in
  `$E2E_SCREENSHOTS_DIR` against design specs. Spec sources, in order: GitHub
  issue attachments, then `$DESIGNS_DIR` (`<TICKET_PREFIX>-<n>-*.png`,
  `<feature>-*.png`, `components/<name>.png`). Findings go in the ticket file; on
  discrepancies the agent asks whether to fix before proceeding.

## Notes / known constraints

- **Agents run sequentially** — they share the worktree filesystem.
- **Devcontainer firewall** — if you use `dev.sh`, the container restricts
  outbound traffic; add any extra hosts your build needs to
  `FIREWALL_EXTRA_DOMAINS`.
- **Plan rejection / agent failure** — current behavior: re-run the plan agent
  with feedback; on a mid-workflow agent failure, stop and report (don't auto-retry).
