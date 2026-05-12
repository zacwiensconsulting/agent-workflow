# Generic devcontainer base for the agent workflow.
#
# This is intentionally minimal — it gives you:
#   - a `node` user with passwordless sudo
#   - git, gh, ripgrep, jq, iptables/ipset (for the firewall), zsh
#   - Claude Code installed globally
#   - persisted bash history at /commandhistory
#
# EXTEND IT for your stack: add your language toolchain (JDK, Python, Go, the
# Firebase CLI, Playwright browsers, a Postgres client, …) below the marked line.
# Rebuild with `./dev.sh build` (the image is keyed on the hash of this file +
# init-firewall.sh, so changes are picked up automatically).

FROM node:22-bookworm

ARG USERNAME=node

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl wget gnupg2 \
      git sudo less procps \
      ripgrep jq fzf \
      iptables ipset iproute2 dnsutils \
      zsh \
  && rm -rf /var/lib/apt/lists/*

# gh CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list \
  && apt-get update && apt-get install -y --no-install-recommends gh \
  && rm -rf /var/lib/apt/lists/*

# Passwordless sudo for the firewall script
RUN echo "$USERNAME ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh, /workspace/.devcontainer/init-firewall.sh" \
      > /etc/sudoers.d/$USERNAME-firewall \
  && chmod 0440 /etc/sudoers.d/$USERNAME-firewall

# Persisted shell history
RUN mkdir -p /commandhistory && chown $USERNAME:$USERNAME /commandhistory \
  && echo 'export HISTFILE=/commandhistory/.bash_history' >> /home/$USERNAME/.bashrc

COPY init-firewall.sh /usr/local/bin/init-firewall.sh
RUN chmod +x /usr/local/bin/init-firewall.sh

# Claude Code
RUN npm install -g @anthropic-ai/claude-code

# ──────────────────────────────────────────────────────────────────────────────
# ADD YOUR PROJECT TOOLCHAIN BELOW (examples — uncomment / edit as needed):
#
# # Java (smc-style):
# RUN apt-get update && apt-get install -y --no-install-recommends temurin-17-jdk \
#   && ln -s /usr/lib/jvm/temurin-17-jdk-* /usr/lib/jvm/temurin-17-jdk
# ENV JAVA_HOME=/usr/lib/jvm/temurin-17-jdk
#
# # Firebase CLI:
# RUN npm install -g firebase-tools
#
# # Playwright browsers (frontend e2e):
# RUN npx -y playwright install --with-deps chromium
#
# # Postgres client:
# RUN apt-get update && apt-get install -y --no-install-recommends postgresql-client
# ──────────────────────────────────────────────────────────────────────────────

USER $USERNAME
WORKDIR /workspace
