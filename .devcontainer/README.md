# Devcontainer

A **minimal, generic** sandbox so the orchestrators can launch sub-agents with
`--dangerously-skip-permissions` safely (egress is firewalled). Run it via
[`../dev.sh`](../dev.sh), not the VS Code "reopen in container" flow — `dev.sh`
manages volumes, the firewall, and per-project image hashing.

## Files

- `Dockerfile` — `node:22-bookworm` + `node` user w/ passwordless sudo (for the
  firewall script only) + git/gh/ripgrep/jq/iptables/ipset/zsh + Claude Code +
  persisted bash history. **You extend this** with your toolchain (see the
  marked block near the bottom).
- `init-firewall.sh` — default-deny egress, allowlists DNS, localhost, the
  container subnet, GitHub (via `api.github.com/meta` CIDRs), npm, Anthropic, and
  anything in `$FIREWALL_EXTRA_DOMAINS` (passed in by `dev.sh` from
  `agent-workflow.config.sh`). Self-checks at the end.

## What to change per project

1. **`agent-workflow.config.sh` → `FIREWALL_EXTRA_DOMAINS`** — every host your
   build/test/deploy tooling hits. If a build fails behind the firewall, the
   missing host is almost always the cause; add it here and rebuild. Examples:
   - Firebase: `firebase.googleapis.com firestore.googleapis.com identitytoolkit.googleapis.com www.gstatic.com storage.googleapis.com`
   - Maven/Gradle: `repo.maven.apache.org plugins.gradle.org services.gradle.org`
   - PyPI: `pypi.org files.pythonhosted.org`
   - Playwright browser downloads: `playwright.azureedge.net` (or pre-install in the Dockerfile instead)
2. **`Dockerfile` → the "ADD YOUR PROJECT TOOLCHAIN" block** — install your
   language runtime, CLIs (e.g. `firebase-tools`), browsers (`playwright install
   --with-deps chromium`), DB clients, and set any needed `ENV` (`JAVA_HOME`, …).
3. **`agent-workflow.config.sh` → `DEVCONTAINER_IMAGE_NAME`** — name the image
   per project so multiple projects don't share one.
4. **Volumes** — `dev.sh` mounts a Claude-config volume, a history volume, and
   one package-cache volume (`~/.npm`). If your toolchain has its own big cache
   (`~/.gradle`, `~/.m2`, `~/.cache/pip`, …), add a `-v` line for it in
   `dev.sh`'s `run_container`.
5. **Capabilities** — `dev.sh` already passes `NET_ADMIN`/`NET_RAW` (firewall)
   and `SYS_ADMIN` + `seccomp=unconfined` (needed for headless Chromium). Drop
   the Chromium-related ones if you have no browser tests.

## Without a devcontainer

Everything still works — the orchestrators detect they're not in a
bypass-permissions sandbox and emit a manual runbook (`/explore`, `/plan`,
`/implement-*`, `/review` run by hand in fresh sessions) instead of launching
agents. The devcontainer is purely a convenience/safety layer.
