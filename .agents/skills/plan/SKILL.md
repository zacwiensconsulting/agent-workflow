---
name: plan
description: Planning step — design the implementation approach, identify tests to write, get user alignment before coding.
metadata:
  version: "2.0"
---

# Plan

Design the implementation approach from exploration findings. Produces a concrete
plan the implement steps will follow.

## When to Use

- After `/explore` has completed for the ticket
- User runs `/plan <issue-number>`

## Config

Read `agent-workflow.config.sh` for: `TICKET_DIR`, `TICKET_PREFIX`,
`ARCHITECTURE_DOC`, `DOMAIN_DOC`, `BACKEND_REFERENCE_SKILL`,
`FRONTEND_REFERENCE_SKILL`, `TESTING_REFERENCE_SKILL`, `TYPE_GEN_CMD`. `<P>` =
`$TICKET_PREFIX`.

## Instructions

### Step 1 — Load the ticket file
Read `$TICKET_DIR/<P>-<number>-<slug>.md`. `## Exploration` should be filled in;
if empty, tell the user to run `/explore <number>` first.

### Step 2 — Read architecture/domain docs, reference skills, and affected files
Read `$ARCHITECTURE_DOC` / `$DOMAIN_DOC` if set — they hold the constraints that
shape the plan. Read the reference skill for the area(s) involved: backend →
`$BACKEND_REFERENCE_SKILL`, frontend → `$FRONTEND_REFERENCE_SKILL`, tests →
`$TESTING_REFERENCE_SKILL`. Then read the key files from the exploration findings
— don't skim.

### Step 3 — Design the plan

- **Bugs** — root cause (line-level), fix approach + why it's correct, the
  failing test to write first (TDD red), risk/side-effect assessment.
- **Features** — where new code goes (modules/files/classes), API design
  (endpoints, request/response shapes), data/schema changes, implementation
  order (dependencies), test strategy per layer, frontend design if applicable.
- **Enhancements** — specific modifications, backward compatibility, new + updated
  tests, migration path if data/API shapes change.
- **Troubleshooting** — root cause diagnosis, evidence (logs, code paths, repro),
  resolution options ranked by confidence/risk, recommendation.

### Step 4 — Present the plan (plan mode)
Use the plan-mode tool. Structure: 1) Summary (one paragraph, what & why),
2) Changes (ordered, with file paths), 3) Tests (name each test, what it
asserts), 4) Files to create/modify (exhaustive), 5) Open questions.

### Step 5 — Get user alignment
Present and wait for approval; address questions.

> When invoked by an orchestrator agent the prompt will say "do NOT use plan
> mode" — in that case skip steps 4–5 and write the plan straight to the ticket
> file (the orchestrator handles user approval).

### Step 6 — Update the ticket file
Fill in `## Plan` in `$TICKET_DIR/<P>-<number>-<slug>.md`:

```markdown
## Plan

### Summary
<one paragraph>

### Changes
1. <change + file path>

### Tests to Write
- `testFoo` — asserts X when Y
- `should display error when Z` — frontend test

### Open Decisions
- <decisions made during alignment>
```

### Step 7 — Commit
```bash
git add "$TICKET_DIR/<P>-<number>-<slug>.md"
git commit -m "chore(<P>-<number>): implementation plan"
```

## Output

Display the plan summary; tell the user to start a fresh session and run
`/implement-be <number>` or `/implement-fe <number>` next (per the ticket's `areas`).
