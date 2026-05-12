---
name: add-skill
description: Create a new agent skill following the open agent standard. Skills live in .agents/skills/ and are symlinked into .claude/skills/ for Claude Code discovery.
metadata:
  version: "2.0"
---

# Add a Skill

Create a new skill following the open agent standard layout used by this bundle.

## When to Use

- User wants to create a new slash-command / skill
- User wants to document a repeatable workflow as a skill
- User asks "how do skills work here"

## Directory Layout

```
repo-root/
  .agents/skills/<skill-name>/SKILL.md          # source of truth (open agent standard)
  .claude/skills/<skill-name> -> ../../.agents/skills/<skill-name>   # symlink (Claude Code discovery)
```

Names starting with `_` (e.g. `_project-templates/`) are NOT live skills —
`install.sh` skips them.

## Steps

### 1. Create the skill directory and SKILL.md
```bash
mkdir -p .agents/skills/<skill-name>
```
Write `.agents/skills/<skill-name>/SKILL.md`:
```markdown
---
name: <skill-name>
description: <one-line description shown in /help and autocomplete>
metadata:
  version: "1.0"
---

# <Title>

<what it does, when to use it>

## When to Use
- <trigger 1>
- <trigger 2>

## Config
<any agent-workflow.config.sh vars this skill reads — omit if none>

## Instructions
<step-by-step for the agent>

## Output
<what it produces>
```

### 2. Symlink into .claude/skills/
```bash
ln -s ../../.agents/skills/<skill-name> .claude/skills/<skill-name>
```
Or just re-run `./install.sh` from the repo root, which links every non-`_` skill.

### 3. Verify
```bash
ls -la .claude/skills/<skill-name>   # should show the symlink
```
The user can now run `/<skill-name>`.

## Conventions

- kebab-case names, 1–3 words; the name becomes the slash command.
- Project-specific *reference* skills (the equivalents of "how to write backend
  code here") should be referenced by `agent-workflow.config.sh`'s
  `*_REFERENCE_SKILL` vars so the generic step skills can find them.
- If you add a new *area* (e.g. `mobile`) you'll usually add an `implement-<area>`
  skill plus config vars and orchestrator launch blocks — see `ADAPTING.md`.
