---
name: backend-reference
description: TEMPLATE — backend coding reference for THIS project. Rename this skill, fill it in, and point BACKEND_REFERENCE_SKILL at it.
metadata:
  version: "0.1-template"
---

# Backend Reference — TEMPLATE

> **This is a template.** Copy this directory, rename it to something descriptive
> for your stack (`firebase-functions`, `core`, `express-api`, …), fill in the
> sections below, and set `BACKEND_REFERENCE_SKILL=<that-name>` in
> `agent-workflow.config.sh`. Then delete this template directory (or leave it —
> `install.sh` ignores `_`-prefixed dirs).
>
> The generic `implement-be`, `plan`, and `review` skills consult this skill for
> "how do I write good backend code in this codebase". Be concrete.

## When to Use

- Implementing or reviewing backend code in this project
- User runs `/<this-skill-name>` or asks how the backend is structured

## Directory Layout

<Describe the backend package layout — where routes/controllers, services,
data access, models, config live. e.g. for Firebase Functions: `src/http/`,
`src/triggers/`, `src/callable/`, `src/lib/`, `index.ts` exports.>

## Canonical Patterns

<The 2–4 patterns an implementer should copy. Name a real file to use as a
reference for each. e.g.:
- HTTP function: see `src/http/createThing.ts`
- Firestore trigger: see `src/triggers/onThingWritten.ts`
- Callable: see `src/callable/getThing.ts`
- Shared validation: `src/lib/validate.ts`>

## Rules / Conventions

<Layering rules, where new code goes, naming, error handling, how config/secrets
are accessed, how external services are wrapped, transaction expectations,
migration/schema-change process, anything Jackson/serialization-like that bites
people.>

## Testing

<How backend tests are structured here, the test command (also in
`agent-workflow.config.sh` as `BACKEND_TEST_CMD`), how to set up test
dependencies, how to mock/emulate external services, any test-data seeding
helpers. Cross-reference `TESTING_REFERENCE_SKILL` if you have one.>

## Review Checklist (project-specific)

<Items the `/review` skill should add to its generic checklist for this codebase.
e.g.:
- [ ] Callable functions check `context.auth` before doing anything
- [ ] Firestore writes that span documents use a batch or transaction
- [ ] No `functions.config()` reads outside `src/lib/config.ts`>

## Common Gotchas

<The things that have bitten people. e.g. cold-start cost of top-level imports,
emulator vs prod behavior differences, region pinning, etc.>
