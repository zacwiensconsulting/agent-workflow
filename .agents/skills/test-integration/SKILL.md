---
name: test-integration
description: Integration test step — write and run end-to-end tests against a real backend + datastore.
metadata:
  version: "2.0"
---

# Integration Tests

Write and run integration tests that exercise the real backend against a real
datastore (or emulator).

## When to Use

- After implementation is done, when the change touches multi-service flows,
  persistence behavior, or API contracts
- `INTEGRATION_TEST_CMD` is set in the config
- User runs `/test-integration <issue-number>`

If `INTEGRATION_TEST_CMD` is empty, skip this step and note in the ticket that
integration tests are not configured for this project.

## Config

Read `agent-workflow.config.sh` for: `INTEGRATION_DIR`, `INTEGRATION_TEST_CMD`,
`INTEGRATION_TEST_TRIGGERS`, `TESTING_REFERENCE_SKILL`, `TICKET_DIR`,
`TICKET_PREFIX`. `<P>` = `$TICKET_PREFIX`. Commands run from `$INTEGRATION_DIR`.

## Instructions

1. **Load the ticket file** — `$TICKET_DIR/<P>-<number>-<slug>.md`; `##
   Implementation` should describe what was built.
2. **Read existing integration tests** — review `$TESTING_REFERENCE_SKILL` for
   integration patterns; explore `$INTEGRATION_DIR` for a template test, the test
   utilities, and how test data is seeded.
3. **Design test cases** — happy path end to end (request → correct response),
   edge cases unit tests can't catch (multi-table/transactional behavior),
   contract validation (shapes match what the frontend expects).
4. **Write the tests** — follow existing patterns; seed needed reference data;
   make real calls to the backend.
5. **Run** — `cd $INTEGRATION_DIR && $INTEGRATION_TEST_CMD`. Fix failures; don't
   skip/disable.
6. **Update the ticket file** — fill in `## Integration Tests` (tests added +
   results).
7. **Commit** —
   `git add $INTEGRATION_DIR "$TICKET_DIR/<P>-<number>-<slug>.md" && git commit -m "test(<P>-<number>): add integration tests for <feature>"`.

## Output

Summarize results; tell the user the next step — `/test-e2e <number>` or
`/review <number>`.
