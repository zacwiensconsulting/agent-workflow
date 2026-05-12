---
name: explore
description: Exploration step — deep codebase investigation for a ticket. Maps affected files, dependencies, test coverage, documents findings.
metadata:
  version: "2.0"
---

# Explore

Deep codebase exploration for a ticket — the first step of any workflow.
Understand the problem space before planning or writing code.

## When to Use

- First step of any workflow (bugfix, feature, enhancement, troubleshoot)
- User runs `/explore <issue-number>`

## Config

Read `agent-workflow.config.sh` for: `TICKET_DIR`, `TICKET_PREFIX`,
`ARCHITECTURE_DOC`, `DOMAIN_DOC`, and (for context) the
`*_REFERENCE_SKILL` names. `<P>` = `$TICKET_PREFIX`.

## Instructions

### Step 1 — Load the ticket file
Read `$TICKET_DIR/<P>-<number>-<slug>.md`: which workflow, which `areas`, the
full issue description and acceptance criteria. If it doesn't exist, tell the
user to run the workflow skill first (e.g. `/bugfix <number>`).

### Step 2 — Read the architecture & domain docs
If `$ARCHITECTURE_DOC` and/or `$DOMAIN_DOC` are set, read them before touching
code — identify which subsystem / layer / stage the ticket touches so you don't
explore the wrong part of the codebase. Also skim the relevant
`*_REFERENCE_SKILL` to know the project's conventions.

### Step 3 — Explore the codebase
Use the `Explore` subagent for broad searches, Grep/Glob for targeted lookups.

- **Bugs** — find the code path producing the behavior; trace the flow end to
  end; `git log --oneline -10 -- <file>` on the suspects; find existing test
  coverage; pinpoint the failure.
- **Features** — map the code the feature extends; find similar patterns to
  follow; locate the right module for new code; check adjacent tests; identify
  data/schema changes needed.
- **Enhancements** — understand current behavior end to end; map all
  callers/consumers; check test coverage gaps; identify side effects.
- **Troubleshooting** — explore broadly; check logs if applicable; look for
  error-handling gaps, races, edge cases; check recent deploys (`git log --oneline -20`).

### Step 4 — Document findings
Collect: affected files (+ why each), code flow, existing test coverage (covered
vs missing), key observations (surprising/risky/important), related patterns.

### Step 5 — Update the ticket file
Fill in the `## Exploration` section of `$TICKET_DIR/<P>-<number>-<slug>.md`:

```markdown
## Exploration

### Affected Files
- `path/to/Foo` — what it does / why relevant

### Code Flow
Entry point → Service.doThing() → Repo.find() → store

### Existing Test Coverage
- `FooTest` — covers happy path, not edge case X
- No tests for component Y

### Key Observations
- Current impl assumes X, breaks when Y
- Similar pattern in `Bar` — follow that
```

### Step 6 — Commit
```bash
git add "$TICKET_DIR/<P>-<number>-<slug>.md"
git commit -m "chore(<P>-<number>): exploration findings"
```

## Output

Summarize the key findings; tell the user to start a fresh session and run
`/plan <number>` next.
