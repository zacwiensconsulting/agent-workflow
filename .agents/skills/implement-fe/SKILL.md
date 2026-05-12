---
name: implement-fe
description: Frontend implementation step — TDD (red-green-refactor) for frontend changes. Stack-specific conventions come from the frontend reference skill.
metadata:
  version: "2.0"
---

# Implement Frontend

TDD implementation for frontend changes. Workflow is stack-agnostic; the *how to
write good code here* part is delegated to `$FRONTEND_REFERENCE_SKILL`.

## When to Use

- After `/plan` is completed and approved
- The ticket's `areas` includes "frontend"
- User runs `/implement-fe <issue-number>`

## Config

Read `agent-workflow.config.sh` for: `FRONTEND_DIR`, `FRONTEND_INSTALL_CMD`,
`FRONTEND_TEST_CMD`, `FRONTEND_BUILD_CMD`, `FRONTEND_REFERENCE_SKILL`,
`TYPE_GEN_CMD`, `ARCHITECTURE_DOC`, `TICKET_DIR`, `TICKET_PREFIX`. `<P>` =
`$TICKET_PREFIX`. Commands below run from `$FRONTEND_DIR` unless noted.

## Instructions

### Step 1 — Load the ticket file
Read `$TICKET_DIR/<P>-<number>-<slug>.md`. `## Plan` must be filled in; if empty,
tell the user to run `/plan <number>` first. If `areas` includes backend and it
was implemented first, read the backend implementation notes for the API contract.

### Step 2 — Install deps if missing
`cd $FRONTEND_DIR && $FRONTEND_INSTALL_CMD` if dependencies aren't present.

### Step 3 — Read the plan, API contract, affected files
Read every frontend file in the plan, plus adjacent components/services to match
patterns. Read the relevant API-contract section of `$ARCHITECTURE_DOC` (if set);
cross-reference the ticket's backend implementation notes if present. Read
`$FRONTEND_REFERENCE_SKILL` for patterns.

### Step 4 — Regenerate API types if needed
If backend changes added/changed DTOs or endpoints and `$TYPE_GEN_CMD` is set,
run it.

### Step 5 — Red: write failing tests
For each frontend test case in the plan: write it, run it (`$FRONTEND_TEST_CMD`,
scoped to the affected spec if your runner supports it), confirm it fails for the
right reason.

### Step 6 — Green: implement
Write the minimum code to pass; follow the conventions in
`$FRONTEND_REFERENCE_SKILL` and adjacent components. Run the affected tests after
each change.

### Step 7 — Refactor
With tests green: clean up, check bindings/styling against existing patterns. Run
the full frontend suite + build: `$FRONTEND_BUILD_CMD && $FRONTEND_TEST_CMD`.

### Step 8 — Update the ticket file
Append to `## Implementation`:

```markdown
### Frontend Changes
- `some.component` — added display for X
- `some.service` — new API call for Z

### Frontend Tests Added
- `some.component.spec: should display X when Y`

### Frontend Test Results
- All frontend tests passing — build succeeds
```

### Step 9 — Commit
```bash
cd $FRONTEND_DIR && git add -A
git commit -m "feat(<P>-<number>): <short description of frontend changes>"
git add "$TICKET_DIR/<P>-<number>-<slug>.md"
git commit -m "chore(<P>-<number>): update ticket with frontend implementation notes"
```

## Output

Summarize what was implemented + test results; tell the user the next step —
`/test-integration <number>`, `/test-e2e <number>`, or `/review <number>`.
