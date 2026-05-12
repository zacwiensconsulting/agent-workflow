---
name: review
description: Review step — run the full test suite, self-review all changes on the branch, create a pull request.
metadata:
  version: "2.0"
---

# Review

Final step of any workflow: run the full suite, self-review the branch diff,
open a PR.

## When to Use

- Last step of any workflow; all implementation and testing steps are complete
- User runs `/review <issue-number>`

## Config

Read `agent-workflow.config.sh` for: `BACKEND_DIR`, `BACKEND_TEST_CMD`,
`FRONTEND_DIR`, `FRONTEND_TEST_CMD`, `FRONTEND_BUILD_CMD`, `INTEGRATION_DIR`,
`INTEGRATION_TEST_CMD`, `TYPE_GEN_CMD`, `E2E_VIDEOS_DIR`,
`BACKEND_REFERENCE_SKILL`, `FRONTEND_REFERENCE_SKILL`, `TICKET_DIR`,
`TICKET_PREFIX`. `<P>` = `$TICKET_PREFIX`.

## Instructions

### Step 1 — Load the ticket file
Read `$TICKET_DIR/<P>-<number>-<slug>.md`: workflow, what was explored / planned
/ implemented, what tests were written.

### Step 2 — Read all changes on the branch
```bash
git log main..HEAD --oneline
git diff main...HEAD --stat
git diff main...HEAD          # read it
```

### Step 3 — Run the full test suite
Run all applicable suites (in parallel where possible):
- Backend: `cd $BACKEND_DIR && $BACKEND_TEST_CMD` (if `BACKEND_DIR` set)
- Frontend: `cd $FRONTEND_DIR && $FRONTEND_BUILD_CMD && $FRONTEND_TEST_CMD` (if `FRONTEND_DIR` set)
- Integration: `cd $INTEGRATION_DIR && $INTEGRATION_TEST_CMD` (if those are set *and* integration tests were added/modified)

All must pass. Fix failures before continuing — never skip/disable tests.

### Step 4 — Self-review checklist
Review the diff against:
- [ ] Architecture/layering respected (per `$BACKEND_REFERENCE_SKILL` / `$FRONTEND_REFERENCE_SKILL`)
- [ ] No business logic in route/controller handlers — delegate to services
- [ ] No unused imports / dead code added
- [ ] Schema migrations numbered/ordered correctly (if applicable)
- [ ] Frontend follows the project's state/data conventions
- [ ] Tests cover the actual change, not just boilerplate
- [ ] No hardcoded values that should be configurable
- [ ] No security issues (injection, XSS, missing authz)
- [ ] Multi-write operations are transactional where the project requires it
- [ ] Commit messages follow conventional commits
- [ ] **Any project-specific checklist items in `$BACKEND_REFERENCE_SKILL` / `$FRONTEND_REFERENCE_SKILL` are satisfied**

Fix any issues found; re-run affected tests.

### Step 5 — Regenerate generated types if needed
If `$TYPE_GEN_CMD` is set and DTOs/endpoints changed, run it; `git diff --name-only`;
if generated files changed, commit them: `chore(<P>-<number>): regenerate generated types`.

### Step 6 — Ensure e2e videos are committed
If e2e tests ran and `$E2E_VIDEOS_DIR` has uncommitted `*.webm`, `git add` and
commit them: `test(<P>-<number>): add e2e video recordings`.

### Step 7 — Update the ticket file
Fill in `## Review` with test results, the self-review outcome (issues found/fixed),
and a placeholder for the PR URL.

### Step 8 — Create the pull request
```bash
git push -u origin <branch-name>
gh pr create --title "<type>(<P>-<number>): <short title>" --body "$(cat <<'EOF'
## Summary
<2-3 bullets from the ticket file>

Closes #<number>

## Changes
<key changes from implementation notes>

## Test Plan
<tests added from the ticket file>

## E2E Videos
<list videos in $E2E_VIDEOS_DIR with descriptions, if any>

## Ticket Context
See `$TICKET_DIR/<P>-<number>-<slug>.md` for full exploration, plan, and implementation notes.
EOF
)"
```
Then commit the final ticket update (with the PR link) and `git push`.

## Output

Display the PR URL and a summary: what changed, test results, notes for the reviewer.
