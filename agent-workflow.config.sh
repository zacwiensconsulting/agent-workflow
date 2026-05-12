#!/usr/bin/env bash
# agent-workflow.config.sh — per-project parameters for the agent workflow bundle.
#
# Copy this file to the root of the target repo and edit the values.
# The orchestrator + step skills read this file (or the placeholders in it) to
# learn where your code lives and how to build/test it.
#
# Anything you don't have, set to "" — skills check for empty and skip.

############################################
# Directories (relative to repo root)
############################################
BACKEND_DIR="functions"          # the backend package (e.g. smc-core, functions, server)
FRONTEND_DIR="web"               # the web frontend package ("" if none)
INTEGRATION_DIR=""               # dir holding the integration test suite ("" if none; can equal BACKEND_DIR)
TICKET_DIR="docs/tickets"        # where ticket files are written (committed with the PR)
DESIGNS_DIR="docs/designs"       # where local design specs live (for /test-visual)
E2E_VIDEOS_DIR="docs/e2e-videos"
E2E_SCREENSHOTS_DIR="docs/e2e-screenshots"

############################################
# Reference docs to read before exploring/planning ("" to skip)
# Project-level architecture / domain docs — the equivalents of smc's
# docs/ARCHITECTURE.md and docs/DOMAIN.md.
############################################
ARCHITECTURE_DOC="docs/ARCHITECTURE.md"
DOMAIN_DOC="docs/DOMAIN.md"

############################################
# Role → skill-name mapping
# These are the .agents/skills/<name> directories the step skills consult for
# stack-specific conventions. Make them from _project-templates/, or point at
# reference skills you already have. "" disables that reference.
############################################
BACKEND_REFERENCE_SKILL="backend-reference"     # e.g. core, firebase-functions
FRONTEND_REFERENCE_SKILL="frontend-reference"   # e.g. ui, angular-app
TESTING_REFERENCE_SKILL="testing-reference"     # e.g. testing

############################################
# Commands (run from the relevant *_DIR). Leave "" to skip that step.
############################################
# Backend
BACKEND_INSTALL_CMD=""                          # e.g. "npm ci", "" for gradle
BACKEND_TEST_CMD="npm test"                     # e.g. "./gradlew test", "npm test", "npx vitest run"
BACKEND_TEST_ONE_CMD='npm test -- -t'           # prefix for running a single test by name (optional)
BACKEND_BUILD_CMD="npm run build"               # e.g. "./gradlew compileKotlin", "tsc"
BACKEND_TYPECHECK_CMD="npx tsc --noEmit"        # "" if covered by build
BACKEND_DEV_CMD="npm run serve"                 # how to run the backend locally / emulators

# Frontend
FRONTEND_INSTALL_CMD="npm install"
FRONTEND_TEST_CMD="npx ng test --watch=false --browsers=ChromeHeadless"
FRONTEND_BUILD_CMD="npx ng build"
FRONTEND_DEV_CMD="npm start"
FRONTEND_DEV_URL="http://localhost:4200"

# Integration
INTEGRATION_TEST_CMD=""                         # e.g. "npx vitest run", "firebase emulators:exec 'npm run test:integration'"
INTEGRATION_TEST_TRIGGERS=""                    # free text: when does this workflow need integration tests?
                                                #   e.g. "Firestore triggers, callable functions, scheduled functions"

# E2E (Playwright assumed)
E2E_TEST_CMD="npx playwright test --reporter=list"   # "" disables /test-e2e

# Type generation (e.g. OpenAPI → TS). "" disables the regen steps in plan/implement-fe/review.
TYPE_GEN_CMD=""                                 # e.g. "cd ../smc-core && ./gradlew generateOpenApiSpec && cd ../smc-ui && npm run generate:api"

############################################
# Branch prefixes per workflow
############################################
BRANCH_PREFIX_BUGFIX="fix"
BRANCH_PREFIX_FEATURE="feature"
BRANCH_PREFIX_ENHANCEMENT="enhance"
BRANCH_PREFIX_TROUBLESHOOT="investigate"

############################################
# Ticket id scheme
############################################
TICKET_PREFIX="GH"               # "GH" for GitHub issues; change if you track tickets elsewhere
ISSUE_FETCH_CMD='gh issue view'  # how to fetch a ticket; skills append the number + --json flags

############################################
# Devcontainer (only used by dev.sh)
############################################
DEVCONTAINER_IMAGE_NAME="agentwf-dev"
FIREWALL_EXTRA_DOMAINS=""        # space-separated extra allowlist domains for init-firewall.sh
                                 #   e.g. "firebase.googleapis.com firestore.googleapis.com www.gstatic.com"
