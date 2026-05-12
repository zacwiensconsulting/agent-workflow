---
name: test-visual
description: Visual review step — compare e2e screenshots against design specs using multimodal analysis. Opt-in; only runs if specs exist.
metadata:
  version: "2.0"
---

# Visual Review

Compare Playwright screenshots against design specs to verify the UI matches the
intended design. Uses Claude's multimodal capabilities.

## When to Use

- After e2e tests have run (screenshots captured)
- Design specs exist for the feature (issue attachments or `$DESIGNS_DIR`)
- User runs `/test-visual <issue-number>`

If no specs exist in either location, skip and note in the ticket that visual
review was skipped (no specs available).

## Config

Read `agent-workflow.config.sh` for: `FRONTEND_DIR`, `DESIGNS_DIR`,
`E2E_SCREENSHOTS_DIR`, `FRONTEND_REFERENCE_SKILL`, `ISSUE_FETCH_CMD`,
`TICKET_DIR`, `TICKET_PREFIX`. `<P>` = `$TICKET_PREFIX`.

## Instructions

### Step 1 — Load the ticket file
What was implemented, which components changed, which e2e tests ran.

### Step 2 — Find design specs
- **Issue attachments** — `$ISSUE_FETCH_CMD <number> --json body -q '.body'`,
  extract image URLs (`github.com/...`, `user-images.githubusercontent.com/...`),
  download to a temp dir.
- **`$DESIGNS_DIR`** — look for `<P>-<number>-*.png`, `<feature>-*.png`,
  `components/<name>.png`.
- Use both; issue attachments take precedence (ticket-specific).

### Step 3 — Collect screenshots
Find `*.png` under `$FRONTEND_DIR/test-results/`; copy the relevant ones into
`$E2E_SCREENSHOTS_DIR`, named by test.

### Step 4 — Compare
For each spec, find the matching screenshot; Read both images; compare: layout
structure, spacing (margins/padding), typography (sizes/weights/colors), colors
vs the design system, component styling, states (hover/focus/disabled),
responsiveness at the tested viewport. Use `$FRONTEND_REFERENCE_SKILL` for the
project's design-system expectations.

### Step 5 — Document findings
Fill in `## Visual Review` in the ticket file: specs compared, what matches,
discrepancies (as a checklist), recommendations, links to screenshots.

### Step 6 — Commit
`git add $E2E_SCREENSHOTS_DIR/*.png && git commit -m "test(<P>-<number>): add e2e screenshots for visual review"`;
commit the ticket update.

### Step 7 — Report
If discrepancies need fixing: list them, ask whether to fix before `/review`; if
yes, return to `/implement-fe`. If clean (or only minor 1–2px diffs): note that
visual review passed; proceed to `/review <number>`.

## Output

Specs compared, pass/fail, discrepancies needing attention, next step.

## Notes

- Optional — only runs when specs exist; minor sub-pixel diffs are acceptable.
- Focus on user-visible issues, not pixel-perfect matching.
- Screenshots are committed to the PR for reviewer reference.
