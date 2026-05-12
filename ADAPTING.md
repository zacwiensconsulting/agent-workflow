# Adapting the bundle to a new project

The bundle ships with **generic** orchestrators and pipeline steps. Everything
project-specific is pushed into one config file plus a handful of "reference
skills" you write per project. This doc explains the seams.

## The model in one paragraph

Orchestrators (`/bugfix`, `/feature`, …) and the generic steps (`/explore`,
`/plan`, `/review`, `/test-integration`, `/test-e2e`, `/test-visual`) are
**stack-agnostic** — they're driven entirely by `agent-workflow.config.sh`. The
two TDD steps (`/implement-be`, `/implement-fe`) keep their **workflow** generic
(red → green → refactor, commit cadence, ticket updates) but delegate all
**stack substance** ("how do I write a good X in this codebase") to a
**reference skill** named in the config (`BACKEND_REFERENCE_SKILL`,
`FRONTEND_REFERENCE_SKILL`). You write those reference skills once per project —
start from `.agents/skills/_project-templates/`.

```
config (where + how to build/test)  ──→  all generic skills read this
reference skills (how to write code) ──→  implement-be / implement-fe consult these
```

## Step 1 — `agent-workflow.config.sh`

Copy it to the repo root and fill it in. Key groups:

- **Directories** — `BACKEND_DIR`, `FRONTEND_DIR`, `INTEGRATION_DIR`,
  `TICKET_DIR`. Set anything you don't have to `""`; skills check and skip.
- **Reference docs** — `ARCHITECTURE_DOC`, `DOMAIN_DOC`. The smc equivalents are
  `docs/ARCHITECTURE.md` / `docs/DOMAIN.md`. `""` if you have none.
- **Role → skill map** — `BACKEND_REFERENCE_SKILL=firebase-functions`,
  `FRONTEND_REFERENCE_SKILL=angular-app`, etc. This is the "different folders map
  to different skills" knob.
- **Commands** — `BACKEND_TEST_CMD`, `FRONTEND_BUILD_CMD`, `INTEGRATION_TEST_CMD`,
  `E2E_TEST_CMD`, `TYPE_GEN_CMD`, … Empty disables the corresponding step/section.
- **Branch prefixes / ticket scheme** — `BRANCH_PREFIX_*`, `TICKET_PREFIX`,
  `ISSUE_FETCH_CMD`.
- **Devcontainer** — only used if you adopt `dev.sh`. `FIREWALL_EXTRA_DOMAINS`
  for the firewall allowlist.

## Step 2 — Reference skills

`_project-templates/` has three skeletons: `backend-reference`,
`frontend-reference`, `testing-reference`. For each:

1. Rename the directory to something descriptive (`firebase-functions`,
   `angular-app`, `mobile-firestore`, …).
2. Fill in the SKILL.md with the conventions an implementer needs: directory
   layout, the canonical patterns to copy, framework gotchas, how tests are
   structured, how to mock external services, naming rules.
3. Point the config at it (`BACKEND_REFERENCE_SKILL=firebase-functions`).

If you already have skills like this (smc has `core`, `ui`, `testing`), just
point the config at them and delete the templates.

You can have **more than three**. Example for a project with an Angular web app +
mobile apps on the Firestore SDK:

```
.agents/skills/
  firebase-functions/    # backend reference  → BACKEND_REFERENCE_SKILL
  angular-web/           # web frontend ref   → FRONTEND_REFERENCE_SKILL
  mobile-firestore/      # extra ref, consulted when areas touches mobile
  testing/               # test patterns ref  → TESTING_REFERENCE_SKILL
```

When you add an area that isn't "backend" or "frontend" (e.g. `mobile`), also
extend the orchestrators' area-classification list and add an implement step (or
reuse `implement-fe`-style flow) — see Step 4.

## Step 3 — Trim what you don't use

- No design specs / visual QA → delete `.agents/skills/test-visual/` and the
  `test-visual` calls in `feature/SKILL.md`.
- No integration suite → set `INTEGRATION_TEST_CMD=""` (the step self-skips) or
  delete `.agents/skills/test-integration/`.
- No browser e2e → set `E2E_TEST_CMD=""` or delete `.agents/skills/test-e2e/`.
- Backend-only or frontend-only project → set the unused `*_DIR` to `""`; the
  orchestrators skip that implement step.
- No `dev.sh` / devcontainer → don't copy `dev.sh`; the orchestrators fall back
  to `git checkout -b` instead of `EnterWorktree` (see each orchestrator's
  "Fallback" section).

## Step 4 — Adding a new area (e.g. mobile)

1. In each orchestrator's "determine affected areas" step, add `mobile` to the
   classification list and to the `areas:` frontmatter options.
2. Either reuse `implement-fe`'s flow with a different reference skill, or add a
   new `.agents/skills/implement-mobile/SKILL.md` (copy `implement-fe`, swap the
   reference-skill var, swap the test command var). Add a config var like
   `MOBILE_DIR` / `MOBILE_TEST_CMD` / `MOBILE_REFERENCE_SKILL`.
3. Add a launch block for it in the orchestrators that should run it.
4. `./install.sh` to pick up the new skill symlink.

## Step 5 — Install & verify

```bash
./install.sh
ls -la .claude/skills/        # should show symlinks into ../../.agents/skills/*
```

Then in Claude Code: `/bugfix <issue-number>`.

## What stays SMC-specific and must NOT be copied verbatim

The bundle has already had these stripped, but if you ever re-derive from the
original smc repo, watch for:

- Hard-coded `smc-core` / `smc-ui` / `smc-test` paths and `./gradlew` / `ng` /
  `vitest` commands → now config vars.
- The OpenAPI type-generation pipeline → now `TYPE_GEN_CMD` (empty by default).
- The `test-integration` trigger text ("Service Bus, mail processing,
  save/recalculate") → now `INTEGRATION_TEST_TRIGGERS`.
- Domain-specific review-checklist items (paid-shift guard, Flyway migration
  numbering, `jdbi.inTransaction`) → moved into the backend reference skill;
  `review/SKILL.md` keeps only generic checks plus "apply the checklist in
  $BACKEND_REFERENCE_SKILL".
- `.devcontainer/init-firewall.sh` allowlist (Maven Central, plugins.gradle.org,
  PostgreSQL apt) → `FIREWALL_EXTRA_DOMAINS`.
- The "Validated 2026-04-20" / JAVA_HOME / ipset / em-dash gotchas from
  `agent-workflow.md` → moved to a devcontainer README, not the design doc.
