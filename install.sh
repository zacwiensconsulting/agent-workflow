#!/usr/bin/env bash
# install.sh — wire the bundle's skills into Claude Code.
#
# Creates a symlink .claude/skills/<name> -> ../../.agents/skills/<name> for every
# skill directory under .agents/skills/ (skipping names that start with "_", which are
# templates / internal groupings, not live skills).
#
# Run from the repo root after copying the bundle in.
set -euo pipefail

cd "$(dirname "$0")"

if [ ! -d .agents/skills ]; then
  echo "error: .agents/skills not found — run this from the repo root after copying the bundle." >&2
  exit 1
fi

mkdir -p .claude/skills

count=0
for dir in .agents/skills/*/; do
  name="$(basename "$dir")"
  case "$name" in
    _*) continue ;;  # _project-templates etc.
  esac
  link=".claude/skills/$name"
  if [ -L "$link" ]; then rm "$link"; fi
  if [ -e "$link" ]; then
    echo "warn: $link exists and is not a symlink — skipping" >&2
    continue
  fi
  ln -s "../../.agents/skills/$name" "$link"
  echo "linked /$name"
  count=$((count + 1))
done

echo
echo "Linked $count skill(s) into .claude/skills/."
if [ ! -f agent-workflow.config.sh ]; then
  echo "next: copy agent-workflow.config.sh to the repo root and edit it."
else
  echo "next: edit agent-workflow.config.sh, then turn _project-templates/* into real reference skills."
fi
