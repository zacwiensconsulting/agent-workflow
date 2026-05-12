# Agent Workflow Bundle

A reusable, project-agnostic version of the multi-agent dev workflow:
orchestrator skills (`/bugfix`, `/feature`, `/enhancement`, `/troubleshoot`) that
fetch a GitHub issue, create an isolated git worktree, and drive a chain of
sub-agents (explore → plan → implement → test → review) that each get a fresh
context window.

See [`docs/agent-workflow.md`](docs/agent-workflow.md) for the full design and
[`docs/agent-workflow.puml`](docs/agent-workflow.puml) for the diagram.

## What's in here

```
agent-workflow.config.sh        # ← per-project parameters (the ONE file you must edit)
install.sh                      # symlinks .agents/skills/* into .claude/skills/*
dev.sh                          # optional: parameterized devcontainer launcher
docs/
  agent-workflow.md             # design doc (project-agnostic)
  agent-workflow.puml           # diagram
.agents/skills/
  bugfix/ feature/ enhancement/ troubleshoot/   # orchestrators (generic)
  explore/ plan/ review/                        # generic pipeline steps
  implement-be/ implement-fe/                   # TDD steps (workflow generic, stack detail
                                                #   delegated to a project reference skill)
  test-integration/ test-e2e/ test-visual/      # test steps (test-visual is opt-in)
  add-skill/                                    # meta: how to add a skill
  _project-templates/                           # copy these, rename, fill in per project:
    backend-reference/  frontend-reference/  testing-reference/
```

## How to reuse in another project

1. Copy what you want into the target repo:
   ```bash
   cp -r agent-workflow-bundle/.agents              <target>/.agents
   cp    agent-workflow-bundle/agent-workflow.config.sh  <target>/
   cp    agent-workflow-bundle/install.sh           <target>/
   cp -r agent-workflow-bundle/docs/agent-workflow.* <target>/docs/
   # optional, only if you want the sandboxed container runner:
   cp    agent-workflow-bundle/dev.sh               <target>/
   ```
2. Edit `agent-workflow.config.sh` — set your dir names, build/test commands, and the
   role → skill name mapping (see [`ADAPTING.md`](ADAPTING.md)).
3. Turn the `_project-templates/*` skills into real reference skills for your stack
   (e.g. `backend-reference` → `firebase-functions`, `frontend-reference` → `angular-app`),
   or point the config at reference skills you already have.
4. Delete any skills you don't use (`test-visual` if you have no design specs,
   `test-integration` if you have no integration suite, etc.).
5. Run `./install.sh` to create the `.claude/skills/*` symlinks.
6. In Claude Code: `/bugfix 123`.

## Why `.agents/` *and* `.claude/`?

Claude Code only discovers skills under `.claude/skills/` (plus `~/.claude/skills/`
and installed plugins). It does **not** scan `.agents/`. This bundle keeps the
source-of-truth skills in `.agents/skills/` (the "open agent standard" layout, so
they're not Claude-Code-specific) and `install.sh` creates `.claude/skills/<name>`
symlinks pointing back at them. Commit both the `.agents/` tree and the symlinks.
