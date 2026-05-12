---
name: frontend-reference
description: TEMPLATE — frontend coding reference for THIS project. Rename this skill, fill it in, and point FRONTEND_REFERENCE_SKILL at it.
metadata:
  version: "0.1-template"
---

# Frontend Reference — TEMPLATE

> **This is a template.** Copy this directory, rename it (`angular-app`, `ui`,
> `web`, …), fill it in, and set `FRONTEND_REFERENCE_SKILL=<that-name>` in
> `agent-workflow.config.sh`. The generic `implement-fe`, `plan`, `review`, and
> `test-visual` skills consult this skill. Be concrete.
>
> If your project also has a separate frontend surface (e.g. mobile apps on a
> Firestore SDK), make a *second* reference skill for it (e.g. `mobile-firestore`)
> and extend the orchestrators' area list — see `ADAPTING.md`.

## When to Use

- Implementing or reviewing frontend code in this project
- User runs `/<this-skill-name>` or asks how the frontend is structured

## Directory Layout

<Where features/pages, shared components, services, utils, state live. e.g. for
Angular: `src/app/features/<feature>/`, `src/app/shared/`, `src/app/core/services/`.>

## Canonical Patterns

<2–4 patterns to copy, each pointing at a real file. e.g.:
- Page component: see `src/app/features/things/things-page.component.ts`
- HTTP access: use `ApiService`, see `src/app/core/services/api.service.ts`
- Data grid column defs: typed `ColDef<RowType>`, see `things-table.component.ts`
- Dialog/snackbar UX: see `confirm-dialog.component.ts`>

## Rules / Conventions

<Component style (standalone? modules?), state management (signals? stores?),
HTTP access rules, UI component library usage, routing vs raw URLs, file
co-location, styling conventions, typed-API usage.>

## Design System

<Tokens / theme / spacing scale / typography that `/test-visual` should check
against. Point at the theme file(s).>

## Testing

<Test framework, the command (`FRONTEND_TEST_CMD` in the config), how to scope to
one spec, common harness setup, how to mock HTTP, e2e/Playwright notes if any.>

## Review Checklist (project-specific)

<Items `/review` should add for this codebase. e.g.:
- [ ] Uses signals, not mutable component fields, for view state
- [ ] Uses `ApiService`, not raw HttpClient
- [ ] New components are standalone with explicit `imports`>

## Common Gotchas

<env config that points at a remote API by default, change-detection traps,
build-vs-test discrepancies, etc.>
