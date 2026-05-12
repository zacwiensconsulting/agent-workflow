---
name: test-e2e
description: Playwright e2e test step — write and run browser-based end-to-end tests, capture videos/screenshots for the PR.
metadata:
  version: "2.0"
---

# E2E Tests (Playwright)

Write and run Playwright browser-based end-to-end tests. Dedicated step because
e2e tests are slow and need careful setup.

## When to Use

- After implementation is done and integration tests pass; the feature has
  significant UI interaction
- `E2E_TEST_CMD` is set in the config
- User runs `/test-e2e <issue-number>`

If `E2E_TEST_CMD` is empty, skip and note in the ticket.

## Config

Read `agent-workflow.config.sh` for: `FRONTEND_DIR`, `E2E_TEST_CMD`,
`FRONTEND_DEV_URL`, `E2E_VIDEOS_DIR`, `E2E_SCREENSHOTS_DIR`, `TICKET_DIR`,
`TICKET_PREFIX`. `<P>` = `$TICKET_PREFIX`. Commands run from `$FRONTEND_DIR`.

## Instructions

1. **Load the ticket file** — what was implemented, which UI flows need coverage.
2. **Check Playwright setup** — `npx playwright --version`; confirm a
   `playwright.config.*` exists. If not, tell the user and help configure it
   (recommend `video: 'on'`, `screenshot: 'on'`, `baseURL: $FRONTEND_DEV_URL`).
3. **Design e2e cases** — happy path completes in the browser; error states
   render; form validation works; navigation flows.
4. **Write the tests** — page-object pattern if the project has one; `data-testid`
   selectors (add them to components if needed); independent tests (no shared
   state); meaningful names describing the user action.
5. **Run** — `$E2E_TEST_CMD`. Debug failures with `npx playwright test --ui`.
6. **Update the ticket file** — fill in `## E2E Tests` (tests added + results).
7. **Capture videos** — copy from `test-results/` into `$E2E_VIDEOS_DIR`, using
   the test name as the filename. Enforce safety limits: delete any `*.webm`
   > 50 MB; if more than 10 videos, keep only the 10 most recent.
8. **Capture screenshots** — copy from `test-results/` into `$E2E_SCREENSHOTS_DIR`
   (used by `/test-visual`).
9. **Commit** —
   `git add -A && git commit -m "test(<P>-<number>): add Playwright e2e tests for <feature>"`;
   commit videos separately (`test(<P>-<number>): add e2e video recordings`);
   commit the ticket update.

## Output

Summarize results; tell the user to run `/test-visual <number>` (if design specs
exist) or `/review <number>` next.
