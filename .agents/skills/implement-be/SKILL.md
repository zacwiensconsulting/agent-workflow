---
name: implement-be
description: Backend implementation step — TDD (red-green-refactor) for backend changes. Stack-specific conventions come from the backend reference skill.
metadata:
  version: "2.0"
---

# Implement Backend

TDD implementation for backend changes. Workflow is stack-agnostic; the *how to
write good code here* part is delegated to `$BACKEND_REFERENCE_SKILL`.

## When to Use

- After `/plan` is completed and approved
- The ticket's `areas` includes "backend"
- User runs `/implement-be <issue-number>`

## Config

Read `agent-workflow.config.sh` for: `BACKEND_DIR`, `BACKEND_INSTALL_CMD`,
`BACKEND_TEST_CMD`, `BACKEND_TEST_ONE_CMD`, `BACKEND_BUILD_CMD`,
`BACKEND_TYPECHECK_CMD`, `BACKEND_REFERENCE_SKILL`, `TESTING_REFERENCE_SKILL`,
`DOMAIN_DOC`, `TICKET_DIR`, `TICKET_PREFIX`. `<P>` = `$TICKET_PREFIX`. All
commands below run from `$BACKEND_DIR` unless noted.

## Instructions

### Step 1 — Load the ticket file
Read `$TICKET_DIR/<P>-<number>-<slug>.md`. `## Plan` must list specific changes,
test cases, and files. If empty, tell the user to run `/plan <number>` first.

### Step 2 — Read the plan, constraints, and affected files
Read every file in the plan's "files to create/modify" list, plus their existing
tests. Read the relevant sections of `$DOMAIN_DOC` (if set) for constraints your
change touches. Read `$BACKEND_REFERENCE_SKILL` and `$TESTING_REFERENCE_SKILL`
for patterns.

### Step 3 — Red: write failing tests
For each test case in the plan: write it, run it
(`$BACKEND_TEST_ONE_CMD "<test name>"` if set, else `$BACKEND_TEST_CMD`), confirm
it fails for the *right* reason (not a compile error / missing import). Use the
test setup patterns from `$TESTING_REFERENCE_SKILL`.

### Step 4 — Green: implement
Write the minimum code to make all tests pass; follow the plan and the
conventions in `$BACKEND_REFERENCE_SKILL` (layering, where new types go, schema
migrations, etc.). Run the affected tests after each change.

### Step 5 — Refactor
With tests green: remove duplication, fix naming, align with adjacent code. Run
the full suite — `$BACKEND_TEST_CMD` — to catch regressions. Fix any failures;
never skip/disable tests.

### Step 6 — Verify build / typecheck
Run `$BACKEND_BUILD_CMD` (and `$BACKEND_TYPECHECK_CMD` if set).

### Step 7 — Update the ticket file
Fill in `## Implementation`:

```markdown
## Implementation

### Backend Changes
- `Foo` — added doThing() for X
- `routes/Bar` — new GET /api/things
- `<migration file>` — things table

### Tests Added
- `FooTest.testDoThingWhenValid` — happy path
- `FooTest.testDoThingWhenInvalid` — error case

### Test Results
- All backend tests passing — no regressions
```

### Step 8 — Commit
```bash
git add -A
git commit -m "feat(<P>-<number>): <short description of backend changes>"   # feat|fix|refactor|chore
git add "$TICKET_DIR/<P>-<number>-<slug>.md"
git commit -m "chore(<P>-<number>): update ticket with backend implementation notes"
```

## Output

Summarize what was implemented + test results; tell the user the next step —
`/implement-fe <number>` if frontend work remains, else `/review <number>`.
