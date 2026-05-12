---
name: testing-reference
description: TEMPLATE — test-writing reference for THIS project. Rename this skill, fill it in, and point TESTING_REFERENCE_SKILL at it.
metadata:
  version: "0.1-template"
---

# Testing Reference — TEMPLATE

> **This is a template.** Copy this directory, rename it (`testing`, …), fill it
> in, and set `TESTING_REFERENCE_SKILL=<that-name>` in
> `agent-workflow.config.sh`. The `implement-be`, `implement-fe`, and
> `test-integration` skills consult this for "how do I write a test here".

## When to Use

- Writing backend, frontend, or integration tests in this project
- User runs `/<this-skill-name>`

## Test Layers

<What kinds of tests this project has and what each covers. e.g.:
- Unit (backend): in-memory deps, no datastore — `BACKEND_TEST_CMD`
- Unit (frontend): component harness — `FRONTEND_TEST_CMD`
- Integration: real backend + real/emulated datastore — `INTEGRATION_TEST_CMD`
- E2E: Playwright in a browser — `E2E_TEST_CMD`>

## Backend Test Patterns

<DI / service-factory setup, how to spin up a temp datastore, how to seed
reference data, where tests live, naming conventions. Point at a canonical test
file.>

## Frontend Test Patterns

<TestBed / harness setup, how to mock HTTP, how to render a component, where
specs live, naming. Point at a canonical spec file.>

## Integration Test Patterns

<How the harness manages its datastore (port, lifecycle), how to seed data, how
to make real requests, where tests live. Point at a canonical test file.>

## Common Gotchas

<Flaky-test traps, ordering issues, async/await pitfalls, fixture cleanup, file
naming that breaks on certain filesystems, etc.>
