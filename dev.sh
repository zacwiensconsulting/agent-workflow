#!/usr/bin/env bash
# dev.sh — optional sandboxed devcontainer runner for the agent workflow.
#
# This is the piece that lets orchestrators launch sub-agents with
# `bypassPermissions` (no permission prompts) safely, behind a firewall.
#
# It expects a `.devcontainer/` directory in the repo with:
#   - Dockerfile          (your base image: node, your toolchain, sudo, etc.)
#   - init-firewall.sh     (run as root at container start; allowlist outbound)
# Those are intentionally NOT shipped in this bundle — they're too stack-specific.
# Bring your own (the smc repo's are a reasonable starting point) and add any
# extra hosts your build needs via FIREWALL_EXTRA_DOMAINS in the config.
#
# Reads agent-workflow.config.sh for: DEVCONTAINER_IMAGE_NAME, BACKEND_DIR,
# FRONTEND_DIR, FRONTEND_INSTALL_CMD, FIREWALL_EXTRA_DOMAINS.
set -euo pipefail
cd "$(dirname "$0")"

[ -f agent-workflow.config.sh ] && source agent-workflow.config.sh
IMAGE_NAME="${DEVCONTAINER_IMAGE_NAME:-agentwf-dev}"
PROJECT_KEY="$(basename "$(pwd)")"

VOL_HISTORY="${PROJECT_KEY}-bashhistory"
VOL_CLAUDE="${PROJECT_KEY}-claude-config"
VOL_CACHE="${PROJECT_KEY}-pkg-cache"   # npm cache; add more (gradle, etc.) as needed

usage() {
  cat <<EOF
Usage: ./dev.sh [command]
  shell    Drop into a shell in a new container (default)
  claude   Start Claude Code with --dangerously-skip-permissions in a new container
  ps       List running ${IMAGE_NAME} containers
  attach   Exec a new shell into the most recent running container ([name] to target one)
  build    Build/rebuild the image from .devcontainer/
  clean    Remove persistent volumes for this project
EOF
}

devcontainer_hash() { cat .devcontainer/Dockerfile .devcontainer/init-firewall.sh | shasum -a 256 | cut -c1-12; }
build_image() {
  [ -d .devcontainer ] || { echo "error: no .devcontainer/ — see the comment at the top of dev.sh" >&2; exit 1; }
  local h; h=$(devcontainer_hash)
  echo "Building $IMAGE_NAME ($h)..."
  docker build -t "$IMAGE_NAME:$h" -t "$IMAGE_NAME:latest" .devcontainer/
}
ensure_image() {
  [ -d .devcontainer ] || { echo "error: no .devcontainer/ — see the comment at the top of dev.sh" >&2; exit 1; }
  local h; h=$(devcontainer_hash)
  docker image inspect "$IMAGE_NAME:$h" >/dev/null 2>&1 || { echo "Devcontainer changed — rebuilding..."; build_image; }
}
ensure_volumes() { for v in "$VOL_HISTORY" "$VOL_CLAUDE" "$VOL_CACHE"; do docker volume inspect "$v" >/dev/null 2>&1 || docker volume create "$v" >/dev/null; done; }

run_container() {
  local cmd="$1"
  local extra_domains_env=""
  [ -n "${FIREWALL_EXTRA_DOMAINS:-}" ] && extra_domains_env="-e FIREWALL_EXTRA_DOMAINS=${FIREWALL_EXTRA_DOMAINS}"
  local install_step="true"
  [ -n "${FRONTEND_DIR:-}" ] && [ -n "${FRONTEND_INSTALL_CMD:-}" ] && install_step="cd /workspace/${FRONTEND_DIR} && ${FRONTEND_INSTALL_CMD} >/dev/null 2>&1 || true; cd /workspace"

  docker run -it --rm \
    --name "${IMAGE_NAME}-$(date +%s)-$$" \
    --label "${IMAGE_NAME}=1" \
    --cap-add=NET_ADMIN --cap-add=NET_RAW --cap-add=SYS_ADMIN \
    --security-opt=seccomp=unconfined \
    -v "$(pwd):/workspace" \
    -v "${VOL_HISTORY}:/commandhistory" \
    -v "${VOL_CLAUDE}:/home/node/.claude" \
    -v "${VOL_CACHE}:/home/node/.npm" \
    -e TERM="${TERM:-xterm-256color}" -e COLORTERM="${COLORTERM:-truecolor}" \
    -e CLAUDE_CODE_OAUTH_TOKEN="${CLAUDE_CODE_OAUTH_TOKEN:-}" \
    -e GH_TOKEN="${GH_TOKEN:-}" \
    -e CLAUDE_CONFIG_DIR=/home/node/.claude \
    -e NODE_OPTIONS="--max-old-space-size=4096" \
    $extra_domains_env \
    -w /workspace \
    "$IMAGE_NAME" \
    bash -c "
      sudo /usr/local/bin/init-firewall.sh || sudo /workspace/.devcontainer/init-firewall.sh || true
      [ -f /home/node/.claude/.claude.json ] || echo '{\"hasCompletedOnboarding\":true}' > /home/node/.claude/.claude.json
      $install_step
      $cmd
    "
}

latest_container() { docker ps --filter "label=${IMAGE_NAME}=1" --format '{{.Names}}' | head -n1; }

case "${1:-shell}" in
  shell)  ensure_image; ensure_volumes; run_container "exec \${SHELL:-bash}" ;;
  claude) ensure_image; ensure_volumes; run_container "claude --dangerously-skip-permissions" ;;
  ps)     docker ps --filter "label=${IMAGE_NAME}=1" ;;
  attach)
    t="${2:-$(latest_container)}"
    [ -z "$t" ] && { echo "No running ${IMAGE_NAME} containers."; exit 1; }
    docker exec -it "$t" "${SHELL:-bash}" ;;
  build)  build_image ;;
  clean)
    read -r -p "Delete volumes $VOL_HISTORY $VOL_CLAUDE $VOL_CACHE? [y/N] " a
    [ "$a" = y ] || [ "$a" = Y ] && docker volume rm "$VOL_HISTORY" "$VOL_CLAUDE" "$VOL_CACHE" 2>/dev/null || echo "Aborted." ;;
  -h|--help|help) usage ;;
  *) echo "Unknown command: $1"; usage; exit 1 ;;
esac
